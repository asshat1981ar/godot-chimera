# M4 UI/UX Plan

**Date:** 2026-07-22
**Baseline:** 0.3.0 (post-M3) · **Target:** 0.4.0
**Inputs:** full code scan of `scripts/`, `scenes/`, `assets/ui_theme.tres`, `project.godot`; cross-checked against `docs/UX_SPEC.md` (R1–R10) and `docs/M3_UX_AUDIT.md`.

## Where things stand

M1–M3 delivered the touch foundation the UX spec demanded: drag pan / pinch zoom / tap select, safe-area insets, 84px touch targets via `gothic_button.gd`, typewriter with reduced-motion and text-speed support, coach marks, haptics, controller focus rings, audio bus muting, journal/camp badges, and a New Game overwrite confirm. Roughly a third of `UX_SPEC.md` remains unbuilt, and the M3 audit missed several live defects.

Spec status at a glance:

| Spec | Status |
|---|---|
| R1 touch map | Partial — pan/pinch/tap done; **tap-to-select→confirm, long-press tooltip, locked-node toast missing** |
| R2 safe area / back | Done, except settings return-to-source (SET-7, now a live bug) |
| R3 HUD quick-bar | Mostly done — node card with Travel button missing |
| R4 theme v2 | Partial — sizes/contrast done; **text-size setting and band-label ProgressBars missing** |
| R5 dialogue v2 | Partial — typewriter done; **choices scroll, Leave separation, disposition feedback, backlog, turn pips missing** |
| R6 combat UI | Done (M3) |
| R7 coach marks | Done |
| R8 feedback layer | Partial — **toast system built but has no callers** |
| R9 empty states / honesty | Partial — New Game confirm done; **raw `%.2f` floats still shipped in party/camp** |
| R10 settings truth | Partial — audio/motion/haptics wired; **no sections, no text size, no replay-tutorial/reset-save rows** |

## Step 0 — Build-breaking bugs and dead wiring (do first)

These block or undermine everything else. The custom validator (`scripts/tests/validate_gdscript.py`) catches none of them, so it gets extended in the same pass.

1. **`settings_screen.gd` declares `_input` twice** (duplicate function = parse error in Godot 4; the settings screen fails to load in a real build). Merge into one handler.
2. **Autoload names used as types / instantiated:**
   - `scene_switcher.gd`: `var _toast: ToastLayer` — `ToastLayer` is an autoload, not a `class_name`; invalid type annotation, and SceneSwitcher also creates a *second* toast layer beside the autoload. Use the autoload.
   - `overhead_map.gd`: `var _ui_adapt: UIAdapt = UIAdapt.new()` — same problem. Use the `UIAdapt` autoload directly (its file comment claiming it is "not an autoload" is stale — fix that too).
3. **Settings opened from the map returns to the main menu** (SET-7), dumping the player out of their session. Pass a `return_to` path in the SceneSwitcher payload; settings Back honors it.
4. **Toast layer has zero callers.** Wire the first real triggers: locked-node tap (with node *name*, not id), recruit/remove companion, and save confirmation on deliberate exits (settings Back, pause → Main Menu).
5. **Minor camera/back fixes:** `overhead_map.gd` back handler has an if/else with identical branches; `map_camera.gd` `focus_on` snaps zoom to 1.0 on every node visit (MAP-13) and its position lerp ignores `reduced_motion`.
6. **Validator upgrade:** detect (a) duplicate top-level `func` names per file, (b) `class_name` colliding with an autoload, (c) autoload names used in `var x: Name` / `-> Name` annotations or `Name.new()`.

**Exit criteria:** validator flags all three load-breaking bugs before the fixes and passes after; settings round-trips map→settings→map; locked-node tap and recruit/remove produce toasts; camera keeps player zoom across visits.

## Phase 1 — Trust the tap (R1.3, R1.4, R1.5, R3.3, MAP-4)

A single tap on a map node still commits travel immediately (`map_node_token.gd:select()`) and can hurl the player into a dialogue scene. The most frequent interaction in the game is also the least forgiving.

- Tap = select: pulse ring on token + node card (name, state chip Open/Sealed/Done ✓, one-line hook, **Travel** button ≥56dp). Second tap on the selected node or the Travel button commits. Tap empty ground deselects.
- Long-press (≥500 ms) opens the tooltip callout — current tooltips are hover-only and dead on touch.
- Locked node: toast + token color pulse (no shake under `reduced_motion`).
- Completed nodes: ✓ badge and "Revisit" copy instead of silent re-entry.
- Desktop regression: click-select still works; WASD/wheel untouched.

**Exit criteria:** UX_SPEC R1 acceptance A3–A5 (no travel on first tap; second tap/Travel only commit path; locked feedback ≤100 ms).

## Phase 2 — Make the differentiator visible (R5, R9.3)

Disposition is the core mechanic and it is nearly invisible: the dialogue bar snaps silently with color-only meaning, and raw dev floats (`%.2f`) ship to players in `party_screen.gd` and `camp_screen.gd`.

- Shared band-label helper (Hostile / Cold / Neutral / Warm / Sworn — icon + text + color) consumed by dialogue, party, and camp. Kills color-only encoding and raw floats in one pass.
- Meter tween + floating signed delta chip on `disposition_changed`; band crossings fire a toast ("Kael now regards you as Warm"). Motion gated by `reduced_motion`.
- Dialogue choices into a ScrollContainer (6 legacy choices + Leave at 84 px already risk overflowing the 720 px canvas); Leave separated from the list with a confirm; turn pips ("Exchange 2 of 4"); ▼ line-complete indicator; tap-to-complete already exists.
- Backlog sheet: last ≥10 lines (speaker + text).

**Exit criteria:** UX_SPEC R5 acceptance A1–A6; grep finds no `%.2f`/raw scene IDs in UI scripts (R9-A3).

## Phase 3 — Settings truth and accessibility (R10 remainder + M3 audit recommendations)

- Settings sections: Audio / Display & Access / Gameplay / Data & About.
- Text-size setting (S/M/L = ×0.9/1.0/1.2 theme font scaling, applied live) — the one accessibility item with no code at all.
- One-time first-launch prompt for text size + motion preference (M3 audit's top recommendation).
- "Replay tutorial" and "Reset save" (double-confirm) as player-facing rows instead of dev-panel-only.
- Write-through persistence (debounced save on change, not only on Back).

**Exit criteria:** UX_SPEC R10 acceptance A1–A4.

## Phase 4 — Performance and polish

- Overhead map: only instantiate visible tiles; pool node/NPC tokens across act changes (currently a Sprite2D per tile for the whole map on every entry).
- Optional on-screen D-pad overlay (M3 audit recommendation).
- Audio ducking during dialogue; put the unused `ink_wash.gdshader` to work in scene transitions.

## Cross-cutting verification

- Extend `run_all_checks.sh` with a UI honesty audit: minimum touch sizes in `.tscn` files, no `%.2f`/raw IDs in UI-facing strings, every `GameState.settings` key has ≥1 consumer outside `settings_screen.gd`.
- Keep `docs/M3_UX_AUDIT.md` claims true by construction, not by document.

## Sequencing rationale

Step 0 and Phase 1 are the highest-leverage slice: small surface area, and they convert the two moments players hit constantly — tapping the map and opening settings mid-run — from actively harmful to solid. Phase 2 is the largest block of new UI but pays into the game's identity. Phases 3–4 are independent and can interleave with content work.
