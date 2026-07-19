#!/bin/bash
# Export a debug APK for the Chimera Godot project.
# Usage: bash export_apk.sh [output.apk]
set -euo pipefail
OUT="${1:-/storage/emulated/0/Documents/chimera-debug.apk}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure a debug keystore exists for this checkout.
KS_DIR="${DIR}/.tools/keystore"
KS="${KS_DIR}/chimera-debug.keystore"
if [ ! -f "${KS}" ]; then
    echo "Generating debug keystore at ${KS}"
    mkdir -p "${KS_DIR}"
    keytool -genkey -v -keystore "${KS}" -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US" > /dev/null 2>&1
fi

# Patch the export preset to use the absolute keystore path for this checkout.
python3 -c "from pathlib import Path; t=Path('${DIR}/export_presets.cfg').read_text(); t=t.replace('res://.tools/keystore/chimera-debug.keystore', '${KS}').replace('/tmp/chimera-debug.keystore', '${KS}'); Path('${DIR}/export_presets.cfg').write_text(t)" && true

bash "${DIR}/run.sh" --headless --export-debug Android "${OUT}" --path "${DIR}"
echo "APK exported to: ${OUT}"
