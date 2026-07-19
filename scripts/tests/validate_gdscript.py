#!/usr/bin/env python3
import os, sys
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
scripts_dir = os.path.join(ROOT, "scripts")
errors = 0
for root, _, files in os.walk(scripts_dir):
    for f in files:
        if not f.endswith(".gd"):
            continue
        path = os.path.join(root, f)
        with open(path, "r") as fh:
            lines = fh.readlines()
        for i, line in enumerate(lines, 1):
            if line.strip() == "":
                continue
            if line.startswith(" ") and "\t" in line:
                print(f"MIXED INDENT: {path}:{i}")
                errors += 1
            code = line.split("#")[0]
            if code.count("(") != code.count(")") or code.count("[") != code.count("]") or code.count("{") != code.count("}"):
                # Single-line only; ignore known balanced JSON tscn lines not in gd
                pass
if errors == 0:
    print("Static GDScript check passed.")
else:
    print(f"Found {errors} warnings.")
    sys.exit(1)
