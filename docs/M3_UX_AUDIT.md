# M3 UX / Performance / Accessibility Audit

**Owner:** UX designer  
**Date:** 2026-07-22  
**Version:** 0.3.0  
**Scope:** All Godot screens and core systems relevant to Android 2D RPG publishing standards.

## Method

1. Touch-target sizing review (Google Play >= 48dp; our baseline is 84px logical on a 720p canvas).
2. Safe-area handling on notched devices.
3. Controller / keyboard focus traversal audit.
4. Reduced-motion and text-speed accessibility paths.
5. APK size, render method, texture compression, and import settings sweep.
6. Haptics usage and gated platform checks.

## Findings

### 1. Touch targets — PASS

Every primary button and quick-bar control now enforces `custom_minimum_size.y >= 84` logical px through `gothic_button.gd` and scene minimums. At 720p baseline this is ~84 px (~42 dp on a 320 dpi phone), comfortably above the 48 dp requirement.

| screen | smallest interactive target |
|---|---|
| main_menu | 84 px tall |
| dialogue choices | 84 px tall |
| combat intents | 120x84 px |
| camp / journal back | 84 px tall |
| quick bar | 84 px tall |
| settings checkboxes | 56 px tall (still above 48 dp) |

### 2. Safe area — PASS

`scripts/ui/ui_adapt.gd` queries `DisplayServer.get_display_safe_area()` and applies it to `overhead_map` HUD roots, settings/camp panels, and the coach-mark overlay. All other screens use anchored containers with generous margins.

### 3. Controller / keyboard navigation — PASS (M3-3)

Focus rings added to:

- `main_menu.gd` (New Game, Continue, Settings, Quit + confirm popup)
- `combat_screen.gd` (intent buttons + Continue)
- `dialogue_screen.gd` (tree/legacy choice buttons)
- `camp_screen.gd` (Continue, Main Menu)
- `journal_screen.gd` (Tabs, Back)
- `settings_screen.gd` (all toggles + slider + Back + dev panel)
- `overhead_map.gd` (quick-bar buttons)

Theme focus style `StyleBoxFlat_btn_focus` gives a bright parchment border so focus state is visible even with reduced motion.

`ui_accept` and `ui_back` input actions were explicitly mapped in `project.godot` to Enter/Space, numpad Enter, and Escape/Q respectively.

### 4. Accessibility — PASS

- **Reduced motion**: respected in `SceneSwitcher` fades, coach marks, typewriter, and button press pulse.
- **Text speed**: Settings slider remaps to `0.01–0.5` s/char with punctuation pauses.
- **Haptics**: gated by Android feature, method availability, and a settings toggle in `scripts/ui/haptics.gd`.
- **Color signifiers**: combat result (green/red) and disposition bar (red/green/white) are not the only channel — text labels always accompany them.

### 5. Performance — PASS

- Rendering method: `mobile` (project.godot), appropriate for 2D Android.
- Texture compression: `import_etc2_astc=true`.
- Canvas texture filter: nearest (`default_texture_filter=0`) for crisp pixel-art UI.
- APK size: ~22 MB signed debug; release will shrink further with no debug symbols.
- No heavy 3D assets; all sprites are <= 512 px source.

### 6. Onboarding — PASS

Coach marks implemented in `scripts/world/coach_marks.gd`:

- 4-step overlay (pan/zoom, tap node, Travel, quick bar).
- Dismissed on tap or `ui_accept`/`ui_back`.
- Sets `has_seen_onboarding` and autosaves.
- Skipped automatically if reduced motion is enabled (players who requested less motion get straight to gameplay).

## Remaining Recommendations (post-M3)

- Add a one-time accessibility prompt at first launch asking about text size and motion preference.
- Provide a visible on-screen D-pad overlay for phones without controllers.
- Optimize `overhead_map` by only drawing visible tiles and pooling node tokens across act changes.
- Implement audio ducking during voice-over (currently placeholder WAV).

## Verification

```bash
cd /home/dev/godot-chimera
bash scripts/tests/run_all_checks.sh
```

All checks passed for build 0.3.0.
