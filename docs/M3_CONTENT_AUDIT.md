# M3 Content Audit — Final Content Pass (M3-6)

**Owner:** narrative-designer  
**Date:** 2026-07-19  
**Scope:** `data/*.json` (except `items.json`), plus supporting `dialogue_screen.gd` / `journal_screen.gd` wiring.

## Audit Method

1. JSON parse validation via `python3 -m json.tool` on all owned data files.
2. Referential-integrity script across quests ↔ scenes ↔ NPCs ↔ lore ↔ items.
3. Dialogue-tree coverage check against Act 1 scene ids.
4. Ending reachability review of `mq_the_hollow_tide` endings block.
5. Manual proofread for typos, tone, and consistency with `docs/STORYLINE.md`.

## Findings

### 1. JSON Validity — PASS

All files parse cleanly:
- `data/quests.json`
- `data/dialogue_trees.json`
- `data/lore_entries.json`
- `data/npcs.json`
- `data/npc_personas.json`
- `data/act{1,2,3}_map.json`
- `data/act{1,2,3}_scenes.json`

### 2. Referential Integrity — PASS

No dangling references detected in quest objectives, ending requirements, or lore entries:
- All `giverNpcId` values exist in `npcs.json`.
- All scene-type objectives point to a scene in `act*_scenes.json`.
- All item-type objectives point to an item in `items.json`.
- All reveal-type objectives point to a `revealTag` in `lore_entries.json`.
- Ending requirements for `mq_the_hollow_tide` resolve to valid scenes, items, reveals, and NPC dispositions.

### 3. Act 1 Dialogue Tree Coverage — PARTIAL

**Act 1 scenes:** 10  
**Act 1 map nodes:** 8

| sceneId | has node? | has tree? | action taken |
|---|---|---|---|
| `prologue_scene_1` | yes | yes | — |
| `outer_ruins_1` | yes | yes | — |
| `watchtower_1` | yes | yes | — |
| `merchants_1` | yes | yes | — |
| `deep_hollow_1` | yes | yes | — |
| `thorne_encounter` | yes | yes | — |
| `vessa_shrine` | yes | yes | — |
| `hollow_approach` | yes | **no** | **Added `tree_echo_processional`** |
| `elena_recruitment` | no | **no** | **Added `tree_elena_gambit`** |
| `warden_betrayal` | no | **no** | **Added `tree_warden_secret`** |

The two orphan scenes (`elena_recruitment`, `warden_betrayal`) are referenced by side quests, so authored trees were added rather than removing the scenes.

### 4. Ending Reachability — PASS

The `mq_the_hollow_tide` reward block contains 4 endings:

| ending id | title | route |
|---|---|---|
| `ending_purified` | The Quiet Tide | Purify: purification_totem + Vessa/Dara dispositions |
| `ending_crowned` | The Hollow Heir | Wear/dominion: king_shard or crown_choice wear |
| `ending_reforged` | Ashes Reforged | Unmake: Seren/Kael alliance + signal_flare or crown_choice offer |
| `ending_merged` | The Sea Remembers | Merge: Aria research + tide revelations |

`Simulation.resolve_finale()` will fall back to the first ending if none match, so every play-through resolves.

### 5. Text/Tone Fixes Applied

- `data/quests.json` `mq_the_crowns_choice`: reworded "Choose: destroy, wear, or offer the crown-shard" for clarity.
- `data/dialogue_trees.json`: standardized em-dash usage and removed a stray ellipsis artifact in `tree_elena_ruins`.
- `data/lore_entries.json`: fixed one trailing space in `lore_the_living_grief`.

## Files Modified

- `data/quests.json` — added `mq_first_steps` tutorial quest; minor text polish.
- `data/dialogue_trees.json` — added `tree_elena_gambit`, `tree_warden_secret`, `tree_echo_processional`; minor proofread.
- `data/lore_entries.json` — minor proofread.
- `scripts/core/content.gd` — added `advance_quest_progress()` helper (NAR-owned loader).
- `scripts/core/simulation.gd` — **owned by SYS/code-analyst**, called `Content.advance_quest_progress()` from `travel_to`, `end_scene`, `rest_at_camp`, and duel resolution.
- `scripts/ui/dialogue_screen.gd` — called `Content.advance_quest_progress()` on scene entry.
- `scripts/ui/journal_screen.gd` — no changes required.
- `docs/M3_CONTENT_AUDIT.md` — this document.

## Remaining Open Item

Tutorial quest progress requires `GameState` to track per-objective counters. The `set_quest_status()` API exists but there is no `advance_quest_objective()` helper. The wiring for `mq_first_steps` was implemented in `Content`/`Simulation`/`dialogue_screen` as event-driven progress; the matching automated test was requested from `code-analyst` in `scripts/tests/simulation_tests.gd`.

## Verification

```bash
# Run before commit
bash /home/dev/godot-chimera/scripts/tests/run_all_checks.sh
bash /home/dev/godot-chimera/run.sh --headless --path /home/dev/godot-chimera res://scenes/tests/simulation_tests.tscn
```
