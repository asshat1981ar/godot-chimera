# Chimera: Ashes of the Hollow King — Codebase Gap Analysis

**Author:** code-analyst (team godot-chimera) · **Task:** T1 / task_0001
**Scope:** full read of `project.godot`, `README.md`, `GODOT_PORT.md`, `export_presets.cfg`, `export_apk.sh`, all 16 GDScript files under `scripts/`, all 10 `.tscn` scenes, and all 12 JSON files under `data/`.
**Benchmark:** what a shipped 2D Android RPG needs (complete core loop, touch-first UX, working settings, session-safe persistence, data-driven content, release-ready export).
**Environment note:** no Godot binary is present (`.tools/` missing, `run.sh` wrapper dangling), so headless scene tests could not be executed here; analysis is static. `python3 scripts/tests/validate_gdscript.py` passes (baseline preserved — this task was read-only).

---

## 1. Current-State Summary

A faithful, cleanly-architected **port skeleton** of the Android/Kotlin prototype: ~1,760 lines of GDScript + scenes. Five autoloads (`GameState`, `EventBus`, `Simulation`, `SceneSwitcher`, `Content`) implement a travel → dialogue → disposition loop over a JSON-authored world (7 NPCs, 7 personas, 25 map nodes across 3 acts, 30 scene stubs, 5 crafting recipes, 1 combat-intent library, ~43 KB of data). One act is playable end-to-end in a narrow sense: tap a node, read 4 procedurally-generated dialogue lines, pick canned choices that move disposition numbers, return to map, camp, repeat. Everything past that — combat, crafting, quests, acts 2–3, endgame, audio, real dialogue — is data-without-code or code-without-UI.

### Component inventory

| # | Component | Files | State | Notes |
|---|-----------|-------|-------|-------|
| 1 | App config / project settings | `project.godot` | ⚠ Partial | Mobile renderer + stretch OK; `window/handheld/orientation=5` = **sensor portrait**, wrong for a 1280×720 landscape game (line 16); input map is keyboard/mouse only (lines 24–31) |
| 2 | Game state & save | `scripts/core/game_state.gd` | ⚠ Partial | Full serialize roundtrip (lines 73–146) but **single slot** (`SAVE_PATH` const, line 5), no schema version; `active_vows` (line 18) and journal writes have no producers; `advance_act()` (line 68) never called |
| 3 | Event bus | `scripts/core/event_bus.gd` | ✅ Implemented | 19 signals, consistently used; `quest_objective_updated` (line 18) and `emit_journal_updated` (line 39) are dead — zero callers |
| 4 | Simulation engine | `scripts/core/simulation.gd` | ⚠ Partial | Travel/disposition feedback solid; duel is headless-only; **unseeded RNG** (`pick_random`, lines 115/124) contradicts "deterministic"; delayed dispositions use **wall-clock timers** (lines 79–84) that are lost on save and leak across scenes; omens tracked but mechanically inert (line 106) |
| 5 | Content loader | `scripts/core/content.gd` | ✅ Implemented | Defensive getters; no schema/referential validation (would have caught the act 2/3 data bugs, §3 G4); no `items.json` although inventory exists |
| 6 | Scene switching | `scripts/core/scene_switcher.gd` | ⚠ Partial | Payload stash works; "parchment fade" is a bare 0.15 s timer (line 14) with no visual; no back-stack |
| 7 | Overhead map | `scripts/world/overhead_map.gd`, `scenes/screens/overhead_map.tscn` | ⚠ Partial | Builds act map, tokens, camera focus. **All edges share one `Line2D` polyline → stray lines between disjoint connections** (lines 44–48, 94–103). Shader + `NoiseTexture2D` + `InkWash` rect in the .tscn are dead resources (never referenced / `visible=false`) |
| 8 | Map camera | `scripts/world/map_camera.gd` | ⚠ Partial | WASD + middle/right-drag + wheel only — **no touch pan, no pinch zoom** (lines 17–32) |
| 9 | Node / NPC tokens | `map_node_token.gd/.tscn`, `npc_token.gd/.tscn` | ⚠ Partial | Left-click only (line 43); tooltips are hover-only (line 56) — no touch equivalent; **completed scenes can be re-entered endlessly, farming disposition** (no completed guard, lines 42–54) |
| 10 | Main menu | `main_menu.gd/.tscn` | ✅ Implemented | Continue gating on save presence works (line 8) |
| 11 | Dialogue screen | `dialogue_screen.gd/.tscn` | 🔴 Stub | Procedural line generator (lines 42–53); 6 hard-coded choices (lines 58–65); always ends after 4 picks (line 80); **"Leave" marks the scene completed** (lines 86–88); ignores `maxTurns`, `allowedReveals`, `forbiddenTopics`, `stakes` from scene JSON |
| 12 | Camp screen | `camp_screen.gd/.tscn` | 🔴 Stub | Risk % displayed but never resolved into events; `_calculate_camp_risk` **duplicated** from `simulation.gd:161-170` instead of shared |
| 13 | Party screen | `party_screen.gd/.tscn` | ⚠ Partial | Recruit anyone instantly — no disposition/scene gates; mutates `GameState.party` directly (lines 32–34), bypassing encapsulation |
| 14 | Journal screen | `journal_screen.gd/.tscn` | 🔴 Stub | `journal_entries` is never appended anywhere in code — always renders the empty-state flavor text |
| 15 | Settings screen | `settings_screen.gd/.tscn` | 🔴 Stub | Writes 5 settings that **nothing reads**: no audio exists, no typewriter effect, no motion effects, no cloud AI |
| 16 | Theme / buttons | `assets/ui_theme.tres`, `gothic_button.gd` | ✅ Implemented | Coherent parchment style; `gothic_button.gd` is written but never attached to any scene button |
| 17 | Combat (stance duels) | engine in `simulation.gd:86-151`, data `combat_intents.json` | 🔴 Missing UI | `start_duel()` only reachable from the test helper `resolve_duel()`; **zero consumers of `Content.combat_intents()`**; no duel scene/screen exists |
| 18 | Crafting & inventory | data `crafting_recipes.json`; API `game_state.gd:54` | 🔴 Missing | **Zero consumers of `Content.recipes()`**; `add_inventory()` never called by gameplay; no items data, no inventory/crafting UI |
| 19 | Audio | — | 🔴 Missing | No `AudioStreamPlayer`, no bus layout, no assets; settings toggles are no-ops |
| 20 | Act transitions / endgame | data for acts 2–3 exists | 🔴 Missing | `advance_act()` dead; acts 2–3 unreachable; no Hollow King confrontation, endings, or credits |
| 21 | Quests / vows / lore reveals | signals only | 🔴 Missing | `quest_objective_updated`, `active_vows`, `allowedReveals` all unwired |
| 22 | Tests | `scripts/tests/simulation_tests.gd`, `validate_gdscript.py` | ⚠ Partial | 6 sim smoke tests (good start); validator is **indent-only** (paren check is a no-op `pass`, lines 19–22); no save roundtrip, no content-integrity, no duel determinism tests; no CI |
| 23 | Android export | `export_presets.cfg`, `export_apk.sh` | ⚠ Partial | Debug-only path; default package id/version; no release keystore; keystore path is machine-absolute and patched at export time (line 31, fragile) |

**Data cross-reference audit (verified programmatically):**
- Act 2 scenes reference NPCs `kael`, `seren` — **absent from `npcs.json`** (breaks names, portraits, disposition defaults in act 2).
- Act 3 scenes reference `dara`, `kael`, `rook`, `seren`, `corruption` — **all absent** from `npcs.json`.
- 5 authored scenes are orphaned (on no map): `echo_confrontation`, `elena_recruitment`, `rook_betrayal`, `seren_alliance`, `warden_betrayal`.
- Cross-act map edges exist (`ashen_gate → hollow_approach`, `broken_shore → ashen_throne`) implying intended act chaining, but nothing executes it.
- Recipes reference NPCs `kael`/`seren`/`dara` (missing) and 8 ingredient items with **no item definitions anywhere**; only 5 item icons exist, none matching recipe ids.

---

## 2. Strengths

1. **Clean layered architecture.** Autoload boundaries are respected: UI sends intents (`Simulation.travel_to`, `apply_dialogue_choice`) and observes `EventBus`; it never reaches into sim internals. `EventBus` is used uniformly instead of ad-hoc node references — rare discipline for a prototype.
2. **Data-driven content pipeline.** JSON parity with the original Android assets (`GODOT_PORT.md:61-67`) means narrative content is authorable without touching code — a big asset for the narrative-designer workflow. `Content` getters are defensive (`.get` with defaults, empty-dict fallbacks), so missing data degrades instead of crashing (`dialogue_screen.gd:43-44` survives a missing persona).
3. **Save/load roundtrip with defensive deserialization.** Type-checked `_assign_string_array`, settings `merge`, enum-safe int casts (`game_state.gd:126-146`). The skeleton of a robust save system already exists.
4. **Deterministic ambition & testability.** Seeded RNG for map tiles (`overhead_map.gd:33-34`), pure-function exchange resolution (`simulation.gd:126-139`), sim callable headlessly — proven by 6 passing smoke tests with a dedicated runner scene.
5. **Sane mobile rendering baseline.** `mobile` renderer, `canvas_items/expand` stretch at 1280×720, nearest-neighbor filter suiting the pixel/ink aesthetic, arm64-only build, one-command APK export script.
6. **Consistent conventions.** snake_case throughout, typed variables, docstring headers on every file, private-member underscore prefix, zero TODO/FIXME debt, centralized theme resource, validator-clean (no mixed indentation).

---

## 3. Gap Analysis vs Shipped 2D Android RPG Standards

Severity: **P0** = core-loop blocker, cannot ship · **P1** = major feature missing/broken, shippable only as demo · **P2** = polish/hardening.
Effort: **S** < ½ day · **M** = ½–2 days · **L** > 2 days.

### P0 — Core-loop blockers

**G1. Combat has no UI and is unreachable — P0 · M**
The stance-duel engine exists (`simulation.gd:86-151`) with events defined (`event_bus.gd:12-14`), but no scene, screen, or button ever calls `start_duel()` outside the test helper. The authored `combat_intents.json` (versioned intents, `statBonus`, `resultBands`, `resolveSegments`, disposition-gated `parley`) has **zero consumers**. Combat is one of the three pillars of the design (map / dialogue / duel) and is functionally absent. Additionally omens are tracked but do nothing (`simulation.gd:106`), and duel outcomes carry no consequences (no disposition, gating, or reward on `duel_resolved`).

**G2. Dialogue is a procedural placeholder, not the authored game — P0 · M**
`dialogue_screen.gd` generates lines from `speechPatterns` + a fixed flavor sentence (lines 42–53) and presents the same 6 choices everywhere (lines 58–65). The authored scene data — `stakes`, `maxTurns`, `allowedReveals`, `forbiddenTopics` (30 scenes across 3 acts) — is entirely ignored. Two structural exploits: **"Leave" completes the scene** (lines 86–88), and completed scenes are re-enterable forever, letting players farm disposition to max in one sitting (`map_node_token.gd:42-54` has no completed guard). For a *narrative* RPG this is the difference between a game and a tech demo.

**G3. No act progression or endgame — P0 · L**
`GameState.advance_act()` (line 68) has zero callers; acts 2 and 3 (17 nodes, 20 scenes of authored content) are unreachable in-game. There is no act-transition flow, no Hollow King confrontation, no endings, no credits. The cross-act map edges in the data (`ashen_gate → hollow_approach`, `broken_shore → ashen_throne`) show the intent, but `overhead_map.gd` renders only the current act and `travel_to` has no act concept. A shipped RPG needs a beginning, middle, and end; today it has only a beginning.

**G4. Content referential integrity is broken for acts 2–3 — P0 · S**
Verified by cross-referencing JSON: act 2 scenes cite NPCs `kael`, `seren`; act 3 cites `dara`, `kael`, `rook`, `seren`, `corruption` — none exist in `npcs.json`. Consequences when those acts ship: blank names, missing portraits/tokens, default 0.0 dispositions, no archetype feedback, and missing recipe givers. Also 5 orphan scenes are unreachable, and recipes reference 8 undefined items. The codebase has **no validation** that would catch this — it was found by hand-audit. Fix is small (author the missing NPC entries + items.json); making it *stay* fixed needs a content-integrity test (G13).

### P1 — Major gaps

**G5. Touch input is not actually supported — P1 · M**
Taps work only via Godot's default mouse-emulation. Camera pan is bound to WASD + middle/right-drag (`map_camera.gd:17-32`) — **a finger drag on empty map does nothing**; pinch zoom (`InputEventMagnifyGesture`) is unhandled, and the `map_zoom_*` actions are wheel-only (`project.godot:28-29`). Tooltips are hover-only (`map_node_token.gd:56`). The `ui_back` action is defined (`project.godot:31`) but **no script consumes it** — Android's back button is dead. Map navigation on a phone is currently tap-only with no pan/zoom.

**G6. No safe-area handling; orientation misconfigured — P1 · S**
No use of `DisplayServer.get_display_safe_area()` anywhere: the HUD `TopBar`/`BottomBar` (`overhead_map.tscn:24-99`) will slide under notches and system gesture bars. And `window/handheld/orientation=5` (`project.godot:16`) is `SCREEN_SENSOR_PORTRAIT` in Godot 4's `DisplayServer.ScreenOrientation` enum (0=landscape … 4=sensor landscape) — a landscape-designed 1280×720 game requesting portrait. One-line fixes, but both are ship-blockers for the Play Store build.

**G7. Audio absent; settings are placebo — P1 · M**
No `AudioStreamPlayer`, bus layout, or audio assets exist; `music_enabled`/`sfx_enabled` toggles write to a dictionary nothing reads. Same for `text_speed` (no typewriter effect consumes it), `reduced_motion` (no motion effects exist to reduce), `ai_enabled`. Settings that do nothing erode player trust and draw review complaints.

**G8. Crafting/inventory loop missing — P1 · M**
`crafting_recipes.json` is loaded but has zero consumers; `add_inventory()` (`game_state.gd:54`) is never called by gameplay; there is no `items.json` (recipes reference 8 undefined ingredients), no inventory screen, no crafting UI, no vendor/economy path. The loop "scene → reward → craft → advantage" cannot close.

**G9. Save system below mobile standard — P1 · M**
Single fixed slot (`game_state.gd:5` — `slot_name` is written into the payload but never affects the path); no schema version for migrations; no autosave on `NOTIFICATION_APPLICATION_PAUSED`/`NOTIFICATION_WM_CLOSE_REQUEST` (progress lost when Android backgrounds the app); pending delayed-disposition timers (`simulation.gd:79-84`) silently vanish on save/load. Shipped mobile RPGs all offer slot management + session-safe autosave.

**G10. Journal/quests/vows are hollow — P1 · M**
`journal_entries` is never appended (journal always empty); `quest_objective_updated` has no emitter; `active_vows` never written; camp risk is computed twice (duplicated in `camp_screen.gd:20-28` and `simulation.gd:161-170`) but never resolves into night events; duel wins/losses have no world consequences. The reactivity that justifies the "simulation RPG" pitch doesn't reach the player.

**G11. Party recruitment has no rules — P1 · S**
Any NPC can be recruited instantly from the party screen (`party_screen.gd:31-37`) regardless of disposition or story state, and removal mutates `GameState.party` directly instead of via a `remove_from_party()` API. Undermines the disposition system the whole game is built on.

### P2 — Polish / hardening

**G12. Determinism is violated in practice — P2 · S**
The project description promises a "deterministic NPC simulation" (`project.godot:4`), but duel AI and test resolution use unseeded `pick_random()` (`simulation.gd:115,124`), NPC wander uses global `randf()` (`npc_token.gd:43-44`), and delayed dispositions run on wall-clock timers instead of game turns. Fine for a demo; wrong for replayable seeds, deterministic replays, or trustworthy tests.

**G13. Test coverage is shallow; validator is cosmetic — P2 · S**
6 sim smoke tests only. Missing: save/load roundtrip, content referential integrity (would have caught G4 automatically), duel determinism, scene-gating regressions, and a JSON schema lint. `validate_gdscript.py` checks only mixed indentation — its paren-balance branch is a no-op `pass` (lines 19–22). No CI wiring.

**G14. Map rendering bug: single-polyline connections — P2 · S**
All edges are points of one `Line2D` (`overhead_map.gd:44-48,94-103`), so `Line2D` strokes a continuous path through every node pair, drawing spurious lines across the map between disjoint connections. Fix: one `Line2D` per edge, or `_draw()` with `draw_line`.

**G15. Transition & visual dead-ends — P2 · S**
`SceneSwitcher`'s "fade" is a timer with no fade (`scene_switcher.gd:14`); the ink-wash shader, its `NoiseTexture2D`, and the `InkWash` ColorRect in `overhead_map.tscn` are loaded/declared but never used; `gothic_button.gd` is unattached. Either wire them (they're the game's identity) or delete.

**G16. Export preset not release-ready — P2 · S**
Debug keystore only; no `package/unique_name`, version name/code, or app category set (defaults to `org.godotengine.*`); `gradle_build/min_sdk` blank; keystore path machine-absolute and rewritten by `export_apk.sh`. Needs a release preset before any store submission. arm64-only is an acceptable modern choice — note it excludes pre-2017 devices.

**G17. No onboarding, failure states, or session structure — P2 · M**
No tutorial/first-run guidance; no game-over or defeat flow (duel loss just dumps you back to the overworld, `simulation.gd:151`); no pause menu on the map; no rate/share hooks. Mobile RPG standards expect a guided first session and clear fail/recover loops.

**G18. Localization & accessibility not started — P2 · M**
All strings hardcoded in English (no `tr()`); fixed 18px theme font with no scaling; no colorblind-safe disposition indicators (color-only tints in `npc_token.gd:28-33` and `dialogue_screen.gd:40`); no haptics; no FPS cap (`Engine.max_fps` unset — battery drain on 120 Hz panels).

### Priority summary

| Gap | 1-line fix direction | Severity | Effort |
|-----|----------------------|----------|--------|
| G1 combat UI + consequences | duel screen consuming `combat_intents.json`, omen as spendable resource, outcomes → disposition/gates | P0 | M |
| G2 dialogue system | data-driven engine honoring `maxTurns`/reveals/forbidden topics; choice gating; leave ≠ complete; no re-farm | P0 | M |
| G3 acts + endgame | act-transition flow, Hollow King finale, endings + credits | P0 | L |
| G4 data integrity | author missing NPCs/items; wire orphan scenes; add integrity test | P0 | S |
| G5 touch input | drag-pan + pinch-zoom + tap tooltips + consume `ui_back` | P1 | M |
| G6 safe area + orientation | safe-area margins on HUD; orientation → sensor landscape (4) | P1 | S |
| G7 audio + real settings | audio buses/manager + SFX/music; make every toggle functional | P1 | M |
| G8 crafting/inventory | `items.json`, inventory + crafting screens, loot/vendor sources | P1 | M |
| G9 saves | slots + schema version + autosave on pause + persist pending effects | P1 | M |
| G10 journal/quests/vows | event-driven journal writer, quest state, camp night events | P1 | M |
| G11 recruitment rules | disposition/scene gates + `remove_from_party()` | P1 | S |
| G12 determinism | seeded `RandomNumberGenerator` in GameState; turn-based effect queue | P2 | S |
| G13 tests/CI | roundtrip + integrity + determinism tests; real GDScript parse check | P2 | S |
| G14 map lines | per-edge `Line2D` or `_draw()` | P2 | S |
| G15 dead visuals | real fade transition; wire or delete ink-wash assets | P2 | S |
| G16 export release | release preset, package id, versioning, release keystore | P2 | S |
| G17 onboarding/failure | tutorial overlay, defeat flow, pause menu | P2 | M |
| G18 l10n/a11y | `tr()` extraction, text scaling, non-color cues, FPS cap | P2 | M |

---

## 4. Recommended Technical Direction (top gaps)

### G1 — Combat: make the duel screen the third pillar
- Add `scenes/screens/duel_screen.tscn` + `scripts/ui/duel_screen.gd` driven purely by `EventBus` duel signals (`duel_started/turn/resolved` already exist). Reuse `assets/images/combat/stance_*.png` poses (assets already generated, never loaded).
- Consume `combat_intents.json` as the authored move list: each intent's `statBonus` modifies a seeded roll mapped through `resultBandThresholds` to `critical…criticalFailure` text. This keeps combat text data-driven alongside narrative content.
- Give omens teeth: spend 1 omen to re-roll or upgrade a band one step — one new field in `_duel_state`, no engine rewrite.
- Determinism: replace `pick_random()` with a `RandomNumberGenerator` whose seed lives in `GameState` (serialized), so duels replay identically from a save. AI stance selection should read `combat_intents` weights per opponent archetype instead of uniform random.
- Consequences: on `duel_resolved`, apply disposition delta vs opponent, gate scene completion (`deep_hollow_1`, `hollow_approach`), and route defeat to a defeat flow (G17) instead of silently resetting phase.

### G2 — Dialogue: data-driven scene runner
- Build a `DialogueEngine` (in `Simulation` or a new `scripts/core/dialogue_engine.gd`) that interprets the existing scene schema: `maxTurns` as the turn budget, `allowedReveals`/`forbiddenTopics` as the choice filter, `stakes` as the intro card. Choice availability becomes a function of disposition + reveals + scene, mirroring the `requiresDispositionAbove` pattern already present in `combat_intents.json`.
- Source choice sets from data (extend scene JSON or the narrative-designer's planned `dialogue_trees.json`), not the hard-coded 6 in `dialogue_screen.gd:58-65`.
- Contract fixes: "Leave" ends the scene **incomplete**; completed scenes block re-entry (or re-enter with deltas disabled); completing at/below `maxTurns` with a resolution marks success. Record `revealed_lore` in `GameState` (serialized) to feed journal + gate dialogue.
- Keep the procedural line generator as a *fallback* only, so acts 2–3 remain playable before full trees are authored.

### G3 — Acts & endgame: smallest honest version
- Add `Simulation.advance_act_when_ready()`: trigger when the current act's gate node scene completes (act 1: `hollow_approach`), then `GameState.advance_act(n+1)`, journal entry, act-title card scene, map rebuild. `overhead_map` already parameterizes on `current_act` — the missing piece is the trigger and the transition screen.
- Endgame: at act 3's final node (`heart_of_tide` per data shape), a scripted Hollow King sequence = dialogue scene → duel (G1) → ending picked from data by disposition/party/crafting state (`purification_totem` as the authored "final ritual" key item). Endings as JSON entries (fits narrative-designer's deliverables), then a credits screen.
- Depends on G4 data fixes (kael/seren/dara/rook/corruption) and portrait generation for new NPCs (`scripts/generate_placeholder_sprites.py` already supports id-convention generation).

### G5+G6 — Android input & display: one input layer, applied everywhere
- Centralize gestures in `map_camera.gd`: `InputEventScreenDrag` (1 finger = pan), `InputEventMagnifyGesture` (pinch = zoom at focal point, reusing `_zoom_at`), keep mouse for desktop parity. Add tap-hold or a small "info" affordance for tooltips instead of hover.
- Back button: one global handler (e.g., in `SceneSwitcher` or a small `BackRouter` autoload) consuming `ui_back` with a per-screen back-stack; map screen back → pause menu instead of nothing.
- Safe areas: apply `DisplayServer.get_display_safe_area()` margins to the HUD `CanvasLayer` contents in `overhead_map.tscn` and to full-screen `Control` roots; re-check on resize. Fix `project.godot:16` to orientation 0 or 4 (landscape). Coordinate with ux-designer's ≥48dp touch-target and thumb-zone audit before both teams edit the same scenes.

### G7 — Audio: minimal vertical slice first
- `default_bus_layout.tres` with Music/SFX buses; an `AudioManager` autoload (2–3 `AudioStreamPlayer`s) reading `GameState.settings`; placeholders generated like the sprites; wire UI clicks through the shared button class (finally attach `gothic_button.gd`) and one ambient loop per act. Then settings toggles become real, and `text_speed` should drive a typewriter effect in dialogue to make that toggle real too.

### G8+G9 — Economy & saves
- Author `data/items.json` (id, name, category, rarity, icon) covering the 8 recipe ingredients + 5 existing icons; inventory screen under the camp/party UI; crafting screen consuming `recipes()` with `requiredScene`/`requiredNpc` gates as authored; seed acquisition through scene resolutions and Elena-as-vendor.
- Saves: extend `save_game(slot_name)` to actually use per-slot paths (`user://save_<slot>.json`), add `schema_version` + migration hook, autosave on scene completion/travel and on `NOTIFICATION_APPLICATION_PAUSED`, and serialize the pending delayed-disposition queue (or convert it to turn-based counters per G12 — the cleaner fix).

### Suggested sequencing (dependencies)
1. **G4 data integrity + G13 integrity test** (unblocks everyone; narrative-designer authors the missing NPCs/items).
2. **G2 dialogue engine** (core of the game; consumes narrative-designer's trees).
3. **G1 combat screen** (uses existing engine + data; independent of G2).
4. **G5/G6 Android input/display** (parallel; coordinate with ux-designer).
5. **G3 acts/endgame** (needs G1+G2 in place for the finale).
6. **G8/G9/G10 economy, saves, journal** (fill the loop), then P2 hardening.

---

## 5. Validation Performed (this task was read-only)

- `python3 /home/dev/godot-chimera/scripts/tests/validate_gdscript.py` → **passes** ("Static GDScript check passed.", exit 0). No files were modified by this analysis, so the baseline is unchanged.
- Godot binary unavailable (`.tools/` missing; `run.sh` wrapper dangling; no system `godot`), so `scenes/tests/simulation_tests.tscn` could not be executed here — recommend running it in the team's Godot environment after any change.
- JSON audits above were produced with `python3 -m json.tool` + cross-reference scripts (all 12 data files parse).
