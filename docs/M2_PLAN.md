# M2 Plan — Loop Polish & Narrative Closure

**Owner:** team lead · **Date:** 2026-07-19 · **Goal:** close the remaining M1 gaps, finish the core loop, and make the three-act experience feel complete.

## Tasks

| ID | Owner | Task | Acceptance criteria | P0/P1 |
|---|---|---|---|---|
| M2-1 | UX | **Fix overhead_map edge rendering** | Per-edge `Line2D` instances; no spurious lines between disconnected edges. Apply the patch proposed in `docs/T8_IMPLEMENTATION_NOTES.md` §C7. | P0 |
| M2-2 | UX | **Typewriter refinement** | Tap-to-skip, reduced_motion instant reveal, punctuation pauses, no text overflow on small screens. | P1 |
| M2-3 | UX | **HUD objective + quest badge** | Quick-bar journal/camp badges show unseen quest/lore counts; an objective label on overhead_map shows current active quest. | P1 |
| M2-4 | UX | **Camp summary screen** | After resting at camp, show a Stardew-style summary: dispositions shifted, scenes completed, items gained, lore unlocked, autosave indicator. | P1 |
| M2-5 | UX | **Empty / error states** | No save slots → "Start your journey" instead of disabled Continue; no recipes → friendly message; no lore/journal → placeholder panel. | P1 |
| M2-6 | NAR | **Finish all act transitions** | `advance_act()` wired to the act gates in `data/maps.json`; act transition screen uses `data/quests.json` act copy. | P0 |
| M2-7 | NAR | **Endings fully wired** | 4 endings from `data/quests.json` evaluated by `Simulation.resolve_finale()`; credits screen shows the earned ending title + condition summary. | P0 |
| M2-8 | NAR | **Dialogue tree coverage** | At least one authored tree for every scene in act 1 and key act 2/3 gate scenes; procedural fallback remains but is no longer the primary path. | P1 |
| M2-9 | NAR | **Quest activation hooks** | Entering a node or completing a scene auto-activates quests whose `unlockConditions` are met; journal badge updates. | P1 |
| M2-10 | SYS | **Scene→combat→scene round-trip** | `start_duel()` is invoked from `dialogue_screen` when a tree choice has `startDuel`; combat result returns and the dialogue continues or the scene resolves. | P0 |
| M2-11 | SYS | **Crafting acquisition hooks** | Items can be granted by scene resolution / quest completion; `Simulation.grant_item()` helper. | P1 |
| M2-12 | SYS | **Lore reveal from scene resolution** | Non-dialogue reveals (e.g., arriving at a location) call `GameState.unlock_lore()` via event or simulation hook. | P1 |
| M2-13 | QA | **CI-style validation script** | A single `scripts/tests/run_all_checks.sh` that runs static GDScript, JSON validation, headless tests, and APK export. | P1 |

## Validation gate (all agents before marking done)

1. `bash scripts/tests/run_all_checks.sh` → pass
2. `bash run.sh --headless --path . res://scenes/tests/simulation_tests.tscn` → 0 failures (extend, don't weaken)
3. `bash export_apk.sh /tmp/chimera-m2.apk` → signed APK produced
4. No edits outside your M1 ownership lane without lead approval

## File ownership (same as M1)

- **UX:** `assets/ui_theme.tres`, `scripts/world/*.gd`, `scenes/world/*.tscn`, `scripts/ui/{main_menu,settings_screen,camp_screen,party_screen,gothic_button}.gd` + `.tscn`, `scenes/screens/overhead_map.tscn`, `scripts/core/scene_switcher.gd`, `scripts/ui/ui_adapt.gd`, `scripts/ui/toast_layer.gd`.
- **NAR:** `data/*.json` (except `items.json`), `scripts/core/content.gd`, `scripts/ui/{dialogue_screen,journal_screen}.gd` + `.tscn`, `scripts/core/dialogue_engine.gd`.
- **SYS:** `scripts/core/{game_state,simulation,event_bus}.gd`, `scripts/tests/simulation_tests.gd`, `data/items.json`, `scripts/core/audio_manager.gd`, `default_bus_layout.tres`, `scenes/screens/{combat_screen,crafting_screen,act_transition,credits}.tscn` + scripts, `project.godot` [autoload] only.
