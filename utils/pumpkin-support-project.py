#!/usr/bin/env python3
"""Package the pumpkin support experiment with explicit, import-safe PETG settings.

Build the named SCAD variant first. This writes a project, never sends a print.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import subprocess
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[1]
MODEL = ROOT / "library/holiday/pumpkin-body"
WORK = MODEL / "_work"
PROCESS = "0.20mm Standard @Flashforge AD5M Pro 0.4 Nozzle"
OVERRIDES = {
    "layer_height": "0.2", "initial_layer_print_height": "0.2",
    "wall_loops": "2", "sparse_infill_density": "0%",
    "top_shell_layers": "4", "bottom_shell_layers": "4",
    "wall_generator": "classic",
    "ensure_vertical_shell_thickness": "ensure_critical_only",
    "outer_wall_speed": "80", "bridge_speed": "25",
    "enable_support": "0", "brim_type": "no_brim", "raft_layers": "0",
}


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("stl", type=Path)
    ap.add_argument("--auto", action="store_true", help="Tree-support comparison only")
    args = ap.parse_args()
    profiles = WORK / "slice/custom-supports/profiles"
    subprocess.run(["python3", str(ROOT / "utils/ffprofile.py"),
        "--machine", "Flashforge Adventurer 5M Pro 0.4 Nozzle",
        "--process", PROCESS, "--filament", "Overture PETG White",
        "--bed-type", "Textured PEI Plate", "--outdir", str(profiles)], check=True,
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    settings = {}
    for kind in ("machine", "process", "filament"):
        data = json.loads((profiles / (kind + ".json")).read_text())
        settings.update({k:v for k,v in data.items() if k not in
                         {"name", "type", "from", "inherits", "version", "compatible_printers"}})
    overrides = dict(OVERRIDES)
    if args.auto:
        overrides.update(enable_support="1", support_type="tree(auto)", support_threshold_angle="30")
    settings.update(overrides)
    settings.update(print_settings_id=PROCESS,
        printer_settings_id="Flashforge Adventurer 5M Pro 0.4 Nozzle",
        filament_settings_id=["Overture PETG White"],
        inherits_group=[PROCESS, "", ""],
        different_settings_to_system=[";".join(sorted(overrides)), "", ""])
    spec = importlib.util.spec_from_file_location("mesh_project", ROOT / "utils/magnet-project.py")
    helper = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(helper)
    vertices, faces = helper.read_stl(args.stl)
    model = ET.Element("model", unit="millimeter", xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02")
    ET.SubElement(model, "metadata", name="Application").text = "BambuStudio-2.3.2"
    ET.SubElement(model, "metadata", name="BambuStudio:3mfVersion").text = "1"
    obj = ET.SubElement(ET.SubElement(model,"resources"),"object",id="1",type="model")
    mesh = ET.SubElement(obj,"mesh")
    vs = ET.SubElement(mesh,"vertices")
    for v in vertices:
        ET.SubElement(vs,"vertex",**dict(zip(("x","y","z"),map(str,v))))
    fs = ET.SubElement(mesh,"triangles")
    for f in faces:
        ET.SubElement(fs,"triangle",**dict(zip(("v1","v2","v3"),map(str,f))))
    ET.SubElement(ET.SubElement(model,"build"),"item",objectid="1")
    config = ET.Element("config")
    obj = ET.SubElement(config,"object",id="1")
    ET.SubElement(obj,"metadata",key="name",value=args.stl.stem)
    ET.SubElement(obj,"metadata",key="extruder",value="1")
    for k,v in overrides.items():
        ET.SubElement(obj,"metadata",key=k,value=v)
    part = ET.SubElement(obj,"part",id="1",subtype="normal_part")
    ET.SubElement(part,"metadata",key="name",value=args.stl.stem)
    plate = ET.SubElement(config,"plate")
    for k,v in {"plater_id":"1", "plater_name":args.stl.stem, "locked":"false"}.items():
        ET.SubElement(plate,"metadata",key=k,value=v)
    instance = ET.SubElement(plate,"model_instance")
    for k,v in {"object_id":"1", "instance_id":"0", "identify_id":"1"}.items():
        ET.SubElement(instance,"metadata",key=k,value=v)
    suffix = "-auto-comparison" if args.auto else "-overture-petg"
    output = WORK / "3mf" / (args.stl.stem + suffix + ".3mf")
    output.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(output,"w",zipfile.ZIP_DEFLATED) as z:
        z.writestr("[Content_Types].xml", '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/></Types>')
        z.writestr("_rels/.rels", '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Target="/3D/3dmodel.model" Id="rel0" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')
        z.writestr("3D/3dmodel.model",ET.tostring(model,encoding="utf-8",xml_declaration=True))
        z.writestr("Metadata/model_settings.config",ET.tostring(config,encoding="utf-8",xml_declaration=True))
        z.writestr("Metadata/project_settings.config",json.dumps(settings))
    print(output)

if __name__ == "__main__":
    main()
