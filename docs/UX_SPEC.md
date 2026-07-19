# Chimera Mobile UX Specification (UX_SPEC.md)

**Author:** ux-designer (team godot-chimera) · **Task:** T4 · **Date:** 2026-07-19
**Scope:** UI/UX audit of every shipped screen, the shared theme, and input handling against mobile-first 2D RPG best practices, plus a concrete redesign plan with measurable acceptance criteria.
**Inputs audited:** `project.godot` (display/input/gui), `assets/ui_theme.tres`, all 7 scenes in `scenes/screens/`, all 7 scripts in `scripts/ui/`, `scripts/world/{map_camera,map_node_token,npc_token,overhead_map}.gd`, `scenes/world/*.tscn`, `scripts/core/{game_state,event_bus,scene_switcher,simulation}.gd`, `GODOT_PORT.md`, `export_presets.cfg`.
**Cross-references:** `docs/ANALYSIS.md` (T1, gaps G1–G18), `docs/COMPETITOR_ANALYSIS.md` (T2, UX benchmark table §5).

---

## 1. Audit basis

- **Target device class:** Android phones, 5.8–6.7", 1080×2400 @ ~420 dpi, landscape; secondary: 10" tablets. Base viewport 1280×720, `canvas_items`/`expand` → on the reference phone the visible logical canvas is ≈1600×720 (stretch scale 1.5).
- **Touch is the primary input.** Mouse/keyboard bindings are desktop-debug conveniences, not the product.
- **Benchmarks applied** (from T2 §5 and platform guidance): touch targets ≥48×48dp with ≥8dp separation (hit area may exceed visuals); body text ≥14–16sp and scalable; ≤2 taps to any core task; pinch-zoom + drag-pan camera conventions; immediate layered feedback (visual + haptic); contextual dismissible onboarding; autosave at natural boundaries; settings that are never placebo.
- **Severity scale** (aligned with ANALYSIS.md): **P0** = ship-blocking on mobile hardware · **P1** = major UX defect, demo-only quality · **P2** = polish/hardening.
- **dp→logical math used throughout:** on the reference device, 1dp = 1.75 logical px, so **48dp ≈ 84 logical px, 8dp gap ≈ 14 logical px, 16sp ≈ 28 logical px** (full derivation in Appendix A).

## 2. Executive summary

The port is architecturally clean (EventBus, SceneSwitcher, sim-authoritative) but the UX layer is still a **desktop demo**: it renders correctly at 1280×720 and works with a mouse, yet on an actual Android phone the core loop is unplayable-to-frustrating. Five findings dominate:

1. **The map cannot be navigated by touch (P0).** Pan is bound to WASD + middle/right-mouse drag; a finger drag on empty map does nothing. Pinch zoom is unhandled. Taps only work through Godot's mouse-emulation fallback. (`map_camera.gd:17–32`, `project.godot:24–30`)
2. **Display configuration is wrong for a landscape game (P0).** `window/handheld/orientation=5` is `SCREEN_SENSOR_PORTRAIT` in Godot 4's enum — the 1280×720 game is locked toward portrait. Zero safe-area handling: HUD bars slide under notches and gesture bars. (`project.godot:16`; no `DisplayServer` call anywhere)
3. **The Android Back button quits the app without saving (P0).** `ui_back` is defined but consumed by no script; with `quit_on_go_back` at its default, Back exits from any screen and discards progress since the last manual save. (`project.godot:31`; no handler in any script)
4. **Every touch target and most text is below the mobile floor (P0/P1).** All buttons are theme-default ≈30 logical px tall (≈17dp on a 420dpi phone); map node hit radius is 24 world px (≈27dp diameter at zoom 1.0, ≈14dp at min zoom); body text 18px ≈ 10sp; node labels 14px ≈ 8sp. No `custom_minimum_size` exists on any button in any screen.
5. **Settings are placebo and feedback is absent (P1).** Music/SFX toggles drive no audio; `text_speed` has no consumer (no typewriter); `reduced_motion` is read by nothing; no tweens exist in the codebase; the SceneSwitcher "fade" is a bare 0.15s timer; `gothic_button.gd` is attached to zero buttons; no toasts; no onboarding; **New Game silently overwrites an existing save.**

The redesign plan in §6 (R1–R10) converts these into spec'd, acceptance-tested work items, phased P0→P2 in §8.

---

## 3. Global (cross-cutting) audit

| ID | Sev | Issue | Evidence | Recommendation |
|----|-----|-------|----------|----------------|
| GLB-1 | P0 | No touch pan: drag requires middle/right mouse or WASD; finger drag on empty map is dead | `map_camera.gd:17–32`, `project.godot:24–27` | R1: screen-drag panning |
| GLB-2 | P0 | No pinch zoom (`InputEventMagnifyGesture` unhandled); zoom is wheel-only | `map_camera.gd:18–22`, `project.godot:28–29` | R1: pinch zoom anchored at centroid |
| GLB-3 | P0 | Android Back quits app unsaved; `ui_back` has zero consumers; no back-stack | `project.godot:31`; no `is_action("ui_back")` anywhere | R2: global back handler + save-on-exit |
| GLB-4 | P0 | `orientation=5` = SCREEN_SENSOR_PORTRAIT for a landscape game | `project.godot:16` (cross-ref G6) | Set to 4 (`SCREEN_SENSOR_LANDSCAPE`) |
| GLB-5 | P1 | No safe-area insets; HUD TopBar/BottomBar sit under notch/gesture bar | no `DisplayServer.get_display_safe_area()` anywhere; `overhead_map.tscn:24–99` | R2: safe-area margin system |
| GLB-6 | P0 | All buttons ≈30 logical px tall (≈17dp); no min sizes anywhere | `ui_theme.tres` (no size constants); no `custom_minimum_size` on any Button in any .tscn | R4: 48dp floor + themed min sizes |
| GLB-7 | P1 | Type floor too small for phones: body 18px ≈ 10sp, labels 14px ≈ 8sp; no text-size setting | `ui_theme.tres:62,72`; `map_node_token.tscn:23` | R4: type scale + text-size setting |
| GLB-8 | P1 | Placebo settings: music/SFX (no audio backend), `text_speed` (no typewriter), `reduced_motion` (zero consumers) | `settings_screen.gd:22–36`; grep shows no readers outside settings | R10: wire or honestly disable |
| GLB-9 | P1 | No feedback layer: zero Tweens in codebase; SceneSwitcher "fade" is a 0.15s timer with no visual; `gothic_button.gd` attached to 0 buttons; no haptics | `scene_switcher.gd:14` (cross-ref G15); all screens use plain `Button`/`Button.new()` | R8: transitions, toasts, button juice |
| GLB-10 | P1 | No onboarding/first-run experience; map opens with only "Select a node to travel." | `overhead_map.tscn:67` (cross-ref G17) | R7: coach marks |
| GLB-11 | P1 | New Game overwrites existing save with no confirmation | `main_menu.gd:11–13` | R9: destructive-action confirm |
| GLB-12 | P2 | Color-only state encoding (locked=gray, completed=green tint, disposition red/green) — colorblind-unsafe, subtle over parchment | `map_node_token.gd:31–33`, `dialogue_screen.gd:40`, `npc_token.gd:28–33` (cross-ref G18) | R4/R5: icon+text+color tri-encoding |
| GLB-13 | P2 | No toast/inline error system; locked-node feedback is text in a corner panel | `overhead_map.gd:132–137` | R8: toast system on EventBus |
| GLB-14 | P2 | Disabled button style is `StyleBoxEmpty` → frameless invisible buttons; main_menu hand-hacks alpha | `ui_theme.tres:66`, `main_menu.gd:9` | R4: themed disabled state |
| GLB-15 | P2 | Inconsistent exit affordances: "Back" vs "Back to Map" vs "Main Menu"; no hardware-back parity | `journal_screen.tscn:48`, `party_screen.tscn:64`, `settings_screen.tscn:68`, `camp_screen.tscn:69` | R2: one back pattern, everywhere |
| GLB-16 | P2 | All strings hardcoded, no `tr()`; no UI-scale setting; no FPS cap (battery on 120Hz panels) | all scripts (cross-ref G18) | R10 + future localization pass |
| GLB-17 | P2 | No pause/menu on map except "Menu"→main menu; no autosave on app background (`NOTIFICATION_APPLICATION_PAUSED` unhandled) | `overhead_map.gd:149–151` | R2: lifecycle save; R3: gear entry |


---

## 4. Per-screen audit

### 4.1 Main Menu (`main_menu.tscn` / `main_menu.gd`)

| ID | Sev | Issue | Evidence | Fix spec |
|----|-----|-------|----------|----------|
| MM-1 | P0 | 4 menu buttons ≈30px tall (≈17dp) in a 320px column | `main_menu.tscn:50–64` | R4 |
| MM-2 | P1 | New Game wipes existing save, no confirm | `main_menu.gd:11–13` | R9 |
| MM-3 | P2 | Quit button on Android is non-standard (and saves silently); should hide on mobile | `main_menu.gd:22–24` | R9 |
| MM-4 | P2 | Disabled Continue = frameless text + ad-hoc 0.5 alpha | `main_menu.gd:8–9`, theme `StyleBoxEmpty` | R4 |
| MM-5 | P2 | No press feedback/juice; `gothic_button.gd` unused | `main_menu.tscn` plain Buttons | R8 |
| MM-6 | P2 | No version string, no first-run detection entry point, title is plain text (no logo lockup) | `main_menu.tscn:34–44` | R7/R9 polish |
| MM-7 | P2 | Column is center-screen — fine for reach, but no safe-area padding on extreme aspect ratios | `main_menu.tscn:19–31` | R2 |

### 4.2 Overhead Map + HUD (`overhead_map.tscn`, `overhead_map.gd`, `map_camera.gd`, `map_node_token.*`, `npc_token.*`)

| ID | Sev | Issue | Evidence | Fix spec |
|----|-----|-------|----------|----------|
| MAP-1 | P0 | Finger drag does not pan; map is static on phones | `map_camera.gd:17–32` | R1 |
| MAP-2 | P0 | No pinch zoom | `map_camera.gd:18–22` | R1 |
| MAP-3 | P0 | Node hit radius 24 world px → ≈27dp at zoom 1.0, ≈14dp at zoom 0.5; far below 48dp | `map_node_token.tscn:6` | R1 (screen-space picking) |
| MAP-4 | P1 | First tap immediately travels (state change on a 27dp target); no select→confirm, mis-taps commit | `map_node_token.gd:42–54` | R1 (tap-to-select, tap-to-travel) |
| MAP-5 | P1 | Tooltips are hover-only; no long-press touch equivalent | `map_node_token.gd:56–59` | R1 |
| MAP-6 | P1 | BottomBar: 4 text buttons ≈30px tall, centered in the two-thumb dead zone | `overhead_map.tscn:71–99` | R3 (quick-bar) |
| MAP-7 | P1 | No HUD quick-bar / objective / status: TopBar burns 48px on "Act 1" only; no settings access; no journal badge | `overhead_map.tscn:24–37` | R3 |
| MAP-8 | P1 | NodeInfo panel (280×160) parked in the right-thumb zone and doubles as the locked-node error surface | `overhead_map.tscn:39–69`, `overhead_map.gd:136–137` | R3 + R8 toasts |
| MAP-9 | P1 | No safe-area margins on TopBar/BottomBar | `overhead_map.tscn:24–99` | R2 |
| MAP-10 | P2 | Node labels 14px ≈ 8sp, unreadable on phones; no zoom-based label scaling | `map_node_token.tscn:23` | R4 |
| MAP-11 | P2 | Locked-node feedback = plain text in corner panel; no token pulse/shake/toast | `overhead_map.gd:136–137` | R8 |
| MAP-12 | P2 | Completed scenes re-enterable → confusion + disposition farming | `map_node_token.gd:42–54` (cross-ref G2) | T7 design; UX: completed-state badge + "revisit" copy |
| MAP-13 | P2 | Camera `focus_on` snaps zoom to 1.0 every visit; lerp smoothing and NPC wander ignore `reduced_motion` | `map_camera.gd:48–50`, `npc_token.gd:35–45` | R10 |
| MAP-14 | P2 | All edges drawn as ONE Line2D polyline → spurious lines between disjoint nodes (visual noise) | `overhead_map.gd:44–48,94–103` (cross-ref G14) | T6 map fix |
| MAP-15 | P2 | No first-entry guidance ("Select a node to travel." is the whole tutorial) | `overhead_map.tscn:67` | R7 |


### 4.3 Dialogue (`dialogue_screen.tscn` / `dialogue_screen.gd`)

| ID | Sev | Issue | Evidence | Fix spec |
|----|-----|-------|----------|----------|
| DLG-1 | P0 | 6 choice buttons + Leave ≈30px tall each, stacked in a VBox with no ScrollContainer → overflow + mis-tap risk on phones | `dialogue_screen.gd:55–74`, `dialogue_screen.tscn:83–85` | R5 |
| DLG-2 | P1 | `text_speed` setting not honored: text renders instantly; no typewriter | `dialogue_screen.gd:46` vs `game_state.gd:24` | R5 |
| DLG-3 | P1 | Disposition changes silently — bar value snaps, no delta indicator, tween, or haptic; the game's differentiator is invisible | `dialogue_screen.gd:37–40,76–84` | R5 |
| DLG-4 | P1 | Same 6 generic choices on every line of every NPC (choice overload, no authored context, no icons/type hints) | `dialogue_screen.gd:58–65` (cross-ref G2) | R5 container + T7 content |
| DLG-5 | P1 | "Leave" mixed into the choice list → accidental scene exits; also silently completes the scene | `dialogue_screen.gd:71–74,86–88` | R5 (separate + confirm) |
| DLG-6 | P1 | Disposition ProgressBar unthemed (default Godot look), no band labels, red/green color-only meaning | `dialogue_screen.tscn:58–61`, `dialogue_screen.gd:40` | R4/R5 |
| DLG-7 | P2 | Line length ≈100+ chars at 18px in a ~900px box; fatiguing to read | `dialogue_screen.tscn:77–81` | R5 (max-width + type scale) |
| DLG-8 | P2 | No backlog/history, no tap-to-complete, no advance indicator (▼), no auto mode | `dialogue_screen.gd` (absent) | R5 |
| DLG-9 | P2 | Hardware Back does nothing here (should = Leave-with-confirm); 24px fixed margins ignore safe area | `dialogue_screen.tscn:24–27` | R2 |
| DLG-10 | P2 | Missing portrait → silently blank panel; no fallback art path logging | `dialogue_screen.gd:29–32` | R9 (fallback state) |
| DLG-11 | P2 | Scene auto-ends after 4 choices regardless of player intent | `dialogue_screen.gd:80–83` (design, cross-ref G2) | T7; UX: show turn pips "2 of 4" |

### 4.4 Camp (`camp_screen.tscn` / `camp_screen.gd`)

| ID | Sev | Issue | Evidence | Fix spec |
|----|-----|-------|----------|----------|
| CAMP-1 | P1 | Continue / Main Menu buttons ≈30px tall | `camp_screen.tscn:63–69` | R4 |
| CAMP-2 | P1 | "Night risk: N%" is a bare number — no explanation, drivers, mitigation, or iconography; nothing to decide or do | `camp_screen.gd:9–10,20–28` (cross-ref G10) | R3-style summary card + T8 hooks |
| CAMP-3 | P2 | Party rows show raw floats ("disposition 0.42") — dev-facing numbers | `camp_screen.gd:15` | R5 band labels |
| CAMP-4 | P2 | "Main Menu" sits directly under "Continue" — mis-tap adjacency (autosave mitigates) | `camp_screen.tscn:63–69` | R9 spacing/ghost style |
| CAMP-5 | P2 | No empty-party state ("You rest alone…"), no ambiance/juice for a rest beat | `camp_screen.gd:11–18` | R9 |
| CAMP-6 | P2 | Log is a fixed sentence; no actual night-event resolution surface | `camp_screen.gd:18` (cross-ref G10) | T8; UX: log list spec in R9 |

### 4.5 Party (`party_screen.tscn` / `party_screen.gd`)

| ID | Sev | Issue | Evidence | Fix spec |
|----|-----|-------|----------|----------|
| PTY-1 | P1 | Recruit/Remove buttons ≈30px tall in dense rows | `party_screen.gd:21–25` | R4 |
| PTY-2 | P1 | Raw disposition floats ("%.2f") in player-facing text; no portraits, roles, or bars | `party_screen.gd:18` | R5 band labels + row cards |
| PTY-3 | P2 | Disabled FACTION_LEADER button gives no reason | `party_screen.gd:23` | R9 (hint text) |
| PTY-4 | P2 | Remove is instant and irreversible — no confirm or undo | `party_screen.gd:31–37` | R9 (undo toast) |
| PTY-5 | P2 | No empty states for either list; no party-size limit display | `party_screen.gd:10–29` | R9 |
| PTY-6 | P2 | Two half-height scroll areas + no safe-area margins; cramped on phones | `party_screen.tscn:42–60` | R2/R4 |

### 4.6 Journal (`journal_screen.tscn` / `journal_screen.gd`)

| ID | Sev | Issue | Evidence | Fix spec |
|----|-----|-------|----------|----------|
| JRN-1 | P2 | "Completed scenes: id1, id2…" dumps raw scene IDs — dev text shipped to players | `journal_screen.gd:16–19` | R9 |
| JRN-2 | P2 | Entries are flat labels — no sections (Acts/Vows/Scenes), timestamps, or unread markers; journal signals are dead (`journal_updated` never emitted) | `journal_screen.gd:11–15` (cross-ref G10) | T7 + R3 badge |
| JRN-3 | P2 | Empty state exists and is flavorful — the one good pattern in the build; extend it to other screens | `journal_screen.gd:20–23` | R9 generalize |
| JRN-4 | P2 | No hardware-back handling; 18px body text | `journal_screen.gd:25–26` | R2/R4 |

### 4.7 Settings (`settings_screen.tscn` / `settings_screen.gd`)

| ID | Sev | Issue | Evidence | Fix spec |
|----|-----|-------|----------|----------|
| SET-1 | P1 | Music/SFX **checkboxes** (not even sliders) control no audio — dishonest UI | `settings_screen.gd:22–27` (cross-ref G7) | R10 |
| SET-2 | P1 | Reduced motion honored by 0 call sites (transitions, camera, wander, hover-scale all ungated) | grep `reduced_motion` → only settings + game_state | R10 |
| SET-3 | P1 | Text-speed slider consumed by nothing; mapping is inverted/cryptic (10–50 → `1/x`) | `settings_screen.gd:16,34–36` | R5 typewriter + R10 |
| SET-4 | P1 | Default-theme CheckBox/HSlider: ≈20px checks and small grabber — untouchable and visually clashing with parchment | `settings_screen.tscn:40–64` | R4/R10 |
| SET-5 | P1 | No accessibility section: text size, high-contrast ink, screen-shake, haptics all absent | `settings_screen.tscn` (cross-ref G18) | R10 |
| SET-6 | P2 | Changes save only on Back press — kill app = lost settings | `settings_screen.gd:38–40` | R10 write-through |
| SET-7 | P2 | Back always returns to main menu; no return-to-source (will break when settings opens from map gear) | `settings_screen.gd:39` | R2 nav model |
| SET-8 | P2 | No reset-save, credits/about, or version display | `settings_screen.tscn` | R10 |


---

## 5. Target UX vision — Chimera Mobile Design Principles

Chimera is a slow-burn, text-forward gothic RPG played in 10–20 minute sessions, one or two thumbs, often one-handed on a commute. The UI must feel like **annotating a map by lamplight**: calm, legible, forgiving, and reactive. Seven principles govern every screen decision:

1. **Thumb-first, glanceable.** 90% of a session is drivable with one thumb. Primary actions live in the bottom-third thumb arcs; the horizontal center of a landscape phone is a reach dead-zone reserved for content, not controls.
2. **The 48dp floor.** No interactive element — button, token, checkbox, slider grabber — presents a hit area below 48×48dp with ≥8dp separation. Hit areas may exceed visuals; visuals may stay delicate, targets may not.
3. **Ink and parchment, never mud.** The gothic identity stays, but body text holds ≥4.5:1 contrast against its worst-case background, and no state is ever encoded by color alone — always color + icon/shape + text.
4. **Every touch answers.** Within 100ms of any input the game visibly acknowledges it (press state, pulse, toast, haptic). There are no silent state changes and no placebo controls — a setting that does nothing is either wired or visibly marked as forthcoming.
5. **Respect the device.** Landscape lock, safe-area insets, hardware Back with a predictable back model, save-on-pause, battery-aware frame pacing. The OS is a partner, not an afterthought.
6. **Teach in context, once.** Onboarding appears at the moment of first need, is dismissible forever, never blocks input, and can be replayed from settings. No desktop vocabulary ("click", "WASD") ever appears on a touch device.
7. **Drama belongs to the fiction, not the chrome.** Juice (tweens, shakes, typewriter) heightens narrative beats; it never slows navigation, and `reduced_motion` removes it globally without removing information.


---

## 6. Redesign specifications

Each spec: **Goal → Spec → Acceptance criteria** (measurable, testable). Issue IDs in parentheses are resolved by that spec.

### R1 — Touch-first map controls (GLB-1/2, MAP-1/2/3/4/5/11)

**Goal:** the map is fully navigable with one finger, with forgiving targeting and zero accidental travel.

**Spec:**
1. **Drag pan:** `InputEventScreenDrag` (and emulated left-mouse drag on desktop) pans the camera; 1:1 world tracking divided by zoom; keep WASD + middle-drag for desktop debug.
2. **Pinch zoom:** `InputEventMagnifyGesture` multiplies zoom by the gesture factor, clamped to existing 0.5–2.5, anchored at the gesture centroid. Double-tap zooms one step (1.0 → 1.5 → 2.0 → back) centered on the tap. Optional **edge-pan** toggle in settings (default off; see R10).
3. **Tap = select, second tap = travel.** A tap (≤300ms, ≤16dp travel) picks the nearest node whose center is within **48dp screen distance** of the tap (screen-space picking replaces the fixed 24px collision radius; hit area scales with zoom so it never drops below 48dp). Selection shows a pulse ring + the node card (R3). Tapping the selected node again confirms travel. Tapping empty ground deselects. Travel is never committed by a first tap.
4. **Long-press (≥500ms)** on a node opens a tooltip callout above the token (name, type, state, one-line hook); dismissed on release/tap-away. Replaces hover-only tooltips.
5. **Locked-node tap:** toast "The path to {name} is sealed" + a short shake of the token (color pulse instead when `reduced_motion` is on). Completed nodes get a ✓ badge and "Revisit" copy instead of silent re-entry.
6. Camera smoothing lerps only when `reduced_motion` is off; otherwise position snaps.

**Acceptance criteria:**
- A1: On an Android build, single-finger drag pans with no perceivable lag (>1 frame) or jump (>8dp) at 60fps; pan works at all zoom levels.
- A2: Pinch zoom tracks continuously through the gesture within the 0.5–2.5 clamps; the world point under the gesture centroid stays within 24dp of its start position.
- A3: Scripted 20-tap pass over all act-1 nodes at zoom 0.75/1.0/1.5: 100% of taps within 48dp of a node center select that node; 0 unintended `travel_to` calls on first taps.
- A4: Second tap on the selected node is the only touch path that calls `Simulation.travel_to`; long-press never travels.
- A5: Locked-node tap produces toast + shake ≤100ms after release; with `reduced_motion=true` the shake is a static color pulse.
- A6: Desktop regression: WASD pan, wheel zoom, and click-select still function.


### R2 — Safe areas, orientation, and back/navigation model (GLB-3/4/5/15/17, MAP-9, DLG-9, SET-7)

**Goal:** the game behaves like a native Android citizen: correct rotation, no UI under cutouts, predictable Back.

**Spec:**
1. `project.godot`: `window/handheld/orientation=4` (`SCREEN_SENSOR_LANDSCAPE`).
2. **Safe-area system:** a `UIAdapt` helper (autoload or static class, following existing conventions) that on `_ready` and `NOTIFICATION_WM_SIZE_CHANGED` reads `DisplayServer.get_display_safe_area()`, converts insets to logical px via the root's stretch transform, and applies them as margin overrides to registered full-screen containers (HUD TopBar/quick-bar, every screen's root container). Minimum padding 16dp even on notch-free devices.
3. **Back model:** one global handler consuming `ui_back` (Escape/Android Back) via `_unhandled_input`: sub-screens → return to map; map → open pause/menu; main menu → quit confirm. Every back navigation calls `GameState.save_game()` first. Dialogue/camp Back follows the same path as their on-screen Leave/Continue.
4. **Lifecycle save:** autosave on `NOTIFICATION_APPLICATION_PAUSED`.
5. Settings "Back" returns to the screen that opened it (return path stashed in the SceneSwitcher payload).

**Acceptance criteria:**
- A1: App launches and stays landscape (both rotations) on device/emulator; never rotates to portrait.
- A2: On a notched emulator profile (Pixel 6 Pro API 34) in landscape: zero interactive pixels inside the display cutout or gesture-bar regions at 16:9, 18:9, 20:9 (screenshot-verified).
- A3: Back on every screen moves exactly one level up the documented hierarchy and saves (save-file mtime changes); no path exits the app without a confirm.
- A4: Background + relaunch at any point restores exact prior state (node, party, journal).
- A5: Settings opened from the map returns to the map; from the menu returns to the menu.

### R3 — HUD quick-bar and map chrome (MAP-6/7/8, GLB-17)

**Goal:** one-thumb access to everything, a map free of clutter, glanceable state.

**Spec — HUD layout (landscape; ≈1600×720 logical on reference device):**

```
┌──────────────────────────────────────────────────────────────┐
│ TopBar (safe-area padded, 56dp): Act 1 · {node} │ objective │ ⚙ │
│                                                              │
│                  (map canvas, clutter-free)                  │
│                                           ┌─ node card ────┐ │
│                                           │ name · state   │ │
│  [+]                                      │ hook  [Travel] │ │
│  [−]  (bottom-left col, 48dp)             └────────────────┘ │
│ [● current node]                        [Camp][Party][Jrnl•2][Menu] │
└──────────────────────────────────────────────────────────────┘
```

1. **Quick-bar (bottom-right, right-thumb arc):** Camp / Party / Journal / Menu, ≥56dp tall, icon + label, ≥8dp separation. Journal carries an unread badge fed by `journal_updated`; clears on open.
2. **TopBar:** left "Act N · {current node}"; center objective line (from `quest_objective_updated`); right ⚙ settings gear (48dp, return-to-map).
3. **Node card** (replaces corner NodeInfo panel): bottom-center-left, collapsible; name, state chip (Open/Sealed/Done ✓), one-line hook, explicit **Travel** button (56dp) as an alternative to tap-again.
4. **Zoom +/− buttons** bottom-left (48dp, 0.25 steps); current-node chip above them (tap → `focus_on` current node).
5. No other persistent chrome on the canvas; dead ink-wash resources wired as menu backdrop or removed (G15).

**Acceptance criteria:**
- A1: Quick-bar buttons ≥56dp tall on the reference device; all four fire with one right-thumb tap without hand repositioning.
- A2: Camp/Party/Journal in 1 tap from map; Settings ≤2 taps; every return is 1 Back press.
- A3: Journal badge increments on new entries while on the map and clears when the journal opens.
- A4: Objective text updates ≤500ms after `quest_objective_updated`.
- A5: Node card appears ≤100ms after selection; Travel button works; no overlap with quick-bar at 16:9 and 20:9.
- A6: Map canvas carries no persistent UI besides TopBar, quick-bar, zoom controls, node card.


### R4 — Theme v2: touch targets, type scale, states (GLB-6/7/12/14, MM-1/4, CAMP-1, PTY-1, SET-4, MAP-10)

**Goal:** a parchment theme that is touch-legal and phone-legible by construction, not by per-screen patching.

**Spec:**
1. **48dp floor, by construction.** Add a `dp(value)` helper (in UIAdapt, R2) converting Android dp → logical px from actual screen DPI and stretch scale. Every interactive control gets its `custom_minimum_size` set at runtime: primary buttons ≥56dp tall, secondary ≥48dp, icon buttons ≥48dp square, ≥8dp separation. Scene baselines (desktop floor): 56 logical px primary, 48 secondary.
2. **Theme states:** replace `StyleBoxEmpty` disabled with a real `StyleBoxFlat` (dimmed bg + border, 55% font alpha); add `font_disabled_color`; keep hover for desktop, and add a distinct focus ring (2px accent outline) for controller/keyboard.
3. **Type scale (logical px @720p baseline):** Display 44 (titles), Section 30, Body 24, Caption/Label 20, Micro 16. Applied via theme overrides; node labels 20 with zoom-aware visibility (hide below zoom 0.75 unless selected).
4. **Contrast:** raise Button normal bg alpha 0.75→0.92 and Panel alpha 0.92→0.95; verify body font `(0.88,0.85,0.79)` on panel `(0.10,0.08,0.07)` ≈ 10:1, and button font on button bg ≥ 4.5:1 after the alpha change.
5. **Themed CheckBox/HSlider/ProgressBar:** 48dp row heights, 24dp check icons, 28dp grabber, parchment-styled ProgressBar (fills for disposition/resolve), so no default-Godot chrome survives.
6. **Text-size setting** (Small/Standard/Large = ×0.9/1.0/1.2) applied live by scaling theme font sizes; layouts must not clip at Large.

**Acceptance criteria:**
- A1: Automated scene crawl (test script): 100% of Buttons/CheckBoxes/Sliders in shipped scenes resolve to ≥48dp on the 420dpi reference device; no two interactive controls closer than 8dp.
- A2: Body text ≥24 logical px (≈14sp) everywhere except Micro labels ≥16 (≈9sp, allowed only on map tokens); measured from the built theme.
- A3: Computed contrast of all theme font/background pairs ≥4.5:1.
- A4: Disabled buttons render with frame + ≤60% opacity in every screen (screenshot diff vs. enabled); zero ad-hoc alpha hacks remain in scripts (grep `modulate.a` → none).
- A5: Text-size Large renders settings, dialogue, and HUD with no clipped/overlapping labels (manual pass at 3 sizes).

### R5 — Dialogue screen v2 (DLG-1..11, CAMP-3, PTY-2)

**Goal:** the disposition conversation — Chimera's differentiator — becomes the best-feeling screen in the game.

**Spec:**
1. **Layout:** left column (320px, safe-area padded): portrait with frame, name plate, **disposition meter** showing band label + icon (Hostile/Cold/Neutral/Warm/Sworn; icon + color, never color alone) and numeric value on long-press. Right: text panel, max line width ~640 logical (≤75 chars), then the choices column.
2. **Choices:** full-width buttons ≥56dp tall in a ScrollContainer; max 4 visible before scroll (with fade indicator); authored choices from T7 data replace the generic 6 (container supports type icons + gated-choice lock hints). **Leave** moves out of the list: ghost-styled, bottom-left, requires a second confirming tap within 3s ("Tap again to leave") and never completes the scene (G2).
3. **Typewriter:** characters reveal at `1/text_speed` chars/sec using the existing setting; tap on the text box completes the line instantly; a ▼ indicator appears when the line is complete; `reduced_motion` → instant full line, no indicator animation.
4. **Disposition feedback:** on `disposition_changed`, the meter tweens to the new value and a signed chip ("+0.2", "−0.1") floats up from it; crossing a band boundary also fires a toast ("Kael now regards you as Warm"); 20ms haptic on choice confirm. All motion gated by `reduced_motion`.
5. **Backlog:** a history button (48dp) opens the last ≥10 lines (speaker + text) in a scroll sheet.
6. **Turn pips:** "Exchange 2 of {maxTurns}" pips under the text panel so the scene's pace is legible.
7. Portrait fallback: placeholder silhouette + logged warning instead of a silent blank.

**Acceptance criteria:**
- A1: Choice buttons ≥48dp tall (target 56dp); >4 choices scroll with a visible indicator; Leave is visually distinct and separated from the choices list.
- A2: Typewriter rate changes measurably with the text-speed slider (chars/sec within ±20% of `1/text_speed`); tap-to-complete works; with `reduced_motion=true` the full line appears in one frame.
- A3: Every disposition change shows the meter tween + signed delta chip ≤500ms after the choice; band crossings toast; zero silent changes.
- A4: Leaving requires two deliberate taps (or dialog confirm); 0 accidental scene exits in a 10-run mis-tap test.
- A5: Hardware Back behaves identically to Leave (with confirm).
- A6: Backlog shows ≥10 previous lines; line length ≤75 chars at default text size.


### R6 — Combat screen (wireframe for the G1 stance-duel UI; implementation lives with T8)

**Goal:** a thumb-friendly, strategically legible duel screen consuming `Simulation.start_duel/submit_stance` and `combat_intents.json` (Strike/Defend/Outmaneuver/Parley bands), with the stance triangle (Strike→Feint→Ward→Strike) made visible.

**Wireframe (landscape):**

```
┌──────────────────────────────────────────────────────────────┐
│ TopBar: "Duel — {opponent name}"                    [Forfeit] │
│ ┌─────────────┐   turn log (2 lines, latest at top)  ┌─────────────┐
│ │ OPPONENT    │   "You Strike — A clean hit.         │  YOU        │
│ │ portrait/   │    Opponent loses 1 Resolve."        │  portrait/  │
│ │ stance pose │                                      │  stance pose│
│ │ Resolve ▓▓▓░│            OMENS                     │ Resolve ▓▓▓▓│
│ │ 10→8        │        you ✦✦✦·· : ✦✦✦·· foe         │ 10          │
│ └─────────────┘                                      └─────────────┘
│        [ STRIKE ]      [ WARD ]      [ FEINT ]                   │
│        beats Feint     beats Strike   beats Ward   (64dp, icons) │
│        [ PARLEY — words cut deeper ]  (gated: disp > −0.5)       │
└──────────────────────────────────────────────────────────────┘
```

**Spec:** 3 stance buttons ≥64dp with pose art (`stance_strike/feint/ward.png`, `_wounded` variant below 4 Resolve) + "beats X" caption; Parley as a wide 4th button, disabled with reason tooltip when disposition-gated; result-band text from `combat_intents.json` shown verbatim in the turn log; clash feedback = pose swap + brief shake/ink splash (haptic 20ms), all gated by reduced motion; an **Omen hint** assist toggle (settings) highlights a suggested stance; `duel_resolved` → result banner (winner, resolve summary, disposition consequences) with a single Continue back to the map.

**Acceptance criteria:**
- A1: A complete duel (up to 20 turns) is playable touch-only; every interactive element ≥56dp.
- A2: Each turn displays the correct authored result-band string for the actual outcome; turn log retains ≥2 lines.
- A3: Parley is disabled with a visible reason iff disposition ≤ −0.5; stance buttons always show the triangle hint.
- A4: `duel_resolved` shows the result banner with consequences before any navigation; Continue returns to the map in 1 tap.
- A5: With `reduced_motion=true`, all shake/tween feedback is replaced by instant state changes (information preserved).

### R7 — Onboarding coach marks (GLB-10, MAP-15, MM-6)

**Goal:** the first session teaches touch idioms at the moment of need, then never repeats.

**Spec:** first-run flags persisted in save (`coach_*`). Four steps on first map entry, each a dimmed overlay with a cutout/highlight ring around its target, body text ≥18sp, and a visible **Skip tour** (48dp):
1. "Drag to wander the ashes." — dismisses on first successful pan.
2. "Tap a ruin to inspect it." — dismisses on first node selection.
3. "Tap again — or press Travel — to journey." — dismisses on first travel.
4. "Camp, companions, and your journal live here." (points at quick-bar) — dismisses on tap.
Settings gains **"Replay tutorial"** (resets flags). Coach marks never block input to their target and never cover it.

**Acceptance criteria:**
- A1: Shown exactly once per save — flags verified across app restart; new save re-arms them.
- A2: Each step auto-advances ≤500ms after its triggering action with no extra taps; Skip tour is always visible and ≥48dp.
- A3: Coach overlay never intercepts touches meant for the highlighted target (input pass-through verified).
- A4: "Replay tutorial" in settings replays all four steps on next map entry.


### R8 — Feedback layer: transitions, toasts, button juice (GLB-9/13, MM-5, MAP-11)

**Goal:** every touch answers within 100ms; the game's gothic identity becomes tangible.

**Spec:**
1. **Real scene transition:** SceneSwitcher gains a full-screen `ColorRect` on a top CanvasLayer — fade out 150ms, switch, fade in 200ms (parchment-dark). `reduced_motion` → instant cut, no fade.
2. **Toast system:** lightweight `Toast` autoload (or EventBus `ui_request("toast", …)` handler on each root screen): bottom-center stack, max 2, 2.5s auto-dismiss, slide-up entrance (fade only under reduced motion). Fired for: node locked, save complete ("Saved · just now"), recruit/remove, disposition band crossings, quest objective updates.
3. **Button juice:** extend the `gothic_button.gd` pattern into a shared `chimera_button.gd` attached to every button (scenes + `Button.new()` sites): press → scale 0.96 for 80ms, release → spring back; disabled → no animation; all skipped under `reduced_motion`. Hover accent stays desktop-only.
4. **Haptics:** `Input.vibrate_handheld(20ms)` on travel confirm, choice confirm, stance select; gated by a Haptics setting; no-op off-device.

**Acceptance criteria:**
- A1: Scene transitions show a visible alpha ramp (frame-captured 0→1→0); reduced motion produces a hard cut.
- A2: Grep + runtime audit: 100% of button instances carry the juice script or themed pressed state; every `pressed` handler's UI effect begins ≤100ms after touch-up.
- A3: All five toast triggers fire in a scripted play-through; stack never exceeds 2; toasts dismiss ≤3s.
- A4: Reduced motion disables every Tween in the game (runtime check: no active tweens while flag on).

### R9 — Empty states, confirmations, honesty UI (GLB-11, MM-2/3, CAMP-4/5/6, PTY-3/4/5, JRN-1/3, DLG-10)

**Goal:** no dead ends, no silent destruction, no raw dev data in player-facing text.

**Spec:**
1. **Empty states** (pattern: icon + one atmospheric line + one guidance line): Journal (exists — keep), Party-available ("No companions yet — earn trust in dialogue."), Camp alone ("You rest alone. The fire crackles."), Inventory (future). Generalize the journal pattern into a shared `empty_state` scene.
2. **Confirmations:** New Game with an existing save → modal ("Begin anew? Your current journey will be erased." Confirm/Cancel); Quit hidden on Android (`OS.has_feature("android")`); Remove companion → action fires with a 5s **Undo** toast instead of a modal.
3. **Player-facing copy:** replace raw floats/IDs — "disposition 0.42" → band labels (Warm); "Completed scenes: id1, id2" → grouped, titled entries; disabled FACTION_LEADER gets the reason "Leaders cannot join your party." Camp risk gets a one-line driver summary ("Kael's distrust raises the risk").
4. Camp log becomes a real night-summary list (hook for T8 night events); spacing between Continue and Main Menu increases, Main Menu becomes ghost-styled.

**Acceptance criteria:**
- A1: New Game confirm appears iff a save exists; Cancel leaves the save byte-identical (hash check).
- A2: Remove companion shows Undo for ≥5s; Undo restores the exact prior party array; no modal appears.
- A3: Every list screen renders its designed empty state when empty (screenshot per screen); grep finds no `%.2f` / raw-ID formatting in UI scripts.
- A4: Quit button absent on Android builds, present on desktop.

### R10 — Settings & accessibility completion (GLB-8/16, SET-1..8, MAP-13)

**Goal:** every control tells the truth; accessibility is a first-class section.

**Spec — new sections:**
1. **Audio:** Music + SFX **sliders** (0–100) + master mute, wired to `AudioServer` buses when T8 lands audio; until then the whole section is visibly **disabled with caption "Arrives in a future update"** — no placebo toggles.
2. **Display & Access:** Text size (S/M/L, R4); **Reduced motion** — now consumed at ≥5 sites (SceneSwitcher fade, typewriter, camera smoothing, token hover/shake, NPC wander, all tweens via a shared `Motion.ok()` guard); Screen shake; Haptics; Edge-pan (R1); High-contrast ink toggle.
3. **Gameplay:** Text speed (consumed by the R5 typewriter); Cloud AI dialogue; Omen-hint assist (R6).
4. **Data & About:** Replay tutorial (R7), Reset save (double-confirm), version + credits.
5. **Write-through persistence:** every change calls `GameState.save_game()` (debounced 500ms); rows ≥48dp with themed controls (R4-5).

**Acceptance criteria:**
- A1: Grep audit: every key in `GameState.settings` has ≥1 consumer outside `settings_screen.gd`; any temporarily unwired control renders disabled with the caption.
- A2: Change a setting → force-stop within 2s → relaunch: value persisted (write-through verified).
- A3: Reduced motion toggle flips all 5+ gated behaviors in one session without restart.
- A4: Text size applies ≤100ms live; all settings rows ≥48dp; no default-Godot checkbox/slider visuals remain.


---

## 7. Acceptance-criteria master checklist

| Spec | Verifies issues | Priority | Verification method |
|------|-----------------|----------|---------------------|
| R1 touch map | GLB-1/2, MAP-1..5/11 | P0 | Android on-device scripted taps + desktop regression |
| R2 safe area/back | GLB-3/4/5/15/17 | P0 | Notched-emulator screenshots; Back-matrix walkthrough; lifecycle test |
| R3 HUD quick-bar | MAP-6/7/8 | P1 | On-device measure + reach test; event-instrumented badge/objective checks |
| R4 theme v2 | GLB-6/7/12/14 + all button issues | P0/P1 | Automated scene crawl (sizes), computed contrast, grep for alpha hacks |
| R5 dialogue v2 | DLG-1..11 | P1 | Timed typewriter measurement, mis-tap test, Back-parity check |
| R6 combat UI | G1 (UX surface) | P1 | Touch-only playthrough; JSON string match; gating checks |
| R7 coach marks | GLB-10, MAP-15 | P2 | Fresh-save run; restart persistence; input pass-through |
| R8 feedback layer | GLB-9/13 | P1 | Frame capture, grep audit, scripted play-through toast triggers |
| R9 empty/confirm | GLB-11, MM/CAMP/PTY/JRN | P1 | Save-hash check, Undo restore check, empty-state screenshots |
| R10 settings truth | GLB-8/16, SET-1..8 | P1 | Grep consumer audit; force-stop persistence; live-apply timing |

## 8. Phasing (feeds T5 plan and T6 implementation)

- **Phase A — P0 (T6 first slice):** R1 (map touch), R2 (orientation, safe area, Back + lifecycle save), R4-§1/§2 (48dp floor + disabled state), R5-§2 (choice button sizing + Leave separation), R9-§2 (New Game confirm). *Exit: game is navigable, legally touchable, and never loses progress on a phone.*
- **Phase B — P1:** R3 (quick-bar + node card), R4-§3..6 (type scale, themed controls), R5-§1..6 (typewriter, disposition feedback, backlog), R8 (transitions/toasts/juice), R10 (settings truth + reduced-motion consumers), R9-§3 (copy cleanup).
- **Phase C — P2 / with T7+T8:** R6 combat screen (with T8), R7 coach marks, badges/haptics polish, R9-§1 empty-state scene, camp night summary.

Dependencies: R5 choice *content* waits on T7 dialogue data (container ships first); R6 waits on T8 duel wiring; R10 audio sliders wait on T8 audio buses (disabled-caption path unblocks immediately).

## 9. Appendices

### A. dp/sp → logical-px derivation (reference device)
Device: 1080×2400 px, 6.1", ~420 dpi, landscape. Stretch scale = min(2400/1280, 1080/720) = **1.5** → visible logical ≈ 1600×720.
1 dp = 420/160 = 2.625 device px = 2.625/1.5 = **1.75 logical px**. Hence:
**48dp ≈ 84 logical px · 56dp ≈ 98 · 8dp ≈ 14 · 16sp ≈ 28 · 14sp ≈ 25 · 12sp ≈ 21.**
Current build for comparison: buttons ≈30 logical px ≈ **17dp**; node token Ø48px ≈ **27dp** (Ø24px ≈ **14dp** at min zoom); body 18px ≈ **10sp**; node labels 14px ≈ **8sp**.
Implementation rule: never hardcode dp conversions — use `dp()` from UIAdapt (real DPI at runtime); scene baselines assume 720p logical.

### B. Thumb zones (landscape phone, two-hand hold)
```
┌────────────────────────────────────────────┐
│  LEFT THUMB ARC      (reach dead zone)      RIGHT THUMB ARC │
│  ███░░                                     ░░███ │
│  zoom +/−, current-node chip, Leave        quick-bar, choices, stance buttons │
└────────────────────────────────────────────┘
```
Primary controls must sit inside the two arcs; center-bottom is acceptable for short, infrequent strips (turn log) but never for primary actions.

### C. Orientation enum note (Godot 4)
`DisplayServer.ScreenOrientation`: 0=LANDSCAPE, 1=PORTRAIT, 2=REVERSE_LANDSCAPE, 3=REVERSE_PORTRAIT, 4=SENSOR_LANDSCAPE, 5=SENSOR_PORTRAIT, 6=SENSOR. Current `orientation=5` locks toward portrait — must become **4** (cross-ref ANALYSIS.md G6).

### D. Android Back behavior note
With `application/config/quit_on_go_back` at its default (true), an unconsumed Back press quits the app from any scene; since saves happen only on explicit paths, this discards progress. R2-§3 consumes `ui_back` globally and saves on every navigation (cross-ref GLB-3).

---
*End of UX_SPEC.md — feeds T5 (DEVELOPMENT_PLAN.md) and T6 (implementation). No code was changed in this phase.*

