#!/usr/bin/env python3
import os, re, sys
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
scripts_dir = os.path.join(ROOT, "scripts")
errors = 0


def load_autoload_names():
    names = []
    in_section = False
    try:
        with open(os.path.join(ROOT, "project.godot"), "r") as fh:
            for line in fh:
                s = line.strip()
                if s == "[autoload]":
                    in_section = True
                    continue
                if in_section:
                    if s.startswith("["):
                        break
                    m = re.match(r"(\w+)=", s)
                    if m:
                        names.append(m.group(1))
    except OSError:
        pass
    return names


AUTOLOADS = load_autoload_names()

for root, _, files in os.walk(scripts_dir):
    for f in files:
        if not f.endswith(".gd"):
            continue
        path = os.path.join(root, f)
        with open(path, "r") as fh:
            lines = fh.readlines()
        top_level_funcs = {}
        for i, line in enumerate(lines, 1):
            if line.strip() == "":
                continue
            if line.startswith(" ") and "\t" in line:
                print(f"MIXED INDENT: {path}:{i}")
                errors += 1
            code = line.split("#")[0]

            # Duplicate top-level function declarations are a parse error in Godot 4.
            m = re.match(r"(?:static\s+)?func\s+(\w+)", line)
            if m:
                name = m.group(1)
                if name in top_level_funcs:
                    print(f"DUPLICATE FUNC: {path}:{i} 'func {name}' already declared at line {top_level_funcs[name]}")
                    errors += 1
                else:
                    top_level_funcs[name] = i

            # class_name colliding with an autoload singleton fails at project load.
            m = re.match(r"class_name\s+(\w+)", line)
            if m and m.group(1) in AUTOLOADS:
                print(f"AUTOLOAD COLLISION: {path}:{i} class_name '{m.group(1)}' shadows an autoload")
                errors += 1

            # Autoload names are instances, not types: they cannot be used in type
            # annotations or instantiated with .new().
            for auto in AUTOLOADS:
                if re.search(rf"\bvar\s+\w+\s*:\s*{auto}\b", code) or re.search(rf"->\s*{auto}\b", code):
                    print(f"AUTOLOAD AS TYPE: {path}:{i} '{auto}' used as a type annotation")
                    errors += 1
                if re.search(rf"\b{auto}\.new\(", code):
                    print(f"AUTOLOAD .new(): {path}:{i} '{auto}' is an autoload instance and cannot be instantiated")
                    errors += 1

if errors == 0:
    print("Static GDScript check passed.")
else:
    print(f"Found {errors} errors.")
    sys.exit(1)
