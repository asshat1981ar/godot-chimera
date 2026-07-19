# Chimera — Systematic Development Plan

**Owner:** team lead · **Task:** T5 · **Date:** 2026-07-19
**Synthesizes:** `docs/ANALYSIS.md` (T1, gaps G1–G18) · `docs/COMPETITOR_ANALYSIS.md` (T2, takeaways C1–C15) · `docs/STORYLINE.md` (T3, canon + data contracts) · `docs/UX_SPEC.md` (T4, redesigns R1–R10)
**Environment:** Godot 4.2.2 + Android SDK installed; validate with `bash run.sh --headless --path . res://scenes/tests/simulation_tests.tscn` and `bash export_apk.sh <out.apk>`.

---

## 1. Vision & Pillars

**Vision:** Ship *Chimera: Ashes of the Hollow King* as a premium, offline, single-player 2D narrative-simulation RPG for Android where *words are weapons* — every duel is a duel of wills, and the player's power is recognition: holding up the exact memory an NPC lost.

**Pillars** (every story must serve one):
1. **The Echo remembers** — disposition-driven narrative; NPCs react to who the Chimera becomes (T3 canon).
2. **A phone game first** — tap-first controls, 5–30 min sessions, autosave at every natural boundary, Back never loses progress (T2 C1/C2/C5, T4 P0s).
3. **Deterministic, data-authored world** — simulation is seed-deterministic; all narrative content lives in `data/*.json` (T1 G12, T3 contracts).
4. **Ink-and-ash identity** — parchment/gothic UI with deliberate feedback and juice, not desktop-default controls (T4 R4/R8).

**Positioning (from T2):** premium offline narrative RPG, "no ads / no energy / no gacha", Google Play *Offline* label; save integrity is the #1 review driver → crash-safe saves are P0.

---

## 2. Milestones

| Milestone | Theme | Exit criteria |
|---|---|---|
| **M1 — Playable on a phone (this sprint, T6–T8)** | P0 blockers | Game navigable by touch; Back safe; autosave; dialogue trees playable; duel + crafting have UI; audio toggles real; all tests green; APK exports |
| **M2 — The loop sings** | P1 majors | HUD quick-bar; typewriter; toasts/juice; journal lore; act transitions + 3 endings; camp summary; integrity test in CI |
| **M3 — Store-ready** | P2 polish | Coach marks; haptics/badges; empty states; controller support; store listing assets per T2 §6 |

---

## 3. Backlog (user stories)

Priority: **P0** ship-blocker · **P1** major · **P2** polish. Owner: [UX] ux-designer · [NAR] narrative-designer · [SYS] code-analyst.

### Epic A — Mobile foundation (T6)
- **A1 [P0][UX]** *As a player, I can pan and zoom the map with one finger and pinch*, so I never need a mouse. **AC:** `InputEventScreenDrag` pans; `InputEventMagnifyGesture` zooms at focal point; WASD/wheel still work. (R1, G5)
- **A2 [P0][UX]** *As a player, the game renders landscape inside my notch and gesture bar.* **AC:** orientation=4 (done by lead); HUD/root margins read `DisplayServer.get_display_safe_area()` and re-apply on resize. (R2, G6)
- **A3 [P0][UX]** *As a player, Android Back navigates back and never silently quits losing progress.* **AC:** global back router consumes `ui_back`; map-screen Back opens pause/menu; navigation triggers autosave via SYS save API. (R2-§3, GLB-3)
- **A4 [P0][UX]** *As a player, every tappable thing is at least 48dp.* **AC:** theme v2 sets ≥84 logical px min heights (720p baseline) on buttons/choices; map node hit radius ≥42 logical px at min zoom; disabled states visually distinct; no button below floor in any screen. (R4)
- **A5 [P0][UX]** *As a player with an existing save, New Game asks before overwriting.* **AC:** confirm dialog with save summary; cancel preserves save. (R9-§2)
- **A6 [P1][UX]** *As a player, a quick-bar on the map gives me camp/party/journal/settings in ≤2 taps with badges.* **AC:** HUD quick-bar, safe-area aware, right thumb zone; journal badge counts unseen entries (event-driven). (R3)
- **A7 [P1][UX]** *As a player, transitions, toasts and button feedback confirm every action.* **AC:** SceneSwitcher parchment fade is visual; toast layer for autosave/rewards/errors; `gothic_button.gd` attached to primary buttons; honors `reduced_motion`. (R8, GLB-9/13)

### Epic B — Narrative engine & content (T7)
- **B1 [P0][NAR]** *As a player, NPC conversations are authored branching trees, not procedural lines.* **AC:** `scripts/core/dialogue_engine.gd` (plain class, **not** an autoload) plays `data/dialogue_trees.json` per T3 §11 contract; `choiceType` maps to existing `Simulation.apply_dialogue_choice` vocabulary; conditions (`minDisposition`, `completedScenes`, `reveals`) gate choices; dialogue screen renders nodes/choices with ≥48dp targets; scene completion stays engine-owned. (G2, R5)
- **B2 [P0][NAR]** *As a player, quests track what I'm doing and why.* **AC:** `data/quests.json` loads via `Content`; quest states persist via `GameState.set_quest_status` / `quest_states` (pre-seeded by lead); journal screen shows active/completed quests with objectives; orphan scenes from T3 reachable via quest gates. (G11)
- **B3 [P1][NAR]** *As a player, lore entries unlock in my journal as I reveal the world.* **AC:** `data/lore_entries.json` wired: reveal events call `GameState.unlock_lore`; journal lore tab; unread count feeds A6 badge. (G11)
- **B4 [P1][NAR]** *As a player, dialogue has a typewriter effect I can tune.* **AC:** speed from `GameState.settings.text_speed`; tap skips; choice buttons sized per A4; Leave separated from choices. (R5-§1/§2)
- **B5 [P0][NAR]** Content loaders: `Content.quests()`, `Content.quest(id)`, `Content.dialogue_tree(id)`, `Content.dialogue_tree_for(scene_id, npc_id)`, `Content.lore_entries()`, `Content.items()`, `Content.item(id)` per §4 contracts; referential-integrity validation extended into tests (npc/scene/item ids). (G4, G13)

### Epic C — Systems: combat, economy, audio, saves (T8)
- **C1 [P0][SYS]** *As a player, stance duels are a real screen, not a log line.* **AC:** `combat_screen.tscn` + `combat_screen.gd`: strike/ward/feint buttons with intent omens from `combat_intents.json`, wounded poses, turn log, touch-only playable end-to-end; duel outcome feeds scene resolution. (G1, R6)
- **C2 [P0][SYS]** *As a player, I never lose progress.* **AC:** `save_game(slot)` with 3 named slots + autosave slot (`user://save_<slot>.json`); `schema_version` + migration hook; atomic write (tmp + rename); autosave on scene completion, travel, and `NOTIFICATION_APPLICATION_PAUSED`; pending delayed-disposition queue serialized (or converted to turn counters per C5). (G9, T2-C2)
- **C3 [P0][SYS]** *As a player, audio settings actually do something.* **AC:** `default_bus_layout.tres` with Music/SFX buses; `AudioManager` autoload (registered in `project.godot` [autoload]) reads `GameState.settings`; UI click sounds via shared button; one placeholder ambient loop per act. (G7, SET-1..3)
- **C4 [P1][SYS]** *As a player, I can craft from gathered items.* **AC:** `data/items.json` per §4 schema; crafting screen consuming `Content.recipes()` with `requiredScene`/`requiredNpc` gates; inventory view; acquisition hooks in scene resolution. (G8)
- **C5 [P1][SYS]** *As a designer, the sim is deterministic.* **AC:** seeded RNG (no unseeded `pick_random`); delayed dispositions as turn counters, not wall-clock timers; omens mechanically meaningful or removed from UI copy. (G12)
- **C6 [P1][SYS]** *As a player, acts transition and the Hollow King finale picks an ending from my state.* **AC:** `advance_act()` wired to act-gate scenes; transition screen; act-3 finale: dialogue → duel → ending from `quests.json` ending ids by disposition/party/crafting state; credits screen. (G3)
- **C7 [P1][SYS]** *As a developer, map rendering is correct.* **AC:** per-edge `Line2D`s (no stray polylines); dead shader/noise resources removed or wired. (overhead_map gap)

---

## 4. Contracts & ownership (avoid parallel-edit conflicts)

**File ownership this sprint** (edit only what you own):
- **[UX]:** `assets/ui_theme.tres`, `scripts/world/*.gd`, `scenes/world/*.tscn`, `scripts/ui/{main_menu,settings_screen,camp_screen,party_screen,gothic_button}.gd` + their `.tscn`, `scenes/screens/overhead_map.tscn`, `scripts/core/scene_switcher.gd`, new `scripts/ui/ui_adapt.gd`, `scripts/ui/toast_layer.gd`.
- **[NAR]:** `data/*.json` (except `items.json`), `scripts/core/content.gd`, `scripts/ui/{dialogue_screen,journal_screen}.gd` + their `.tscn`, new `scripts/core/dialogue_engine.gd`.
- **[SYS]:** `scripts/core/{game_state,simulation,event_bus}.gd`, `scripts/tests/simulation_tests.gd`, new `data/items.json`, new `scripts/core/audio_manager.gd`, `default_bus_layout.tres`, new `scenes/screens/{combat_screen,crafting_screen,act_transition,credits}.tscn` + scripts, `project.godot` ([autoload] section only — orientation/vram already set by lead).
- **Shared read-only:** everything else. If a change is needed outside your lane, message lead.

**Pre-seeded by lead (done):** `project.godot` orientation=4 + `import_etc2_astc=true`; `GameState.quest_states`, `GameState.unlocked_lore`, `set_quest_status`, `is_quest_active/completed`, `unlock_lore` with serialization.

**Data contracts:** as STORYLINE.md §11 (quests/dialogue_trees/lore). `items.json` (SYS authors, NAR loads): `{ id, name, category ("ingredient"|"key"|"consumable"), rarity ("common"|"rare"|"unique"), icon }` — ids limited to T3 vocabulary (`purified_coral`, `hollow_iron`, `king_shard`, `forge_ember`, `memory_dust`, `glass_flask`, `salt_crystal`, `tide_essence`, `tide_ward`, `echo_blade`, `memory_vial`, `signal_flare`, `purification_totem`).

**Validation gate (all agents, before marking done):**
1. `python3 scripts/tests/validate_gdscript.py` → pass
2. All touched JSON → `python3 -m json.tool` clean
3. `bash run.sh --headless --path . res://scenes/tests/simulation_tests.tscn` → 0 failures (extend, don't weaken)
4. No edits outside your ownership list

---

## 5. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Parallel agents conflict on files | Ownership table above; new screens are new files |
| Dialogue content volume vs sprint | B1 engine first; 4 authored trees from T3 suffice for M1 |
| Audio assets don't exist | Placeholder generation pattern (like sprites); settings truth is the P0, not asset quality |
| `orientation`/`etc2_astc` regressions | Lead-owned lines; T9 re-exports APK |
| Scope creep to M2/M3 | Agents implement P0s fully, P1s only if P0s green |

## 6. Tracing (sources → stories)
G1→C1 · G2→B1 · G3→C6 · G4→B5/T3(done) · G5/G6→A1/A2 · G7→C3 · G8→C4 · G9→C2 · G10→B2/B3 · G11→B2/B3 · G12→C5 · G13→B5 · T2-C1/C2/C5→A3/C2 · T2-C7→A6 · R1→A1 · R2→A2/A3 · R3→A6 · R4→A4 · R5→B1/B4 · R6→C1 · R8→A7 · R9→A5 · R10→C3/B4
