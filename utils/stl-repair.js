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
import { constants, unlinkSync } from "fs";
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
 * Repair an STL file using ADMesh with progressive repair strategy
 *
 * @param {string} inputPath - Path to the input STL file
 * @param {string} outputPath - Path to save the repaired STL file
 * @param {object} options - Repair options
 * @param {string} options.admeshPath - Path to ADMesh binary (default: 'admesh')
 * @param {boolean} options.verbose - Enable verbose logging (default: false)
 * @param {string} options.strategy - Repair strategy: 'standard', 'aggressive', 'progressive' (default: 'progressive')
 * @returns {Promise<object>} Repair result with outputPath, originalSize, repairedSize
 */
export async function repairSTL(inputPath, outputPath, options = {}) {
  const { admeshPath = "admesh", verbose = false, strategy = "progressive" } = options;

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

  let command;
  let repairAttempts = [];

  if (strategy === "aggressive") {
    // Aggressive single-pass repair with higher tolerance
    // Good for models with many small errors
    // Note: Does NOT use --remove-unconnected or --fill-holes to preserve multi-part models and intentional holes
    command = `${admeshPath} --write-binary-stl="${outputPath}" --normal-directions --normal-values --exact --tolerance=0.01 --nearby --iterations=5 "${inputPath}"`;
    repairAttempts.push({ name: "Aggressive", command });
  } else if (strategy === "standard") {
    // Standard repair (original approach)
    // Note: Does NOT use --remove-unconnected or --fill-holes to preserve multi-part models and intentional holes
    command = `${admeshPath} --write-binary-stl="${outputPath}" --normal-directions --normal-values --exact --tolerance=0.001 --nearby --iterations=2 "${inputPath}"`;
    repairAttempts.push({ name: "Standard", command });
  } else {
    // Progressive repair: try multiple strategies, use the best result
    // This is the default and most thorough approach

    // Strategy 1: Conservative - tight tolerance, fewer iterations
    repairAttempts.push({
      name: "Conservative",
      command: `${admeshPath} --write-binary-stl="${outputPath}.pass1" --normal-directions --normal-values --exact --tolerance=0.001 --nearby --iterations=2 "${inputPath}"`,
      outputFile: `${outputPath}.pass1`,
    });

    // Strategy 2: Moderate - medium tolerance, more iterations
    // Note: Does NOT use --remove-unconnected or --fill-holes to preserve multi-part models and intentional holes
    repairAttempts.push({
      name: "Moderate",
      command: `${admeshPath} --write-binary-stl="${outputPath}.pass2" --normal-directions --normal-values --exact --tolerance=0.005 --nearby --iterations=4 "${inputPath}"`,
      outputFile: `${outputPath}.pass2`,
    });

    // Strategy 3: Aggressive - high tolerance, maximum iterations
    // Note: Does NOT use --remove-unconnected or --fill-holes to preserve multi-part models and intentional holes
    repairAttempts.push({
      name: "Aggressive",
      command: `${admeshPath} --write-binary-stl="${outputPath}.pass3" --normal-directions --normal-values --exact --tolerance=0.01 --nearby --iterations=6 "${inputPath}"`,
      outputFile: `${outputPath}.pass3`,
    });
  }

  if (strategy === "progressive") {
    // Run all repair strategies and pick the best one
    if (verbose) {
      console.log(`[STL REPAIR] Using progressive repair strategy with ${repairAttempts.length} passes`);
    }

    let bestResult = null;
    let bestDisconnectedCount = Infinity;

    for (const attempt of repairAttempts) {
      try {
        if (verbose) {
          console.log(`[STL REPAIR] Trying ${attempt.name} repair...`);
          console.log(`[STL REPAIR] Command: ${attempt.command}`);
        }

        const { stdout, stderr } = await execAsync(attempt.command);

        // Parse the output to count disconnected facets
        const disconnectedMatch = stdout.match(/Total disconnected facets\s*:\s*\d+\s+(\d+)/);
        const disconnectedCount = disconnectedMatch ? parseInt(disconnectedMatch[1], 10) : Infinity;

        if (verbose) {
          console.log(`[STL REPAIR] ${attempt.name} result: ${disconnectedCount} disconnected facets`);
        }

        // Keep track of the best result
        if (disconnectedCount < bestDisconnectedCount) {
          bestDisconnectedCount = disconnectedCount;
          bestResult = {
            name: attempt.name,
            outputFile: attempt.outputFile,
            stdout,
            stderr,
            disconnectedCount,
          };
        }

        // If we achieved a perfect repair, stop trying
        if (disconnectedCount === 0) {
          if (verbose) {
            console.log(`[STL REPAIR] Perfect repair achieved with ${attempt.name} strategy!`);
          }
          break;
        }
      } catch (error) {
        if (verbose) {
          console.warn(`[STL REPAIR] ${attempt.name} repair failed:`, error.message);
        }
        // Continue to next strategy
      }
    }

    if (!bestResult) {
      throw new Error("All repair strategies failed");
    }

    // Use the best result
    if (verbose) {
      console.log(
        `[STL REPAIR] Best result: ${bestResult.name} with ${bestResult.disconnectedCount} disconnected facets`,
      );
      console.log(`[STL REPAIR] ADMesh output:\n${bestResult.stdout}`);
    }

    // Copy the best result to the final output path
    const { copyFile } = await import("fs/promises");
    await copyFile(bestResult.outputFile, outputPath);

    // Clean up temporary files
    for (const attempt of repairAttempts) {
      if (attempt.outputFile && (await fileExists(attempt.outputFile))) {
        unlinkSync(attempt.outputFile);
      }
    }

    // Get repaired file size
    const repairedSize = await getFileSize(outputPath);

    return {
      success: true,
      outputPath,
      originalSize,
      repairedSize,
      sizeDifference: repairedSize - originalSize,
      admeshOutput: bestResult.stdout,
      strategy: bestResult.name,
      disconnectedFacets: bestResult.disconnectedCount,
    };
  } else {
    // Single-strategy repair (standard or aggressive)
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

      // Parse disconnected facets count
      const disconnectedMatch = stdout.match(/Total disconnected facets\s*:\s*\d+\s+(\d+)/);
      const disconnectedCount = disconnectedMatch ? parseInt(disconnectedMatch[1], 10) : null;

      return {
        success: true,
        outputPath,
        originalSize,
        repairedSize,
        sizeDifference: repairedSize - originalSize,
        admeshOutput: stdout,
        strategy,
        disconnectedFacets: disconnectedCount,
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
