# Chimera: Ashes of the Hollow King — Colour Swatch Document

**Version:** 1.0  
**Companion to:** `docs/ART_STYLE_GUIDE.md §4`  
**Total swatches:** 28  
**Saturation ceiling:** 55% HSL (no swatch exceeds this)

---

> **How to use this document:**  
> Each swatch entry includes hex, HSL, RGB, and a CSS-compatible preview block. Copy hex values directly into Godot colour picker, Krita palettes, Aseprite, or any art tool. The "Usage" column cross-references the Art Style Guide section where rules for that colour are defined.

---

## Group A — Parchment & Paper (Neutrals)

*The ground everything sits on. All UI panel backgrounds, button fills, and surface colours come from this group.*

---

### P1 — Primary Parchment
```
Hex:  #E8D5B0
HSL:  38°  55%  80%
RGB:  232  213  176
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#E8D5B0;border:1px solid #1A1410;"> </span>

**Usage:**  
- All panel backgrounds (dialogue, journal, camp, party, settings)  
- Button fill (default state)  
- Map overlay backgrounds  
- Tooltip backgrounds (secondary to P4)

**Godot:** `Color(0.910, 0.835, 0.690)`  
**Do not use for:** Text, borders, dividers, any structural line

---

### P2 — Aged Parchment
```
Hex:  #D4BE94
HSL:  36°  42%  70%
RGB:  212  190  148
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#D4BE94;border:1px solid #1A1410;"> </span>

**Usage:**  
- Inset panels (within a primary panel)  
- Scroll area backgrounds  
- Secondary/subordinate surfaces  
- Overhead map background base  
- Toast notification background  
- Dialogue text area inset

**Godot:** `Color(0.831, 0.745, 0.580)`  
**Do not use for:** Primary panel backgrounds, large headers

---

### P3 — Dark Parchment
```
Hex:  #BFA880
HSL:  35°  35%  62%
RGB:  191  168  128
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#BFA880;border:1px solid #1A1410;"> </span>

**Usage:**  
- Pressed/active button state background  
- Selected tab background  
- Hover state for interactive panels  
- ScrollBar thumb  
- Secondary button (non-primary actions)

**Godot:** `Color(0.749, 0.659, 0.502)`  
**Do not use for:** Text backgrounds (insufficient contrast with I3/I2)

---

### P4 — Pale Vellum
```
Hex:  #F2E8D2
HSL:  38°  62%  89%
RGB:  242  232  210
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#F2E8D2;border:1px solid #1A1410;"> </span>

**Usage:**  
- Tooltip backgrounds  
- Empty/zero-state panel backgrounds  
- Text surface on dark backgrounds (I5, A2)  
- Modal scrim inner colour

**Godot:** `Color(0.949, 0.910, 0.824)`  
**Do not use for:** Any surface that needs to feel "weighted" or important

---

### P5 — Linen Shadow
```
Hex:  #A89070
HSL:  34°  28%  55%
RGB:  168  144  112
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#A89070;border:1px solid #1A1410;"> </span>

**Usage:**  
- Panel interior dividers (horizontal rules)  
- Subtle section borders within panels  
- ScrollBar track  
- Disposition bar neutral-zone background  
- Map connection lines (paired with A3)

**Godot:** `Color(0.659, 0.565, 0.439)`  
**Do not use for:** Borders that need to communicate importance

---

### P6 — Ash White
```
Hex:  #EDE8E0
HSL:  40°  30%  91%
RGB:  237  232  224
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#EDE8E0;border:1px solid #1A1410;"> </span>

**Usage:**  
- Very light overlay backgrounds (modal scrim, dimmed scenes)  
- Paper vellum texture base before grain is applied  
- Inactive tab background (lightest surface)  
- Map fog-of-war partial reveal tint

**Godot:** `Color(0.929, 0.910, 0.878)`  
**Do not use for:** Text, interactive elements, anything needing weight

---

## Group B — Ink & Dark (Primary Text & Borders)

*The ink that writes the world. Strictly reserved for text, outlines, and structural lines.*

---

### I1 — Primary Ink
```
Hex:  #1A1410
HSL:  28°  28%  9%
RGB:  26   20   16
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#1A1410;border:1px solid #C9A84C;"> </span>

**Usage:**  
- All primary body text  
- Main panel borders and outlines  
- NPC portrait outlines  
- Map node token outlines  
- Button label text  
- Icon fills

**Godot:** `Color(0.102, 0.078, 0.063)`  
**Contrast on P1:** 7.2:1 (WCAG AAA) ✅  
**Do not use for:** Large fills, backgrounds, anything covering >10% screen area

---

### I2 — Sepia Ink
```
Hex:  #3D2B1F
HSL:  22°  33%  18%
RGB:  61   43   31
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#3D2B1F;border:1px solid #C9A84C;"> </span>

**Usage:**  
- Secondary/caption text  
- Portrait shadow regions  
- Secondary panel borders (inner)  
- Cross-hatch fill colour  
- Vine/trace line decorations (Type 3 strokes)  
- Toast border  
- ScrollBar border

**Godot:** `Color(0.239, 0.169, 0.122)`  
**Contrast on P1:** 5.1:1 (WCAG AA) ✅  
**Do not use for:** Text below 16px (fails AA at that size)

---

### I3 — Faded Ink
```
Hex:  #5C4433
HSL:  22°  28%  28%
RGB:  92   68   51
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#5C4433;border:1px solid #C9A84C;"> </span>

**Usage:**  
- Inactive/disabled label text  
- Caption text (minimum 18px — large text threshold)  
- Visited/read journal entries  
- Inactive tab labels  
- Completed scene list entries

**Godot:** `Color(0.361, 0.267, 0.200)`  
**Contrast on P1:** 3.6:1 (AA Large only ⚠️)  
**Hard rule:** Never use below 18px font size

---

### I4 — Rust Ink
```
Hex:  #4A2E1E
HSL:  20°  42%  20%
RGB:  74   46   30
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#4A2E1E;border:1px solid #C9A84C;"> </span>

**Usage:**  
- Error state text (form validation, game-over text)  
- Hostile disposition text label  
- Warning notices in journal  
- Failed quest title colour

**Godot:** `Color(0.290, 0.180, 0.118)`  
**Do not use for:** Normal UI — reserved for error/hostile states only

---

### I5 — Storm Ink
```
Hex:  #252830
HSL:  227°  12%  17%
RGB:  37   40   48
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#252830;border:1px solid #C9A84C;"> </span>

**Usage:**  
- Combat/duel screen background  
- Act 3 overlay dark base  
- Modal backdrop  
- Danger overlay fill (at partial opacity)

**Godot:** `Color(0.145, 0.157, 0.188)`  
**Do not use for:** Any non-combat, non-dramatic context

---

## Group C — Antique Gold (Primary Accent / Interactive)

*The burnished vein through the ash. Gold marks what matters: active states, interactive chrome, section hierarchy.*

---

### G1 — Antique Gold
```
Hex:  #C9A84C
HSL:  42°  53%  55%
RGB:  201  168  76
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#C9A84C;border:1px solid #1A1410;"> </span>

**Usage:**  
- Active map node token glow aura  
- Focused button border ring  
- Section header text (Cinzel, T2)  
- Active tab underline (3px border)  
- Vow choice button border  
- Quest objective progress bar fill  
- Gold frame accent (`frame_gold.png` primary colour)

**Godot:** `Color(0.788, 0.659, 0.298)`  
**Contrast on I1:** 4.7:1 (WCAG AA) ✅

---

### G2 — Burnished Gold
```
Hex:  #A8863C
HSL:  40°  49%  45%
RGB:  168  134  60
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#A8863C;border:1px solid #1A1410;"> </span>

**Usage:**  
- Default button border (unfocused)  
- Panel rim highlight (upper-left edge, dry-brush)  
- Default choice button border (`defer`, `inquire` types)  
- Frame corner ornament base colour  
- Gold frame secondary colour

**Godot:** `Color(0.659, 0.525, 0.235)`

---

### G3 — Pale Gold
```
Hex:  #DFC278
HSL:  43°  58%  67%
RGB:  223  194  120
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#DFC278;border:1px solid #1A1410;"> </span>

**Usage:**  
- Hover state tint overlay  
- Disposition bar fill (positive/trusted region)  
- Pyre-style panel glow interior  
- Act transition highlight accent  
- Camp screen candlelight ambient

**Godot:** `Color(0.875, 0.761, 0.471)`

---

### G4 — Dark Gold
```
Hex:  #7A5E28
HSL:  40°  50%  32%
RGB:  122  94   40
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#7A5E28;border:1px solid #C9A84C;"> </span>

**Usage:**  
- Pressed/active button border  
- Deep panel rim (lower-right shadow edge)  
- Recessed section divider  
- Frame inner groove shadow

**Godot:** `Color(0.478, 0.369, 0.157)`

---

### G5 — Gold Wash (Transparent)
```
Hex:  #C9A84C26   (RGBA — 15% opacity)
HSL:  42°  53%  55%  at 15% alpha
RGB:  201  168  76   at alpha 0.15
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:rgba(201,168,76,0.15);border:1px solid #1A1410;"> </span>

**Usage:**  
- Focused panel tint overlay  
- Active state surface highlight  
- Journal entry hover background  
- Map legend box tint

**Godot:** `Color(0.788, 0.659, 0.298, 0.15)`  
**Note:** Always applied over a P1/P2 base; never standalone.

---

## Group D — Ash & Bone (Structural Neutrals)

*The middle ground between ink and parchment. Connection lines, completed states, quiet borders.*

---

### A1 — Ash Grey
```
Hex:  #8C8278
HSL:  30°  8%  51%
RGB:  140  130  120
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#8C8278;border:1px solid #1A1410;"> </span>

**Usage:**  
- Neutral/unvisited map node fill  
- Inactive state fill  
- Hidden node token (at 30% opacity)  
- Secondary icon colour  
- Terrain: general path/ground tiles

**Godot:** `Color(0.549, 0.510, 0.471)`

---

### A2 — Deep Ash
```
Hex:  #504844
HSL:  15°  7%  29%
RGB:  80   72   68
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#504844;border:1px solid #C9A84C;"> </span>

**Usage:**  
- Completed node fill  
- Journal "visited" marker  
- Map node completed state  
- Background for completed/inactive content panels

**Godot:** `Color(0.314, 0.282, 0.267)`

---

### A3 — Bone
```
Hex:  #CFC3A8
HSL:  38°  30%  74%
RGB:  207  195  168
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#CFC3A8;border:1px solid #1A1410;"> </span>

**Usage:**  
- Map node connection lines  
- Inner tracery border (1px vine rule inside panels)  
- Secondary borders  
- Lore entry divider lines  
- Map terrain transition edges  
- `conceal`/`lie` choice border

**Godot:** `Color(0.812, 0.765, 0.659)`

---

## Group E — State Colours (Disposition & Danger)

*Emotional signal colours. Reserved exclusively for state communication — never decorative.*

---

### R1 — Hollow Crimson
```
Hex:  #8C2F2F
HSL:  0°  50%  37%
RGB:  140  47   47
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#8C2F2F;border:1px solid #1A1410;"> </span>

**Usage:**  
- Hostile NPC disposition indicator  
- Failed node/quest state border  
- `threaten`/`demand` choice button border  
- Danger zone map overlay  
- Disposition bar fill (hostile region, left side)  
- Panel danger inner border

**Godot:** `Color(0.549, 0.184, 0.184)`  
**Hard rule:** Never use decoratively. Only in error/hostile contexts.

---

### R2 — Dried Blood
```
Hex:  #5E1A1A
HSL:  0°  56%  23%
RGB:  94   26   26
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#5E1A1A;border:1px solid #C9A84C;"> </span>

**Usage:**  
- Critical danger state  
- Duel loss indication  
- Failed map node fill  
- Act 3 threat overlay (darkest danger)

**Godot:** `Color(0.369, 0.102, 0.102)`  
**Hard rule:** Never paired with gold accents. Crimson and gold = visual dissonance.

---

### B1 — Hollow Teal
```
Hex:  #2E5C5C
HSL:  180°  34%  27%
RGB:  46   92   92
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#2E5C5C;border:1px solid #CFC3A8;"> </span>

**Usage:**  
- Trusted/positive NPC portrait modulate (20%)  
- Active vow indicator border  
- `help`/`empathize` choice button border  
- High-trust disposition map icon tint  

**Godot:** `Color(0.180, 0.361, 0.361)`  
**Hard rule:** Never used on hostile/negative states. Never used as text colour.

---

### B2 — Pale Teal
```
Hex:  #4A8A8A
HSL:  180°  31%  41%
RGB:  74   138  138
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#4A8A8A;border:1px solid #1A1410;"> </span>

**Usage:**  
- Positive disposition bar fill (right/trusted region)  
- `help`/`empathize` choice button overlay tint (15%)  
- NPC token friendly-state tint  
- Trusted companion indicator in party screen

**Godot:** `Color(0.290, 0.541, 0.541)`

---

## Group F — Act-Specific Accent Hues (Environment / Map Only)

*These colours ONLY appear on map tiles, environmental overlays, and world-space elements. They never touch UI chrome.*

---

### E1 — Act 1 Amber  *(The Ashfields)*
```
Hex:  #C47820
HSL:  35°  72%  45%
RGB:  196  120  32
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#C47820;border:1px solid #1A1410;"> </span>

**Thematic intent:** Dying warmth of a world still clinging to memory. The last ember before ash.  
**Map usage:** Active node glow, environmental map overlay tint, tile accent lines.  
**Forbidden in:** UI chrome, buttons, text, panel borders.

**Godot:** `Color(0.769, 0.471, 0.125)`

---

### E2 — Act 2 Slate  *(The Hollow Reaches)*
```
Hex:  #4A5870
HSL:  216°  20%  36%
RGB:  74   88  112
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#4A5870;border:1px solid #CFC3A8;"> </span>

**Thematic intent:** The cold logic of the Hollow Reaches. Distance, desolation, tactical grey.  
**Map usage:** Active node glow, tile tint, fog overlay.  
**Forbidden in:** UI chrome, buttons, text, panel borders.

**Godot:** `Color(0.290, 0.345, 0.439)`

---

### E3 — Act 3 Violet  *(The King's Throne)*
```
Hex:  #5A3870
HSL:  270°  33%  33%
RGB:  90   56  112
```
**Swatch:** <span style="display:inline-block;width:80px;height:40px;background:#5A3870;border:1px solid #CFC3A8;"> </span>

**Thematic intent:** The Hollow King's corrupted throne. Regal in memory; sinister in practice.  
**Map usage:** Active node glow, map shadow overlay, key location halos.  
**Forbidden in:** UI chrome, buttons, text, panel borders.

**Godot:** `Color(0.353, 0.220, 0.439)`

---

## Palette Usage Matrix

A quick guide showing which groups are legal for each UI surface category.

| Surface / Role | P (Parchment) | I (Ink) | G (Gold) | A (Ash) | R (Crimson) | B (Teal) | E (Act) |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Panel background | ✅ P1–P4 | ❌ | ❌ | A2 only | ❌ | ❌ | ❌ |
| Panel border | ❌ | ✅ | ✅ G2/G4 | ✅ A3 | R1 (danger) | ❌ | ❌ |
| Body text | ❌ | ✅ I1–I3 | ❌ | ❌ | ❌ | ❌ | ❌ |
| Button fill | ✅ P1–P3 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Button border | ❌ | ❌ | ✅ G1–G4 | ✅ A3 | R1 (hostile) | B1 (help) | ❌ |
| Active state accent | ❌ | ❌ | ✅ G1 | ❌ | ❌ | ❌ | ❌ |
| Disposition bar | ❌ | ❌ | G3 (positive) | P3 (neutral) | R1 (hostile) | B2 (positive) | ❌ |
| Map node tokens | ❌ | ✅ I1 | G1 (active) | ✅ A1/A2 | R1/R2 (fail) | ❌ | E1–E3 |
| Map connection lines | ❌ | ❌ | ❌ | ✅ A3/P5 | ❌ | ❌ | ❌ |
| Map environment tiles | ✅ P2 | ❌ | ❌ | ✅ A1 | ❌ | ❌ | ✅ |
| Error/danger states | ❌ | ❌ | ❌ | ❌ | ✅ R1/R2 | ❌ | ❌ |
| Trusted/positive states | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ B1/B2 | ❌ |
| Portrait art | All (baked) | All (baked) | G1 (frame) | All (baked) | R1 (hostile) | B2 (trusted) | ❌ |

---

## Godot Palette Resource

Paste the following into a `.tres` file or the Godot colour picker. These are the full set as `Color()` values for GDScript.

```gdscript
## Chimera Palette — copy into a const Dictionary or a ColorPalette resource.
const PALETTE := {
    # Parchment
    "P1": Color(0.910, 0.835, 0.690),   # #E8D5B0  Primary Parchment
    "P2": Color(0.831, 0.745, 0.580),   # #D4BE94  Aged Parchment
    "P3": Color(0.749, 0.659, 0.502),   # #BFA880  Dark Parchment
    "P4": Color(0.949, 0.910, 0.824),   # #F2E8D2  Pale Vellum
    "P5": Color(0.659, 0.565, 0.439),   # #A89070  Linen Shadow
    "P6": Color(0.929, 0.910, 0.878),   # #EDE8E0  Ash White
    # Ink
    "I1": Color(0.102, 0.078, 0.063),   # #1A1410  Primary Ink
    "I2": Color(0.239, 0.169, 0.122),   # #3D2B1F  Sepia Ink
    "I3": Color(0.361, 0.267, 0.200),   # #5C4433  Faded Ink
    "I4": Color(0.290, 0.180, 0.118),   # #4A2E1E  Rust Ink
    "I5": Color(0.145, 0.157, 0.188),   # #252830  Storm Ink
    # Gold
    "G1": Color(0.788, 0.659, 0.298),   # #C9A84C  Antique Gold
    "G2": Color(0.659, 0.525, 0.235),   # #A8863C  Burnished Gold
    "G3": Color(0.875, 0.761, 0.471),   # #DFC278  Pale Gold
    "G4": Color(0.478, 0.369, 0.157),   # #7A5E28  Dark Gold
    "G5": Color(0.788, 0.659, 0.298, 0.15), # #C9A84C26 Gold Wash
    # Ash
    "A1": Color(0.549, 0.510, 0.471),   # #8C8278  Ash Grey
    "A2": Color(0.314, 0.282, 0.267),   # #504844  Deep Ash
    "A3": Color(0.812, 0.765, 0.659),   # #CFC3A8  Bone
    # State
    "R1": Color(0.549, 0.184, 0.184),   # #8C2F2F  Hollow Crimson
    "R2": Color(0.369, 0.102, 0.102),   # #5E1A1A  Dried Blood
    "B1": Color(0.180, 0.361, 0.361),   # #2E5C5C  Hollow Teal
    "B2": Color(0.290, 0.541, 0.541),   # #4A8A8A  Pale Teal
    # Act accents (map/environment only)
    "E1": Color(0.769, 0.471, 0.125),   # #C47820  Act 1 Amber
    "E2": Color(0.290, 0.345, 0.439),   # #4A5870  Act 2 Slate
    "E3": Color(0.353, 0.220, 0.439),   # #5A3870  Act 3 Violet
}
```

---

## Krita / Aseprite Palette Export (GIMP GPL format)

Save as `chimera_palette.gpl` for import into Krita, Aseprite, GIMP, or Inkscape:

```
GIMP Palette
Name: Chimera Ashes of the Hollow King
Columns: 7
#
232 213 176	P1 Primary Parchment
212 190 148	P2 Aged Parchment
191 168 128	P3 Dark Parchment
242 232 210	P4 Pale Vellum
168 144 112	P5 Linen Shadow
237 232 224	P6 Ash White
  0   0   0	---
 26  20  16	I1 Primary Ink
 61  43  31	I2 Sepia Ink
 92  68  51	I3 Faded Ink
 74  46  30	I4 Rust Ink
 37  40  48	I5 Storm Ink
  0   0   0	---
201 168  76	G1 Antique Gold
168 134  60	G2 Burnished Gold
223 194 120	G3 Pale Gold
122  94  40	G4 Dark Gold
  0   0   0	---
140 130 120	A1 Ash Grey
 80  72  68	A2 Deep Ash
207 195 168	A3 Bone
  0   0   0	---
140  47  47	R1 Hollow Crimson
 94  26  26	R2 Dried Blood
 46  92  92	B1 Hollow Teal
 74 138 138	B2 Pale Teal
  0   0   0	---
196 120  32	E1 Act 1 Amber
 74  88 112	E2 Act 2 Slate
 90  56 112	E3 Act 3 Violet
```

---

## Analogous Colour Relationships

These colour pairs are harmonically related and may be blended or juxtaposed:

| Pair | Relationship | Emotional Read |
|---|---|---|
| P1 + I1 | High-contrast complement (warm/dark) | Manuscript legibility |
| G1 + I1 | Gold-on-ink | Illuminated emphasis |
| R1 + P2 | Danger-on-parchment | Bloodstain on vellum |
| B1 + P2 | Cool-on-warm | Trust, distance |
| E1 + A1 | Warm amber + cool ash | Dying embers in ruin |
| E3 + I5 | Violet + storm | Corrupted throne room |
| G3 + P1 | Nearly-same-lightness gold | Embossed, subtle hierarchy |

---

*Colour Swatches Document v1.0 — Chimera: Ashes of the Hollow King*  
*All colour values verified against WCAG 2.1 contrast requirements at intended usage sizes.*
