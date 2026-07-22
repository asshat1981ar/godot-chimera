# Chimera: Ashes of the Hollow King — Godot Port
## Project Context Document

---

## Project Overview

**Chimera: Ashes of the Hollow King** is a narrative-simulation RPG originally built for Android, now being ported to **Godot 4.2.2** as a **2.5D overhead exploration game**. The port preserves the original authored JSON data pipeline and deterministic simulation logic while adding a parchment/gothic visual style, overhead map traversal, and a Godot-native UI layer.

- **Target platform:** Android (primary), Desktop (secondary)
- **Engine:** Godot 4.2.2 (arm64, bundled under `.tools/`)
- **Package ID:** `com.chimera.ashesofthehollowking`
- **Version:** `0.1.0-godot-port`
- **Viewport:** 1280×720, stretch mode `canvas_items`, orientation landscape (mode 4)
- **Rendering:** Mobile renderer with ETC2/ASTC VRAM compression

---

## Architecture

### Design Philosophy

The codebase follows a strict **separation of concerns**:

1. **Simulation layer** (`scripts/core/`) — all game-state mutation. UI never writes state directly.
2. **Event bus** (`EventBus`) — decoupled communication. UI observes signals; simulation emits them.
3. **Content layer** (`Content`) — read-only JSON data access. No mutation.
4. **UI layer** (`scripts/ui/`, `scripts/world/`) — reads state, sends intents to simulation, reacts to events.

### Autoload Singletons (Global Nodes)

These are registered as autoloads in `project.godot` and available globally by name:

| Singleton | Script | Role |
|---|---|---|
| `GameState` | `scripts/core/game_state.gd` | Canonical save/load state |
| `EventBus` | `scripts/core/event_bus.gd` | Observable signal bus |
| `Simulation` | `scripts/core/simulation.gd` | Deterministic game logic |
| `Content` | `scripts/core/content.gd` | JSON data loader/lookup |
| `SceneSwitcher` | `scripts/core/scene_switcher.gd` | Scene transition manager |
| `AudioManager` | `scripts/core/audio_manager.gd` | Music/SFX playback |
| `UIAdapt` | `scripts/ui/ui_adapt.gd` | Accessibility/responsive helpers |

### Data Flow

```
User Input
    │
    ▼
UI Script (scripts/ui/ or scripts/world/)
    │  calls Simulation.method() or GameState.method()
    ▼
Simulation (scripts/core/simulation.gd)
    │  mutates GameState, emits EventBus signals
    ▼
GameState (scripts/core/game_state.gd)
    │  emits EventBus.state_changed / specific signals
    ▼
EventBus (scripts/core/event_bus.gd)
    │  broadcasts to all connected listeners
    ▼
UI Scripts / AudioManager / etc. (react to signals)
```

### Scene Graph Structure

```
Root (Godot SceneTree)
├── [Autoloads: GameState, EventBus, Simulation, Content, SceneSwitcher, AudioManager, UIAdapt]
├── _overlay (ColorRect — full-screen parchment fade, owned by SceneSwitcher)
├── _toast (ToastLayer — persistent toast notifications, owned by SceneSwitcher)
└── [Current Scene] — swapped by SceneSwitcher.switch_to()
```

---

## Key Files

### Core Singletons

#### `scripts/core/game_state.gd`
- **The single source of truth** for all mutable game data.
- Key state variables:
  - `current_phase: Phase` — enum (MENU, OVERWORLD, SCENE, CAMP, DUEL, ACT_TRANSITION, SETTINGS)
  - `current_act: int` — 1, 2, or 3
  - `current_node_id: String` — active map node
  - `party: Array[String]` — NPC IDs in party
  - `inventory: Dictionary` — `item_id → quantity`
  - `completed_scenes: Array[String]`
  - `unlocked_nodes: Array[String]`
  - `dispositions: Dictionary` — `npc_id → float [-1.0, 1.0]`
  - `journal_entries: Array[Dictionary]`
  - `active_vows: Array[String]`
  - `quest_states: Dictionary` — `quest_id → {status, objectives}`
  - `unlocked_lore: Array[String]`
  - `rng_seed: int` — deterministic RNG; 0 = derive from unix time at new game
  - `pending_dispositions: Dictionary` — delayed disposition changes
  - `settings: Dictionary` — music, SFX, reduced_motion, ai_enabled, text_speed
- Save path: `user://chimera_save.json`, schema version 1
- Autosaves on `mark_scene_completed()`, `mark_node_visited()`, and `NOTIFICATION_APPLICATION_PAUSED`

#### `scripts/core/event_bus.gd`
- Pure signal declarations + typed `emit_*()` wrapper methods.
- Key signals:
  - `state_changed(key: String, value: Variant)`
  - `scene_entered(scene_id: String)`
  - `disposition_changed(npc_id: String, delta: float, new_value: float)`
  - `dialogue_started(npc_id: String, topic: String)` / `dialogue_line_added` / `dialogue_choice_presented`
  - `duel_started` / `duel_turn` / `duel_resolved`
  - `camp_night_started(risk_level: float)`
  - `journal_updated(entry_id: String)`
  - `inventory_changed(item_id: String, quantity: int)`
  - `quest_objective_updated` / `act_advanced` / `finale_resolved`
  - `ui_request(screen_name: String, payload: Dictionary)`

#### `scripts/core/simulation.gd`
- **All game logic lives here.** UI never mutates `GameState` directly for gameplay events.
- Enums: `Stance` (STRIKE, WARD, FEINT), `DuelPhase` (OPENING, EXCHANGE, RESOLUTION)
- Key methods:
  - `travel_to(node_id)` — validates unlock, marks visited, triggers scene entry
  - `apply_dialogue_choice(npc_id, choice_type)` — maps choice type to disposition delta
  - `_archetype_feedback(npc_id, choice_type)` — archetype-driven delayed consequences
- Disposition deltas by choice type:
  - `defer`/`help`: +0.05 | `empathize`/`vow`: +0.10
  - `threaten`/`demand`: -0.08 | `lie`/`conceal`: -0.03
- Uses `_rng: RandomNumberGenerator` seeded from `GameState.rng_seed`

#### `scripts/core/content.gd`
- Loads all JSON files at startup in `_ready()` → `_load_json()`
- Returns empty arrays/dictionaries gracefully on missing files (never crashes)
- Key lookup methods:
  - `npcs()`, `npc_by_id(id)`, `npc_persona(id)`, `npc_initial_disposition(id)`, `npc_archetype(id)`
  - `node_by_id(id)`, `scene_by_id(id)`, `is_node_default_unlocked(id)`
  - `quests()`, `dialogue_tree_by_id(id)`, `lore_entry_by_id(id)`, `item_by_id(id)`

#### `scripts/core/dialogue_engine.gd`
- `class_name DialogueEngine` — instantiated per dialogue session (not a singleton)
- Manages tree traversal: `start(tree)` → `choose(index)` → signals
- Valid `choiceType` values: `defer`, `help`, `threaten`, `demand`, `empathize`, `vow`, `lie`, `conceal`, `inquire`
- Signals: `node_presented(node)`, `duel_requested(opponent_id)`, `scene_ended(scene_id)`
- Session-local state: `_session_reveals: Array[String]`, `_session_vows: Array[String]`
- Calls `Simulation.apply_dialogue_choice()` and `GameState.adjust_disposition()` on choices

#### `scripts/core/scene_switcher.gd`
- `switch_to(path, payload)` — fade out → change scene → fade in (0.35s duration)
- `switch_to_packed(scene, payload)` — same with a `PackedScene`
- `quit_to_menu()` — saves then returns to main menu
- `toast(text, duration)` — shows persistent toast overlay
- `pending_payload: Dictionary` — passed to incoming scene via `SceneSwitcher.pending_payload`
- Respects `UIAdapt.is_reduced_motion()` (skips tween if true)

#### `scripts/core/audio_manager.gd`
- Manages three audio buses: `Master`, `Music`, `SFX`
- `play_ui_click()` — plays `assets/audio/ui_click.wav`
- `apply_settings()` — reads `GameState.settings` to mute/unmute buses
- Reacts to `EventBus.state_changed("settings", ...)` to reapply settings live

---

## Data Layer

### JSON Data Files (`data/`)

All content is authored as JSON and loaded by `Content` singleton:

| File | Description |
|---|---|
| `npcs.json` | NPC definitions (id, name, archetype, initialDisposition) |
| `npc_personas.json` | Extended persona data keyed by NPC id |
| `act1_map.json` / `act2_map.json` / `act3_map.json` | Map node graphs per act |
| `act1_scenes.json` / `act2_scenes.json` / `act3_scenes.json` | Scene definitions per act |
| `dialogue_trees.json` | Full dialogue tree data (`{version, trees: {}}`) |
| `quests.json` | Quest definitions with objectives |
| `lore_entries.json` | Discoverable lore entries |
| `items.json` | Item definitions (may not exist; handled gracefully) |
| `crafting_recipes.json` | Crafting recipe definitions |
| `combat_intents.json` | Combat intent/stance data |
| `portrait_manifest.json` | Maps NPC ids to portrait asset paths |
| `sprite_manifest.json` | Maps entity ids to sprite asset paths |

### NPC Archetypes
Used by `_archetype_feedback()` in `Simulation`:
- `SHIFTING_THE_BURDEN` — `defer` choice triggers delayed -0.12 disposition after 3 turns
- `ESCALATION` — `threaten`/`demand` triggers escalating consequences

---

## Scenes

### Screen Scenes (`scenes/screens/`)

| Scene | Script | Purpose |
|---|---|---|
| `main_menu.tscn` | `scripts/ui/main_menu.gd` | New Game, Continue, Settings, Quit |
| `overhead_map.tscn` | `scripts/world/overhead_map.gd` | 2.5D act map with node tokens |
| `dialogue_screen.tscn` | `scripts/ui/dialogue_screen.gd` | Portrait + dialogue bubble + disposition bar |
| `camp_screen.tscn` | `scripts/ui/camp_screen.gd` | Rest/camp with risk summary |
| `party_screen.tscn` | `scripts/ui/party_screen.gd` | Recruit/remove companions |
| `journal_screen.tscn` | `scripts/ui/journal_screen.gd` | Completed scenes + lore entries |
| `settings_screen.tscn` | `scripts/ui/settings_screen.gd` | Audio, motion, AI, text speed |
| `combat_screen.tscn` | `scripts/ui/combat_screen.gd` | Stance-duel combat UI |
| `crafting_screen.tscn` | `scripts/ui/crafting_screen.gd` | Item crafting UI |
| `act_transition.tscn` | `scripts/ui/act_transition.gd` | Act transition animation |
| `credits.tscn` | `scripts/ui/credits.gd` | Credits screen |

### World Scenes (`scenes/world/`)

| Scene | Script | Purpose |
|---|---|---|
| `map_node_token.tscn` | `scripts/world/map_node_token.gd` | Clickable map node (active/neutral/completed/blocked/failed/hidden states) |
| `npc_token.tscn` | `scripts/world/npc_token.gd` | Wandering NPC token, tinted by disposition |

### Test Scenes (`scenes/tests/`)
- `simulation_tests.tscn` / `scripts/tests/simulation_tests.gd` — headless test runner

---

## Assets

### Asset Structure

```
assets/
├── audio/
│   ├── music_menu.wav          # Main menu music (looping)
│   └── ui_click.wav            # UI button click SFX
├── fonts/
│   ├── cinzel_decorative.ttf   # Display/heading font — ornate serif, used for titles and headers
│   ├── eb_garamond.ttf         # Body font — readable serif, used for dialogue and UI text
│   └── im_fell_english.ttf     # Accent font — irregular letterforms for journal/lore entries
├── images/
│   ├── combat/                 # Stance sprites (strike/ward/feint × normal/wounded)
│   ├── items/                  # Item icon sprites
│   ├── map/                    # Map node state sprites (active/blocked/completed/failed/hidden/neutral)
│   ├── map_tiles/              # Terrain tiles (ash/parchment/shore/stone/water)
│   ├── npcs/
│   │   ├── portraits/          # NPC portrait images (portrait_<id>.png)
│   │   └── tokens/             # NPC map tokens (token_<id>.png)
│   └── ui/                     # App icon, UI frames, panels, decorative borders
├── shaders/
│   ├── ink_wash.gdshader       # Ink-wash effect for parchment surfaces
│   ├── parchment_bg.gdshader   # Animated parchment background texture variation
│   └── quill_reveal.gdshader   # Text/element reveal wipe simulating quill writing
└── ui_theme.tres               # Shared parchment/gothic Godot Theme resource
```

### Hand-Drawn UI Art Style
The visual style guide for the UI has been formally defined. All UI artwork must conform to the following principles:

#### Core Aesthetic
- **Style:** Hand-drawn ink illustration on aged parchment — evokes illuminated manuscripts, gothic field journals, and woodblock prints.
- **Line work:** Slightly irregular, variable-width ink strokes. Hard edges are avoided; lines taper, wobble faintly, and occasionally double (as in real pen work).
- **Colour palette:** Restricted to warm sepia/ochre parchment backgrounds with dark ink (near-black `#1a120a`) linework. Accent colours: ash grey (`#8a8070`), faded crimson (`#7a2020`), dim gold (`#c8a84b`), pale bone (`#e8dcc8`).
- **Textures:** All panels and backgrounds carry a subtle paper grain/fibrous noise. No flat solid fills.
- **No anti-aliased vector sharpness** — renders should look slightly imperfect as if hand-inked.

#### UI Element Conventions
- **Panels / dialogue boxes:** Drawn as ink-bordered parchment sheets with torn or deckled edges. Border decorations use simple knotwork or thorn motifs at corners.
- **Buttons:** Appear as ink-stamped labels or wax-sealed roundels. Hover/focus state adds a faint ink bleed/spread outward from the border.