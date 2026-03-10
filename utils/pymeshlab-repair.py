#!/usr/bin/env python3
"""
PyMeshLab STL Repair Script

Uses PyMeshLab to repair STL files by fixing common issues:
- Non-manifold edges
- Non-manifold vertices
- Duplicate faces
- Duplicate vertices
- Inverted normals
- Small connected components

Usage:
    python3 pymeshlab-repair.py <input.stl> <output.stl> [--verbose]

Returns JSON to stdout with repair results.
"""

import sys
import json
import os
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
    Repair an STL file using PyMeshLab
    
    Args:
        input_path: Path to input STL file
        output_path: Path to save repaired STL file
        verbose: Enable verbose logging
        
    Returns:
        dict: Repair results with success status and details
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
        initial_verts = ms.current_mesh().vertex_number()
        initial_faces = ms.current_mesh().face_number()
        
        if verbose:
            print(f"[PYMESHLAB] Initial mesh: {initial_verts} vertices, {initial_faces} faces", file=sys.stderr)
        
        # Apply repair filters - optimized for 3D printing
        # Based on PyMeshLab documentation and best practices
        repair_steps = []

        # 1. Remove duplicate vertices (merge vertices at same location)
        if verbose:
            print("[PYMESHLAB] Removing duplicate vertices...", file=sys.stderr)
        ms.meshing_remove_duplicate_vertices()
        repair_steps.append("remove_duplicate_vertices")

        # 2. Remove duplicate faces
        if verbose:
            print("[PYMESHLAB] Removing duplicate faces...", file=sys.stderr)
        ms.meshing_remove_duplicate_faces()
        repair_steps.append("remove_duplicate_faces")

        # 3. Remove unreferenced vertices
        if verbose:
            print("[PYMESHLAB] Removing unreferenced vertices...", file=sys.stderr)
        ms.meshing_remove_unreferenced_vertices()
        repair_steps.append("remove_unreferenced_vertices")

        # 4. Repair non-manifold edges by SPLITTING vertices (not removing faces)
        # This preserves geometry better than removing faces
        if verbose:
            print("[PYMESHLAB] Repairing non-manifold edges by splitting vertices...", file=sys.stderr)
        ms.meshing_repair_non_manifold_edges(method='Split Vertices')
        repair_steps.append("repair_non_manifold_edges_split")

        # 5. Repair non-manifold vertices by splitting
        if verbose:
            print("[PYMESHLAB] Repairing non-manifold vertices...", file=sys.stderr)
        ms.meshing_repair_non_manifold_vertices(vertdispratio=0)
        repair_steps.append("repair_non_manifold_vertices")

        # 6. Close holes to fix any remaining open edges
        if verbose:
            print("[PYMESHLAB] Closing holes...", file=sys.stderr)
        ms.meshing_close_holes(maxholesize=30)
        repair_steps.append("close_holes")

        # 7. Re-orient all faces coherently (fix inverted normals)
        if verbose:
            print("[PYMESHLAB] Re-orienting faces...", file=sys.stderr)
        ms.meshing_re_orient_faces_coherently()
        repair_steps.append("re_orient_faces")
        
        # Get final mesh statistics
        final_verts = ms.current_mesh().vertex_number()
        final_faces = ms.current_mesh().face_number()
        
        if verbose:
            print(f"[PYMESHLAB] Final mesh: {final_verts} vertices, {final_faces} faces", file=sys.stderr)
        
        # Save the repaired mesh
        if verbose:
            print(f"[PYMESHLAB] Saving repaired mesh to: {output_path}", file=sys.stderr)
        
        ms.save_current_mesh(output_path, binary=True)
        
        # Get repaired file size
        repaired_size = os.path.getsize(output_path)
        
        return {
            "success": True,
            "outputPath": output_path,
            "originalSize": original_size,
            "repairedSize": repaired_size,
            "sizeDifference": repaired_size - original_size,
            "initialVertices": initial_verts,
            "initialFaces": initial_faces,
            "finalVertices": final_verts,
            "finalFaces": final_faces,
            "verticesRemoved": initial_verts - final_verts,
            "facesRemoved": initial_faces - final_faces,
            "repairSteps": repair_steps
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(json.dumps({
            "success": False,
            "error": "Usage: pymeshlab-repair.py <input.stl> <output.stl> [--verbose]"
        }))
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    verbose = "--verbose" in sys.argv
    
    result = repair_stl(input_file, output_file, verbose)
    print(json.dumps(result))
    
    sys.exit(0 if result["success"] else 1)
