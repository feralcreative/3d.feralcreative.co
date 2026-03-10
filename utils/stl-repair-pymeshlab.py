#!/usr/bin/env python3
"""
STL Repair Utility using PyMeshLab

This script uses PyMeshLab (the Python interface to MeshLab) to repair STL files.
PyMeshLab is far more powerful than ADMesh and can fix complex mesh issues.

Installation:
    pip3 install pymeshlab

Usage:
    python3 stl-repair-pymeshlab.py <input.stl> <output.stl> [--verbose]
"""

import sys
import os
import json
import argparse
from pathlib import Path

try:
    import pymeshlab
except ImportError:
    print(json.dumps({
        "success": False,
        "error": "PyMeshLab not installed. Install with: pip3 install pymeshlab"
    }))
    sys.exit(1)


def repair_stl(input_path, output_path, verbose=False):
    """
    Repair an STL file using PyMeshLab's powerful mesh repair algorithms.
    
    Args:
        input_path: Path to input STL file
        output_path: Path to save repaired STL file
        verbose: Enable verbose logging
        
    Returns:
        dict: Result with success status, file info, and repair statistics
    """
    try:
        # Validate input file exists
        if not os.path.exists(input_path):
            return {
                "success": False,
                "error": f"Input file not found: {input_path}"
            }
        
        # Get original file size
        original_size = os.path.getsize(input_path)
        
        if verbose:
            print(f"[PYMESHLAB] Loading mesh from: {input_path}", file=sys.stderr)
        
        # Create a new MeshSet
        ms = pymeshlab.MeshSet()
        
        # Load the STL file
        ms.load_new_mesh(input_path)
        
        # Get initial mesh statistics
        initial_stats = {
            "vertices": ms.current_mesh().vertex_number(),
            "faces": ms.current_mesh().face_number(),
        }
        
        if verbose:
            print(f"[PYMESHLAB] Initial mesh: {initial_stats['vertices']} vertices, {initial_stats['faces']} faces", file=sys.stderr)
        
        # Apply repair filters in sequence
        repair_steps = []
        
        # 1. Remove duplicate faces
        if verbose:
            print("[PYMESHLAB] Step 1: Removing duplicate faces...", file=sys.stderr)
        ms.meshing_remove_duplicate_faces()
        repair_steps.append("remove_duplicate_faces")
        
        # 2. Remove duplicate vertices
        if verbose:
            print("[PYMESHLAB] Step 2: Removing duplicate vertices...", file=sys.stderr)
        ms.meshing_remove_duplicate_vertices()
        repair_steps.append("remove_duplicate_vertices")
        
        # 3. Remove unreferenced vertices
        if verbose:
            print("[PYMESHLAB] Step 3: Removing unreferenced vertices...", file=sys.stderr)
        ms.meshing_remove_unreferenced_vertices()
        repair_steps.append("remove_unreferenced_vertices")
        
        # 4. Repair non-manifold edges by removing faces
        if verbose:
            print("[PYMESHLAB] Step 4: Repairing non-manifold edges...", file=sys.stderr)
        ms.meshing_repair_non_manifold_edges(method=0)  # 0 = remove faces
        repair_steps.append("repair_non_manifold_edges")
        
        # 5. Repair non-manifold vertices by splitting
        if verbose:
            print("[PYMESHLAB] Step 5: Repairing non-manifold vertices...", file=sys.stderr)
        ms.meshing_repair_non_manifold_vertices(vertdispratio=0.0)
        repair_steps.append("repair_non_manifold_vertices")
        
        # 6. Close holes (this is the key step for fixing disconnected facets)
        if verbose:
            print("[PYMESHLAB] Step 6: Closing holes...", file=sys.stderr)
        ms.meshing_close_holes(maxholesize=30)  # Close holes up to 30 edges
        repair_steps.append("close_holes")
        
        # 7. Re-orient all faces coherently
        if verbose:
            print("[PYMESHLAB] Step 7: Re-orienting faces...", file=sys.stderr)
        ms.meshing_re_orient_faces_coherently()
        repair_steps.append("reorient_faces")
        
        # 8. Snap vertices to remove tiny gaps
        if verbose:
            print("[PYMESHLAB] Step 8: Snapping nearby vertices...", file=sys.stderr)
        ms.meshing_snap_mismatched_borders(threshold_perc=0.01)
        repair_steps.append("snap_borders")
        
        # Get final mesh statistics
        final_stats = {
            "vertices": ms.current_mesh().vertex_number(),
            "faces": ms.current_mesh().face_number(),
        }
        
        if verbose:
            print(f"[PYMESHLAB] Final mesh: {final_stats['vertices']} vertices, {final_stats['faces']} faces", file=sys.stderr)
        
        # Save the repaired mesh
        if verbose:
            print(f"[PYMESHLAB] Saving repaired mesh to: {output_path}", file=sys.stderr)
        
        ms.save_current_mesh(output_path, binary=True, save_vertex_normal=False)
        
        # Get repaired file size
        repaired_size = os.path.getsize(output_path)
        
        return {
            "success": True,
            "outputPath": output_path,
            "originalSize": original_size,
            "repairedSize": repaired_size,
            "sizeDifference": repaired_size - original_size,
            "initialStats": initial_stats,
            "finalStats": final_stats,
            "repairSteps": repair_steps,
            "verticesChanged": final_stats["vertices"] - initial_stats["vertices"],
            "facesChanged": final_stats["faces"] - initial_stats["faces"],
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "errorType": type(e).__name__
        }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Repair STL files using PyMeshLab")
    parser.add_argument("input", help="Input STL file path")
    parser.add_argument("output", help="Output STL file path")
    parser.add_argument("--verbose", "-v", action="store_true", help="Enable verbose logging")
    
    args = parser.parse_args()
    
    result = repair_stl(args.input, args.output, args.verbose)
    
    # Output JSON result to stdout
    print(json.dumps(result, indent=2))
    
    # Exit with appropriate code
    sys.exit(0 if result["success"] else 1)

