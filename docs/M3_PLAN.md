# M3 Plan — Store-Ready Release

**Owner:** team lead · **Date:** 2026-07-19 · **Goal:** take the playable M2 build to Google Play / sideload-ready quality.

## Tasks

| ID | Owner | Task | Acceptance criteria | P0/P1 |
|---|---|---|---|---|
| M3-1 | UX | **Coach marks / first-run onboarding** | First launch shows 3–4 contextual tooltips on the map: pan/zoom, tap node, Travel, quick-bar. `has_seen_onboarding` flag persisted in GameState.settings. Dismissible, reduced_motion safe. | P0 |
| M3-2 | UX | **Haptics** | Short haptic feedback on button press, node tap, combat hit, and camp save. Respects system settings; falls back to no-op on unsupported devices. | P1 |
| M3-3 | UX | **Controller / keyboard navigation** | D-pad/left-stick moves node focus; A/Enter confirms; B/Back returns; Focus visual indicator on all buttons. Works in main menu, map, dialogue, combat, camp, journal. | P1 |
| M3-4 | UX | **Performance + accessibility pass** | Minimum FPS target 30 on mid-tier Android; reduced_motion disables camera pan/zoom animations and scene fades; font scaling respects device settings; color-blind safe icons (shape + color). | P1 |
| M3-5 | UX | **Store screenshots + feature art** | Generate 3–5 16:9 screenshots from headless/playback scenes: overworld, dialogue, combat, journal, camp. Provide a 1024×500 feature graphic and 512×512 hi-res icon. | P0 |
| M3-6 | NAR | **Final content pass** | Proofread all dialogue trees, quest copy, and lore entries for consistency; fix dangling scene/npc ids; ensure every act 1 scene has at least one tree; all endings reachable in data. | P0 |
| M3-7 | NAR | **Tutorial quest** | Add a guided first quest (`mq_first_steps`) with explicit objectives: visit one node, talk to an NPC, win/avoid a duel, rest at camp. Journal tracks progress. | P0 |
| M3-8 | NAR | **Play-through validation** | Document a golden path from New Game → Act 1 → Act 2 → Act 3 → one ending in `docs/PLAYTHROUGH.md` with expected node/scene sequence. | P1 |
| M3-9 | SYS | **Release checklist + versioning** | `project.godot` version bumped to 0.3.0; export_presets.cfg debug symbols removed; `run_all_checks.sh` passes; signed release APK produced with `release.keystore` path documented. | P0 |
| M3-10 | SYS | **Build/CI pipeline** | GitHub Actions workflow (`.github/workflows/godot.yml`) that checks out repo, validates GDScript/JSON, runs headless tests, and exports Android APK on every PR. Use existing `run.sh` + `export_apk.sh`. | P1 |
| M3-11 | SYS | **Cheat / dev menu** | Optional hidden dev panel (tap build number 5× in settings) to jump act, unlock nodes, grant items, toggle God mode for QA. | P1 |
| M3-12 | QA | **Final validation gate** | `bash scripts/tests/run_all_checks.sh` + manual install of APK on device/emulator + smoke test: new game → first dialogue → first duel → camp → journal → exit/resume. | P0 |
| M3-13 | Lead | **Release notes + README update** | `README.md` rewritten for players: install, synopsis, controls, save info, team, license, known issues. `docs/RELEASE_NOTES_v0.3.0.md` with changelog. | P0 |

## File ownership (same as M2)

- **UX:** `assets/ui_theme.tres`, `scripts/world/*.gd`, `scenes/world/*.tscn`, `scripts/ui/{main_menu,settings_screen,camp_screen,party_screen,gothic_button,act_transition,credits}.gd + .tscn`, `scenes/screens/*.tscn` (ui shells), `scripts/core/scene_switcher.gd`, `scripts/ui/ui_adapt.gd`, `scripts/ui/toast_layer.gd`.
- **NAR:** `data/*.json` EXCEPT `items.json`, `scripts/core/content.gd`, `scripts/ui/{dialogue_screen,journal_screen}.gd + .tscn`, `scripts/core/dialogue_engine.gd`.
- **SYS:** `scripts/core/{game_state,simulation,event_bus}.gd`, `scripts/tests/simulation_tests.gd`, `data/items.json`, `scripts/core/audio_manager.gd`, `default_bus_layout.tres`, `scenes/screens/{combat_screen,crafting_screen,act_transition,credits}.tscn + scripts`, `project.godot` [autoload] only.
- **Lead:** `.github/workflows/`, `README.md`, `docs/RELEASE_NOTES_v0.3.0.md`, release signing config.

## Validation gate

1. `bash scripts/tests/run_all_checks.sh` → pass
2. Headless simulation tests → 0 failures
3. APK exported, apksigner verifies, `aapt dump badging` shows `package: name='com.chimera.ash' versionCode='3' versionName='0.3.0'`
4. Golden path documented and smoke-testable
5. README + release notes complete
