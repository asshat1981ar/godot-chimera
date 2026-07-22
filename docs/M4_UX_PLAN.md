# M4 UI/UX Plan

**Date:** 2026-07-22 (revised same day after step 0 + art-direction merge)
**Baseline:** 0.3.0 (post-M3) · **Target:** 0.4.0
**Inputs:** full code scan of `scripts/`, `scenes/`, `assets/ui_theme.tres`, `project.godot`; cross-checked against `docs/UX_SPEC.md` (R1–R10) and `docs/M3_UX_AUDIT.md`. Revision adds the T10 art-direction package merged 2026-07-22 (`docs/ART_STYLE_GUIDE.md`, `docs/UI_MOCKUP_SPEC.md`, `docs/COLOUR_SWATCHES.md`, `docs/STYLE_GUIDE_QUICK_REF.md`, `docs/T10_STYLE_GUIDE_NOTES.md`, `assets/chimera_palette.gpl`).

## Where things stand

M1–M3 delivered the touch foundation the UX spec demanded: drag pan / pinch zoom / tap select, safe-area insets, 84px touch targets via `gothic_button.gd`, typewriter with reduced-motion and text-speed support, coach marks, haptics, controller focus rings, audio bus muting, journal/camp badges, and a New Game overwrite confirm. Roughly a third of `UX_SPEC.md` remains unbuilt, and the M3 audit missed several live defects.

Spec status at a glance:

| Spec | Status |
|---|---|
| R1 touch map | Partial — pan/pinch/tap done; **tap-to-select→confirm, long-press tooltip, locked-node toast missing** |
| R2 safe area / back | Done — settings return-to-source (SET-7) fixed in step 0 |
| R3 HUD quick-bar | Mostly done — node card with Travel button missing |
| R4 theme v2 | Partial — sizes/contrast done; **text-size setting and band-label ProgressBars missing** |
| R5 dialogue v2 | Partial — typewriter done; **choices scroll, Leave separation, disposition feedback, backlog, turn pips missing** |
| R6 combat UI | Done (M3) |
| R7 coach marks | Done |
| R8 feedback layer | Partial — first toast callers wired in step 0; disposition/quest triggers land in Phase 2 |
| R9 empty states / honesty | Partial — New Game confirm done; **raw `%.2f` floats still shipped in party/camp** |
| R10 settings truth | Partial — audio/motion/haptics wired; **no sections, no text size, no replay-tutorial/reset-save rows** |

## Step 0 — Build-breaking bugs and dead wiring — ✅ DONE (PR #1, merged 2026-07-22)

These blocked or undermined everything else. The custom validator (`scripts/tests/validate_gdscript.py`) caught none of them, so it was extended in the same pass. All exit criteria verified: the upgraded validator flagged all four pre-fix error sites and passes post-fix; `run_all_checks.sh` passes through signed APK export.

1. **`settings_screen.gd` declares `_input` twice** (duplicate function = parse error in Godot 4; the settings screen fails to load in a real build). Merge into one handler.
2. **Autoload names used as types / instantiated:**
   - `scene_switcher.gd`: `var _toast: ToastLayer` — `ToastLayer` is an autoload, not a `class_name`; invalid type annotation, and SceneSwitcher also creates a *second* toast layer beside the autoload. Use the autoload.
   - `overhead_map.gd`: `var _ui_adapt: UIAdapt = UIAdapt.new()` — same problem. Use the `UIAdapt` autoload directly (its file comment claiming it is "not an autoload" is stale — fix that too).
3. **Settings opened from the map returns to the main menu** (SET-7), dumping the player out of their session. Pass a `return_to` path in the SceneSwitcher payload; settings Back honors it.
4. **Toast layer has zero callers.** Wire the first real triggers: locked-node tap (with node *name*, not id), recruit/remove companion, and save confirmation on deliberate exits (settings Back, pause → Main Menu).
5. **Minor camera/back fixes:** `overhead_map.gd` back handler has an if/else with identical branches; `map_camera.gd` `focus_on` snaps zoom to 1.0 on every node visit (MAP-13) and its position lerp ignores `reduced_motion`.
6. **Validator upgrade:** detect (a) duplicate top-level `func` names per file, (b) `class_name` colliding with an autoload, (c) autoload names used in `var x: Name` / `-> Name` annotations or `Name.new()`.

**Exit criteria:** validator flags all three load-breaking bugs before the fixes and passes after; settings round-trips map→settings→map; locked-node tap and recruit/remove produce toasts; camera keeps player zoom across visits. *(All met.)*

## New input — art direction package (merged 2026-07-22, PR #2)

The T10 style-guide work defines the visual system the remaining phases build in: 28-swatch palette (55% saturation ceiling), hand-drawn stroke rules (overshot corners, imperfection budget), panel/button recipes, per-screen mockups, and an asset acceptance gate (`ART_STYLE_GUIDE.md §13`). Consequences for this plan:

**New prerequisite — fonts.** `assets/fonts/` does not exist and `ui_theme.tres` uses the Godot default font. Four OFL fonts (IM Fell English, Crimson Pro, Cinzel, Courier Prime) must be added and wired into the theme before any Phase 1–2 visual work is themed (`T10_STYLE_GUIDE_NOTES.md` "Fonts Required").

**New workstream — asset production.** The `*-queued` branches named for button/HUD sprite production delivered no assets; that work is still open. The style guide + `UI_MOCKUP_SPEC.md` are the production brief. First batch, in dependency order: 9-patch panel + button textures (panel/button recipes in `STYLE_GUIDE_QUICK_REF.md`), HUD icons, map node tokens (all 6 states), toast frame.

**Spec-conflict register.** Where `UI_MOCKUP_SPEC.md` and `UX_SPEC.md` disagree, **UX_SPEC wins on interaction, the mockup spec wins on visual treatment**:

| Conflict | Resolution |
|---|---|
| Mockup keeps Leave inside the dialogue choice VBox; UX_SPEC R5.2 separates it with a confirm | Separate Leave (R5.2); style it with the mockup's Leave recipe (P3 bg, A3 border, ← accent) |
| Mockup has no node card / tap-to-select→confirm flow (documents the current first-tap-travels HUD) | Build the node card (R1.3/R3.3); style it with the panel recipe; add an addendum to `UI_MOCKUP_SPEC.md` |
| Mockup node labels: Courier Prime 12px — below UX_SPEC R4's own micro floor (≥16 logical px) | Keep Courier Prime, floor at 16px, keep zoom-aware visibility |
| Mockup bottom HUD bar (72px, Camp/Journal/Party) vs shipped right-side quick-bar (R3, thumb-arc rationale) | Keep the shipped quick-bar layout; restyle it per the HUD bar's dark-ink treatment (I1 85% bg, G2 border) |

**Latent content the mockups unlock:** the code's node state machine only uses 4 of the 6 specified states — `map_ruins_failed.png` and `map_ruins_hidden.png` already exist on disk unused. Wiring `failed`/`hidden` states lands in Phase 1.

## Phase 1 — Trust the tap (R1.3, R1.4, R1.5, R3.3, MAP-4)

A single tap on a map node still commits travel immediately (`map_node_token.gd:select()`) and can hurl the player into a dialogue scene. The most frequent interaction in the game is also the least forgiving.

- Tap = select: pulse ring on token + node card (name, state chip Open/Sealed/Done ✓, one-line hook, **Travel** button ≥56dp). Second tap on the selected node or the Travel button commits. Tap empty ground deselects.
- Long-press (≥500 ms) opens the tooltip callout — current tooltips are hover-only and dead on touch.
- Locked node: toast + token color pulse (no shake under `reduced_motion`).
- Completed nodes: ✓ badge and "Revisit" copy instead of silent re-entry.
- Wire the two unused token states: `failed` (R2 fill) and `hidden` (30% opacity, no label) per `UI_MOCKUP_SPEC.md` "Map Node Token States" — art already exists on disk.
- Node card styled with the panel recipe (P2 fill, I1 4px border, A3 tracery) once panel textures land; ships first with the current theme so interaction work never waits on art.
- Desktop regression: click-select still works; WASD/wheel untouched.

**Exit criteria:** UX_SPEC R1 acceptance A3–A5 (no travel on first tap; second tap/Travel only commit path; locked feedback ≤100 ms).

## Phase 2 — Make the differentiator visible (R5, R9.3)

Disposition is the core mechanic and it is nearly invisible: the dialogue bar snaps silently with color-only meaning, and raw dev floats (`%.2f`) ship to players in `party_screen.gd` and `camp_screen.gd`.

- Shared band-label helper (Hostile / Cold / Neutral / Warm / Sworn — icon + text + color) consumed by dialogue, party, and camp. Kills color-only encoding and raw floats in one pass.
- Meter tween + floating signed delta chip on `disposition_changed`; band crossings fire a toast ("Kael now regards you as Warm"). Motion gated by `reduced_motion`.
- Dialogue choices into a ScrollContainer (6 legacy choices + Leave at 84 px already risk overflowing the 720 px canvas); Leave separated from the list with a confirm; turn pips ("Exchange 2 of 4"); ▼ line-complete indicator; tap-to-complete already exists.
- **Choice tinting by `choiceType`** per the `UI_MOCKUP_SPEC.md` §3 reference table (defer/help/vow/threaten/lie/… → bg tint + border + left accent glyph) in `dialogue_screen.gd _create_choice_button()` — gives choices a visual consequence grammar and satisfies the icon+color+text tri-encoding rule at the same time.
- Disposition meter colors move to palette swatches R1/P5/B2 (already anticipated by `T10_STYLE_GUIDE_NOTES.md` integration table).
- Backlog sheet: last ≥10 lines (speaker + text).

**Exit criteria:** UX_SPEC R5 acceptance A1–A6; grep finds no `%.2f`/raw scene IDs in UI scripts (R9-A3).

## Phase 3 — Settings truth and accessibility (R10 remainder + M3 audit recommendations)

- Settings sections: Audio / Display & Access / Gameplay / Data & About.
- Text-size setting (S/M/L = ×0.9/1.0/1.2 theme font scaling, applied live) — the one accessibility item with no code at all.
- One-time first-launch prompt for text size + motion preference (M3 audit's top recommendation).
- "Replay tutorial" and "Reset save" (double-confirm) as player-facing rows instead of dev-panel-only.
- Write-through persistence (debounced save on change, not only on Back).

**Exit criteria:** UX_SPEC R10 acceptance A1–A4.

## Phase 4 — Theme v3, performance, and polish

- **Theme v3:** apply the palette to `ui_theme.tres` (panel/button/checkbox/slider recipes, no pure black/white, act accents E1–E3 kept out of UI chrome per the 7 color rules), swap in the four fonts, integrate first asset batches behind the §13 acceptance gate.
- **Ink wash shader:** implement the five-stage spec from `ART_STYLE_GUIDE.md §7.3` (paper grain → edge darkening → Bayer dither → vignette → UV wobble; wobble off under reduced motion) in the currently-unused `ink_wash.gdshader`, applied to map background and scene transitions.
- Overhead map: only instantiate visible tiles; pool node/NPC tokens across act changes (currently a Sprite2D per tile for the whole map on every entry).
- Optional on-screen D-pad overlay (M3 audit recommendation).
- Audio ducking during dialogue.

## Cross-cutting verification

- Extend `run_all_checks.sh` with a UI honesty audit: minimum touch sizes in `.tscn` files, no `%.2f`/raw IDs in UI-facing strings, every `GameState.settings` key has ≥1 consumer outside `settings_screen.gd`.
- Keep `docs/M3_UX_AUDIT.md` claims true by construction, not by document.

## Sequencing rationale

Step 0 (done) and Phase 1 are the highest-leverage slice: small surface area, and they convert the two moments players hit constantly — tapping the map and opening settings mid-run — from actively harmful to solid. Phase 2 is the largest block of new UI but pays into the game's identity. Phases 3–4 are independent and can interleave with content work.

The art track runs in parallel and never blocks interaction work: fonts land first (small, unblocks theme typography), then panel/button 9-patches, then icons and tokens. Every phase ships functional with the current theme; styling upgrades apply as assets pass the acceptance gate. The choice tinting and node-state wiring need no new art at all — palette colors and existing PNGs suffice.
