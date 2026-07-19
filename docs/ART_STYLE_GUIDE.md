# Chimera: Ashes of the Hollow King — Hand-Drawn UI Art Style Guide

**Version:** 1.0  
**Status:** Acceptance Gate for Asset Production  
**Scope:** All UI surfaces, map tiles, NPC portraits, tokens, HUD elements, and world-space decorations.

---

## Table of Contents

1. [Vision Statement](#1-vision-statement)
2. [Reference Board Analysis](#2-reference-board-analysis)
3. [Core Style Traits](#3-core-style-traits)
4. [Colour System](#4-colour-system)
5. [Typography](#5-typography)
6. [Stroke & Line Language](#6-stroke--line-language)
7. [Texture Treatment](#7-texture-treatment)
8. [Component Specifications](#8-component-specifications)
9. [NPC Portraits](#9-npc-portraits)
10. [Map & World Art](#10-map--world-art)
11. [Animation & Motion](#11-animation--motion)
12. [Accessibility Checklist](#12-accessibility-checklist)
13. [Asset Production Acceptance Criteria](#13-asset-production-acceptance-criteria)
14. [Appendix: Palette Swatches](#14-appendix-palette-swatches)

---

## 1. Vision Statement

**"A crumbling illuminated manuscript brought to dim, amber life."**

Chimera's visual identity sits at the intersection of **medieval ink-and-wash illustration**, **gothic woodcut printing**, and **battered field journal**. Every UI surface should feel as though it was drawn by a weary scribe in a failing kingdom — purposeful, slightly imperfect, emotionally weighted.

### Mood Words
`Ashen` · `Worn` · `Reverent` · `Forbidding` · `Intimate` · `Fragile`

### Anti-Mood Words (things we explicitly avoid)
`Clean` · `Flat` · `Neon` · `Pixel-sharp` · `Playful` · `Sterile`

### One-Sentence Test
> *"Does this asset look like it could exist in a monk's marginalia, stained by candlelight and decades of ash?"*

If yes → ship it. If no → revise.

---

## 2. Reference Board Analysis

The following titles were surveyed to extract actionable style traits. Each entry notes **what we take** and **what we reject**.

---

### 2.1 Pentiment (Obsidian, 2022)
**Genre:** Narrative mystery  
**Art Direction:** Hand-lettered, manuscript illustration, period-accurate illumination

| Trait | Detail | Take / Reject |
|---|---|---|
| Stroke weight | 1–3 px (at 1080p), never anti-aliased at edges | ✅ Take |
| Colour | Near-monochrome + single warm ink accent | ✅ Take |
| Text rendering | Hand-lettered display; serif body | ✅ Take |
| Panel borders | Ragged ink edges, no drop shadows | ✅ Take |
| Fill style | Cross-hatch and stipple for shadow | ✅ Take |
| Portraits | Flat ink silhouette + minimal colour wash | ✅ Take |
| UI chrome | Deliberate inconsistency in line weight | ✅ Take |
| Animation | Smear-frame, morph transitions | ⚠️ Partial (respect reduced-motion) |
| Resolution | 1080p native — line crispness relies on this | ❌ Reject (we target 720p, must adapt) |

**Key takeaway:** Pentiment proves that UI can be a fully illustrated document. Our panels are parchment *pages*, not windows.

---

### 2.2 Slay the Spire (MegaCrit, 2019)
**Genre:** Roguelike deck-builder  
**Art Direction:** Oil-painting characters, hand-drawn card borders, ink-stained backgrounds

| Trait | Detail | Take / Reject |
|---|---|---|
| Card border | Engraved, embossed-looking gold/iron frame | ✅ Take (our dialogue panel rims) |
| Background texture | Heavy paper/linen weave visible in all surfaces | ✅ Take |
| Status icons | Flat silhouette + single-colour fill | ✅ Take |
| Character art | Painterly, high-contrast | ❌ Reject (too painterly; we stay ink-wash) |
| UI legibility | High-contrast text against dark panels | ✅ Take |
| Fog of war | Desaturated + vignette overlay | ✅ Take (for locked map nodes) |

**Key takeaway:** Textured backgrounds and engraved borders elevate even simple rectangle panels. The "worn gold" frame motif goes directly into our `frame_gold.png` spec.

---

### 2.3 Darkest Dungeon (Red Hook, 2016)
**Genre:** Gothic horror RPG  
**Art Direction:** Scratchy charcoal/ink, high-contrast chiaroscuro, wood-engraving feel

| Trait | Detail | Take / Reject |
|---|---|---|
| Stroke character | Deliberate roughness, visible stroke direction | ✅ Take |
| Colour temperature | Desaturated with deep umber/crimson accents | ✅ Take |
| Lighting model | Rim light only, subjects emerge from darkness | ✅ Take (portrait vignette) |
| UI borders | Riveted iron or carved stone — very heavy | ⚠️ Partial (lighter; we use parchment, not iron) |
| Text style | Condensed serif, tracked wide | ✅ Take |
| Dread atmosphere | Red-tinted overlays for stress/danger states | ✅ Take (disposition bar tint) |
| Splatter/stamp | Bloodied stamps for events | ❌ Reject (too horror-specific) |

**Key takeaway:** Stroke *direction* communicates mood. Downward strokes = weight, doom. Upward strokes = aspiration, hope. Use this deliberately on NPC portraits.

---

### 2.4 Hollow Knight (Team Cherry, 2017)
**Genre:** Metroidvania  
**Art Direction:** Indian-ink silhouette, watercolour environmental wash, minimal palette

| Trait | Detail | Take / Reject |
|---|---|---|
| Silhouette clarity | Pure black outlines, fills are single flat colours or watercolour washes | ✅ Take |
| Colour per zone | Each act/region has one dominant accent colour | ✅ Take (Act palette system) |
| Particle / dust | Fine ash/spore particles in dark environments | ✅ Take (ambient particles on overhead map) |
| UI minimalism | HUD is tiny and non-intrusive | ✅ Take |
| Environmental storytelling | Background elements are half-finished illustrations | ✅ Take (map background) |
| Animation | Fluid squash-and-stretch | ❌ Reject (not hand-drawn feel; our animations are subtle) |

**Key takeaway:** Strong silhouette + constrained palette = readable at small sizes on mobile. Our NPC tokens are silhouette-first.

---

### 2.5 Return of the Obra Dinn (Lucas Pope, 2018)
**Genre:** Deduction mystery  
**Art Direction:** 1-bit dithering, Mac OS original palette homage

| Trait | Detail | Take / Reject |
|---|---|---|
| Dither pattern | Ordered Bayer dither for halftones | ✅ Take (in our ink-wash shader) |
| Monochrome discipline | Everything readable in 2 values | ✅ Take (accessibility test) |
| Engraving lines | Parallel hatch lines to simulate print | ✅ Take |
| Literal 1-bit palette | Too extreme for our readability needs | ❌ Reject |
| Atmosphere | Dense hatching creates oppressive weight | ✅ Take (for duel/combat UI) |

**Key takeaway:** Dithered halftones and engraving lines are the ink-wash shader's primary tool. Cross-reference `ink_wash.gdshader`.

---

### 2.6 Disco Elysium (ZA/UM, 2019)
**Genre:** CRPG / narrative detective  
**Art Direction:** Expressionist oil painting, sketched UI elements, watercolour skill check panels

| Trait | Detail | Take / Reject |
|---|---|---|
| Panel backgrounds | Loose, impressionistic brush strokes | ✅ Take (parchment surface variation) |
| Skill/stat icons | Small, hand-drawn pictograms | ✅ Take (disposition/quest icons) |
| Dialogue box | Minimal chrome — text on near-transparent surface | ✅ Take |
| World saturation | Bold, emotional use of colour | ⚠️ Partial (our palette is more muted) |
| Portrait style | Loose oil paint with visible brushwork | ❌ Reject (we stay in ink-wash, not oil) |
| UI feedback | Colour-coded text for tone (red = aggressive, blue = intellectual) | ✅ Take (choice button tinting by choice type) |

**Key takeaway:** Tinting choice buttons by `choiceType` (aggression vs empathy vs deception) is a proven UX pattern in narrative RPGs. Add to dialogue screen spec.

---

### 2.7 Pyre (Supergiant Games, 2017)
**Genre:** Narrative sports RPG  
**Art Direction:** Watercolour washes, calligraphic script, illuminated manuscript borders

| Trait | Detail | Take / Reject |
|---|---|---|
| Border motifs | Vine/thorn tracery inside panel rims | ✅ Take |
| Glow effects | Soft, desaturated inner glow on magical elements | ✅ Take (active node token glow) |
| Background gradient | Deep indigo-to-black vignette | ✅ Take (overhead map sky) |
| Portrait frames | Ornate oval frames, period-appropriate | ✅ Take |
| Music integration | UI responds visually to music tempo | ❌ Reject (complexity vs. value) |

**Key takeaway:** Vine/thorn tracery inside our panel borders adds immediate period authenticity at low pixel cost — achievable with a tileable `frame_inner_tracery.png` strip.

---

### 2.8 Sunless Sea / Sunless Skies (Failbetter, 2015–2019)
**Genre:** Nautical narrative roguelike  
**Art Direction:** Engraved maps, gazette typography, British Victorian ink

| Trait | Detail | Take / Reject |
|---|---|---|
| Map style | Engraved sea-chart; nodes are labeled in copperplate | ✅ Take |
| Journal typography | Serif, high leading, rag-right | ✅ Take |
| Danger zones | Dark ink wash overlay, reduced contrast | ✅ Take |
| Port icons | Small, detailed woodcut silhouettes | ✅ Take (our map_node_token states) |
| Colour | Near-total desaturation, gold accent | ✅ Take |
| Screen-space ink spill | Ink splatters at event boundaries | ⚠️ Partial (use sparingly, no distracting motion) |

**Key takeaway:** The map *is* the journal. Our overhead map should read as a page from a field atlas, not a game board.

---

## 3. Core Style Traits

These are the **non-negotiable rules** derived from the reference analysis. Every asset submitted for production must satisfy all of these.

### 3.1 Stroke Weight System

| Element Category | Min Stroke (px @ 720p) | Max Stroke (px @ 720p) | Character |
|---|---|---|---|
| Panel border (outer) | 3 | 5 | Irregular, tapers at corners |
| Panel border (inner tracery) | 1 | 2 | Delicate, consistent |
| NPC portrait outline | 2 | 4 | Directional (see §9) |
| Map node token outline | 2 | 3 | Clean silhouette |
| Map connection line | 1 | 2 | Hand-ruled, slight bow |
| UI icon | 1 | 2 | Minimal, flat |
| Body text stroke (UI labels) | N/A — font renders | N/A | — |
| Decorative divider | 1 | 1 | Hairline, slightly uneven |

**Rule:** Stroke weight must never be perfectly uniform along its length. A 10% ± variation in width is mandatory — achieved by drawing on textured brushes or in post-process via the ink-wash shader's `edge_wobble` parameter.

### 3.2 Edge Character

- **Outer silhouette edges:** Slightly rough. Not pixelated, not perfectly smooth. Think "inked with a 70% saturated brush on cold-press paper."
- **Interior fill edges:** Softer. Where ink meets parchment, allow a 1–2 px feathering.
- **Hard rule:** No pure anti-aliased bezier smoothness anywhere visible. If Photoshop/Krita produces a perfectly smooth edge, introduce a paper texture overlay at ≥ 15% opacity.

### 3.3 Fill Language

| Fill Type | Usage | Technique |
|---|---|---|
| Flat ink | Silhouettes, token fills, icon fills | Solid colour, no gradient |
| Ink wash | Background panels, environmental zones | 20–60% opacity colour over parchment |
| Cross-hatch | Shadow regions, locked/failed states, duel screen | Parallel lines at 45°, 15–20 px spacing @ 720p |
| Stipple | Mid-tones in portraits, stone textures | Random dots, denser = darker |
| Dry-brush streak | Highlight on raised surfaces | Single directional strokes, low opacity (30–50%) |
| No fills allowed | N/A | Gradients, lens flare, bloom, normal-mapped lighting |

### 3.4 Imperfection Budget

Each asset must contain at least **two visible imperfections** from this list:

1. A stroke that slightly overshoots its corner
2. A fill that does not perfectly reach its stroke boundary (1–3 px gap)
3. A visible texture grain from the paper layer
4. A slightly uneven hatching interval (±2 px variation)
5. An ink bleed at one corner of a panel (subtle colour spread)
6. A decorative motif (vine, rune, flourish) that is slightly asymmetric

This is a **feature, not a bug.** Perfection reads as digital. Imperfection reads as authored.

### 3.5 Lighting Model

- **Global:** No real-time lighting on UI. All lighting is baked into asset texture.
- **Light source:** Upper-left at approximately 10 o'clock — consistent with candlelight from the left.
- **Highlights:** Dry-brush streaks on upper-left surfaces of raised elements (buttons, panel rims).
- **Shadows:** Cross-hatch or stipple on lower-right of raised elements. Never drop-shadow (too digital).
- **Exception:** The `ink_wash.gdshader` may apply a subtle vignette in screen-space — this counts as "environmental" lighting, not per-element.

---

## 4. Colour System

### 4.1 Design Principles

1. **Parchment is the neutral.** All UI surfaces are tinted variants of `#E8D5B0` (Primary Parchment). Nothing is pure white.
2. **Ink is the primary.** Text, borders, and outlines use near-black ink tones, never pure `#000000`.
3. **Gold is the accent.** Interactive elements, active states, and hierarchy markers use the Antique Gold family.
4. **Saturation ceiling: 55%.** No colour in the palette exceeds 55% HSL saturation. We are a crumbling world, not a vibrant one.
5. **Per-act colour temperature.** Each act gets one accent hue shift applied to environmental and map elements only — UI chrome remains constant.

### 4.2 Full Colour Palette (28 swatches)

See `docs/COLOUR_SWATCHES.md` for rendered swatches. Hex values below.

#### Group A — Parchment & Paper (Neutrals)

| ID | Name | Hex | HSL | Usage |
|---|---|---|---|---|
| `P1` | Primary Parchment | `#E8D5B0` | 38°, 55%, 80% | All panel backgrounds, button fills |
| `P2` | Aged Parchment | `#D4BE94` | 36°, 42%, 70% | Inset panels, scroll backgrounds, secondary surfaces |
| `P3` | Dark Parchment | `#BFA880` | 35°, 35%, 62% | Pressed button state, selected tabs |
| `P4` | Pale Vellum | `#F2E8D2` | 38°, 62%, 89% | Tooltip backgrounds, empty states |
| `P5` | Linen Shadow | `#A89070` | 34°, 28%, 55% | Dividers, panel interior shadows |
| `P6` | Ash White | `#EDE8E0` | 40°, 30%, 91% | Very light overlay backgrounds, modal scrim |

#### Group B — Ink & Dark (Primary Text & Borders)

| ID | Name | Hex | HSL | Usage |
|---|---|---|---|---|
| `I1` | Primary Ink | `#1A1410` | 28°, 28%, 9% | Primary body text, main borders |
| `I2` | Sepia Ink | `#3D2B1F` | 22°, 33%, 18% | Secondary text, portrait shadow regions |
| `I3` | Faded Ink | `#5C4433` | 22°, 28%, 28% | Inactive labels, caption text |
| `I4` | Rust Ink | `#4A2E1E` | 20°, 42%, 20% | Error states, hostile disposition tint |
| `I5` | Storm Ink | `#252830` | 227°, 12%, 17% | Combat screen backgrounds, duel overlay |

#### Group C — Antique Gold (Primary Accent / Interactive)

| ID | Name | Hex | HSL | Usage |
|---|---|---|---|---|
| `G1` | Antique Gold | `#C9A84C` | 42°, 53%, 55% | Active node token glow, focused button rim, section headers |
| `G2` | Burnished Gold | `#A8863C` | 40°, 49%, 45% | Button border default, panel rim highlight |
| `G3` | Pale Gold | `#DFC278` | 43°, 58%, 67% | Hover state tint, disposition bar positive fill |
| `G4` | Dark Gold | `#7A5E28` | 40°, 50%, 32% | Pressed/active border, deep panel rims |
| `G5` | Gold Wash | `#C9A84C26` | 42°, 53%, 55%, 15% | Subtle panel tint overlay (RGBA) |

#### Group D — Ash & Blood (Per-Act Accents + State Colours)

| ID | Name | Hex | HSL | Usage |
|---|---|---|---|---|
| `A1` | Ash Grey | `#8C8278` | 30°, 8%, 51% | Neutral/unvisited map nodes, inactive states |
| `A2` | Deep Ash | `#504844` | 15°, 7%, 29% | Completed node fill, journal visited markers |
| `A3` | Bone | `#CFC3A8` | 38°, 30%, 74% | Map connection lines, secondary borders |
| `R1` | Hollow Crimson | `#8C2F2F` | 0°, 50%, 37% | Hostile NPC disposition, failed quest, combat danger |
| `R2` | Dried Blood | `#5E1A1A` | 0°, 56%, 23% | Critical danger state, duel loss indication |
| `B1` | Hollow Teal | `#2E5C5C` | 180°, 34%, 27% | Positive/trusted NPC tint, active vow indicator |
| `B2` | Pale Teal | `#4A8A8A` | 180°, 31%, 41% | Positive disposition bar, help/empathize choices |

#### Group E — Act-Specific Accent Hues (Environment / Map Only)

| ID | Name | Hex | HSL | Act | Usage |
|---|---|---|---|---|---|
| `E1` | Act 1 Amber | `#C47820` | 35°, 72%, 45% | Act 1 | Map node glow, environmental overlay — The Ashfields |
| `E2` | Act 2 Slate | `#4A5870` | 216°, 20%, 36% | Act 2 | Map node glow, environmental overlay — The Hollow Reaches |
| `E3` | Act 3 Violet | `#5A3870` | 270°, 33%, 33% | Act 3 | Map node glow, environmental overlay — The King's Throne |

### 4.3 Colour Usage Rules

```
Rule C-01: Never use pure #000000 or #FFFFFF anywhere.
Rule C-02: Text on parchment (P1/P2) must use I1 or I2 only.
Rule C-03: Text on dark surfaces (I5, A2) must use P4 or P1 only.
Rule C-04: Accent gold (G1–G4) must never fill large surfaces — borders and icons only.
Rule C-05: Act accent colours (E1–E3) are forbidden in UI chrome. Map/environment only.
Rule C-06: R1/R2 (crimson) are reserved for hostile/danger states. Never decorative.
Rule C-07: B1/B2 (teal) are reserved for positive disposition states. Never decorative.
Rule C-08: Minimum contrast ratio for body text: 4.5:1 (WCAG AA). Test I1 on P1: passes at ~7.2:1.
Rule C-09: Choice button tints by choiceType (see §8.4). Never override with non-palette colours.
```

### 4.4 Contrast Ratios (Pre-Computed)

| Foreground | Background | Ratio | WCAG Level |
|---|---|---|---|
| I1 `#1A1410` | P1 `#E8D5B0` | 7.2 : 1 | AAA ✅ |
| I2 `#3D2B1F` | P1 `#E8D5B0` | 5.1 : 1 | AA ✅ |
| I3 `#5C4433` | P1 `#E8D5B0` | 3.6 : 1 | AA Large ⚠️ |
| P4 `#F2E8D2` | I5 `#252830` | 9.3 : 1 | AAA ✅ |
| P1 `#E8D5B0` | I1 `#1A1410` | 7.2 : 1 | AAA ✅ |
| G1 `#C9A84C` | I1 `#1A1410` | 4.7 : 1 | AA ✅ |

> **Action:** `I3` (Faded Ink) must only be used at ≥ 18px (large text threshold). Flag any use below 18px for remediation.

---

## 5. Typography

### 5.1 Typeface Selections

The project uses system-safe or embeddable open-licence fonts. All fonts must be bundled in `assets/fonts/`.

| Role | Font Family | Weight | Size Range | Licence |
|---|---|---|---|---|
| Display / Title | **IM Fell English** (serif, slightly irregular) | Regular | 28–72 px | OFL |
| Body / Dialogue | **Crimson Pro** (text serif, high legibility) | Regular / Italic | 16–22 px | OFL |
| UI Labels / Buttons | **Cinzel** (Roman caps, carved feel) | Regular | 14–20 px | OFL |
| Monospace / Dates | **Courier Prime** (typewriter) | Regular | 12–16 px | OFL |
| Fallback | System serif (no custom font loaded) | — | — | — |

> **Source:** Google Fonts — all four are available at fonts.google.com under OFL licence, suitable for commercial game distribution.

### 5.2 Type Scale

Base unit: 4 px. All sizes are multiples of 4.

| Level | Role | Size | Line Height | Tracking |
|---|---|---|---|---|
| T1 | Screen title | 48 px | 56 px | +2 px |
| T2 | Section header | 32 px | 40 px | +1 px |
| T3 | Panel header | 24 px | 32 px | 0 |
| T4 | Body / Dialogue | 18–20 px | 28 px | 0 |
| T5 | UI label / Button | 16 px | 24 px | +1 px |
| T6 | Caption / Tooltip | 14 px | 20 px | 0 |
| T7 | Minimum (never below) | 12 px | 16 px | 0 |

### 5.3 Text Rendering Rules

```
Rule T-01: All dialogue text uses Crimson Pro Regular at T4 size on P1/P2 background.
Rule T-02: Italic is used for internal thoughts, lore quotations, and NPC emotional asides only.
Rule T-03: ALL CAPS is used only in Cinzel for UI labels. Never body text.
Rule T-04: No underline. Use I1 colour for emphasis, not underline formatting.
Rule T-05: Choice button text uses Cinzel at T5, left-aligned, with 12 px left padding.
Rule T-06: Font size must never scale below 12 px on any device within our target viewport range.
Rule T-07: Typewriter effect (dialogue_screen.gd) reveals characters left-to-right, no per-glyph animation.
```

### 5.4 Rendered Text on Handwritten Backgrounds

When text is placed over textured parchment:
- Add a 4 px semi-transparent `P1` (at 40% alpha) text shadow offset 1px down-right — not a drop shadow, an **ink bleed** effect.
- Do NOT use Godot's built-in drop shadow at full opacity. Reduce to ≤ 30%.

---

## 6. Stroke & Line Language

### 6.1 The Three Line Types

**Type 1 — Weight Line (Structural)**
- Used for: panel borders, portrait outlines, token silhouettes
- Character: begins thin, swells through body, tapers at end
- Minimum visible length: 8 px
- Brush profile: calligraphy flat-nib simulation

**Type 2 — Scratch Line (Texture / Hatch)**
- Used for: fill hatching, cross-hatch shadows, stipple fields
- Character: short (12–40 px), consistent direction within a region, 10% random angle variance
- Spacing: 14–20 px centre-to-centre at 720p
- Brush profile: dry-brush, opacity 60–80%

**Type 3 — Trace Line (Decorative)**
- Used for: vine tracery in borders, rune inscriptions, cartographic labels
- Character: hairline (1 px), flowing curves, always in `I2` or `A3`
- Application: border inner ring only, not over text

### 6.2 Corner Treatment

All rectangular panels use **overshot corners**: the stroke passes 3–5 px beyond the corner point before stopping. This is the single most important gesture for the "hand-drawn" read at a glance.

```
   Correct:                  Incorrect:
   
   +----→ (overshoot)        +-----+
   |                         |     |
   ↓                         |     |
   (overshoot)               +-----+
```

### 6.3 Line Direction Emotion Map

Use this table when choosing hatch direction for shadow fills:

| Hatch Direction | Emotional Tone | Use For |
|---|---|---|
| Top-left → Bottom-right (45°) | Neutral, stable | Default shadow on panels |
| Top-right → Bottom-left (135°) | Tension, danger | Combat/duel screen overlays |
| Horizontal (0°) | Calm, resigned | Camp screen, journal |
| Vertical (90°) | Reverent, formal | Portrait shadow fills |
| Random / Chaotic | Fear, madness | Act 3 horror zones (use sparingly) |

---

## 7. Texture Treatment

### 7.1 Base Texture Layers

Every non-transparent surface uses a layered approach:

```
Layer 4: Content (text, icons, portraits)              opacity: 100%
Layer 3: Ink detail (hatching, borders, strokes)       opacity: 100%
Layer 2: Stain / variation (watercolour bleed)         opacity: 15–25%
Layer 1: Paper grain (tileable noise texture)          opacity: 20–35%
Layer 0: Base colour fill (from palette)               opacity: 100%
```

### 7.2 Paper Grain Specification

- Source: `assets/images/ui/paper_grain.png` (tileable, 256×256, greyscale)
- Blend mode: **Multiply** (darkens paper, preserving base colour)
- Opacity: 20–35% depending on surface darkness
- Scale: 1:1 at 720p (do not scale the grain texture)
- **Generation command** (ImageMagick, already in `generate_placeholder_sprites.py` pattern):
  ```bash
  convert -size 256x256 plasma:grey -blur 0x0.5 \
    -level 40%,90% -depth 8 assets/images/ui/paper_grain.png
  ```

### 7.3 Ink Wash Shader Reference

The `assets/shaders/ink_wash.gdshader` should implement the following stages:

```
Stage 1 — Paper base:     Apply paper_grain.png as multiply at 25%
Stage 2 — Edge darkening: Increase contrast within 3 px of silhouette edge
Stage 3 — Dither:         Bayer 4×4 ordered dither on mid-tone regions (30–70% value)
Stage 4 — Vignette:       Radial darkening, I2 colour at 35% opacity, radius 80% of screen
Stage 5 — Wobble:         Offset UV by sin(uv.x * 40) * 0.002 — simulates uneven dip-pen line
```

Shader parameters exposed as uniforms:
- `edge_wobble_strength: float = 0.002` (0 = disable for reduced-motion)
- `dither_intensity: float = 0.6` (0–1)
- `vignette_strength: float = 0.35` (0–1)
- `grain_opacity: float = 0.25` (0–1)

> **Reduced motion:** When `UIAdapt.is_reduced_motion()` is true, set `edge_wobble_strength = 0.0`.

### 7.4 Stain Variation

Panels should have subtle watercolour stain variation — not uniform fills. Implementation options:

**Option A (Shader):** Add a low-frequency Voronoi noise layer in the ink-wash shader at 15% multiply.  
**Option B (Pre-baked):** Supply the panel background as a PNG with stain variation already painted — preferred for performance on mobile.

For Option B, provide two stain variants per panel type (`_a` and `_b` suffix). The game randomly selects at panel instantiation for variety.

---

## 8. Component Specifications

### 8.1 Panel / Window

```
┌─────────────────────────────────┐  ← outer stroke: 4px, I1 colour, overshot corners
│░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│  ← paper grain layer (20% multiply)
│  ┌───────────────────────────┐  │  ← inner tracery border: 1px, A3 colour
│  │ Panel content area        │  │
│  │                           │  │
│  └───────────────────────────┘  │
│░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
└─────────────────────────────────┘

Background fill:  P2 (#D4BE94) with paper grain layer
Outer border:     I1 (#1A1410), 4px, overshot corners
Inner tracery:    A3 (#CFC3A8), 1px vine/line decorative rule
Corner ornament:  Small ink flourish (4×4 px minimum, 8×8 preferred)
Padding (inner):  16 px all sides (minimum)
Border radius:    0 px (no rounded corners — this is a manuscript)
```

**Panel States:**
- **Default:** As above
- **Focused/Active:** Outer border shifts to G2 `#A8863C` + subtle G5 background tint
- **Disabled:** Entire panel at 50% opacity, cross-hatch overlay at 20% opacity
- **Danger:** Thin R1 inner border line added inside tracery

### 8.2 Dialogue Panel

Extends the base panel. Specific dimensions for `dialogue_screen.tscn`:

```
Portrait panel:   280×420 px (at 720p logical)
Dialogue panel:   680×400 px (at 720p logical)
Gap between:      20 px
Text area:        Dialogue panel minus 32 px padding all sides
Choice container: Bottom 200 px of dialogue panel, separated by 1px A3 divider
Name label:       T3 (24px), Cinzel, I1, above portrait, centred
Speaker switch:   When non-primary NPC speaks, portrait panel tints to P3 as visual cue
```

**Disposition Bar (inside portrait panel, below portrait):**
```
Height:        12 px
Width:         Portrait panel width minus 32 px
Fill left:     R1 (#8C2F2F) — hostile end
Fill centre:   P5 (#A89070) — neutral
Fill right:    B2 (#4A8A8A) — trusted end
Marker:        2px I1 vertical line at current disposition position
Border:        1px I2, overshot corners on left and right only
Background:    P3 (#BFA880)
```

### 8.3 Button — Standard

```
Height:        84 px minimum (touch target rule)
Width:         100% of container minus 16 px margin each side
Background:    P1 (#E8D5B0), paper grain layer
Border:        2px G2 (#A8863C), overshot corners
Label:         Cinzel, T5 (16px), I1, left-aligned, 16px left padding
Icon (opt):    20×20 px icon, right of label, 8px gap, I2 colour

States:
  Default:     As above
  Hover:       Background → P3, border → G1, cursor: pointer
  Pressed:     Background → P3, border → G4, scale: 0.96 (gothic_button.gd)
  Focused:     Border → G1 2px + 1px G5 outer glow outline
  Disabled:    Opacity 50%, cross-hatch overlay fill (20%), no interaction
```

### 8.4 Choice Button — Dialogue

Extends Standard Button. Additional tint by `choiceType`:

| Choice Type | Background Tint | Border Override | Text Colour |
|---|---|---|---|
| `defer` | P2 (no tint) | G2 | I1 |
| `help` | B2 at 15% overlay | B1 | I1 |
| `empathize` | B2 at 15% overlay | B1 | I1 |
| `vow` | B1 at 20% overlay | G1 (gold) | I1 |
| `threaten` | R1 at 15% overlay | R1 | I1 |
| `demand` | R1 at 15% overlay | R1 | I1 |
| `lie` | I2 at 10% overlay | I3 | I1 |
| `conceal` | I2 at 10% overlay | I3 | I1 |
| `inquire` | P2 (no tint) | A3 | I1 |

### 8.5 Tab / TabContainer

```
Tab (active):     P1 background, G2 bottom border 3px, I1 label
Tab (inactive):   P3 background, A3 bottom border 1px, I3 label at 70% opacity
Tab height:       44 px
Tab min width:    100 px
Separator:        1px A3 between tab bar and content area
```

### 8.6 ScrollBar

```
Track:     P3, 8px wide, 1px I2 border
Thumb:     P5, rounded-not-round (2px corner radius max), min height 40px
Arrows:    None (swipe to scroll on mobile)
```

### 8.7 Progress Bar (Disposition, Quest Objectives)

See §8.2 for disposition bar. Quest objective bar:

```
Height:    8 px
Width:     Full container
Fill:      G1 (#C9A84C) left-to-right
Background: P3
Border:    1px I2
Corner:    0 px radius
```

### 8.8 Toast Notification (toast_layer.gd)

```
Background:  P2 at 92% opacity
Border:      2px I2, overshot corners
Text:        Crimson Pro, T5 (16px), I1, centred
Width:       360 px
Height:      min 56 px, auto-expand for long text
Position:    Centre-top, 24 px from top edge
Entry anim:  Fade in 0.2s (skip if reduced-motion)
Exit anim:   Fade out 0.3s (skip if reduced-motion)
```

---

## 9. NPC Portraits

### 9.1 Portrait Dimensions

| Use | Canvas Size | Visible Head+Shoulders Crop |
|---|---|---|
| Dialogue screen | 248×380 px | 70% head, 30% shoulders |
| Overhead map token | 64×64 px | Silhouette only |
| Journal entry (small) | 80×80 px | Head only |

### 9.2 Portrait Style Rules

**Mandatory per portrait:**

1. **Ink outline:** Weight line (Type 1, §6.1), 3 px average, directional — strokes on the shadow side heavier than light side.
2. **Value structure:** Three value zones only — Light (P4), Mid (P2/P3), Dark (I2). No gradients.
3. **Watercolour wash:** Each portrait has one primary hue wash (20–35% opacity, flat, inside outline).
4. **Cross-hatch shadow:** Vertical hatch (see §6.3) on shadow regions at 45°–90° direction.
5. **Eye treatment:** Eyes are ink-heavy. Use 2× the stroke weight of surrounding face detail.
6. **Background:** Oval frame (`frame_oval.png`), A3 colour inner background.

**Archetype visual language:**

| Archetype | Visual Marker | Stroke Character |
|---|---|---|
| `SHIFTING_THE_BURDEN` | Slight downward gaze, heavy lower eyelids | Heavier strokes at base/jaw |
| `ESCALATION` | Direct frontal gaze, tension lines at brow | Radiating strokes outward from face |
| Faction Leader | Formal framing, symmetrical composition | Consistent, controlled weight |
| Player-allied | Warmer wash (amber tint), lighter hatching | Lighter overall, softer edges |

### 9.3 Disposition-Linked Portrait Tinting

The Godot scene `dialogue_screen.gd` applies `_refresh_disposition()` to the portrait TextureRect modulate. Art direction for each range:

| Disposition Range | Tint Applied | Visual Intent |
|---|---|---|
| `> 0.5` (Trusted) | B2 `#4A8A8A` at 20% modulate | Warm, welcoming |
| `0.2 – 0.5` (Friendly) | None (natural) | Neutral, open |
| `-0.2 – 0.2` (Neutral) | None (natural) | Guarded |
| `-0.5 – -0.2` (Cold) | I2 `#3D2B1F` at 15% modulate | Shadowed, withdrawn |
| `< -0.5` (Hostile) | R1 `#8C2F2F` at 25% modulate | Menacing, bloodied |

> **Note:** These modulate values are code-side (already in `dialogue_screen.gd _refresh_disposition()`). The portrait art itself should be painted for neutral disposition; tinting handles the rest. Do not paint disposition-specific versions.

### 9.4 Known NPC Portrait Art Direction Notes

| NPC ID | Name | Primary Wash Hue | Archetype | Notes |
|---|---|---|---|---|
| `aria` | Aria | Teal-grey (`#5A8080`) | `SHIFTING_THE_BURDEN` | Downcast eyes, many fine-line details on clothing |
| `elena` | Elena | Warm amber (`#C47820`) | Faction Leader | Symmetrical, formal, high collar |
| `hollow_king` | The Hollow King | Ash-violet (`#5A3870`) | Unique | Near-silhouette; 90% dark values, crown as key identifier |
| `marcus` | Marcus | Warm ochre (`#A87828`) | `ESCALATION` | Tension lines at brow, direct gaze, battle-worn |
| `thorne` | Thorne | Cold slate (`#485070`) | `ESCALATION` | Angular jaw, high contrast, minimal mid-tones |
| `vessa` | Vessa | Green-grey (`#507050`) | `SHIFTING_THE_BURDEN` | Soft edges, tilted head, many imperfections deliberately |
| `warden` | Warden | Iron grey (`#606060`) | Faction Leader | Faceless or masked — silhouette dominant, no eye contact |

---

## 10. Map & World Art

### 10.1 Overhead Map Visual Language

The overhead map is a **cartographic illustration** — it should read as a hand-drawn field atlas page.

```
Background:     P2 (#D4BE94) — aged parchment
Grain layer:    paper_grain.png at 30% multiply
Terrain tiles:  Painterly ink-wash fills (see §10.2)
Node connections: A3 (#CFC3A8) 1–2px dashed lines, slight bow/arc — hand-ruled
Grid:           None visible
Compass rose:   Decorative ink illustration, bottom-right corner
Border:         Map edge has torn-paper effect (irregular alpha at edges)
Scale marker:   Small cartographic text in Courier Prime T7
```

### 10.2 Terrain Tile Style

Each tile in `assets/images/map_tiles/`:

| Tile ID | Colour Base | Fill Technique | Notes |
|---|---|---|---|
| `tile_parchment` | P2 `#D4BE94` | Flat + grain | Base terrain, most of map |
| `tile_ash` | A1 `#8C8278` | Stipple over P2 | Blighted zones, Act 1 wasteland |
| `tile_stone` | `#707068` | Horizontal hatch | Fortresses, roads |
| `tile_water` | `#3A5A6A` | Wavy horizontal lines | Rivers and coast |
| `tile_shore` | P2 + `#3A5A6A` blend | Stipple transition | Coastal blend between water/parchment |

### 10.3 Map Node Token States

Each state in `assets/images/map/map_ruins_<state>.png`:

| State | Visual Treatment | Colour Key |
|---|---|---|
| `neutral` | Ink silhouette, A1 fill, A3 border | A1/A3 |
| `active` | G1 glow aura (4px bloom ring), I1 outline, P1 fill | G1/I1 |
| `completed` | A2 fill, I3 border, small checkmark-flourish overlay | A2/I3 |
| `blocked` | 45° cross-hatch over token, R1 X mark overlay | R1/I2 |
| `failed` | R2 fill, R1 border, downward scratches | R1/R2 |
| `hidden` | Near-invisible: A1 fill at 30% opacity, no border, slight shimmer (shader) | A1 (30%) |

**Token silhouette:** Ruin/castle shape, 48×48 px inner silhouette on 64×64 canvas, 8px padding all sides.

### 10.4 NPC Token Style

NPC tokens (`assets/images/npcs/tokens/token_<id>.png`):

```
Canvas:        64×64 px
Silhouette:    Character bust/head silhouette, I1 colour, ink-weight outline (2–3px)
Fill:          Single flat colour per NPC (see §9.4 primary wash hue)
Background:    Circular P1 background disc, A3 border 1–2px
Disposition:   No art change — tinting handled in code (npc_token.gd modulate)
```

---

## 11. Animation & Motion

### 11.1 Principles

1. **Stillness is the default.** Nothing animates for decoration alone. Motion = information.
2. **Ink physics.** Animations simulate the way ink behaves: it spreads, it bleeds, it dries.
3. **Reduced motion compliance.** Every animation must have a zero-duration/fade fallback tested against `UIAdapt.is_reduced_motion()`.

### 11.2 Approved Animation Catalogue

| Animation | Duration | Easing | Reduced-Motion Alt |
|---|---|---|---|
| Scene fade in/out (SceneSwitcher) | 0.35s | Linear | Skip (instant cut) |
| Button press pulse (gothic_button.gd) | 0.12s | Ease-out | Skip |
| Toast fade in | 0.20s | Ease-out | Instant show |
| Toast fade out | 0.30s | Ease-in | Instant hide |
| Node token active pulse (map) | 1.5s loop, scale ±2% | Sine | Skip loop (static) |
| Disposition bar fill | 0.4s | Ease-out | Instant |
| Act transition | 1.0s ink-wash wipe | Custom shader | 0.35s fade |
| Typewriter text | Per-character, 0.04s default | Stepped | Full text instant |
| Portrait disposition tint | 0.5s | Ease-in-out | Instant |
| Portrait entry slide | 0.25s from left | Ease-out | Skip |
| Camp screen night cycle (ambient) | 4.0s loop, subtle light shift | Sine | Skip |

### 11.3 Typewriter Specification

Already implemented in `dialogue_screen.gd`. Art direction note:
- Speed range: 0.01s (fastest) – 0.5s (slowest) per character
- Default: 0.04s
- Skip trigger: screen tap/click — jumps to full text (one tap shows all, not dismiss)
- Sound: no per-character sound (would be irritating on mobile) — only optional "page turn" sound at node end

---

## 12. Accessibility Checklist

Before any asset is approved for integration, it must pass all items in this list.

### Visual

- [ ] All body text meets 4.5:1 contrast ratio minimum (use §4.4 pre-computed values)
- [ ] No information is conveyed by colour alone (state differences also use shape/pattern)
- [ ] All interactive elements are minimum 84×84 px touch target
- [ ] Disposition bar has both colour fill AND a numerical/positional marker
- [ ] Map node states differ in silhouette shape OR pattern, not colour alone
- [ ] Font size minimum 12 px (T7) respected throughout

### Motion

- [ ] All animations check `UIAdapt.is_reduced_motion()` before running
- [ ] Looping animations (node pulse, camp ambient) have explicit pause capability
- [ ] No strobing effects or rapid flicker animations (>3 Hz) anywhere

### Content

- [ ] NPC names always visible in dialogue (not assumed from context)
- [ ] All toast messages are ≤ 2 lines at default font size
- [ ] Disposition bar includes tooltip/label on tap (future — mark as backlog)

---

## 13. Asset Production Acceptance Criteria

This section defines the **acceptance gate** for each asset type. An asset is production-ready only when it passes all criteria for its type.

### 13.1 General Acceptance (All Assets)

| Criterion | Pass Condition |
|---|---|
| Palette compliance | All colours are within ±5° hue / ±10% lightness of an approved palette entry |
| Stroke character | At least one overshot corner or deliberate stroke irregularity visible |
| Imperfection budget | At least two items from §3.4 checklist are present |
| Texture layer | Paper grain visible at 100% zoom |
| File format | PNG-24 (with alpha where needed), exported at 720p logical resolution |
| File naming | Matches manifest naming convention exactly (e.g., `portrait_aria.png`) |
| File size | ≤ 512 KB per image. Portrait max 1 MB. |

### 13.2 NPC Portrait Acceptance

| Criterion | Pass Condition |
|---|---|
| Value structure | Passes the "squint test" — readable at 50% size in greyscale |
| Oval frame | Uses the `frame_oval.png` template, properly masked |
| Eye treatment | Eyes have 2× stroke weight relative to face detail |
| Archetype marker | At least one visual marker from §9.4 is present |
| Neutral state | Art depicts neutral disposition (no tinting applied at source) |
| Background | Oval framed, A3 inner background, consistent across all portraits |

### 13.3 Map Node Token Acceptance

| Criterion | Pass Condition |
|---|---|
| Silhouette readability | Recognisable as a distinct state in 32×32 px preview |
| All 6 states | `neutral`, `active`, `completed`, `blocked`, `failed`, `hidden` all delivered |
| State differentiation | Minimum 2 visual cues differ between any two adjacent states |
| Canvas compliance | 64×64 px canvas, 8 px padding, no content in padding zone |

### 13.4 Panel / Background Asset Acceptance

| Criterion | Pass Condition |
|---|---|
| Tileable (if applicable) | Seamless tile with no visible seam at 2× repeat |
| Stain variants | Two variants (`_a`, `_b`) delivered if pre-baked stain method used |
| Dark region | No region below 10% lightness except intentional ink strokes |
| Light region | No region above 95% lightness (no pure white) |

### 13.5 UI Icon Acceptance

| Criterion | Pass Condition |
|---|---|
| Legibility | Recognisable at 20×20 px |
| Monochrome test | Passes in greyscale (no colour-only information) |
| Stroke weight | 1–2 px, consistent within icon |
| Canvas | 32×32 px canvas with 4 px padding |

---

## 14. Appendix: Palette Swatches

See companion file `docs/COLOUR_SWATCHES.md` for rendered swatches with hex, HSL, RGB, and usage notes in a table with CSS colour blocks.

### Quick Reference Card

```
╔══════════════════════════════════════════════════════════════════╗
║          CHIMERA: ASHES OF THE HOLLOW KING — COLOUR QUICK REF   ║
╠══════════════════════════════════════════════════════════════════╣
║  PARCHMENT                  INK                                  ║
║  P1 █ #E8D5B0  Primary      I1 █ #1A1410  Primary Ink           ║
║  P2 █ #D4BE94  Aged         I2 █ #3D2B1F  Sepia                 ║
║  P3 █ #BFA880  Dark         I3 █ #5C4433  Faded                 ║
║  P4 █ #F2E8D2  Pale Vellum  I4 █ #4A2E1E  Rust (error)         ║
║  P5 █ #A89070  Linen Shadow  I5 █ #252830  Storm (combat)       ║
║  P6 █ #EDE8E0  Ash White                                         ║
╠══════════════════════════════════════════════════════════════════╣
║  GOLD (INTERACTIVE)         ASH / BONE                           ║
║  G1 █ #C9A84C  Antique      A1 █ #8C8278  Ash Grey              ║
║  G2 █ #A8863C  Burnished    A2 █ #504844  Deep Ash              ║
║  G3 █ #DFC278  Pale         A3 █ #CFC3A8  Bone                  ║
║  G4 █ #7A5E28  Dark                                              ║
╠══════════════════════════════════════════════════════════════════╣
║  STATE COLOURS              ACT ACCENTS (MAP ONLY)               ║
║  R1 █ #8C2F2F  Hostile      E1 █ #C47820  Act 1 Amber           ║
║  R2 █ #5E1A1A  Danger       E2 █ #4A5870  Act 2 Slate           ║
║  B1 █ #2E5C5C  Trusted      E3 █ #5A3870  Act 3 Violet          ║
║  B2 █ #4A8A8A  Positive                                          ║
╚══════════════════════════════════════════════════════════════════╝
```

---

*This document is the acceptance gate for all visual asset production in Chimera: Ashes of the Hollow King. Assets may not enter the integration pipeline without review against the criteria defined in §13.*

*Last reviewed: Style Guide v1.0*  
*Next review trigger: Act 2 asset batch kickoff, or any palette change request.*
