/**
 * STL Repair Utility
 *
 * Uses PyMeshLab (Python) to repair STL files by fixing common issues:
 * - Inverted normals
 * - Non-manifold edges and vertices
 * - Holes in the mesh
 * - Duplicate faces and vertices
 * - Incorrect normal values
 *
 * Requires PyMeshLab to be installed: pip3 install pymeshlab
 */

import { exec } from "child_process";
import { promisify } from "util";
import { access, stat } from "fs/promises";
import { constants } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const execAsync = promisify(exec);
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * Check if PyMeshLab is installed and accessible
 * @returns {Promise<boolean>} True if PyMeshLab is available
 */
export async function isPyMeshLabInstalled() {
  try {
    const { stdout } = await execAsync("python3 -c 'import pymeshlab; print(pymeshlab.__version__)'");
    return stdout.trim().length > 0;
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
export async function repairSTL(inputPath, outputPath, options = {}) {
  const { verbose = false } = options;

  // Validate input file exists
  if (!(await fileExists(inputPath))) {
    throw new Error(`Input file not found: ${inputPath}`);
  }

  // Check if PyMeshLab is installed
  if (!(await isPyMeshLabInstalled())) {
    throw new Error("PyMeshLab not installed. Install with: pip3 install pymeshlab");
  }

  // Get original file size
  const originalSize = await getFileSize(inputPath);

  // Path to the Python repair script
  const pythonScript = join(__dirname, "stl-repair-pymeshlab.py");

  // Build the command
  const verboseFlag = verbose ? "--verbose" : "";
  const command = `python3 "${pythonScript}" "${inputPath}" "${outputPath}" ${verboseFlag}`.trim();

  if (verbose) {
    console.log(`[STL REPAIR] Running PyMeshLab repair: ${command}`);
  }

  try {
    const { stdout, stderr } = await execAsync(command);

    if (stderr && verbose) {
      console.log(`[STL REPAIR] PyMeshLab stderr:\n${stderr}`);
    }

    // Parse the JSON output from the Python script
    let result;
    try {
      result = JSON.parse(stdout);
    } catch (parseError) {
      throw new Error(`Failed to parse PyMeshLab output: ${parseError.message}\nOutput: ${stdout}`);
    }

    if (!result.success) {
      throw new Error(result.error || "PyMeshLab repair failed");
    }

    // Verify output file was created
    if (!(await fileExists(outputPath))) {
      throw new Error(`PyMeshLab failed to create output file: ${outputPath}`);
    }

    if (verbose) {
      console.log(`[STL REPAIR] Repair complete:`);
      console.log(`  - Initial: ${result.initialStats.vertices} vertices, ${result.initialStats.faces} faces`);
      console.log(`  - Final: ${result.finalStats.vertices} vertices, ${result.finalStats.faces} faces`);
      console.log(`  - Vertices changed: ${result.verticesChanged}`);
      console.log(`  - Faces changed: ${result.facesChanged}`);
      console.log(`  - Repair steps: ${result.repairSteps.join(", ")}`);
    }

    return {
      success: true,
      outputPath: result.outputPath,
      originalSize: result.originalSize,
      repairedSize: result.repairedSize,
      sizeDifference: result.sizeDifference,
      initialStats: result.initialStats,
      finalStats: result.finalStats,
      verticesChanged: result.verticesChanged,
      facesChanged: result.facesChanged,
      repairSteps: result.repairSteps,
    };
  } catch (error) {
    console.error("[STL REPAIR] Error:", error.message);

    // Provide more helpful error messages
    if (error.message.includes("pymeshlab")) {
      throw new Error("PyMeshLab not installed. Install with: pip3 install pymeshlab");
    }

    throw new Error(`STL repair failed: ${error.message}`);
  }
}
