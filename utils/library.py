#!/usr/bin/env python3
"""Find model sources and keep regenerable work separate from retained assets."""
import argparse
import fnmatch
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import sys
import time
from urllib.parse import quote

REPO = Path(__file__).resolve().parent.parent
LIBRARY = REPO / "library"


def models():
    result = []
    ids = set()
    owners = {}
    # Any depth: library/<category>/<model>/ and library/holiday/halloween/<model>/
    # alike. A model folder may sit inside another one; lookup() picks the deepest.
    for path in sorted(LIBRARY.rglob("model.json")):
        if any(part in ("_work", "originals") for part in path.relative_to(LIBRARY).parts):
            continue
        if not path.parent.resolve().is_relative_to(LIBRARY.resolve()):
            raise ValueError(f"Model folder leaves the library: {path.parent}")
        data = json.loads(path.read_text())
        if data["id"] in ids:
            raise ValueError(f"Duplicate model ID: {data['id']}")
        ids.add(data["id"])
        data["directory"] = path.parent
        for name in data.get("exports", []):
            if name in owners:
                raise ValueError(f"Duplicate export name: {name}")
            if Path(name).name != name or not re.fullmatch(r"[A-Za-z0-9_.-]+", name):
                raise ValueError(f"Invalid export name: {name}")
            owners[name] = data["id"]
        for source in data.get("scad_files", []):
            if not asset(data, source).is_file():
                raise ValueError(f"Missing source: {path.parent / source}")
        result.append(data)
    return result


def category(model):
    return model["directory"].parent.relative_to(LIBRARY).as_posix()


def asset(model, relative):
    path = model["directory"] / relative
    if not path.resolve().is_relative_to(model["directory"].resolve()):
        raise ValueError(f"Path leaves model folder: {relative}")
    return path


def workspace(model):
    return asset(model, "_work")


def lookup(value, collection=None):
    collection = models() if collection is None else collection
    given = Path(value)
    absolute = given.absolute()
    matches = []
    # A path inside a nested model folder is also inside its parent's; the
    # deepest model folder containing the path owns it.
    containing = [m for m in collection if absolute.is_relative_to(m["directory"]) and absolute != m["directory"]]
    owner = max(containing, key=lambda m: len(m["directory"].parts), default=None)
    for model in collection:
        directory = model["directory"]
        if value == model["id"] or absolute == directory:
            source = model.get("scad")
            if not source:
                raise ValueError(f"{model['id']} has no configured SCAD entrypoint; name an STL or 3MF to slice")
            matches.append((model, asset(model, source)))
        elif model is owner:
            matches.append((model, asset(model, absolute.relative_to(directory))))
        else:
            key = os.path.relpath(absolute, REPO)
            if key in model.get("aliases", {}):
                matches.append((model, asset(model, model["aliases"][key])))
    if len(matches) > 1:
        raise ValueError(f"Ambiguous model path: {value}")
    if matches:
        model, path = matches[0]
        if not path.is_file() and "_work" in path.parts and (model["directory"] / path.name).is_file():
            path = model["directory"] / path.name
        return model, path
    return None, given


def resolve(args):
    model, path = lookup(args.input)
    if not path.is_file():
        raise ValueError(f"No such model file: {args.input}")
    missing = model.get("missing_dependencies", {}).get(str(path.relative_to(model["directory"])), []) if model else []
    if path.suffix == ".scad" and missing:
        raise ValueError(f"{model['id']} has missing source dependencies: {', '.join(missing)}")
    if args.shell:
        default_name = model.get("output_names", {}).get(str(path.relative_to(model["directory"])), path.stem) if model else path.stem
        values = {"MODEL_INPUT": str(path), "MODEL_DIR": str(model["directory"]) if model else "", "MODEL_DEFAULT_NAME": default_name}
        if model:
            for kind in ["stl", "renders", "slice", "3mf"]:
                values["MODEL_WORK_" + kind.upper()] = str(asset(model, "_work/" + kind))
        for key, value in values.items():
            print(f"{key}={shlex.quote(value)}")
        flags = model.get("openscad_args", []) if model else []
        print("MODEL_OPENSCAD_ARGS=(" + " ".join(shlex.quote(f) for f in flags) + ")")
    else:
        print(path)


def selected(names, collection):
    chosen = []
    for name in names:
        if Path(name).suffix in {".stl", ".3mf"}:
            name = re.sub(r"-v\d{2,}$", "", Path(name).stem)
        elif "/" in name and any(c in name for c in "*?["):
            name = Path(name).name
        found = []
        for model in collection:
            names_to_match = [model["id"], str(model["directory"]), str(model["directory"].relative_to(REPO))]
            names_to_match += model.get("exports", [])
            if any(fnmatch.fnmatchcase(n, name) for n in names_to_match):
                exports = model.get("exports", [])
                if any(fnmatch.fnmatchcase(n, name) for n in names_to_match[:3]):
                    outputs = exports
                elif any(c in name for c in "*?["):
                    # The pattern matched exports, so take only those, not the whole model.
                    outputs = [e for e in exports if fnmatch.fnmatchcase(e, name)]
                else:
                    outputs = [name]
                found.append((model, outputs))
        if not found:
            raise ValueError(f"No library model or export matches: {name}")
        chosen.extend(found)
    return chosen


def can_finalize(args):
    try:
        selected(args.names, models())
    except ValueError:
        return 1
    return 0


def register_export(args):
    model = next((m for m in models() if m["directory"] == Path(args.model).absolute()), None)
    if not model:
        raise ValueError(f"Unknown model directory: {args.model}")
    if Path(args.name).name != args.name or not re.fullmatch(r"[A-Za-z0-9_.-]+", args.name):
        raise ValueError(f"Invalid export name: {args.name}")
    if any(args.name in other.get("exports", []) and other["id"] != model["id"] for other in models()):
        raise ValueError(f"Export name already belongs to another model: {args.name}")
    if args.check:
        return
    if args.name not in model.get("exports", []):
        model.setdefault("exports", []).append(args.name)
        del model["directory"]
        path = Path(args.model) / "model.json"
        path.write_text(json.dumps(model, indent=2) + "\n")


def finalize(args):
    collection = models()
    chosen = [(m, m.get("exports", [])) for m in collection] if args.all else selected(args.names, collection)
    for model, outputs in chosen:
        work = workspace(model)
        if args.all or not outputs or model["id"] in args.names:
            outputs = sorted(set(outputs) | {p.stem for p in (work / "3mf").glob("*.3mf")})
        for name in outputs:
            if "coupon" in name:
                continue
            source = work / "stl" / f"{name}.stl"
            destination = asset(model, f"{name}.stl")
            job = work / "3mf" / f"{name}.3mf"
            if not source.is_file() and not job.is_file():
                continue
            protected = model.get("protected_assets", [])
            if (source.is_file() and model.get("scad") and destination.name in protected) or (job.is_file() and job.name in protected):
                raise ValueError(f"Finalization would overwrite a source asset in {model['id']}; use a distinct output name")
            if source.is_file() and model.get("scad"):
                shutil.copy2(source, destination)
                publish = model.setdefault("publish_exports", [])
                model["draft_exports"] = [n for n in model.get("draft_exports", []) if n != name]
                if name not in publish:
                    publish.append(name)
                    data = {k: v for k, v in model.items() if k != "directory"}
                    (model["directory"] / "model.json").write_text(json.dumps(data, indent=2) + "\n")
            for path in (work / "stl").glob(f"{name}-v[0-9][0-9]*.stl"):
                path.unlink()
            for path in (work / "stl").glob(f"{name}-*coupon*.stl"):
                path.unlink()
            for path in (work / "renders").glob(f"{name}-*.png"):
                if "-" not in path.name[len(name) + 1:-4]:
                    path.unlink()
            if job.is_file():
                shutil.copy2(job, asset(model, job.name))
            print(f"Finalized {model['id']}: {name}")


def discard(args):
    chosen = selected(args.names, models())
    discarded = set()
    for model, outputs in chosen:
        work = workspace(model)
        for name in outputs:
            discarded.add(name)
            protected = set(model.get("protected_assets", []))
            paths = set()
            for folder, pattern in [("stl", name + ".stl"), ("stl", name + "-v*.stl"), ("stl", name + "-*coupon*.stl"), ("renders", name + "-*.png"), ("3mf", name + ".3mf")]:
                paths.update((work / folder).glob(pattern))
            job = work / "slice" / name
            if job.is_dir():
                paths.update(p for p in job.rglob("*") if p.is_file())
            for suffix in [".stl", ".3mf"]:
                path = asset(model, name + suffix)
                if path.is_file() and path.name not in protected:
                    paths.add(path)
            for path in sorted(paths):
                asset(model, path.relative_to(model["directory"]))
                if path.is_symlink():
                    continue
                print(("delete " if args.apply else "would delete ") + str(path.relative_to(REPO)))
                if args.apply:
                    path.unlink()
        print(f"{model['id']}: sources, originals, licenses, and saved jobs preserved")
    if args.apply:
        for ledger in [REPO / "docs/stl-versions.txt", REPO / "docs/print-log.txt"]:
            if not ledger.is_file():
                continue
            def retain(line):
                fields = line.split()
                return not fields or line.startswith("#") or not any(fields[0] == n or fields[0].startswith(n + "-coupon") for n in discarded)
            ledger.write_text("".join(line for line in ledger.read_text().splitlines(keepends=True) if retain(line)))


def clean(args):
    doomed = set()
    printed = set()
    log = REPO / "docs/print-log.txt"
    if log.is_file():
        for line in log.read_text().splitlines():
            fields = line.split()
            if len(fields) >= 5 and not line.startswith("#") and fields[4].isdigit():
                printed.add(f"{fields[0]}-coupon-v{int(fields[4]):02d}.stl")
    for model in models():
        work = workspace(model)
        if not work.is_dir():
            continue
        paths = [p for p in work.rglob("*") if p.is_file() and not p.is_symlink() and not any(".keep" in q for q in p.relative_to(work).parts)]
        version_groups = {}
        for p in paths:
            match = re.fullmatch(r"(.+)-v(\d{2,})\.stl", p.name)
            if match:
                version_groups.setdefault((p.parent, match[1]), []).append((int(match[2]), p))
        for group in version_groups.values():
            for i, (_, p) in enumerate(sorted(group, reverse=True)):
                old = args.stale is not None and time.time() - p.stat().st_mtime >= args.stale * 86400
                if (i >= args.keep or old) and p.name not in printed and not args.scratch:
                    doomed.add(p)
        for p in paths:
            if any(part.startswith("exp-") for part in p.relative_to(work).parts):
                doomed.add(p)
            elif not args.scratch and args.stale is not None and time.time() - p.stat().st_mtime >= args.stale * 86400:
                if p.suffix != ".stl" or args.all:
                    if p.name not in printed:
                        doomed.add(p)
    for path in sorted(doomed):
        print(("delete " if args.apply else "would delete ") + str(path.relative_to(REPO)))
        if args.apply:
            path.unlink()
    print(f"Library cleanup: {len(doomed)} workspace files {'deleted' if args.apply else 'selected (dry run)'}; retained model assets untouched.")


def catalog(args):
    collection = models()
    if args.command == "list":
        for m in collection:
            if args.scad and bool(m.get("scad_files")) != (args.scad == "yes"):
                continue
            if args.origin and m["origin"] != args.origin:
                continue
            if args.category and args.category not in (category(m), *category(m).split("/")):
                continue
            print(f"{m['id']}\t{m['origin']}\t{m.get('status', 'unreviewed')}\t{m['directory'].relative_to(REPO)}")
        return
    lines = ["# Model library", "", "Each model folder contains its sources, retained printable files, and documentation. `_work/` contains regenerable drafts, renders, coupons, and slice jobs. Shared tools, logos, BOSL2, and printer profiles remain at the repository root.", "", "Generate this index with `python3 utils/library.py catalog`. Filter the inventory with `python3 utils/library.py list --scad yes`, `--scad no`, `--origin adapted`, or `--category hand-tools`. SCAD availability is independent of origin; legacy models with several sources may require an explicit source path.", "", "| Model | Category | Origin | SCAD source | Formats | Status |", "| --- | --- | --- | --- | --- | --- |"]
    for m in collection:
        relative = m["directory"].relative_to(LIBRARY).as_posix()
        source = m.get("scad") or next(iter(m.get("scad_files", [])), None)
        scad = f"[SCAD]({quote(relative + '/' + source)}) ({len(m.get('scad_files', []))})" if source else "—"
        nested = [o["directory"] for o in collection if o is not m and o["directory"].is_relative_to(m["directory"])]
        formats = sorted({p.suffix[1:].upper() for p in m["directory"].rglob("*") if p.is_file() and "_work" not in p.relative_to(m["directory"]).parts and not any(p.is_relative_to(d) for d in nested) and p.suffix.lower() in {".scad", ".stl", ".3mf", ".skp", ".pdf", ".step", ".fcstd", ".f3d", ".obj"}})
        lines.append(f"| [{m['id']}]({quote(relative)}/) | {category(m)} | {m['origin']} | {scad} | {', '.join(formats)} | {m.get('status', 'unreviewed')} |")
    LIBRARY.mkdir(exist_ok=True)
    (LIBRARY / "README.md").write_text("\n".join(lines) + "\n")
    print(f"Indexed {len(collection)} models in library/README.md")


def publish_files(args):
    for model in models():
        protected = model.get("protected_assets", [])
        names = model.get("publish_exports", model.get("exports", []))
        if args.all:
            names = sorted(set(names) | set(model.get("exports", [])))
        for name in names:
            if "coupon" in name or name in model.get("publication_excluded_exports", []):
                continue
            retained = asset(model, name + ".stl")
            latest = workspace(model) / "stl" / (name + ".stl")
            if retained.name in protected:
                continue
            if args.all and latest.is_file():
                print(latest)
            elif retained.is_file():
                print(retained)


def check(args):
    collection = models()
    aliases = {}
    for model in collection:
        for name in model.get("protected_assets", []) + model.get("licenses", []):
            if not asset(model, name).is_file():
                raise ValueError(f"Missing retained source asset: {model['id']}/{name}")
        for old, target in model.get("aliases", {}).items():
            if old in aliases and aliases[old] != model["id"]:
                raise ValueError(f"Duplicate legacy alias: {old}")
            aliases[old] = model["id"]
            asset(model, target)
    print(f"Checked {len(collection)} model manifests and {len(aliases)} legacy aliases.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    subs = parser.add_subparsers(dest="command", required=True)
    p = subs.add_parser("resolve"); p.add_argument("input"); p.add_argument("--shell", action="store_true"); p.set_defaults(func=resolve)
    p = subs.add_parser("can-finalize"); p.add_argument("names", nargs="+"); p.set_defaults(func=can_finalize)
    p = subs.add_parser("register-export"); p.add_argument("model"); p.add_argument("name"); p.add_argument("--check", action="store_true"); p.set_defaults(func=register_export)
    p = subs.add_parser("finalize"); p.add_argument("names", nargs="*"); p.add_argument("--all", action="store_true"); p.set_defaults(func=finalize)
    p = subs.add_parser("discard"); p.add_argument("names", nargs="+"); p.add_argument("--apply", action="store_true"); p.set_defaults(func=discard)
    p = subs.add_parser("clean"); p.add_argument("--keep", type=int, default=2); p.add_argument("--stale", type=int); p.add_argument("--all", action="store_true"); p.add_argument("--scratch", action="store_true"); p.add_argument("--apply", "-y", action="store_true"); p.set_defaults(func=clean)
    p = subs.add_parser("catalog"); p.set_defaults(func=catalog)
    p = subs.add_parser("publish-files"); p.add_argument("--all", action="store_true"); p.set_defaults(func=publish_files)
    p = subs.add_parser("check"); p.set_defaults(func=check)
    p = subs.add_parser("list"); p.add_argument("--scad", choices=["yes", "no"]); p.add_argument("--origin"); p.add_argument("--category"); p.set_defaults(func=catalog)
    args = parser.parse_args()
    if args.command == "clean":
        if args.all:
            args.keep = 0; args.stale = 0
        if args.keep < 0 or (args.stale is not None and args.stale < 0):
            parser.error("Cleanup limits must be nonnegative")
    try:
        return args.func(args) or 0
    except (ValueError, KeyError, OSError, json.JSONDecodeError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
