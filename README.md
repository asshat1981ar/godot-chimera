# Chimera: Ashes of the Hollow King

A premium, offline, 2D narrative RPG for Android, rebuilt in Godot 4.

You are the Chimera: a figure woven from ash and stolen memories. Walk the Hollow Reach, speak with outcasts and fallen kings, and let your choices reshape the world. No ads. No energy. No gacha. Save anywhere.

---

## Install

Download the latest APK from Releases and sideload it, or build locally:

```bash
cd /home/dev/godot-chimera
bash run.sh --version
bash scripts/tests/run_all_checks.sh      # validate before export
bash export_apk.sh /tmp/chimera.apk       # signed debug APK
```

Requirements (already set up in this environment):
- Godot 4.2.2 at `.tools/`
- Android export templates in `~/.local/share/godot/export_templates/4.2.2.stable/`
- Android SDK build-tools 34 + `apksigner`
- Debug keystore at `.tools/keystore/chimera-debug.keystore`

---

## Controls

**Touch**
- Drag to pan the map; pinch to zoom; double-tap a node to focus.
- Tap a node once to open its card, then tap **Travel** to go there.
- Quick-bar (bottom-right): Camp, Party, Journal, Menu.
- Android Back saves and returns to the previous screen.

**Controller / keyboard**
- D-pad / WASD: move focus
- A / Enter / Space: confirm
- B / Escape / Q: back

**Accessibility**
- Settings → Reduced motion disables camera and scene animations.
- Text speed slider and independent Music / SFX toggles.

---

## How to play

1. Start a **New Game** or **Continue** an autosave.
2. On the map, travel to glowing nodes.
3. Talk to NPCs. Choices change dispositions and unlock branches.
4. Some conversations lead to duels; others reveal lore or recruit allies.
5. Rest at camp to heal, review your journal, and autosave.
6. Complete three acts and earn one of several endings.

Your progress autosaves whenever you complete a scene, visit a node, rest at camp, or pause the app.

---

## Project structure

```
assets/         sprites, audio, shaders, theme, store art
data/           JSON-authored content: scenes, maps, NPCs, quests, dialogue trees, lore, items
scenes/         Godot screens and world scenes
scripts/        core systems, UI, world, tests
docs/           design docs, plans, audit reports
.tools/         bundled Godot 4.2.2 binary + debug keystore
run.sh          Godot wrapper (copies binary to /dev/shm if needed)
export_apk.sh   one-command Android APK exporter
```

---

## Tests and validation

```bash
bash scripts/tests/run_all_checks.sh
```

Runs static GDScript checks, JSON validation, headless import, headless simulation tests, and a signed APK export.

Headless tests only:

```bash
bash run.sh --headless --path . res://scenes/tests/simulation_tests.tscn
```

---

## Milestones

- **M1** — Playable on a phone: touch map, autosave, authored dialogue trees, combat + crafting screens, audio buses.
- **M2** — Loop polish: map edge rendering fix, typewriter, HUD objectives, camp summary, act transitions, endings, scene→combat→scene round-trip.
- **M3** — Store-ready: onboarding, haptics, controller support, store art, CI, release signing, UX/accessibility audit, playthrough guide.

---

## Store assets

Generated store art is in `assets/store/`:

- `feature_graphic_1024x500.png` — Google Play feature graphic.
- `hi_res_icon_512x512.png` — hi-res app icon.
- `screenshot_overworld_1280x720.png`
- `screenshot_dialogue_1280x720.png`
- `screenshot_combat_1280x720.png`
- `screenshot_camp_1280x720.png`
- `screenshot_journal_1280x720.png`

---

## Team

- Lead architecture & integration
- Code analyst — systems, saves, combat, crafting, audio, CI
- UX designer — mobile UX, accessibility, store art
- Narrative designer — storyline, dialogue, lore, quests
- Market researcher — competitor analysis

---

## License

© 2026 team-godot-chimera. All rights reserved.

Placeholder audio generated in-engine. Portraits, tiles, and icons are original placeholder art.
