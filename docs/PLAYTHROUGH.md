# Chimera: Ashes of the Hollow King — First-Hour Playthrough Guide

**Version:** 0.3.0  
**Goal:** Show a new player the intended golden-path through the first act while demonstrating core systems.

---

## Opening

1. Launch the app. The main menu appears with **New Game**, **Continue** (if an autosave exists), **Settings**, and **Quit**.
2. Tap **New Game**.
   - If a save already exists, a confirmation popup explains what will be overwritten. Tap **New Game** again to confirm or **Cancel** to return.
3. The game autosaves and opens the **overhead map** at **Hollow Gate**.
   - A 4-step coach-mark overlay appears: pan/zoom, tap a node, travel, quick bar.
   - Tap or press any key to advance.

---

## Act 1 — The Hollow

### Scene 1: Prologue at Hollow Gate

- The map camera focuses on a glowing ruin. Tap **Hollow Gate**.
- The game transitions to the **dialogue screen** with **Warden**, the gate-captain who sealed the Hollow.
- Read the typewriter text; tap the screen once to speed it up, or wait for it to finish.
- Choose any response. Each choice shifts Warden's **disposition** (visible in the portrait bar) and advances the tutorial quest `mq_first_steps`.
- The conversation ends and you return to the map. **Hollow Gate** is now marked complete.

### Travel to Outer Ruins

- Tap **Outer Ruins** (unlocked from the start) and confirm travel.
- The journal badge increments because a new lore entry is unlocked.
- Enter the scene to meet an NPC; complete or skip the conversation.
- Completing this scene advances the `mq_first_steps` "talk" objective.

### Watchtower Duel

- Tap **Watchtower**. This scene leads to a **duel**.
- On the **combat screen**, choose an intent: **Strike**, **Ward**, or **Feint**.
- Stance triangle: Strike beats Feint, Feint beats Ward, Ward beats Strike. Ties cost both sides an Omen point.
- When one side's Resolve reaches 0, the duel ends.
- Tap **Continue** to return to the previous dialogue or the map. The `mq_first_steps` "duel" objective is now complete.

### Rest and Review

- Tap the **Camp** button on the quick bar.
- The **camp screen** shows:
  - Night risk based on party dispositions.
  - A summary of scenes completed, items gained, and lore unlocked since the last rest.
  - A "Saved" indicator (the autosave already happened when you rested).
- Tap **Continue** to return to the map.
- The `mq_first_steps` "camp" objective completes; the tutorial quest is finished.

### Further Act 1 Content

- Open the **Journal** from the quick bar to read unlocked lore, active quests, and completed scenes.
- Try **Settings** from the quick bar or main menu to toggle music, SFX, haptics, reduced motion, and text speed.
- Explore remaining Act 1 nodes:
  - **Merchants** (Elena) — trade/recruit angle.
  - **Deep Hollow** — requires higher Warden disposition or completion of earlier scenes.
  - **Shrine** (Vessa) — purification and lore.

---

## Save and Resume

- The game autosaves after every scene, node visit, camp rest, and Android lifecycle pause.
- On the main menu, **Continue** resumes the autosave.
- You can also start **New Game** at any time; the previous autosave is overwritten after confirmation.

---

## Controls Summary

| Action | Touch | Controller / Keyboard |
|---|---|---|
| Move focus / pan map | drag / pinch | D-pad / WASD |
| Select / travel | tap | Enter / Space / A |
| Back / pause | Android Back | Escape / Q / B |
| Skip typewriter | tap text | Enter |

---

## What This Demonstrates

- **Deterministic narrative state:** scene completion, dispositions, inventory, and quest progress persist across sessions.
- **Branching dialogue:** authored trees plus legacy procedural fallback drive NPC reactions.
- **Tactical combat:** stance-based duels resolved in `Simulation`.
- **Camp loop:** the rest screen gives feedback on the player's last session.
- **Accessibility:** reduced motion, text speed, haptics toggle, and controller focus all work from first launch.
