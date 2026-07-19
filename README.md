# Chimera: Ashes of the Hollow King — Godot Port

A 2.5D overhead reimagining of the original Android narrative-simulation RPG.

## Quick start (this environment)

Godot 4.2.2 is bundled under `.tools/` and run through a wrapper that copies the
binary to `/dev/shm` because the project storage is mounted `noexec`.

```bash
cd /mnt/sdcard/project-chimera-workspace/godot-chimera
bash run.sh --version                # verify Godot binary
bash run.sh --editor .               # open the Godot editor
bash run.sh --path .                 # run the game
```

## Tests

```bash
cd /mnt/sdcard/project-chimera-workspace/godot-chimera
bash run.sh --headless --path . res://scenes/tests/simulation_tests.tscn
```

## Export Android APK (debug)

```bash
cd /mnt/sdcard/project-chimera-workspace/godot-chimera
bash export_apk.sh                   # writes /storage/emulated/0/Documents/chimera-debug.apk
bash export_apk.sh /path/to/out.apk  # custom output path
```

Requirements:
- Android export templates 4.2.2 are installed at
  `~/.local/share/godot/export_templates/4.2.2.stable/`
- A debug keystore is provided at `.tools/keystore/chimera-debug.keystore`
- Android SDK `build-tools` (33.0.1 or newer) and `apksigner` are on PATH/available

## Regenerate placeholder sprites

```bash
python3 scripts/generate_placeholder_sprites.py
```

## Project layout

```
assets/          sprites, shaders, theme
 data/           JSON authored content (copied from Android project)
 scenes/         Godot scenes (screens + world)
 scripts/        GDScript singletons + features + UI
 .tools/         bundled Godot 4.2.2 arm64 binary + libs
 export_apk.sh   one-command debug APK exporter
```

## Main scenes

- `scenes/screens/main_menu.tscn`
- `scenes/screens/overhead_map.tscn`
- `scenes/screens/dialogue_screen.tscn`
- `scenes/screens/camp_screen.tscn`
- `scenes/screens/party_screen.tscn`
- `scenes/screens/journal_screen.tscn`
- `scenes/screens/settings_screen.tscn`

See `GODOT_PORT.md` for the full architecture and migration guide.
