# Chimera: Ashes of the Hollow King — Style Guide Quick Reference

**For:** Artists, UI implementers, PR reviewers  
**Full docs:** `ART_STYLE_GUIDE.md` · `COLOUR_SWATCHES.md` · `VISUAL_REFERENCE_BOARD.md` · `UI_MOCKUP_SPEC.md`

---

## The One-Sentence Rule

> *"Does this asset look like it was drawn by a weary scribe in a failing kingdom — purposeful, slightly imperfect, emotionally weighted?"*

---

## Colour: 7 Rules You Must Memorise

| # | Rule |
|---|---|
| 1 | No pure `#000000` or `#FFFFFF` anywhere |
| 2 | Text on parchment → use **I1** `#1A1410` or **I2** `#3D2B1F` only |
| 3 | Text on dark surfaces → use **P4** `#F2E8D2` only |
| 4 | Gold (**G1–G4**) goes on borders and icons only — never as a fill on large surfaces |
| 5 | Act colours (**E1–E3**) → map and environment only. Never in UI chrome |
| 6 | Crimson (**R1/R2**) → hostile/danger states only. Never decorative |
| 7 | Teal (**B1/B2**) → positive/trusted states only. Never decorative |

---

## Stroke: 3 Non-Negotiable Rules

| # | Rule |
|---|---|
| 1 | **Corners must overshoot** by 3–5 px (the most important single rule) |
| 2 | **Stroke weight must vary** ±10% along its length — no perfectly uniform lines |
| 3 | **Imperfection budget:** every asset needs 2 visible imperfections from the list in §3.4 |

---

## Touch Target Rule

Every interactive element → **minimum 84 × 84 px** (enforced in `gothic_button.gd`)

---

## Reduced Motion Rule

Every animation must check `UIAdapt.is_reduced_motion()` and have a zero/fade alternative.

---

## Asset Colour Palette — Pocket Card

```
P1 #E8D5B0  P2 #D4BE94  P3 #BFA880  P4 #F2E8D2  P5 #A89070  P6 #EDE8E0
I1 #1A1410  I2 #3D2B1F  I3 #5C4433  I4 #4A2E1E  I5 #252830
G1 #C9A84C  G2 #A8863C  G3 #DFC278  G4 #7A5E28
A1 #8C8278  A2 #504844  A3 #CFC3A8
R1 #8C2F2F  R2 #5E1A1A  B1 #2E5C5C  B2 #4A8A8A
E1 #C47820  E2 #4A5870  E3 #5A3870
```

Import the full palette: `assets/chimera_palette.gpl` (GIMP/Krita/Aseprite compatible)

---

## Asset Acceptance Gate (3-Item Fast Check)

Before submitting any asset:

- [ ] All colours within ±5° hue / ±10% lightness of a named palette entry
- [ ] At least one overshot corner OR deliberate stroke irregularity visible
- [ ] Paper grain texture visible at 100% zoom

Full criteria in `ART_STYLE_GUIDE.md §13`.

---

## Screen Panel Default Recipe

```
Background fill:   P2 (#D4BE94)
Outer border:      I1 (#1A1410), 4px, overshot corners
Inner tracery:     A3 (#CFC3A8), 1px vine rule
Corner ornament:   Small ink flourish
Padding (inner):   16px all sides
Border radius:     0px — no rounded corners
```

## Button Default Recipe

```
Height:      84px minimum
Background:  P1 (#E8D5B0), paper grain layer
Border:      G2 (#A8863C), 2px, overshot corners
Label:       Cinzel, 16px, I1 (#1A1410), left-aligned, 16px L-pad
Hover:       Background → P3, border → G1
Pressed:     Background → P3, border → G4, scale 0.96
Disabled:    50% opacity, cross-hatch overlay 20%
```

---

## Document Index

| Document | Purpose |
|---|---|
| `docs/ART_STYLE_GUIDE.md` | Master reference: all style rules, component specs, acceptance criteria |
| `docs/COLOUR_SWATCHES.md` | 28 colour swatches with hex/HSL/RGB, Godot values, GPL palette export |
| `docs/VISUAL_REFERENCE_BOARD.md` | Reference game analysis: what we take from each and why |
| `docs/UI_MOCKUP_SPEC.md` | Per-screen ASCII layout diagrams + component maps |
| `docs/STYLE_GUIDE_QUICK_REF.md` | This file — pocket reference for daily use |
| `assets/chimera_palette.gpl` | Importable palette for Krita/Aseprite/GIMP |
