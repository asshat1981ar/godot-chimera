# Chimera: Ashes of the Hollow King — UI Mockup Specification

**Version:** 1.0  
**Purpose:** Screen-by-screen layout specification for hand-drawn UI implementation  
**Companion to:** `docs/ART_STYLE_GUIDE.md`, `docs/COLOUR_SWATCHES.md`, `docs/VISUAL_REFERENCE_BOARD.md`  
**Format:** ASCII layout diagrams + annotation tables (Figma substitute)

---

> These mockups describe exact layout and visual treatment for each screen at **1280×720 px** (the project's logical viewport). All measurements are in logical pixels. Grid baseline: 4 px.

---

## Viewport & Safe Area

```
╔════════════════════════════════════════════════════════════╗  720
║ [16px safe margin top — reserved for toast/system UI]       ║
║                                                             ║
║  [Content area: 1248 × 688 px, centred with 16px margin]   ║
║                                                             ║
║ [16px safe margin bottom]                                   ║
╚════════════════════════════════════════════════════════════╝  0
0                                                         1280
```

UIAdapt applies additional insets on devices with notches/camera holes. All content must be authored within the 1248×688 content area; the 16px margins are safety buffers only.

---

## Screen 1: Main Menu (`scenes/screens/main_menu.tscn`)

### Layout Diagram

```
1280 × 720 px
┌──────────────────────────────────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░░░░░ PARCHMENT BACKGROUND ░░░░░░░░░░░░░░░░░░░░░ │
│ ░ [AGED MAP TILE BACKGROUND — tile_parchment.png tiled, 30% ░░░ │
│ ░   ink_wash.gdshader applied, vignette 35% I2 at edges]  ░░░░░ │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│                                                                  │
│                   ┌──────────────────────┐                       │
│                   │  ╔════════════════╗  │  ← Title panel       │
│                   │  ║  CHIMERA       ║  │    P2 background     │
│                   │  ║  Ashes of the  ║  │    G2 outer border   │
│                   │  ║  Hollow King   ║  │    A3 inner tracery  │
│                   │  ╚════════════════╝  │    4px + 1px         │
│                   └──────────────────────┘                       │
│                   Title: IM Fell English, T1 (48px), I1          │
│                   Subtitle: Crimson Pro Italic, T3 (24px), I2    │
│                   Subtitle 2: Cinzel, T6 (14px), I3              │
│                                                                  │
│             ┌──────────────────────────────────────┐             │
│             │  [ NEW GAME                        ] │  ← 84px    │
│             │  [ CONTINUE                        ] │    tall ea. │
│             │  [ SETTINGS                        ] │    G2 bdr  │
│             │  [ QUIT                            ] │    P1 fill │
│             └──────────────────────────────────────┘             │
│              Buttons: 440px wide, centred, 8px gap between       │
│                                                                  │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│  Version text (bottom right): Crimson Pro, T7 (12px), I3         │
│  "v0.1.0-godot-port"                                            │
└──────────────────────────────────────────────────────────────────┘
```

### New Game Confirmation Popup

```
┌──────────────────────────────────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░ [DIMMED BACKGROUND — P6 at 70%] ░░░░░░░░░░░░░░ │
│        ┌────────────────────────────────────────────┐            │
│        │ ╔══════════════════════════════════════════╗            │
│        │ ║  EXISTING SAVE FOUND                     ║ ← I1/G2   │
│        │ ╠══════════════════════════════════════════╣            │
│        │ ║  ░░░░░░░░░ SUMMARY TEXT ░░░░░░░░░░░░    ║ ← P2 bg   │
│        │ ║  Act N · Last node: X · Party: N         ║            │
│        │ ║  Starting new game overwrites this save.  ║            │
│        │ ╠══════════════════════════════════════════╣            │
│        │ ║  [ CANCEL ]          [ CONFIRM ]         ║ ← 84px    │
│        │ ╚══════════════════════════════════════════╝            │
│        └────────────────────────────────────────────┘            │
└──────────────────────────────────────────────────────────────────┘
Popup: 600×320px, centred, P2 background, I1 4px border, G2 accent.
CANCEL button: secondary style (P3 background, A3 border).
CONFIRM button: primary style (P1 background, R1 border — danger action).
```

### Component Map

| Component | Node Path | Style | Notes |
|---|---|---|---|
| Background | `$Background` | tile_parchment.png + ink_wash shader | Full screen |
| Title Panel | `$VBoxContainer/TitlePanel` | P2 bg, G2 border, A3 tracery | Centre of screen |
| Title Label | `$VBoxContainer/TitlePanel/Title` | IM Fell English, 48px, I1 | "CHIMERA" |
| Subtitle | `$VBoxContainer/TitlePanel/Subtitle` | Crimson Pro Italic, 24px, I2 | "Ashes of the…" |
| New Game Btn | `$VBoxContainer/NewGameButton` | Standard button, no special tint | GothicButton |
| Continue Btn | `$VBoxContainer/ContinueButton` | 50% opacity when disabled | GothicButton |
| Settings Btn | `$VBoxContainer/SettingsButton` | Standard button | GothicButton |
| Quit Btn | `$VBoxContainer/QuitButton` | Secondary style | GothicButton |
| Confirm Popup | `$NewGameConfirm` | P2 bg, R1 confirm border | Dialog panel |
| Version Label | `$VersionLabel` | Courier Prime, 12px, I3 | Bottom-right |

---

## Screen 2: Overhead Map (`scenes/screens/overhead_map.tscn`)

### Layout Diagram

```
1280 × 720 px
┌──────────────────────────────────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░░░░░ MAP CANVAS BACKGROUND ░░░░░░░░░░░░░░░░░░░░ │
│ ░ [tile_parchment.png tiled, torn-paper alpha edge, compass] ░░ │
│ ░ [ink_wash.gdshader: grain 30%, vignette 40%, no wobble]  ░░░░ │
│                                                                  │
│   [MAP NODE TOKENS — scattered per act1_map.json positions]     │
│                                                                  │
│   ◉ — Active node (64×64 px, G1 glow aura)                     │
│   ○ — Neutral node (48×48 px visible, A1 fill, A3 border)      │
│   ✓ — Completed node (A2 fill, I3 border)                       │
│   ✗ — Failed node (R2 fill, R1 border)                          │
│   ░ — Hidden node (30% opacity, no label)                        │
│                                                                  │
│   Connection lines: A3 1px dashed, slight bow curve             │
│   Node labels: Courier Prime, T7 (12px), I2, below token        │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ BOTTOM HUD BAR — 72px tall                               │   │
│  │ [◀ CAMP]  [NODE NAME: Ashfield Crossing]  [JOURNAL ▶]   │   │
│  │  P2 bg    I1 label, T4, centred           HUD buttons   │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

### HUD Bar Detail

```
┌────────────────────────────────────────────────────────────────┐
│ BOTTOM HUD — 1280 × 72 px                                      │
│ Background: I1 at 85% opacity (dark ink bar)                   │
│ Top border: 2px G2 line                                        │
│                                                                │
│  ┌──────────┐   ┌────────────────────┐   ┌──────────────────┐ │
│  │  CAMP    │   │  Ashfield Crossing  │   │ JOURNAL  PARTY  │ │
│  │  84×56px │   │  Cinzel T4, P4     │   │ 84×56px  ea.   │ │
│  │  G2 bdr  │   │  centred           │   │  G2 bdr        │ │
│  └──────────┘   └────────────────────┘   └──────────────────┘ │
└────────────────────────────────────────────────────────────────┘
```

### Component Map

| Component | Node Path | Style | Notes |
|---|---|---|---|
| Map Background | `$MapBackground` | tile_parchment tiled, ink_wash shader | Full screen |
| Camera | `$MapCamera` (MapCamera.gd) | No visual style | Handles pan/zoom |
| Node Container | `$MapNodes` | Parent for map_node_token instances | Positioned per JSON |
| NPC Container | `$NPCTokens` | Parent for npc_token instances | Wandering NPCs |
| HUD Bar | `$HUDBar` | I1 85% bg, G2 2px top border | Bottom 72px |
| Current Node Label | `$HUDBar/NodeLabel` | Cinzel, 18px, P4 | Centre of HUD |
| Camp Button | `$HUDBar/CampButton` | GothicButton, dark variant | Left of HUD |
| Journal Button | `$HUDBar/JournalButton` | GothicButton, dark variant | Right of HUD |
| Party Button | `$HUDBar/PartyButton` | GothicButton, dark variant | Right of HUD |
| Act Label | `$HUDBar/ActLabel` | Courier Prime, 12px, I3 | Top-right of HUD |

---

## Screen 3: Dialogue Screen (`scenes/screens/dialogue_screen.tscn`)

### Layout Diagram

```
1280 × 720 px
┌──────────────────────────────────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░ PARCHMENT BACKGROUND ░░░░░░░░░░░░░░░░░░░░░░░░░ │
│                                                                  │
│  ┌────────────────┐  ┌──────────────────────────────────────┐   │
│  │ PORTRAIT PANEL │  │ DIALOGUE PANEL                        │   │
│  │ 280 × 480 px   │  │ 940 × 480 px                          │   │
│  │ P2 bg, I1 4px  │  │ P2 bg, I1 3px border, A3 tracery    │   │
│  │                │  │                                       │   │
│  │ ┌────────────┐ │  │ ┌───────────────────────────────┐    │   │
│  │ │ PORTRAIT   │ │  │ │ NPC DIALOGUE TEXT              │    │   │
│  │ │ 248×340px  │ │  │ │ Crimson Pro, 18px, I1, P2 bg  │    │   │
│  │ │ oval frame │ │  │ │ Line height 28px               │    │   │
│  │ │ A3 bg      │ │  │ │ Typewriter reveal active       │    │   │
│  │ └────────────┘ │  │ └───────────────────────────────┘    │   │
│  │                │  │ ────────────────── ← A3 1px rule     │   │
│  │ [NPC NAME]     │  │ CHOICE BUTTONS (VBox, 4–6 buttons)    │   │
│  │ Cinzel 20px I1 │  │ Each: 84px tall, choice tint colours  │   │
│  │                │  │ Cinzel 16px, I1 label, 16px L-pad     │   │
│  │ ┌ DISP BAR ┐  │  │ [ defer → P2 bg, G2 border          ] │   │
│  │ │R1---P5--B2│  │  │ [ help  → B2 tint, B1 border        ] │   │
│  │ └──────────┘  │  │ [ threaten → R1 tint, R1 border     ] │   │
│  │  12px, full W  │  │ [ empathize → B2 tint, B1 border    ] │   │
│  │               │  │ [ lie → I2 tint, A3 border           ] │   │
│  │               │  │ [ Leave → P3 bg, A3 border           ] │   │
│  └────────────────┘  └──────────────────────────────────────┘   │
│   20px gap between panels; total width: 280+20+940 = 1240px     │
│   Centred in viewport with 20px margin each side                 │
└──────────────────────────────────────────────────────────────────┘
```

### Choice Button Visual Tints (Reference Table)

| Choice Type | Button BG | Border | Left accent | Emotional read |
|---|---|---|---|---|
| `defer` | P2 `#D4BE94` | G2 `#A8863C` | — | Neutral, deferential |
| `help` | B2 15% tint | B1 `#2E5C5C` | Small ❧ in B2 | Helpful, reaching |
| `empathize` | B2 15% tint | B1 `#2E5C5C` | Small ❧ in B2 | Caring, warm |
| `vow` | B1 20% tint | G1 `#C9A84C` | ◈ symbol in G1 | Sacred commitment |
| `threaten` | R1 15% tint | R1 `#8C2F2F` | ▲ in R1 | Aggressive, dangerous |
| `demand` | R1 15% tint | R1 `#8C2F2F` | ▲ in R1 | Forceful, blunt |
| `lie` | I2 10% tint | A3 `#CFC3A8` | ~ in I3 | Deceitful, indirect |
| `conceal` | I2 10% tint | A3 `#CFC3A8` | ~ in I3 | Hidden, withheld |
| `inquire` | P2 (no tint) | A3 `#CFC3A8` | ? in I3 | Curious, open |
| Leave/Exit | P3 `#BFA880` | A3 `#CFC3A8` | ← in I3 | Neutral exit |

---

## Screen 4: Journal Screen (`scenes/screens/journal_screen.tscn`)

### Layout Diagram

```
1280 × 720 px
┌──────────────────────────────────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░ PARCHMENT BACKGROUND ░░░░░░░░░░░░░░░░░░░░░░░░░ │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ JOURNAL PANEL — 1200 × 640 px, P2 bg, I1 4px border     │   │
│  │                                                           │   │
│  │  ┌─────────────────────────────────────────────────┐     │   │
│  │  │ TAB BAR — 48px                                   │     │   │
│  │  │ [QUESTS] [LORE] [SCENES]                         │     │   │
│  │  │ Active: P1, G2 3px underline, Cinzel 16px I1    │     │   │
│  │  │ Inactive: P3, A3 1px underline, Cinzel 16px I3  │     │   │
│  │  └─────────────────────────────────────────────────┘     │   │
│  │  ────────────────────────── ← A3 1px rule                │   │
│  │  ┌─────────────────────────────────────────────────┐     │   │
│  │  │ SCROLL CONTENT AREA — fills remaining height    │     │   │
│  │  │                                                 │     │   │
│  │  │ QUESTS TAB:                                     │     │   │
│  │  │   [Active] Quest Name                           │     │   │
│  │  │   Cinzel 18px, I1                               │     │   │
│  │  │     • Objective 1 (2/3)                         │     │   │
│  │  │       G1 progress bar 8px                       │     │   │
│  │  │     • Objective 2 (complete)                    │     │   │
│  │  │       A2 fill progress bar 8px                  │     │   │
│  │  │   ─────────────────── ← A3 divider rule         │     │   │
│  │  │   [Completed] Quest Name ← I3 faded             │     │   │
│  │  │                                                 │     │   │
│  │  │ LORE TAB:                                       │     │   │
│  │  │   LORE TITLE — THE ASHFIELDS ← Cinzel 20px G1  │     │   │
│  │  │   category · discovered ← I3 12px              │     │   │
│  │  │   Body text of lore entry...                    │     │   │
│  │  │   Crimson Pro 16px, I2, wide leading            │     │   │
│  │  └─────────────────────────────────────────────────┘     │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  [← BACK] — GothicButton, bottom-left, outside journal panel    │
└──────────────────────────────────────────────────────────────────┘
```

---

## Screen 5: Combat / Duel Screen (`scenes/screens/combat_screen.tscn`)

### Layout Diagram

```
1280 × 720 px
┌──────────────────────────────────────────────────────────────────┐
│ ████████████████████████████████████████████████████████████████ │
│ ██  I5 STORM INK background — #252830, ink_wash shader ████████ │
│ ██  vignette 45%, dither active, wobble minimal (0.001) ███████ │
│                                                                  │
│  ┌──────────────────────────┐    ┌──────────────────────────┐  │
│  │ PLAYER STANCE PANEL      │    │ OPPONENT STANCE PANEL     │  │
│  │ 480 × 300 px             │    │ 480 × 300 px              │  │
│  │ I1 90% bg, G2 border     │    │ I1 90% bg, R1 border      │  │
│  │                          │    │                            │  │
│  │ [STANCE SPRITE 200×200]  │    │ [OPPONENT PORTRAIT 200×] │  │
│  │ stance_strike.png etc.   │    │ portrait_<id>.png         │  │
│  │                          │    │                            │  │
│  │ "STRIKE" ← Cinzel T2 G1 │    │ "[NPC NAME]" ← P4 T3     │  │
│  └──────────────────────────┘    └──────────────────────────┘  │
│                                                                  │
│         ┌──────────────────────────────────────────┐            │
│         │ DUEL STATUS PANEL — 800 × 80 px          │            │
│         │ I1 80% bg, G2 1px top border             │            │
│         │ "Round 1 — OPENING PHASE"                │            │
│         │ Cinzel 18px, G1, centred                 │            │
│         └──────────────────────────────────────────┘            │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ STANCE CHOICE BAR — 1200 × 100 px                       │    │
│  │ I5 bg, G2 top border 2px                                │    │
│  │ [STRIKE 84px×84px] [WARD 84px×84px] [FEINT 84px×84px] │    │
│  │  G2 border default; G1 border + G5 bg on focus          │    │
│  │  Each button: icon (32×32 stance sprite) + Cinzel label  │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ COMBAT LOG — 1200 × 80 px, scrollable                   │    │
│  │ P2 bg at 80% opacity, I2 1px top border                 │    │
│  │ Crimson Pro Italic 14px, I2, right-aligned              │    │
│  │ "Thorne raises his blade..." (most recent line shown)   │    │
│  └─────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────┘
```

---

## Screen 6: Camp Screen (`scenes/screens/camp_screen.tscn`)

### Layout Diagram

```
1280 × 720 px
┌──────────────────────────────────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░ PARCHMENT BACKGROUND (night-tinted) ░░░░░░░░░░░ │
│ ░ tile_parchment.png at P3 tint (30% darker), candlelight anim ░ │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ CAMP PANEL — 960 × 540 px, P2 bg, I1 4px, A3 tracery   │   │
│  │                                                           │   │
│  │  "CAMP — Night N" ← IM Fell English, 32px, I1           │   │
│  │  ─────────────────────────── ← A3 1px rule               │   │
│  │                                                           │   │
│  │  RISK SUMMARY:                                            │   │
│  │  "Risk level: HIGH"  ← Cinzel 18px, R1 if risk>0.6     │   │
│  │  Risk bar: R1→G1 fill gradient, 8px tall, full width    │   │
│  │                                                           │   │
│  │  PARTY STATUS:                                            │   │
│  │  For each party member: name + disposition indicator      │   │
│  │  Small B2 or R1 dot (8px) + Crimson Pro 16px name I1    │   │
│  │                                                           │   │
│  │  ─────────────────────────── ← A3 1px rule               │   │
│  │                                                           │   │
│  │  ACTIONS:                                                 │   │
│  │  [ REST SAFELY  — risk -0.2  ] ← GothicButton, B1 bdr  │   │
│  │  [ PRESS ON     — risk +0.1  ] ← GothicButton, R1 bdr  │   │
│  │  [ RETURN TO MAP             ] ← GothicButton, A3 bdr  │   │
│  │                                                           │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  Candlelight ambient: G3 at 8% overlay, pulsing 4s sine (skip  │
│  if reduced-motion). Centred on camp panel.                     │
└──────────────────────────────────────────────────────────────────┘
```

---

## Screen 7: Settings Screen (`scenes/screens/settings_screen.tscn`)

### Layout Diagram

```
1280 × 720 px
┌──────────────────────────────────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░ PARCHMENT BACKGROUND ░░░░░░░░░░░░░░░░░░░░░░░░░ │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ SETTINGS PANEL — 800 × 560 px, P2 bg, I1 4px, centred  │   │
│  │                                                           │   │
│  │  "SETTINGS" ← IM Fell English, 32px, I1, centred        │   │
│  │  ─────────────────────────── ← A3 1px rule               │   │
│  │                                                           │   │
│  │  Toggle rows (each 72px tall, full panel width):         │   │
│  │                                                           │   │
│  │  ┌──────────────────────────────────────────────────┐   │   │
│  │  │ [✓] Music Enabled       ← CheckBox + Label       │   │   │
│  │  │     Cinzel 18px, I1                              │   │   │
│  │  └──────────────────────────────────────────────────┘   │   │
│  │  ┌──────────────────────────────────────────────────┐   │   │
│  │  │ [✓] Sound Effects       ← CheckBox + Label       │   │   │
│  │  └──────────────────────────────────────────────────┘   │   │
│  │  ┌──────────────────────────────────────────────────┐   │   │
│  │  │ [ ] Reduced Motion      ← CheckBox + Label       │   │   │
│  │  └──────────────────────────────────────────────────┘   │   │
│  │  ┌──────────────────────────────────────────────────┐   │   │
│  │  │ [ ] AI Assistance       ← CheckBox + Label       │   │   │
│  │  └──────────────────────────────────────────────────┘   │   │
│  │                                                           │   │
│  │  Text Speed: [====■══════] 60%                          │   │
│  │  Slider: P3 track, G2 thumb, G1 active track           │   │
│  │  Label: Crimson Pro 16px, I2                           │   │
│  │                                                           │   │
│  │  ─────────────────────────── ← A3 1px rule               │   │
│  │  [ ← BACK ]  ← GothicButton secondary, 200px wide      │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

### CheckBox Style

```
Custom CheckBox visual treatment (NOT system default):

Unchecked: □  — P1 fill, I1 1px border, 28×28px, overshot corners
Checked:   ☑  — P1 fill, G2 2px border, I1 checkmark drawn at
                 45° angle (not system checkbox), slight overshoot
Hover:         G5 (gold wash) background tint
```

---

## Screen 8: Party Screen (`scenes/screens/party_screen.tscn`)

### Layout Diagram

```
1280 × 720 px
┌──────────────────────────────────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░ PARCHMENT BACKGROUND ░░░░░░░░░░░░░░░░░░░░░░░░░ │
│                                                                  │
│  ┌────────────────────────┐  ┌──────────────────────────────┐  │
│  │ CURRENT PARTY          │  │ AVAILABLE COMPANIONS          │  │
│  │ 580 × 600 px           │  │ 580 × 600 px                  │  │
│  │ P2 bg, I1 3px border   │  │ P2 bg, A3 2px border (softer) │  │
│  │                        │  │                                │  │
│  │ "PARTY" G1 Cinzel T3  │  │ "AVAILABLE" I3 Cinzel T3     │  │
│  │ ─────── A3 rule ──────│  │ ─────── A3 rule ─────────    │  │
│  │                        │  │                                │  │
│  │ For each party member:  │  │ For each available NPC:       │  │
│  │ ┌────────────────────┐ │  │ ┌──────────────────────────┐ │  │
│  │ │ [Portrait 48×48]   │ │  │ │ [Portrait 48×48] Name    │ │  │
│  │ │ Name — Role        │ │  │ │ Role  disp: 0.45         │ │  │
│  │ │ Disp bar 80px wide │ │  │ │ [RECRUIT] GothicButton   │ │  │
│  │ │ [REMOVE] G-btn     │ │  │ │  B1 border               │ │  │
│  │ └────────────────────┘ │  │ └──────────────────────────┘ │  │
│  │                        │  │                                │  │
│  │ (scrollable VBox)       │  │ (scrollable VBox)             │  │
│  └────────────────────────┘  └──────────────────────────────┘  │
│                                                                  │
│  [ ← BACK ] GothicButton, bottom-centre, 200px wide            │
└──────────────────────────────────────────────────────────────────┘
```

---

## Screen 9: Act Transition (`scenes/screens/act_transition.tscn`)

### Layout Diagram

```
1280 × 720 px — full-screen, no chrome
┌──────────────────────────────────────────────────────────────────┐
│ ████████████████████████████████████████████████████████████████ │
│ ██ I1 FULL-SCREEN INK BLACK BACKGROUND                    ██████ │
│ ██ ink_wash.gdshader — maximum grain, maximum dither      ██████ │
│                                                                  │
│                                                                  │
│           ACT II                                                 │
│           The Hollow Reaches                                     │
│                                                                  │
│           IM Fell English, 64px, P4 (Pale Vellum)               │
│           Cinzel, 20px, G1 (Antique Gold), below                │
│                                                                  │
│                                                                  │
│  ░░░░░░ Ink-wipe transition: left-to-right brush edge ░░░░░░░░ │
│  ░░ Duration 1.0s. Act colour (E1/E2/E3) tints the ink edge. ░░ │
│                                                                  │
│  Small act icon/rune (48×48px) centred below text               │
│  G1 colour, hatched/stippled fill                               │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Screen 10: Crafting Screen (`scenes/screens/crafting_screen.tscn`)

### Layout Diagram

```
1280 × 720 px
┌──────────────────────────────────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░ PARCHMENT BACKGROUND ░░░░░░░░░░░░░░░░░░░░░░░░░ │
│                                                                  │
│  ┌────────────────────┐  ┌────────────────────────────────────┐ │
│  │ INGREDIENT LIST    │  │ RECIPE DETAIL PANEL                 │ │
│  │ 380 × 600 px       │  │ 800 × 600 px                        │ │
│  │ P2 bg, I1 3px bdr  │  │ P2 bg, I1 3px border, A3 tracery  │ │
│  │                    │  │                                     │ │
│  │ "INVENTORY" Cinzel │  │ Recipe Name: Cinzel T3, I1          │ │
│  │ ──── A3 rule ───  │  │ Description: Crimson Pro 16px, I2   │ │
│  │                    │  │                                     │ │
│  │ [Icon][Item Name]  │  │ Ingredients:                        │ │
│  │ qty: N ← I3 16px  │  │  [icon] Herb Bundle × 2 ✓          │ │
│  │ ── A3 ──          │  │  [icon] Ash Urn × 1    ✗           │ │
│  │ [Icon][Item Name]  │  │  G1 tick = have it, R1 × = lack   │ │
│  │ qty: N             │  │                                     │ │
│  │                    │  │ Output:                             │ │
│  │ (scrollable)       │  │  [icon 64×64] Item Name             │ │
│  │                    │  │  Crimson Pro 18px, I1              │ │
│  │                    │  │                                     │ │
│  │                    │  │ [ CRAFT ]  GothicButton, G2 bdr    │ │
│  │                    │  │  Disabled (50% opacity) if missing  │ │
│  └────────────────────┘  └────────────────────────────────────┘ │
│                                                                  │
│  [ ← BACK ] GothicButton, bottom-left                          │
└──────────────────────────────────────────────────────────────────┘
```

---

## Reusable Component: Map Node Token States

### All 6 States at 64×64 px

```
NEUTRAL              ACTIVE               COMPLETED
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   ╱────╲     │    │  ╱────╲      │    │   ╱────╲     │
│  ╱ RUIN ╲    │    │ ╱ RUIN ╲     │    │  ╱ RUIN ╲    │
│ │  SILH  │   │    ││  SILH  │    │    │ │  SILH  │   │
│  ╲      ╱    │    │ ╲      ╱     │    │  ╲  ✓  ╱    │
│   ╲────╱     │    │  ╲────╱      │    │   ╲────╱     │
│              │    │  ○○○○○○○     │    │              │
│ A1 fill      │    │ G1 glow aura │    │ A2 fill      │
│ A3 border    │    │ G1 border    │    │ I3 border    │
│ I1 outline   │    │ P1 fill      │    │ I3 outline   │
└──────────────┘    └──────────────┘    └──────────────┘

BLOCKED              FAILED               HIDDEN
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   ╱────╲     │    │   ╱────╲     │    │   ╱────╲     │
│  ╱╲RUIN╱╲   │    │  ╱ RUIN ╲    │    │  ╱ RUIN ╲    │
│ │╲ SILH╱│   │    │ │  SILH  │   │    │ │  SILH  │   │
│  ╲╱    ╲╱   │    │  ╲  ✗   ╱    │    │  ╲      ╱    │
│   ╲────╱    │    │   ╲────╱     │    │   ╲────╱     │
│ ///hatch/// │    │              │    │              │
│ A1+hatch    │    │ R2 fill      │    │ A1 30% alpha │
│ R1 X-mark   │    │ R1 border    │    │ no border    │
│ I2 border   │    │ scratch marks│    │ shimmer anim │
└──────────────┘    └──────────────┘    └──────────────┘
```

---

## Reusable Component: Toast Notification

```
                ┌──────────────────────────────────────────┐
                │ ╔══════════════════════════════════════╗  │
                │ ║  Toast message text centred here     ║  │
                │ ║  Crimson Pro 16px, I1, centred        ║  │
                │ ╚══════════════════════════════════════╝  │
                └──────────────────────────────────────────┘
                  360 × 56px minimum
                  Centred top, 24px from top edge
                  P2 at 92% opacity, I2 2px border, overshot corners
                  Fade in 0.2s / display / fade out 0.3s
```

---

## Typography Reference Sheet

```
╔════════════════════════════════════════════════════════════╗
║ CHIMERA TYPOGRAPHY REFERENCE                               ║
╠════════════════════════════════════════════════════════════╣
║ T1 — Screen Title (IM Fell English, 48px, I1)             ║
║      CHIMERA: ASHES OF THE HOLLOW KING                    ║
╠════════════════════════════════════════════════════════════╣
║ T2 — Section Header (Cinzel, 32px, G1)                    ║
║      ACT I: THE ASHFIELDS                                 ║
╠════════════════════════════════════════════════════════════╣
║ T3 — Panel Header (Cinzel, 24px, I1)                      ║
║      Current Party                                        ║
╠════════════════════════════════════════════════════════════╣
║ T4 — Body / Dialogue (Crimson Pro, 18px, I1)              ║
║      The ash fell for seven years before anyone noticed    ║
║      that the Hollow King had stopped blinking.           ║
╠════════════════════════════════════════════════════════════╣
║ T4i — Dialogue Aside (Crimson Pro Italic, 18px, I2)       ║
║      His hands trembled at the word "king."               ║
╠════════════════════════════════════════════════════════════╣
║ T5 — Button Label (Cinzel, 16px, I1)                      ║
║      RECRUIT TO PARTY                                     ║
╠════════════════════════════════════════════════════════════╣
║ T6 — Caption (Crimson Pro, 14px, I3 — min 18px only)      ║
║      Act 1 · Ashfield Crossing · Completed                ║
╠════════════════════════════════════════════════════════════╣
║ T7 — Minimum (Courier Prime, 12px, I3)                    ║
║      v0.1.0-godot-port · 2024                             ║
╚════════════════════════════════════════════════════════════╝
```

---

## Checklist: Before Handing Off to Asset Production

- [ ] All screens reviewed against this mockup spec
- [ ] All colour values verified against `COLOUR_SWATCHES.md`
- [ ] All stroke weights reviewed against `ART_STYLE_GUIDE.md §6`
- [ ] Typography choices cross-referenced against `ART_STYLE_GUIDE.md §5`
- [ ] Reduced-motion alt defined for every animated element
- [ ] Touch targets verified ≥ 84×84 px for all interactive elements
- [ ] Contrast ratios checked for all text/background combinations
- [ ] Asset file names match `portrait_manifest.json` / `sprite_manifest.json` conventions
- [ ] All 6 map node token states accounted for
- [ ] All 9 dialogue choice types have button tints defined

---

*UI Mockup Specification v1.0 — Chimera: Ashes of the Hollow King*  
*This document is the layout authority for scene construction. Discrepancies between this spec and existing `.tscn` files should be resolved in favour of this spec unless a design decision document supersedes it.*
