# T9 — Final Integration Review

**Lead:** team lead · **Date:** 2026-07-19 · **Scope:** validate T6/T7/T8 integration, APK export, static checks, data integrity.

---

## 1. Summary

All implementation tasks (T6 UX, T7 narrative, T8 gameplay systems) have landed on disk. The project builds, the headless simulation suite passes 41/41, all JSON is clean, and a signed Android APK exports successfully (≈22 MB).

---

## 2. Validation checklist

| Check | Command | Result |
|---|---|---|
| Static GDScript | `python3 scripts/tests/validate_gdscript.py` | ✅ passed |
| JSON clean (all data/*.json) | `python3 -m json.tool` for each | ✅ all clean |
| Headless simulation tests | `bash run.sh --headless --path . res://scenes/tests/simulation_tests.tscn` | ✅ 41 passed, 0 failed |
| Godot headless import | `timeout 60 bash run.sh --headless --path . --quit` | ✅ exit 0 |
| Signed APK export | `bash export_apk.sh /tmp/chimera_test.apk` | ✅ 22 MB, signed |

---

## 3. What got built (from git diff)

- **UX/T6** (`+1,482 / −153` across 29 files):
  - `scripts/world/map_camera.gd` — drag pan, pinch zoom, tap-select.
  - `scripts/ui/ui_adapt.gd` — safe-area margins; `scripts/ui/toast_layer.gd` — feedback layer.
  - `scripts/core/scene_switcher.gd` — visual fade + toast integration.
  - `scripts/ui/main_menu.gd` + `.tscn` — save-slot-aware Continue, overwrite confirmation.
  - `scenes/screens/overhead_map.tscn` + world scripts — quick-bar, Back handling.
  - `assets/ui_theme.tres`, `scripts/ui/gothic_button.gd` — 48dp touch target floor + audio hook.

- **Narrative/T7**:
  - `scripts/core/dialogue_engine.gd` — deterministic tree interpreter (conditions, effects).
  - `scripts/ui/dialogue_screen.gd` + `.tscn` — typewriter, choice rendering, Leave.
  - `scripts/ui/journal_screen.gd` + `.tscn` — quests + lore tabs.
  - `scripts/core/content.gd` — loaders for quests, dialogue trees, lore, items.
  - `data/quests.json`, `data/dialogue_trees.json`, `data/lore_entries.json` (T3 carry-over).

- **Systems/T8**:
  - `scripts/core/game_state.gd` — save slots, autosave, schema migration, atomic writes, `rng_seed`, `pending_dispositions`.
  - `scripts/core/simulation.gd` — seeded RNG, turn-based delayed dispositions, combat/duel resolution, `advance_act`, finale resolver.
  - `scripts/core/audio_manager.gd` + `default_bus_layout.tres` + `assets/audio/` — Music/SFX buses, settings-aware muting, placeholder loops.
  - `scripts/ui/combat_screen.gd` + `.tscn`, `scripts/ui/crafting_screen.gd` + `.tscn`, `act_transition`, `credits`.
  - `data/items.json` — item catalog satisfying all recipe references.
  - `scripts/tests/simulation_tests.gd` — expanded from 12 → 41 tests (save slots, determinism, delayed disposition turn counter, recipe→item integrity).

- **Project settings**:
  - `project.godot` orientation fixed to `4` (landscape), ETC2/ASTC import enabled, AudioManager/UIAdapt/ToastLayer autoloads added.

---

## 4. Remaining known issues / P2 polish

1. **C7 — overhead_map edge rendering.** code-analyst identified that `scripts/world/overhead_map.gd` uses a single shared `Line2D` for all edges, drawing spurious lines between unrelated segments. A patch was proposed in `docs/T8_IMPLEMENTATION_NOTES.md` §C7 but intentionally left to UX lane. **Impact:** visual artifact, not functional; can be fixed in M2/M3.
2. **Coach marks / onboarding.** Not implemented (UX_SPEC.md R7) — store-ready milestone P2.
3. **Haptics / controller support.** P2.
4. **Store assets.** P2; export_presets.cfg has icon slots but no dedicated Play Store feature art.

---

## 5. Conclusion

**M1 (playable on a phone) is functionally complete:** touch navigation, Back-safe autosaves, authored dialogue trees, working combat + crafting screens, real audio buses, deterministic simulation, and a signed APK export. P0 acceptance criteria from `docs/DEVELOPMENT_PLAN.md` are met. The remaining P1/P2 items are documented and owned.

Signed off by: team lead
