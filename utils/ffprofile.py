#!/usr/bin/env python3
"""
ffprofile.py — resolve Flash Studio profile inheritance and emit merged profiles.

Why this exists, because it is not obvious and it cost a print:

Flash Studio's profiles are thin overlays. A file typically sets two or three
keys and names a parent in `inherits`, matched by the parent's `name` field
rather than its filename. The GUI walks that chain. **The CLI does not.** Point
`--load-settings` / `--load-filaments` at a bare child profile and only the keys
literally present in that file take effect; everything else falls back to the
slicer's built-in defaults, NOT to the parent. Verified 2026-08-10: slicing with
the bundle's own PETG Pro profile produced `filament_type` PLA,
`filament_max_volumetric_speed` 2 and `outer_wall_line_width` 0.

The consequence is that a CLI slice driven from profile files is silently wrong
unless someone resolves the chain first. That is this script's whole job: walk
the chain, merge child over parent, apply any explicit overrides, and write out
flat profiles with `inherits` removed so there is nothing left to resolve.

Usage:
  utils/ffprofile.py --outdir /tmp/prof \\
      --machine  "Flashforge Adventurer 5M Pro 0.4 Nozzle" \\
      --process  "0.12mm Fine @Flashforge AD5M Pro 0.4 Nozzle" \\
      --filament "Flashforge PETG Pro" \\
      --set filament:nozzle_temperature=240 \\
      --set process:reduce_crossing_wall=1

A --filament (or --process/--machine) argument may also be a path to a JSON
file, which is how a user preset outside the bundle gets resolved — its
`inherits` is still looked up inside the bundle.

Overrides are type-preserving. Filament settings are single-element lists of
strings in this format (`["240"]`) while process settings are bare scalars, and
writing the wrong shape is a good way to have a value ignored. Rather than
encode that rule per key, --set matches whatever shape the resolved value
already has.
"""

import argparse
import glob
import json
import os
import sys

BUNDLE = ("/Applications/Flash Studio.app/Contents/Resources/profiles/Flashforge")

# Our own presets live in the repo, not in the bundle, so they have to be
# searched first -- a name that exists in both must resolve to ours. Parents
# still come from the bundle, which is what the walk upward relies on.
REPO_PROFILES = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "docs", "profiles")

# Only `inherits` is removed, because a merged profile has nothing left to
# inherit and leaving it in would invite the slicer to resolve the chain a
# second time. Everything else is left exactly as the system profiles have it.
#
# Resist the urge to tidy the rest. `instantiation`, `setting_id` and
# `is_custom_defined` all look like bookkeeping, but stripping them makes the
# slicer stop treating the machine profile as a real printer, and it then
# rejects the pair with "process not compatible with printer" even though the
# process's compatible_printers names that machine exactly.
DROP_ON_WRITE = ("inherits",)


def find_by_name(name, kind, bundle):
    """Locate a profile by its `name` field, which is not its filename.

    The repo is searched ahead of the bundle so our presets win over any
    same-named system profile.
    """
    for root in (REPO_PROFILES, bundle):
        for path in sorted(glob.glob(os.path.join(root, kind, "*.json"))):
            try:
                with open(path) as fh:
                    if json.load(fh).get("name") == name:
                        return path
            except (OSError, ValueError):
                continue
    return None


def resolve(ref, kind, bundle):
    """Merge a profile with all of its ancestors. Returns (merged, chain)."""
    if os.path.sep in ref or ref.endswith(".json"):
        path = ref
        if not os.path.isfile(path):
            sys.exit("error: no such profile file: %s" % path)
    else:
        path = find_by_name(ref, kind, bundle)
        if not path:
            sys.exit("error: no %s profile named %r in %s" % (kind, ref, bundle))

    with open(path) as fh:
        merged = json.load(fh)
    chain = [os.path.basename(path)]

    # Walk upward, letting what we already have win over each new parent. The
    # accumulated dict is always the child of whatever comes next.
    while merged.get("inherits"):
        parent_path = find_by_name(merged["inherits"], kind, bundle)
        if not parent_path:
            sys.exit("error: %s chain broken: no profile named %r"
                     % (kind, merged["inherits"]))
        with open(parent_path) as fh:
            parent = json.load(fh)
        chain.append(os.path.basename(parent_path))

        child = {k: v for k, v in merged.items() if k != "inherits"}
        merged = dict(parent)
        merged.update(child)
        merged["inherits"] = parent.get("inherits")

    merged.pop("inherits", None)
    return merged, chain


def apply_override(merged, key, raw, kind):
    """Set key to raw, matching the shape the resolved value already uses."""
    if key not in merged:
        sys.exit("error: %s has no setting %r to override — check the spelling, "
                 "since a typo here would otherwise pass silently" % (kind, key))
    current = merged[key]
    merged[key] = [str(raw)] if isinstance(current, list) else str(raw)
    return current


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--bundle", default=BUNDLE)
    ap.add_argument("--machine", required=True)
    ap.add_argument("--process", required=True)
    ap.add_argument("--filament", required=True)
    ap.add_argument("--set", action="append", default=[], metavar="KIND:KEY=VALUE",
                    help="override a resolved value, e.g. filament:nozzle_temperature=240")
    ap.add_argument("--outdir", required=True)
    ap.add_argument("--quiet", action="store_true")
    args = ap.parse_args()

    if not os.path.isdir(args.bundle):
        sys.exit("error: profile bundle not found: %s\n"
                 "  Is Flash Studio installed?" % args.bundle)

    kinds = {"machine": args.machine,
             "process": args.process,
             "filament": args.filament}
    resolved, chains = {}, {}
    for kind, ref in kinds.items():
        resolved[kind], chains[kind] = resolve(ref, kind, args.bundle)

    # Overrides last, so they beat every profile in every chain.
    applied = []
    for spec in args.set:
        if ":" not in spec or "=" not in spec:
            sys.exit("error: --set wants KIND:KEY=VALUE, got %r" % spec)
        kind, rest = spec.split(":", 1)
        key, value = rest.split("=", 1)
        if kind not in resolved:
            sys.exit("error: --set kind must be machine, process or filament")
        before = apply_override(resolved[kind], key, value, kind)
        applied.append((kind, key, before, resolved[kind][key]))

    os.makedirs(args.outdir, exist_ok=True)
    written = {}
    for kind, data in resolved.items():
        out = dict(data)
        for k in DROP_ON_WRITE:
            out.pop(k, None)
        # The name is deliberately left alone. A process profile declares
        # `compatible_printers` by machine NAME, so renaming the merged machine
        # profile makes the slicer reject the pair with "process not compatible
        # with printer" after it has already resolved everything correctly.
        path = os.path.join(args.outdir, "%s.json" % kind)
        with open(path, "w") as fh:
            json.dump(out, fh, indent=2, sort_keys=True)
        written[kind] = path

    # Human-readable report on stderr, machine-readable paths on stdout, so a
    # caller can swallow one without losing the other.
    if not args.quiet:
        for kind in ("machine", "process", "filament"):
            print("%-8s %s" % (kind, " <- ".join(chains[kind])), file=sys.stderr)
        for kind, key, before, after in applied:
            print("  set  %s:%-32s %s -> %s" % (kind, key, before, after),
                  file=sys.stderr)

    print(json.dumps(written))


if __name__ == "__main__":
    main()
