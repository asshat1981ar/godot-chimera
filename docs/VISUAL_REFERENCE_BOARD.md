# Chimera: Ashes of the Hollow King — Visual Reference Board

**Version:** 1.0  
**Purpose:** Collected visual reference analysis for hand-drawn UI style production  
**Companion to:** `docs/ART_STYLE_GUIDE.md`, `docs/COLOUR_SWATCHES.md`

---

> This document serves as a written reference board — a substitute for a Figma moodboard where screenshots cannot be embedded. Each section describes precisely what to look at and why, with enough detail that an artist can source the references independently and understand the intended extraction.

---

## How to Use This Document

1. **Source the references** using the titles and scene descriptions provided.
2. **Extract** the named traits — each entry explains *where* in the reference the trait is visible.
3. **Apply** using the Art Style Guide rules (cross-referenced by section).
4. **Do not copy** style wholesale from any reference — treat each as a single trait extraction.

---

## Reference Category 1: Panel & Border Language

### REF-B01: Pentiment (2022) — Manuscript Page Layout
**Source:** Any "reading a document" screen in Pentiment (e.g., the prologue letter-reading scene).  
**What to look at:** The border of the vellum page as it sits on the table. Notice the very slight irregularity in the ink line that forms the manuscript border — it is not a Photoshop stroke. It was drawn. The corners slightly overshoot.  
**Trait extracted:** Overshot corner rule (§6.2), Inner tracery border (§8.1)  
**Danger:** Do not copy the fully animated "ink appearing" effect for our static panels. Static = our version.

---

### REF-B02: Slay the Spire (2019) — Card Border
**Source:** Any card in the base deck display. Look at the outer gold engraving frame.  
**What to look at:** The frame is embossed — it has a light upper-left edge and a darker lower-right edge, suggesting it is carved/raised. The texture of the card background (parchment/linen) is visible through the semi-transparent fill.  
**Trait extracted:** Panel rim highlight (dry-brush upper-left, §3.5), `frame_gold.png` production spec (§8.1)  
**Adaptation:** Our frame is lighter, less ornate. One engraved groove, not three.

---

### REF-B03: Pyre (2017) — Book/Scripture Panel
**Source:** Any "reading the Book of Rites" scene. The panel used to display lore text.  
**What to look at:** The inner border has a vine-and-thorn tracery running along the inside of the outer border. It is one pixel wide. The outer border is heavier (3–4px equivalent). The content area has no border — the tracery IS the border.  
**Trait extracted:** Inner tracery border spec (§8.1), Type 3 trace line (§6.1)  
**Colour match:** Our tracery uses A3 `#CFC3A8` (Bone), slightly warmer than Pyre's.

---

### REF-B04: Sunless Sea (2015) — Port Screen Panel
**Source:** Any harbour or port interaction screen. The information panel listing port stats.  
**What to look at:** The panel has a very thin gold divider line between sections. The background texture shows a linen weave. The overall feel is "gazette" — a printed publication, not a hand-drawn manuscript.  
**Trait extracted:** Section divider style (§8.5 tab separator), P5 divider colour (§4.2)  
**Adaptation:** Our dividers are A3 (Bone), not gold — gold is reserved for interactive elements only.

---

## Reference Category 2: NPC Portrait & Character Art

### REF-P01: Darkest Dungeon (2016) — Hero Portraits
**Source:** The hero selection/roster screen. Any hero portrait (Crusader recommended for clarity).  
**What to look at:** The portrait is lit from upper-left. The shadow side (lower-right) has visible parallel hatching. The outline is NOT uniform — it is heavier on the shadow side and thins at highlights. The eye is drawn with extra-thick ink — two to three times the weight of the surrounding face detail.  
**Trait extracted:** Portrait directional lighting (§9.2), Eye treatment rule (§9.2), Stroke direction emotion map (§6.3)  
**Colour match:** Darkest Dungeon's palette is more red-shifted; ours is warmer amber. Same darkness principle.

---

### REF-P02: Hollow Knight (2017) — NPC Stained Glass / Dream Sequence Portraits
**Source:** When talking to Hornet (first encounter). Her portrait-style introduction frame.  
**What to look at:** The silhouette is clean ink — pure black. The fill inside the silhouette is a single flat watercolour hue (grey-blue for Hornet). No gradient. The outline reads perfectly at very small sizes because the silhouette contrast is total.  
**Trait extracted:** Portrait silhouette-first rule (§9.2), Token silhouette style (§10.4), Flat colour wash fill (§3.3)  
**Key lesson:** Strong silhouette = reads at 64×64 px. Always test portraits at token size.

---

### REF-P03: Disco Elysium (2019) — Skill Check Portrait Illustrations
**Source:** Any "thought cabinet" or "thought" artwork. Each thought has an expressionist illustration.  
**What to look at:** The watercolour wash bleeds slightly outside the ink outline on one or two edges (top/left typically). This is intentional — it creates the impression the ink was laid over wet paint. The composition always has a strong focal element (one object or face) and a muted/simplified background.  
**Trait extracted:** Ink bleed outside outline (§3.4 imperfection budget item 5), Focal point discipline (§9.2)  
**Adaptation:** Our bleed is subtle (1–2px) and appears at maximum one corner per portrait.

---

### REF-P04: Pentiment (2022) — Character Face Close-Ups
**Source:** Any extended conversation with Brother Illuminator. His face during emotional moments.  
**What to look at:** His expression changes are communicated entirely through eyebrow angle and mouth set. The face has four value zones maximum: light skin, shadow, beard dark, eye dark. When he is distressed, the hatching lines on his face angle downward more steeply. When curious, they lift.  
**Trait extracted:** Value structure (three zones, §9.2), Stroke direction emotion map applied to faces (§6.3)  
**Direct application:** Thorne's portrait should use the "tension lines" pattern from this reference.

---

## Reference Category 3: Map & Cartographic Art

### REF-M01: Sunless Sea (2015) — The Neath Chart
**Source:** The main world map at any point mid-game.  
**What to look at:** Islands are drawn as engraved silhouettes — slight hatching on the interior to suggest topology. Connections between ports are drawn as dotted lines with a slight bow (not perfectly straight). Station names are rendered in a condensed serif font resembling copperplate. The ocean fill is a repeating pattern of horizontal wavy lines (like a medieval sea chart). A compass rose sits in one corner.  
**Trait extracted:** Map connection line style (§10.1), Cartographic typography (§5.1 Courier Prime for map labels), Terrain tile water style (§10.2), Compass rose requirement (§10.1)  
**Key rule:** Map labels use Courier Prime T7 (12px minimum), never Cinzel (too formal for field annotations).

---

### REF-M02: Hollow Knight (2017) — Cornifer's Maps
**Source:** Any discovered map in the player's inventory. The hand-drawn map of Forgotten Crossroads.  
**What to look at:** The map is clearly drawn on paper — it has a slight paper texture underneath. Unexplored areas are lighter or absent. The paths between rooms are single lines, not corridors. Room shapes are abstracted, not architectural. Ink colour is sepia (warm dark brown), not black.  
**Trait extracted:** Map ink colour = I2 `#3D2B1F` (Sepia Ink) not I1 (§10.1), Abstracted node-as-silhouette (§10.3), Fog of exploration (hidden node style §10.3)  
**Direct application:** All overhead map connection lines use I2, not I1.

---

### REF-M03: Darkest Dungeon (2016) — Region Select Screen
**Source:** The hamlet/region overview screen.  
**What to look at:** Each dungeon icon is a detailed ink woodcut. The active dungeon glows with a dim amber light — not a bloom, but a painted halo around the icon. Locked/unavailable dungeons have a cross-hatch overlay at approximately 40% opacity, reducing their visual presence without removing them from view.  
**Trait extracted:** Active node glow = painted halo not bloom (§10.3 active state), Blocked node cross-hatch overlay (§10.3 blocked state), Disabled state visual treatment (§8.1 panel disabled state)  
**Colour match:** Our halo uses G1 `#C9A84C` (Antique Gold). Darkest Dungeon uses a more orange amber — ours is slightly more yellow/gold.

---

### REF-M04: Pyre (2017) — The Downside Map
**Source:** The overworld map traversal screen at any point in Act 2.  
**What to look at:** The sky/background is a very deep gradient (near-black at top, deep indigo at horizon) with faint star-like speckles. The terrain is flat illustration without 3D relief. Connection paths have animated dust motes along them — we take the style of the path (thin, slightly curved) but skip the animation.  
**Trait extracted:** Map background sky gradient colours (§10.1, using I5 `#252830` to P2 `#D4BE94` for our day-lit version), Path style (§10.1 connection lines), Ambient particle style for overhead map (§2.4)

---

## Reference Category 4: Dialogue & Text UI

### REF-D01: Disco Elysium (2019) — Dialogue Panel
**Source:** Any extended conversation. The main dialogue text panel.  
**What to look at:** The panel background is a very dark, nearly transparent surface — text sits almost directly on the environment. However, there is a very thin border line (1px) at the top and bottom of the panel only — no left/right border. Text uses a wide-set condensed serif. Speaker name is in a distinctly different colour (slightly gold/amber) from the body text.  
**Trait extracted:** Speaker name in G1 (Antique Gold) separate from body text (§8.2), Minimal chrome philosophy for dialogue (§8.2), Wide leading for body text (§5.2 T4 line height 28px)  
**Adaptation:** We have more chrome than Disco Elysium (portrait + panel) but the text area within our dialogue panel should feel as uncluttered as theirs.

---

### REF-D02: Pentiment (2022) — Choice Presentation
**Source:** Any dialogue choice moment. Andreas is presented with 2–4 choices.  
**What to look at:** Each choice has a small decorative mark to its left (a period, a fleuron, or a pointing hand — "manicule"). The choices are NOT in buttons — they are in the running text. However, they are visually distinguished by a slightly different ink weight and a marginal marker. When hovering, the entire choice line gets a light parchment highlight.  
**Trait extracted:** Choice button left-padding margin (§8.3, 16px left padding simulates the text-margin feel), Decorative marker for choices (add small I2 "❧" or "→" icon at left of choice label in dialogue screen)  
**Adaptation:** We use actual buttons (mobile touch target requirement) but style them to feel like manuscript selections, not app buttons.

---

### REF-D03: Sunless Skies (2019) — Event Card Text
**Source:** Any random event card presentation.  
**What to look at:** The event description text uses very wide line-height (nearly 1.6× the font size). Paragraphs are separated by a thin ink rule — not whitespace alone. The first paragraph has a drop cap (an enlarged first letter). Italics are used for any in-world sound or environmental detail.  
**Trait extracted:** Body text leading (§5.2 T4 at 28px for 18px text = 1.56× ratio), Italic usage rules (§5.3 Rule T-02), Section rule divider (§8.5)  
**Note:** Drop caps are a "stretch goal" for journal entries — not required for v1.0 asset production.

---

## Reference Category 5: Combat & Duel UI

### REF-C01: Darkest Dungeon (2016) — Combat Turn UI
**Source:** Any combat encounter. The hero/enemy selection bar at the bottom.  
**What to look at:** The combat UI background is nearly black (charcoal, not flat black). It has a heavy vignette — the centre is lighter than the edges. Active hero slots glow with a thin gold/yellow line. Inactive slots are cross-hatched or darkened. The skill buttons are styled like metal tags — not like app buttons.  
**Trait extracted:** Duel screen background = I5 `#252830` (§4.2), Combat active highlight = G1 (§10.3 active state), Heavy vignette on combat screens (§7.3 shader vignette stage 4)

---

### REF-C02: Slay the Spire (2019) — Intent Icons
**Source:** Any combat with an elite or boss enemy. The intent icon above the enemy.  
**What to look at:** Each intent type (attack, defend, buff, debuff) has a distinct silhouette icon — not text. The icons are flat, single-colour, readable at 24×24 px. They are always in the same position (above the enemy) so the player builds muscle memory for their location.  
**Trait extracted:** Combat stance icon style (§13.5 icon spec — 32×32 canvas, 4px padding, silhouette), Icon position consistency for stance UI  
**Direct application:** `STRIKE`, `WARD`, `FEINT` stance icons in `assets/images/combat/` follow this silhouette-first, flat-colour approach.

---

### REF-C03: Obra Dinn (2018) — Fate Resolution Screen
**Source:** The moment a fate is "resolved" in the fate book. The black-and-white scene freeze.  
**What to look at:** The entire screen converts to a Bayer-dithered monochrome representation. The dither pattern is regular (not noise) — you can see the ordered grid structure. At the boundary of very light and very dark areas, the dither creates a half-tone effect.  
**Trait extracted:** Dither pattern for the ink-wash shader (§7.3 Stage 3), Cross-hatch shadow fills at high density resembling dither (§3.3 cross-hatch), Blocked node visual treatment (§10.3)

---

## Reference Category 6: Motion & Transition

### REF-A01: Pentiment (2022) — Act Transition "Book Turn"
**Source:** Moving between acts/chapters. The scene where pages appear to turn.  
**What to look at:** The transition is a wipe from left-to-right with an ink appearance (the new page "writes itself" in). The wipe edge has an irregular, brush-stroke shape — not a straight line. It is never faster than 0.8 seconds.  
**Trait extracted:** Act transition style — ink-wipe direction (§11.2 Act transition, 1.0s duration), Wipe edge = brush-stroke shape not linear (act_transition.gd implementation note)  
**Reduced motion:** Skip the wipe entirely, use standard 0.35s fade (SceneSwitcher default).

---

### REF-A02: Hollow Knight (2017) — Scene Entry Fade
**Source:** Entering any new room. The transition from dark tunnel to lit room.  
**What to look at:** A black screen fades in very quickly (0.25s). There is no animation on the fade itself — it is linear opacity. The simplicity is the point: you are in a new place, without theatrical fanfare.  
**Trait extracted:** Scene fade duration baseline = 0.25–0.35s (§11.2 SceneSwitcher), Linear easing for general fades (§11.2 scene fade row)

---

### REF-A03: Disco Elysium (2019) — Skill Check Pop-In
**Source:** Any skill check that succeeds or fails. The large text that appears ("SUCCESS" / "FAILURE").  
**What to look at:** The text appears with a slight upward translate (10–15px) over 0.2 seconds, then is fully visible. It does not bounce, scale, or flash. The motion is the minimum needed to attract attention. It disappears with a simple fade.  
**Trait extracted:** Toast notification entry animation baseline (§11.2 toast fade in), General principle: "motion minimum to attract attention" (§11.1 Principle 1)

---

## Reference Summary Matrix

| Reference | Panel | Portrait | Map | Dialogue | Combat | Motion |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| Pentiment | ✅ REF-B01 | ✅ REF-P04 | — | ✅ REF-D02 | — | ✅ REF-A01 |
| Slay the Spire | ✅ REF-B02 | — | — | — | ✅ REF-C02 | — |
| Darkest Dungeon | — | ✅ REF-P01 | ✅ REF-M03 | — | ✅ REF-C01 | — |
| Hollow Knight | — | ✅ REF-P02 | ✅ REF-M02 | — | — | ✅ REF-A02 |
| Obra Dinn | — | — | — | — | ✅ REF-C03 | — |
| Disco Elysium | ✅ REF-B04 | ✅ REF-P03 | — | ✅ REF-D01 | — | ✅ REF-A03 |
| Pyre | ✅ REF-B03 | — | ✅ REF-M04 | — | — | — |
| Sunless Sea/Skies | ✅ REF-B04 | — | ✅ REF-M01 | ✅ REF-D03 | — | — |

---

## What Chimera Is NOT

To prevent scope creep and style drift, the following references were surveyed and **rejected** as primary sources:

| Title | Why Rejected |
|---|---|
| Hades (Supergiant, 2020) | Too polished, too saturated, too contemporary. Beautiful but antithetical to our mood. |
| Divinity: Original Sin 2 (Larian, 2017) | Painterly realism. Our style is 2D illustration, not 3D-rendered. |
| Dead Cells (Motion Twin, 2017) | Pixel art. Our resolution target and style are deliberately non-pixel. |
| Celeste (Extremely OK Games, 2018) | Pixel art with very different emotional register (hope vs. despair). |
| Gris (Nomada Studio, 2018) | Watercolour is gorgeous but too soft, too hopeful, too abstract for our gothic narrative. |
| Baldur's Gate 3 (Larian, 2023) | 3D rendered UI with painterly 2D portraits. Scale of production incompatible with our reference. |
| Elden Ring (FromSoftware, 2022) | 3D rendered; however, its UI chrome (thin gold lines, dark surfaces) is a useful secondary reference for our duel screen only. |

---

*Visual Reference Board v1.0 — Chimera: Ashes of the Hollow King*  
*This document is the sourcing companion for `ART_STYLE_GUIDE.md`. Trait extraction must be traced to a specific reference entry above before being applied to assets.*
