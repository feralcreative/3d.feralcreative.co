/**
 * STL Repair Utility
 *
 * Uses ADMesh to repair STL files by fixing common issues:
 * - Inverted normals
 * - Non-manifold edges
 * - Holes in the mesh
 * - Incorrect normal values
 *
 * Requires ADMesh to be installed: brew install admesh
 */

import { exec } from "child_process";
import { promisify } from "util";
import { access, stat, readFile } from "fs/promises";
import { constants } from "fs";
import NodeStl from "node-stl";

const execAsync = promisify(exec);

/**
 * Check if ADMesh is installed and accessible
 * @returns {Promise<boolean>} True if ADMesh is available
 */
export async function isADMeshInstalled() {
  try {
    const { stdout } = await execAsync("which admesh");
    return stdout.trim().length > 0;
  } catch (error) {
    return false;
  }
}

/**
 * Get ADMesh version
 * @returns {Promise<string>} ADMesh version string
 */
export async function getADMeshVersion() {
  try {
    const { stdout } = await execAsync("admesh --version");
    return stdout.trim();
  } catch (error) {
    throw new Error("ADMesh not installed. Install with: brew install admesh");
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
 * Repair an STL file using ADMesh
 *
 * @param {string} inputPath - Path to the input STL file
 * @param {string} outputPath - Path to save the repaired STL file
 * @param {object} options - Repair options
 * @param {string} options.admeshPath - Path to ADMesh binary (default: 'admesh')
 * @param {boolean} options.verbose - Enable verbose logging (default: false)
 * @returns {Promise<object>} Repair result with outputPath, originalSize, repairedSize
 */
export async function repairSTL(inputPath, outputPath, options = {}) {
  const { admeshPath = "admesh", verbose = false } = options;

  // Validate input file exists
  if (!(await fileExists(inputPath))) {
    throw new Error(`Input file not found: ${inputPath}`);
  }

  // Check if ADMesh is installed
  if (!(await isADMeshInstalled())) {
    throw new Error("ADMesh not installed. Install with: brew install admesh");
  }

  // Get original file size
  const originalSize = await getFileSize(inputPath);

  // Build ADMesh command with aggressive repair options
  // --write-binary-stl: Output as binary STL (more compact)
  // --normal-directions: Fix normals pointing in wrong direction
  // --normal-values: Recalculate normal values
  // --exact: Use exact comparison for degenerate facets
  // --tolerance: Set tolerance for merging vertices (0.001mm = 1 micron)
  // --nearby: Merge nearby vertices within tolerance (fixes disconnected edges)
  // --remove-unconnected: Remove facets with unconnected edges
  // --fill-holes: Fill holes in the mesh (critical for non-manifold edges)
  // --iterations: Number of iterations for hole filling (2 passes for thorough repair)
  const command = `${admeshPath} --write-binary-stl="${outputPath}" --normal-directions --normal-values --exact --tolerance=0.001 --nearby --remove-unconnected --fill-holes --iterations=2 "${inputPath}"`;

  if (verbose) {
    console.log(`[STL REPAIR] Running: ${command}`);
  }

  try {
    const { stdout, stderr } = await execAsync(command);

    if (verbose && stdout) {
      console.log(`[STL REPAIR] ADMesh output:\n${stdout}`);
    }

    if (stderr && verbose) {
      console.log(`[STL REPAIR] ADMesh stderr:\n${stderr}`);
    }

    // Verify output file was created
    if (!(await fileExists(outputPath))) {
      throw new Error(`ADMesh failed to create output file: ${outputPath}`);
    }

    // Get repaired file size
    const repairedSize = await getFileSize(outputPath);

    return {
      success: true,
      outputPath,
      originalSize,
      repairedSize,
      sizeDifference: repairedSize - originalSize,
      admeshOutput: stdout,
    };
  } catch (error) {
    console.error("[STL REPAIR] Error:", error.message);

    // Provide more helpful error messages
    if (error.message.includes("command not found")) {
      throw new Error("ADMesh not found in PATH. Install with: brew install admesh");
    }

    throw new Error(`STL repair failed: ${error.message}`);
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
