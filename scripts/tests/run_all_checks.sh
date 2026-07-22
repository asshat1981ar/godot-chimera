#!/bin/bash
set -e
PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_DIR"

echo "=== Chimera M2 validation gate ==="

echo "[1/5] Static GDScript check..."
python3 scripts/tests/validate_gdscript.py

echo "[2/5] JSON validation..."
for f in $(find data -name '*.json'); do
    python3 -m json.tool "$f" > /dev/null
    echo "  OK $f"
done

echo "[3/5] Headless project import..."
timeout 60 bash run.sh --headless --path . --quit

echo "[4/5] Headless simulation tests..."
bash run.sh --headless --path . res://scenes/tests/simulation_tests.tscn

echo "[5/5] APK export..."
APK="/tmp/chimera-m2-check.apk"
bash export_apk.sh "$APK"
ls -lh "$APK"

echo "=== All checks passed ==="
