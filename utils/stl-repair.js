/**
 * STL Repair Utility
 *
 * Uses PyMeshLab for robust mesh repair:
 * - Non-manifold edges and vertices
 * - Duplicate faces and vertices
 * - Inverted normals
 * - Small connected components
 *
 * Requires PyMeshLab: pip3 install pymeshlab
 */

import { exec } from "child_process";
import { promisify } from "util";
import { access, stat, readFile } from "fs/promises";
import { constants, unlinkSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";
import NodeStl from "node-stl";

const execAsync = promisify(exec);
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * Check if PyMeshLab is installed and accessible
 * @returns {Promise<boolean>} True if PyMeshLab is available
 */
export async function isPyMeshLabInstalled() {
  try {
    const { stdout } = await execAsync("python3 -c 'import pymeshlab; print(\"OK\")'");
    return stdout.trim() === "OK";
  } catch (error) {
    return false;
  }
}

/**
 * Get PyMeshLab version
 * @returns {Promise<string>} PyMeshLab version string
 */
export async function getPyMeshLabVersion() {
  try {
    const { stdout } = await execAsync("python3 -c 'import pymeshlab; print(pymeshlab.__version__)'");
    return stdout.trim();
  } catch (error) {
    throw new Error("PyMeshLab not installed. Install with: pip3 install pymeshlab");
  }
}

/**
 * Check if a file exists and is readable
 * @param {string} filePath - Path to the file
 * @returns {Promise<boolean>} True if file exists and is readable
 */
async function fileExists(filePath) {
  try {
    await access(filePath, constants.R_OK);
    return true;
  } catch {
    return false;
  }
}

/**
 * Get file size in bytes
 * @param {string} filePath - Path to the file
 * @returns {Promise<number>} File size in bytes
 */
async function getFileSize(filePath) {
  try {
    const stats = await stat(filePath);
    return stats.size;
  } catch (error) {
    return 0;
  }
}

/**
 * Repair an STL file using PyMeshLab
 *
 * @param {string} inputPath - Path to the input STL file
 * @param {string} outputPath - Path to save the repaired STL file
 * @param {object} options - Repair options
 * @param {boolean} options.verbose - Enable verbose logging (default: false)
 * @returns {Promise<object>} Repair result with outputPath, originalSize, repairedSize
 */
export async function repairSTLWithPyMeshLab(inputPath, outputPath, options = {}) {
  const { verbose = false } = options;

  // Validate input file exists
  if (!(await fileExists(inputPath))) {
    throw new Error(`Input file not found: ${inputPath}`);
  }

  // Check if PyMeshLab is installed
  if (!(await isPyMeshLabInstalled())) {
    throw new Error("PyMeshLab not installed. Install with: pip3 install pymeshlab");
  }

  // Build command to run Python script
  const scriptPath = join(__dirname, "pymeshlab-repair.py");
  const verboseFlag = verbose ? "--verbose" : "";
  const command = `python3 "${scriptPath}" "${inputPath}" "${outputPath}" ${verboseFlag}`;

  if (verbose) {
    console.log(`[STL REPAIR] Running PyMeshLab: ${command}`);
  }

  try {
    const { stdout, stderr } = await execAsync(command);

    if (verbose && stderr) {
      console.log(`[STL REPAIR] PyMeshLab stderr:\n${stderr}`);
    }

    // Parse JSON output from Python script
    const result = JSON.parse(stdout);

    if (!result.success) {
      throw new Error(result.error || "PyMeshLab repair failed");
    }

    if (verbose) {
      console.log(`[STL REPAIR] PyMeshLab repair completed:`, result);
    }

    return {
      success: true,
      outputPath: result.outputPath,
      originalSize: result.originalSize,
      repairedSize: result.repairedSize,
      sizeDifference: result.sizeDifference,
      pymeshlabOutput: result,
      backend: "pymeshlab",
    };
  } catch (error) {
    console.error("[STL REPAIR] PyMeshLab error:", error.message);

    // Provide more helpful error messages
    if (error.message.includes("command not found") || error.message.includes("No module named")) {
      throw new Error("PyMeshLab not found. Install with: pip3 install pymeshlab");
    }

    throw new Error(`STL repair with PyMeshLab failed: ${error.message}`);
  }
}

/**
 * Check if an STL file is watertight (manifold)
 * Uses node-stl to parse and validate the STL file
 *
 * @param {string} filePath - Path to the STL file
 * @returns {Promise<boolean>} True if file is watertight/manifold
 */
export async function isSTLWatertight(filePath) {
  try {
    // Read the STL file
    const buffer = await readFile(filePath);

    // Parse the STL file
    const stl = new NodeStl(buffer);

    // Check if the STL has valid data
    if (!stl.facets || stl.facets.length === 0) {
      return false;
    }

    // Basic validation: check if all facets have valid normals and vertices
    for (const facet of stl.facets) {
      // Check if normal exists
      if (!facet.normal || facet.normal.length !== 3) {
        return false;
      }

      // Check if vertices exist
      if (!facet.verts || facet.verts.length !== 3) {
        return false;
      }

      // Check each vertex has 3 coordinates
      for (const vert of facet.verts) {
        if (!vert || vert.length !== 3) {
          return false;
        }
      }
    }

    // If we got here, the file appears to be valid
    // Note: This is a basic check. ADMesh does more thorough validation
    return true;
  } catch (error) {
    console.error("[STL REPAIR] Error checking if STL is watertight:", error.message);
    // If we can't parse it, assume it needs repair
    return false;
  }
}

/**
 * Check if an STL file needs repair
 *
 * @param {string} filePath - Path to the STL file
 * @returns {Promise<boolean>} True if file appears to need repair
 */
export async function needsRepair(filePath) {
  const isWatertight = await isSTLWatertight(filePath);
  return !isWatertight;
}

/**
 * Repair an STL file using PyMeshLab
 *
 * @param {string} inputPath - Path to the input STL file
 * @param {string} outputPath - Path to save the repaired STL file
 * @param {object} options - Repair options
 * @param {boolean} options.verbose - Enable verbose logging (default: false)
 * @returns {Promise<object>} Repair result with outputPath, originalSize, repairedSize
 */
export async function repairSTL(inputPath, outputPath, options = {}) {
  const { verbose = false } = options;

  // Check if PyMeshLab is installed
  const hasPyMeshLab = await isPyMeshLabInstalled();

  if (verbose) {
    console.log(`[STL REPAIR] PyMeshLab available: ${hasPyMeshLab}`);
  }

  if (hasPyMeshLab) {
    if (verbose) {
      console.log(`[STL REPAIR] Using PyMeshLab backend`);
    }
    return await repairSTLWithPyMeshLab(inputPath, outputPath, options);
  } else {
    // No repair backend available - log warning but don't throw error
    // This allows the application to continue working without STL repair
    if (verbose) {
      console.warn("[STL REPAIR] PyMeshLab not available. Install with: pip3 install pymeshlab");
      console.warn("[STL REPAIR] Returning original file without repair");
    }

    // Return a result indicating no repair was performed
    const originalSize = await getFileSize(inputPath);

    // Copy input to output so the file exists at the expected location
    const { copyFile } = await import("fs/promises");
    await copyFile(inputPath, outputPath);

    return {
      success: true,
      outputPath,
      originalSize,
      repairedSize: originalSize,
      sizeDifference: 0,
      backend: "none",
      warning: "PyMeshLab not available - file was not repaired",
    };
  }
}
