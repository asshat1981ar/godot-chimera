#!/bin/bash
set -e
PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_DIR"

echo "=== Chimera M3 validation gate ==="

echo "[1/6] Static GDScript check..."
python3 scripts/tests/validate_gdscript.py

echo "[2/6] JSON validation..."
for f in $(find data -name '*.json'); do
    python3 -m json.tool "$f" > /dev/null
    echo "  OK $f"
done

echo "[3/6] Headless project import..."
timeout 60 bash run.sh --headless --path . --quit

echo "[4/6] Headless simulation tests..."
bash run.sh --headless --path . res://scenes/tests/simulation_tests.tscn

echo "[5/6] APK export..."
APK="/tmp/chimera-m2-check.apk"
bash export_apk.sh "$APK"
ls -lh "$APK"

echo "[6/6] APK badging verification..."
export PATH="${ANDROID_SDK_BUILD_TOOLS:-/home/dev/android-sdk/build-tools/34.0.0}:${ANDROID_SDK_PLATFORM_TOOLS:-/home/dev/android-sdk/platform-tools}:$PATH"
aapt dump badging "$APK" | head -n 1
apksigner verify --verbose "$APK" | head -n 6

echo "=== All checks passed ==="
