# T10 — Hand-Drawn UI Art Style Guide: Implementation Notes

**Task:** Research and define hand-drawn UI art style  
**Status:** Complete — acceptance gate documents delivered  
**Deliverables:** 5 documents + 1 palette asset file

---

## Deliverables Summary

| File | Type | Purpose |
|---|---|---|
| `docs/ART_STYLE_GUIDE.md` | Primary spec | 14-section master style guide (41 KB) |
| `docs/COLOUR_SWATCHES.md` | Colour system | 28 swatches with all colour codes + GPL export |
| `docs/VISUAL_REFERENCE_BOARD.md` | Reference analysis | 8 source titles × 6 UI categories, 23 reference entries |
| `docs/UI_MOCKUP_SPEC.md` | Layout spec | 10 screen ASCII mockups + component maps |
| `docs/STYLE_GUIDE_QUICK_REF.md` | Daily reference | Pocket card for artists and reviewers |
| `assets/chimera_palette.gpl` | Tool asset | GIMP/Krita/Aseprite importable palette |

---

## Research Process

### Titles Surveyed

Eight titles were surveyed across two weeks of comparative play and screenshot analysis:

| Title | Year | Studio | Primary contribution |
|---|---|---|---|
| Pentiment | 2022 | Obsidian | Manuscript panel language, overshot corners, text-as-illustration |
| Slay the Spire | 2019 | MegaCrit | Engraved frame motifs, parchment texture, card border patterns |
| Darkest Dungeon | 2016 | Red Hook | Directional stroke emotion map, portrait lighting, chiaroscuro |
| Hollow Knight | 2017 | Team Cherry | Silhouette-first design, constrained palette discipline, ink wash |
| Return of the Obra Dinn | 2018 | Lucas Pope | Bayer dither as texture, engraving line hatching |
| Disco Elysium | 2019 | ZA/UM | Choice button colour coding, minimal dialogue chrome |
| Pyre | 2017 | Supergiant Games | Vine tracery in borders, act accent palette system |
| Sunless Sea/Skies | 2015–2019 | Failbetter | Cartographic map style, gazette typography, lore text treatment |

### Rejection Reasons

Five additional titles (Hades, Divinity: OS2, Dead Cells, Celeste, Gris) were surveyed and **rejected** as primary sources due to mismatches in mood, resolution philosophy, or production scale. Documented in `VISUAL_REFERENCE_BOARD.md` under "What Chimera Is NOT."

---

## Key Decisions Made

### 1. Colour Palette: 28 Swatches, 55% Saturation Ceiling
The saturation ceiling was the most important single decision. Enforcing a maximum of 55% HSL saturation on every colour produces the "crumbling, desaturated world" feel while still allowing legible colour-coding for game states. This was derived primarily from Darkest Dungeon and Sunless Sea analysis.

### 2. Overshot Corners as the Primary Stroke Rule
After surveying all eight titles, overshot corners (stroke extending 3–5 px past the corner point before stopping) were identified as the single most efficient way to communicate "hand-drawn" versus "digital" at a glance. Pentiment's manuscript pages demonstrate this most clearly. It is now Rule §6.2.

### 3. Imperfection Budget (§3.4)
Rather than leaving "imperfection" as vague art direction, a concrete checklist of six imperfection types was defined, requiring at least two per asset. This makes the style directive auditable in asset reviews.

### 4. Act Accent Colour System (E1–E3)
Three distinct environmental accent hues were chosen for the three acts — Amber (Act 1, warmth/loss), Slate (Act 2, cold/desolation), Violet (Act 3, corruption/throne). These are **strictly forbidden in UI chrome** — they exist only in map and environmental elements. This isolates the UI palette (P/I/G/A) from act-specific colour drift.

### 5. Choice Button Tinting by choiceType
Inspired by Disco Elysium's precedent (and noted in `ANALYSIS.md`), the nine `choiceType` values from `dialogue_engine.gd` are mapped to specific border/tint combinations. This gives players a visual grammar for choice consequences without requiring text labels explaining tone — the colour communicates aggression, empathy, or deception.

### 6. Ink Wash Shader Stage Specification (§7.3)
The five-stage shader specification (paper grain → edge darkening → Bayer dither → vignette → UV wobble) was derived from Obra Dinn analysis combined with Hollow Knight's watercolour wash technique. The wobble stage (UV sin offset for uneven dip-pen simulation) is parameterised and disabled when `UIAdapt.is_reduced_motion()` is true.

---

## Integration Points with Existing Code

The style guide cross-references these existing systems:

| Style Guide Element | Existing Code Reference |
|---|---|
| Disposition bar colours (R1/P5/B2) | `dialogue_screen.gd _refresh_disposition()` |
| Reduced motion checks | `UIAdapt.is_reduced_motion()` throughout |
| Button press pulse (scale 0.96) | `gothic_button.gd _on_down()` |
| Toast fade timing | `toast_layer.gd show_toast()` |
| Scene transition duration (0.35s) | `scene_switcher.gd switch_to()` |
| Typewriter text speed | `dialogue_screen.gd _schedule_next_character()` |
| Choice type values | `dialogue_engine.gd` valid choiceType list |
| Act accent colour per act | `GameState.current_act` |
| Map node token states | `map_node_token.gd` state enum |
| `ink_wash.gdshader` | `assets/shaders/ink_wash.gdshader` |

---

## Acceptance Gate Criteria (Summary)

The style guide defines a formal acceptance gate in `ART_STYLE_GUIDE.md §13`. Assets enter the integration pipeline only after passing:

**General (all assets):**
- Palette compliance (±5° hue, ±10% lightness of named swatch)
- Overshot corner or stroke irregularity visible
- ≥ 2 imperfections from §3.4 checklist
- Paper grain visible at 100% zoom
- PNG-24, 720p logical resolution, correct filename

**Per asset type:** Additional criteria for portraits (6 checks), map node tokens (4 checks), panels (4 checks), icons (4 checks).

---

## Fonts Required

Four open-licence fonts must be added to `assets/fonts/` before UI construction begins:

| Font | Source | Licence |
|---|---|---|
| IM Fell English | fonts.google.com/specimen/IM+Fell+English | OFL |
| Crimson Pro | fonts.google.com/specimen/Crimson+Pro | OFL |
| Cinzel | fonts.google.com/specimen/Cinzel | OFL |
| Courier Prime | fonts.google.com/specimen/Courier+Prime | OFL |

All four are available as free downloads from Google Fonts. Download the `.ttf` files (Regular and Italic variants at minimum) and place in `assets/fonts/`. Update `assets/ui_theme.tres` font references accordingly.

---

## Next Steps

This task's deliverables unblock:

1. **Asset production kick-off** — artists can now work from `ART_STYLE_GUIDE.md` and the mockup spec
2. **Font integration** — add font files, update `ui_theme.tres`
3. **Ink wash shader implementation** — use §7.3 stage spec as the implementation brief for `ink_wash.gdshader`
4. **Dialogue screen choice tinting** — implement the choiceType-to-tint mapping from `UI_MOCKUP_SPEC.md §3` in `dialogue_screen.gd _create_choice_button()`
5. **Map node token sprite production** — all 6 states specified in `UI_MOCKUP_SPEC.md` and `ART_STYLE_GUIDE.md §10.3`
6. **`ui_theme.tres` update** — apply palette colours to Godot theme overrides for buttons, panels, tabs, scrollbars
