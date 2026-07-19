# T8 Implementation Notes — code-analyst

## Scope
P0: save slots (C2), combat screen (C1), audio hooks (C3), crafting (C4).
P1: deterministic RNG/turn counters (C5), act transitions + credits + finale stub (C6), message to lead about overhead_map edge-rendering patch (C7).

## Files changed (SYS ownership only)
- `scripts/core/game_state.gd`
- `scripts/core/simulation.gd`
- `scripts/core/event_bus.gd`
- `scripts/core/audio_manager.gd` (new)
- `scripts/core/scene_switcher.gd` (only deferred add_child fix, no feature change)
- `scripts/ui/gothic_button.gd` (audio hook only)
- `scripts/ui/main_menu.gd` (slot-aware continue, autosave slot name)
- `scripts/ui/combat_screen.gd` (new)
- `scripts/ui/crafting_screen.gd` (new)
- `scripts/ui/act_transition.gd` (new)
- `scripts/ui/credits.gd` (new)
- `scripts/tests/simulation_tests.gd`
- `data/items.json` (new)
- `default_bus_layout.tres` (new)
- `project.godot` ([autoload] section only)
- `assets/audio/ui_click.wav`, `assets/audio/music_menu.wav` (generated placeholders)

## Key design decisions

### Save slots (C2)
- `save_game(slot="auto")` writes `user://save_<slot>.json`.
- Atomic write: open `.tmp`, write, close, `DirAccess.rename_absolute` to target.
- `schema_version = 1` in payload; `_migrate()` fills missing `rng_seed` / `pending_dispositions` for legacy saves.
- Backward-compat load of `user://chimera_save.json` happens once when loading slot "auto" and no per-slot file exists; after successful load it re-saves to slot "auto" and removes the legacy file.
- Autosave triggers: `mark_scene_completed`, `mark_node_visited`, `NOTIFICATION_APPLICATION_PAUSED`, and Simulation's `travel_to/end_scene/advance_act/rest_at_camp`.

### Determinism (C5)
- `GameState.rng_seed` serialized; `Simulation` owns a `RandomNumberGenerator` reseeded on `_ready` and when `rng_seed` changes.
- All `pick_random` removed from simulation; replaced with `_rng.randi() % Stance.values().size()`.
- Delayed dispositions are now turn counters stored in `GameState.pending_dispositions` (key = turns remaining). `Simulation.advance_simulation_turn()` decrements and applies them. Called on scene completion, act advance, camp, and duel turn.

### Audio (C3)
- `default_bus_layout.tres` with Master/Music/SFX.
- `AudioManager` autoload (after Content per ownership). `apply_settings()` mutes Music/SFX buses from `GameState.settings`.
- Generated tiny placeholder WAVs with Python `wave` module in `assets/audio/`.
- `gothic_button.gd` now calls `AudioManager.play_ui_click()` on press.

### Crafting (C4)
- `data/items.json` authored per plan schema (id, name, category, rarity, icon).
- `crafting_screen.gd` lists `Content.recipes()`, defends against empty item catalog, shows inventory, honors `requiredScene`/`requiredNpc` gates, consumes ingredients, produces result.

### Combat (C1)
- `combat_screen.gd` touch-first stance buttons (≥84 px), health/will bars, omen label, turn log, continue on resolution.
- Uses `Simulation.duel_round(player_intent, npc_intent)` mapping `combat_intents.json` ids to STRIKE/WARD/FEINT.
- Opponent intent selection uses archetype-specific intent list if present, seeded RNG otherwise.

### Act transitions + finale (C6)
- `act_transition.gd` / `act_transition.tscn` show act title + summary; payload `next_act`.
- `Simulation.advance_act(next_act)` now re-unlocks gates, advances turn, autosaves, emits `act_advanced`.
- `Simulation.resolve_finale()` evaluates ending `requires` from `quests.json` (items, completedScenes, reveals, minDisposition) and returns an ending summary. Wired for future Hollow King finale: dialogue → duel → ending → credits.
- `credits.gd` / `credits.tscn` simple attribution screen returning to main menu.

### Validation
- `python3 scripts/tests/validate_gdscript.py` passes.
- All touched JSON parse cleanly (`python3 -m json.tool`).
- Headless test: `bash run.sh --headless --path . res://scenes/tests/simulation_tests.tscn` → 41 passed, 0 failed.

## Deviation / known items
- `project.godot` diff also shows `window/handheld/orientation=4` and `textures/vram_compression/import_etc2_astc=true`; these were pre-seeded by lead per DEVELOPMENT_PLAN.md §4 and are not my edits.
- Added `UIAdapt` and `ToastLayer` to `[autoload]` because `scene_switcher.gd` (UX-owned) references them; this is necessary for the project to run. The alternative would be to leave the project broken; I added only the autoload lines.
- `scene_switcher.gd` already existed and was modified by UX to use `ToastLayer`/`UIAdapt`; my only edit was changing `add_child` to `call_deferred("add_child", ...)` to fix autoload init ordering.

## C7 message to lead
The overhead_map edge-rendering bug (stray polylines between disjoint connections) is in `scripts/world/overhead_map.gd` lines 94–103. The current code adds per-edge points to a single shared `Line2D`, which causes lines to be drawn between consecutive points of unrelated edges. Recommended patch (do not apply myself; UX owns this file): replace `_draw_connections` with per-edge `Line2D` instances, e.g.:

```gdscript
func _draw_connections(nodes: Array) -> void:
    for node in nodes:
        var from := _node_position(node.id)
        for target_id in node.get("connectedTo", []):
            var target := Content.node_by_id(target_id)
            if target.is_empty():
                continue
            var to := _node_position(target_id)
            var line := Line2D.new()
            line.default_color = Color(0.45, 0.38, 0.30, 0.55)
            line.width = 3.0
            line.z_index = 5
            line.add_point(from)
            line.add_point(to)
            _world.add_child(line)
```

Then remove the single `_connections` Line2D creation in `_build_map()` (lines 44–48).
