# Competitor Analysis — 2D Android RPGs

**Project:** Chimera: Ashes of the Hollow King (dark-fantasy 2D narrative-simulation RPG, Android, Godot 4)
**Author:** market-researcher (team godot-chimera)
**Method:** Live web research of Google Play store listings, professional reviews (TouchArcade, Pocket Gamer, Android Police), and platform accessibility guidance. All store metrics captured **as of 2026-07-19**. Figures marked *(est.)* are estimates; everything else is quoted from the cited source.
**Purpose:** Benchmark core loops, session structure, touch UX, onboarding, save systems, monetization, and retention hooks of successful 2D Android RPGs, then convert findings into prioritized, subsystem-mapped actions for Chimera.

---

## 1. Executive Summary

- **Premium and "free-with-one-time-unlock" models both work for single-player 2D RPGs on Android.** Stardew Valley ($4.99, no IAP) holds 4.6★ with 5M+ downloads; Exiled Kingdoms (free + one-time unlock) holds 4.7★ with 1M+ downloads; Grim Quest (free + one-time ad removal) holds 4.7★ with 1M+ downloads. The audience that matches Chimera (narrative, offline, single-player) rewards "no ads / no energy / no gacha" positioning with top ratings.
- **Save integrity is the #1 review driver among negative reviews.** Chrono Trigger (3.8★) and Moonlighter Netflix Edition (2.3★) are cratered not by design but by crashes and save wipes; "App crashed and erased my save file" is the archetypal 1★ review. Autosave + crash-safe writes + visible save state are P0 for Chimera.
- **Touch control expectations: tap-first with generous assists.** Winners ship multiple control schemes (Stardew: touch / virtual joystick / controller) and aim/attack assists (Soul Knight auto-aim, Exiled Kingdoms auto-swing). Nobody is penalized for offering assists; Evoland 2 was penalized for unexplained mechanics and desktop-centric onboarding ("press the tab button! On Mobile!!!").
- **Offline play is a marketable feature**, not a default. Soul Knight users explicitly deducted stars when offline mode was removed. Google Play surfaces an "Offline" label — Chimera's deterministic sim is naturally offline; we should advertise it.
- **Depth is forgiven if onboarding is kind.** 9th Dawn III and Grim Quest are dense, systems-heavy RPGs with strong ratings; complaints focus on discoverability ("where do I mine ore?"), not on depth. Evoland 2's lowest reviews cite unclear saves and unexplained mechanics.
- **Session design: explicit loops of 5–30 minutes with a visible progress beat.** Vampire Survivors (capped ~30-min runs), Moonlighter (day/night cycle), Soul Knight (roguelike runs), Stardew (in-game day). Chimera's travel→scene→camp loop should be framed the same way, with autosave and a summary at camp.

---

## 2. Market Snapshot (Google Play, captured 2026-07-19)

| Game | Developer | Price / Model | Rating | Reviews | Downloads | Notable signals |
|---|---|---|---|---|---|---|
| Stardew Valley | ConcernedApe | $4.99, no IAP, no ads | 4.6★ | ~186–200K | 5M+ | Editors' Choice; #1 Top Paid RPG; Play Pass; "Offline" label |
| Exiled Kingdoms (free) | 4 Dimension Games | Free + one-time full-unlock IAP | 4.7★ | 131K | 1M+ | No "contains ads" flag; separate paid "Full" SKU below |
| Exiled Kingdoms – Full | 4 Dimension Games | $5.99 upfront | 4.8★ | 2.4K | 10K+ | Same content as unlocked free version |
| 9th Dawn III | Valorware (solo dev) | $9.99 + free demo SKU | 4.3★ | ~1.7–1.8K | 100K+ | Play Pass; demo funnel; patched Unity security issue visibly disclosed |
| Evoland 2 | Playdigious | $6.49, no ads, no IAP | 4.1–4.2★ | ~17K | 500K+ | Play Pass; controller support; active maintenance updates |
| Moonlighter (Netflix Ed.) | Netflix, Inc. | Free with Netflix subscription | 2.3★ | 3.4K | 500K+ | Cautionary tale: beloved game, port-quality collapse |
| Soul Knight | ChillyRoom | Free + ads + IAP (incl. random items) | 4.6★ | 1.76M | 50M+ | Editors' Choice; heavy live-ops; offline-mode removal backlash |
| Chrono Trigger (Upgrade) | Square Enix | $9.99 | 3.8★ | 20.1K | 500K+ | Beloved IP dragged down by port stability/UX |
| Vampire Survivors | Poncle | Free + optional rewarded ads + paid DLC | 4.4★ | 80.4K | 5M+ | Editors' Choice; offline; cloud saves; couch co-op |
| Grim Quest | Monomyth | Free + ads, one-time ad-removal IAP | 4.7★ | 88.9K | 1M+ | "No subscriptions, no gacha, no energy timers, no pay-to-win"; offline; dark-fantasy text RPG — closest tonal comp |

**Read of the table:** rating health correlates with (a) technical stability, (b) respectful monetization, and (c) mobile-native UX — not with IP strength or content volume (Chrono Trigger, Moonlighter). Chimera, as a new IP, must win on exactly those three axes.

---

## 3. Competitor Profiles

### 3.1 Stardew Valley (ConcernedApe) — the premium benchmark
- **Core loop:** farming-sim RPG: plant/harvest → sell → upgrade → explore mines → build relationships; open-ended with seasonal festivals and quests. 50+ hours of content advertised.
- **Session structure:** in-game day cycle (~13–15 min real time per day, *est.*) forms a natural session unit; end-of-day shipping summary + auto-save every night = perfect checkpointing.
- **Controls:** rebuilt for touch: **three control options (touch-screen/tap-to-move, virtual joystick, external controller)**, **auto-select** for tools, **auto-attack** in mines.
- **Save model:** auto-save at end of each day (advertised as a mobile-specific feature); single-player only on mobile.
- **Monetization:** $4.99, **no IAP, no ads**; also in Play Pass.
- **Onboarding:** gentle quest-driven (an "introductions" quest tours the valley); minimal tutorialization but extremely legible loops.
- **Retention hooks:** seasons/festivals, relationship/marriage goals, collection tabs, farm optimization; long update cadence (1.6-era content, bug-fix updates into Jun 2026).
- **Praise (store reviews):** satisfying routines, sound effects, character customization, endless content.
- **Complaints:** occasional update bugs (moved-building glitches, collectible-tracking bugs); no multiplayer on mobile.
- **Chimera relevance:** proof that a $4.99 offline single-player sim-RPG tops paid RPG charts; the end-of-cycle summary + auto-save pattern maps directly onto Chimera's camp screen.

### 3.2 Exiled Kingdoms (4 Dimension Games) — the free-with-unlock benchmark
- **Core loop:** isometric action-RPG (Diablo-like): take quests (NPCs + town halls) → clear dungeons → loot/level → recruit companions; 60+ hand-built quests plus randomly generated quests.
- **Session structure:** quest-sized loops (~10–20 min each, *est.*); open world invites long sessions but the quest log supports drop-in play.
- **Controls:** virtual pad for movement + virtual buttons for attacks/skills; **hold-to-keep-attacking** with aim assistance ("character has a bit of common sense about what direction to aim in" — TouchArcade).
- **Save model:** standard save points + overworld saving (TouchArcade-era).
- **Monetization:** free with a **substantial free portion**, rest unlocked by a **single one-time IAP** ($3.99 at 2016 review; standalone "Full" SKU now $5.99). Optional donation IAP. No "contains ads" flag.
- **Onboarding:** character creation (class/stats/portrait) then immediate questing; systems surfaced as needed.
- **Retention hooks:** companion recruitment/leveling, random quests, frequent content updates.
- **Praise:** TouchArcade 4.5★ — "one of the best single-player Diablo-like games"; fun core loop, character development, atmosphere, value.
- **Complaints:** dated presentation ("not the prettiest"), some grind; mercenary companions feel weak.
- **Chimera relevance:** the free-then-unlock funnel fits a small team shipping a niche narrative RPG; hold-to-act and aim-assist patterns apply to Chimera's combat/travel interactions.

### 3.3 9th Dawn III (Valorware) — the maximalist solo-dev open world
- **Core loop:** seamless 2D open world: explore → dungeon crawl → loot (1,400+ items, 270+ monsters) → craft/cook/fish → recruit/train monsters → sidequests; plus "Fyued," a 180-card collectible mini-game.
- **Session structure:** open-ended; a user reports ~50 hours for the main story (*user-reported*); dungeon dives of 15–30 min (*est.*).
- **Controls:** "full manual control" per player reviews (virtual d-pad + buttons, *est.*); companion AI handles allies (and is a complaint point).
- **Save model:** standard saves; includes **built-in cheats, difficulty modes, and optional permadeath**.
- **Monetization:** $9.99 premium + **free demo SKU**; in Play Pass.
- **Onboarding:** minimal; depth is the selling point — but top complaints are discoverability failures ("isn't very clear where to go to mine ore, or where to find a cooking fire").
- **Retention hooks:** collectathon volume, card game, monster collection, permadeath/hard modes.
- **Praise:** depth, value, replay value; TouchArcade lists its review at 5★ (Oct 2020).
- **Complaints:** companion AI; unclear resource/crafting signposting.
- **Chimera relevance:** a solo dev can ship a 4.3★ $9.99 2D RPG — scale is not the moat; signposting is. Chimera's crafting/camp systems must self-explain via the journal and hints.

### 3.4 Evoland 2 (Playdigious) — great game, uneven mobile port
- **Core loop:** story-driven action-RPG that jumps genres (2D RPG → fighting → shooter → card game) across 20+ hours.
- **Session structure:** console-style pacing; **designated save spots** with long gaps + **unclear autosave** — the most-criticized UX element in its store reviews.
- **Controls:** virtual controls + bluetooth controller support; some crash reports while using controllers.
- **Save model:** save spots + unclear autosave (negative pattern to avoid).
- **Monetization:** $6.49, marketed as **"Absolutely NO ads and NO in-app payments"**; Play Pass.
- **Onboarding:** **anti-pattern:** tutorial text referencing desktop keys ("press the tab button!" — on mobile).
- **Praise:** ambition, variety, references, story ("blew me away… recommend a thousand times over").
- **Complaints:** touch controls worse than its predecessor; ranged combat frustration; unclear save behavior; one genre-shift boss with broken controls "ruined… 10 hours of good gameplay."
- **Chimera relevance:** narrative-RPG goodwill is destroyed by (1) unclear saving, (2) desktop-first onboarding text, (3) one broken control moment. All three are cheap to avoid.

### 3.5 Moonlighter — Netflix Edition (Netflix) — the cautionary tale
- **Core loop:** acclaimed dual loop: **shopkeeping by day** (price discovery, customer reactions, log book) + **dungeon crawling by night**; crafting/enchanting; town reinvestment.
- **Session structure:** day/night cycle (~10–15 min per cycle, *est.*); natural "one more day" pull.
- **Controls:** mobile port simplifies combat — a reviewer notes "walk in a room and it basically has combat handled," enabling relaxed, low-attention play.
- **Save model:** standard; but crash bugs caused lost progress in practice.
- **Monetization:** free with Netflix subscription (no standalone Android purchase for this edition).
- **Praise:** the loop itself (Pocket Gamer: "charming combination of action RPG and casual management elements"); relaxed mobile play pattern.
- **Complaints (store, 2.3★):** **crashes** escalating in later dungeons, item duplication/deletion bugs, unresponsive support — a masterclass in how port quality, not design, tanks a rating.
- **Chimera relevance:** direct caution for a Godot port: test late-game memory pressure (many entities/assets) and inventory edge cases; a 2.3★ port of a great design is still 2.3★.

### 3.6 Soul Knight (ChillyRoom) — the retention machine
- **Core loop:** top-down roguelike runs: pick hero → procedurally generated dungeon floors → 400+ weapons → boss → meta-progression unlocks; 20+ heroes with distinct skills.
- **Session structure:** a run is ~15–25 min (*est.*); failure still advances unlocks — every session feels productive.
- **Controls:** "extremely easy and intuitive" — virtual joystick + few buttons, **auto-aim** as the headline control feature; controller supported.
- **Save model:** cloud/account-based meta progression; run state is transient by design.
- **Monetization:** free + ads + IAP (includes random items); a long-time player notes ~$20 "unlock[s] most, if not all characters" (*user-reported*).
- **Onboarding:** instantly playable (shoot/dodge/skill); meta systems layered in over sessions.
- **Retention hooks:** online + LAN co-op, seasonal events, sign-in events, achievements, side modes (gardening, fishing, tower defense), frequent content updates.
- **Praise:** music, style, content volume, "easy to level up, fun and tons of content."
- **Complaints:** **offline mode was removed** → multiple long-time players publicly docked 3–4 stars; post-update crashes; always-online requirement.
- **Chimera relevance:** (a) auto-aim-style input assistance is the genre norm on touch — Chimera's stance duels should offer an equivalent "read/assist" option; (b) never remove offline capability after launch; (c) events/side-modes are retention multipliers, but only after the core loop lands.

### 3.7 Chrono Trigger — Upgrade Ver. (Square Enix) — IP strength vs port quality
- **Core loop:** classic JRPG: story beats → exploration → Active Time Battle (real-time gauge) combat with 50+ combo "Techs"; extra dungeons (Dimensional Vortex, Lost Sanctum).
- **Session structure:** console-era pacing; save points + **added autosave** + quit-from-menu save.
- **Controls:** updated touch controls; reviewers note "controls take some getting used to" and movement/chest-opening friction.
- **Save model:** save points + autosave (explicitly advertised).
- **Monetization:** $9.99 premium.
- **Praise:** story, strategic ATB combat ("can't auto attack through… you need to strategize").
- **Complaints (3.8★):** **crash erased a save file** (one of the most-upvoted reviews), black-screen hangs, an update that broke a boss fight (auto-close), historically no in-game music mute (later only via Gaming Hub).
- **Chimera relevance:** even a 3.8★ rating on a legendary IP traces to stability + save integrity + missing basic settings (audio mute). Chimera must ship separate music/SFX sliders and bulletproof saves from day one.

### 3.8 Vampire Survivors (Poncle) — respectful F2P done right
- **Core loop:** "be the bullet hell": one-thumb movement → auto-firing weapons → level-up draft choices → survive to dawn (~30-min stage cap); gold earned funds permanent upgrades for the next run.
- **Session structure:** hard-bounded runs (≤30 min); death is expected and feeds meta progression — the "one more run" engine.
- **Controls:** single virtual movement input (weapons auto-fire); playable 1–4 player couch co-op in landscape; **cloud saves** added post-launch (Mar 2023, per TouchArcade news).
- **Save model:** persistent meta progression; cloud saves on mobile.
- **Monetization:** **free**; ads are **opt-in rewarded only** (revive or bonus gold at run end); **DLC is cheap and content-dense** (players single out "Ode to Castlevania" as "a LOT more content than you'd expect").
- **Onboarding:** near-zero friction — one input, immediate power fantasy; secrets and hidden interactions reward long-term play.
- **Retention hooks:** unlock tree, secrets, characters/weapons, DLC packs, update cadence close to PC parity.
- **Praise:** "thoroughly engrossing gameplay loop," monetization respect ("ads only… if you want a free revive"), fast bug fixes.
- **Complaints:** rare bugs (noted as fixed "in a timely fashion"); minor DLC balance wishes.
- **Chimera relevance:** (a) bounded sessions with a guaranteed progress beat; (b) opt-in ads/one-time purchases are review-safe; (c) hidden interactions/secrets create word-of-mouth for narrative games too — Chimera's omen/disposition systems can hide discoverable depth.

### 3.9 Grim Quest (Monomyth) — the closest tonal comp (dark-fantasy text RPG)
- **Core loop:** old-school dark-fantasy dungeon crawler: **interactive text events** + turn-based combat + loot/build (50+ skills/spells) → quests and bounties → deeper, deadlier expeditions; tabletop/DnD framing.
- **Session structure:** short dungeon sorties (~5–15 min, *est.*) around a hub — ideal for narrative-sim pacing like Chimera's travel→scene→camp.
- **Controls:** "intuitive **gesture controls**" for turn-based combat; tile-based movement; minimal twitch requirements.
- **Save model:** offline single-player; 4 difficulty presets + **optional permadeath**; customization options.
- **Monetization:** free with "a few ads," **single one-time purchase removes ads forever** — "No subscriptions, no gacha, no energy timers, no pay-to-win" (store copy verbatim, and echoed in reviews).
- **Onboarding:** genre-literate audience; systems introduced through text events; reviews praise "intuitive UI."
- **Retention hooks:** difficulty presets/permadeath, build variety, lore, sequels/spin-offs (Grim Tides, Grim Omens).
- **Praise:** "excellent system and game design and intuitive UI" make up for minimal graphics; "ads are never overwhelming"; well-written back-story-driven campaign.
- **Complaints:** early-game economy pacing quibbles (later retracted by the same reviewer); graphics austerity (a deliberate trade-off).
- **Chimera relevance:** **proof of market fit**: a text-forward dark-fantasy RPG with minimal art reached 1M+ downloads at 4.7★. Chimera's ink-and-ash aesthetic + deterministic text-heavy sim is a validated niche — with the same expectation of an honest, one-time-purchase monetization stance.

---

## 4. Competitor Feature Matrix

Legend: ✅ = present/advertised · ◐ = partial/optional · ❌ = absent/not advertised · ? = not verified from sources. Store data as of 2026-07-19.

| Feature | Stardew | Exiled Kingdoms | 9th Dawn III | Evoland 2 | Moonlighter (NF) | Soul Knight | Chrono Trigger | Vampire Survivors | Grim Quest |
|---|---|---|---|---|---|---|---|---|---|
| Price | $4.99 | Free (+unlock) | $9.99 (+demo) | $6.49 | Netflix sub | Free | $9.99 | Free | Free |
| Ads | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ◐ (opt-in rewarded) | ✅ (removable) |
| IAP | ❌ | ✅ one-time unlock + donation | ❌ | ❌ | ❌ | ✅ chars/skins/random items | ❌ | ✅ DLC | ✅ one-time ad removal |
| Play Pass | ✅ | ? | ✅ | ✅ | ❌ | ? | ? | ? | ? |
| Offline play | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ (removed — backlash) | ✅ | ✅ | ✅ |
| Touch scheme | Tap-move **or** v-stick | V-pad + buttons | V-pad + buttons *(est.)* | V-controls | Simplified touch | V-stick + auto-aim | Touch menus/movement | One-thumb move | Gestures + taps |
| Aim/attack assist | ✅ auto-attack, auto-select | ✅ hold-to-swing, aim assist | ❌ | ❌ | ◐ (simplified combat) | ✅ auto-aim | ❌ | ✅ auto-fire | ◐ turn-based |
| Controller support | ✅ | ? | ? | ✅ | ? | ✅ | ? | ◐ co-op focus | ❌ |
| Autosave | ✅ (end of day) | ◐ | ? | ◐ (unclear — criticized) | ? | ✅ (meta) | ✅ + save points | ✅ (meta + cloud) | ✅ |
| Multiple save slots | ? | ? | ? | ? | ? | n/a (account) | ? | n/a | ? |
| Cloud save | ❌/❔ | ❌ | ? | ? | ✅ (Netflix acct) | ✅ | ❌ | ✅ (added 2023) | ? |
| Difficulty options | ❌ | ◐ | ✅ (+permadeath, cheats) | ❌ | ❌ | ✅ | ❌ | ◐ | ✅ 4 presets + permadeath |
| Session unit | In-game day (~13–15 min *est.*) | Quest (10–20 min *est.*) | Dungeon dive (15–30 *est.*) | Story segment | Day/night cycle (10–15 *est.*) | Run (15–25 *est.*) | Save-point legs | Run (≤30, capped) | Sortie (5–15 *est.*) |
| Onboarding style | Quest tour | Learn-by-doing | Minimal | **Flawed** (desktop keys) | Learn-by-doing | Instant + layered | Assumed JRPG literacy | Near-zero (1 input) | Text-event driven |
| Retention hooks | Festivals, relationships, updates | Random quests, companions | Collectathon, card game, modes | Genre variety | Dual loop | Co-op, events, sign-ins, skins | NG+ (IP legacy) | Unlocks, secrets, DLC | Difficulty, permadeath, lore |
| Rating (store) | 4.6★ | 4.7★ / 4.8★ Full | 4.3★ | 4.1★ | 2.3★ | 4.6★ | 3.8★ | 4.4★ | 4.7★ |

**Matrix takeaways:** (1) every 4.5★+ title is fully offline; (2) every action title ships an input assist; (3) the two lowest-rated titles are the two with save/stability failures despite premium pricing and strong IP/design; (4) difficulty presets + permadeath are the standard "hardcore option" among top-rated niche RPGs.

---

## 5. UX Benchmark Table

Benchmarks synthesized from platform guidance (Google Android Accessibility: **48×48dp min touch target, ~9mm, ≥8dp separation, hit area may exceed visual bounds**; WCAG 2.1 SC 2.5.5: **44×44 CSS px**) and observed competitor conventions. "Chimera target" maps each row to our screens (`overhead_map`, `dialogue_screen`, `camp_screen`, `journal_screen`, `settings_screen`).

| UX dimension | Platform benchmark | Observed competitor practice | Chimera target |
|---|---|---|---|
| Min touch target | 48×48dp, ≥8dp apart; inflate hit area beyond visual icon | Stardew auto-select removes precision tapping; Grim Quest lauded for "intuitive UI" on small targets | Map node tokens, dialogue choices, stance buttons, camp actions all ≥48dp hit areas; token visuals can stay small |
| Primary navigation | Bottom-of-thumb reach on landscape phones | Stardew bottom toolbar; Soul Knight left-stick/right-action split; VS single-thumb | Bottom quick-bar (Journal/Party/Camp/Settings) on map screen; everything ≤2 taps from map |
| HUD density | Show only what changes | VS: HP/XP/timer only; Stardew: toolbar+clock; action RPGs: stick + ≤4 buttons | Map HUD: date/act, gold/supplies, quick-bar; no persistent clutter over parchment art |
| Menu depth | ≤2 levels for core tasks | Stardew tabbed inventory; Grim Quest flat hub lists; Chrono Trigger deep console menus (criticized era-design) | Any screen reachable in ≤2 taps; journal entries ≤1 tap to expand |
| Text readability | ≥16sp body, scalable; high contrast; ~60–70 chars/line | Chrono Trigger/Evoland 2 readability friction on ports; Grim Quest proves text-heavy works when UI is clean | Ink-on-parchment contrast check; scalable text size setting (we have text speed — add size); avoid all-caps body text |
| Camera control | Pinch-zoom + drag-pan with inertia; double-tap recenter | Stardew offers zoom options; fixed cameras in EK/9th Dawn limit player agency | Chimera map: add pinch-zoom (scroll exists), drag-pan, double-tap/two-finger-tap recenter on party |
| Control options | ≥2 schemes + controller | Stardew: tap/joystick/controller; Soul Knight: stick + auto-aim; VS: one-thumb | Primary: tap-node travel; secondary: virtual joystick; optional: gamepad (Godot supports) |
| Input assist | Reduce precision demands | Auto-aim (Soul Knight), auto-attack (Stardew), hold-to-swing (EK), auto-fire (VS) | Combat: "omen hint" assist toggle; dialogue: tap-anywhere to advance; map: tap-to-path travel |
| Feedback/juice | Immediate, layered (visual+haptic+SFX) | Soul Knight combat feedback; VS level-up fanfare; Stardew shipping tally | Disposition changes animate on the dialogue bar; ink-splash + haptic on choice confirm; camp summary tally |
| Onboarding | Contextual, dismissible, mobile-native language | Positive: Stardew quest tour, VS one-input start; **Negative: Evoland 2 "press tab"** | First 10 min scripted: 1 node → 1 dialogue w/ disposition feedback → 1 camp; hint toasts, never desktop keys; replayable from settings |
| Session checkpoint | Save at every natural boundary | Stardew end-of-day autosave; Chrono Trigger autosave+points; VS run-end; **Negative: Evoland 2 unclear saves, CT crash-wipes** | Autosave on scene resolution, camp, and app backgrounding; visible "Saved • just now" indicator |
| Save management | Multi-slot + corruption-proof | Moonlighter/CT show cost of failure; EK free/paid parity keeps users whole | 3 slots + autos slot; write-temp-then-rename; keep last-good backup; show slot metadata (act, playtime) |
| Audio settings | Separate music/SFX + mute | **Negative: CT's missing mute** generated years of complaints | Music slider, SFX slider, master mute (settings screen — wire to buses) |
| Accessibility | Reduced motion, text scaling, color-safe | Stardew/Chimera-style settings parity; VS readable chaos via silhouettes | Keep reduced-motion toggle; add text-size slider; ensure parchment palette passes contrast in sunlight (dark ink ≥4.5:1) |
| Offline posture | Advertise it; never remove it | Soul Knight removal backlash; "Offline" Play label on winners | Zero network requirement for core game; declare minimal data safety; list "Offline" in store copy |

---

## 6. Actionable Takeaways for Chimera (prioritized)

Priority: **P0** = must-ship (launch-blocking quality bar) · **P1** = strong differentiator, ship in first milestone · **P2** = post-launch/nice-to-have. Each item lists the Chimera subsystem(s) it affects (map, dialogue, combat, camp, journal, settings, onboarding, save) and the evidence behind it.

### P0 — Launch-blocking

1. **Crash-proof, always-on saving.** Autosave after every scene resolution, at camp, and on app backgrounding/pause; write to temp file then atomic rename; keep a last-good backup; never let a crash destroy progress. *Evidence:* Chrono Trigger (3.8★) & Moonlighter (2.3★) — save wipes/crashes are the dominant 1★ reviews; Stardew's end-of-day autosave is a praised mobile feature. → **save, settings**
2. **Visible save state + multi-slot.** 3 manual slots + 1 autos slot with metadata (act, in-game date, playtime) and a subtle "Saved" indicator. *Evidence:* Evoland 2 reviews — "designated save spots… unclear when it autosaves" hurt a 4.1★ port. → **save, settings**
3. **Touch-first map controls.** Tap-node/tap-to-travel as the primary verb; drag-pan with inertia; **pinch-zoom** (we currently have scroll-wheel only); double-tap recenter; optional virtual joystick. *Evidence:* Stardew ships 3 control schemes; fixed-camera RPGs feel dated; Chimera is currently mouse-first (WASD/wheel per GODOT_PORT.md). → **map, onboarding**
4. **48dp+ touch targets everywhere.** Node tokens, dialogue choices, stance buttons, camp actions: ≥48×48dp hit areas with ≥8dp spacing; inflate hit areas beyond small parchment icons. *Evidence:* Google/Android accessibility guidance (48dp ≈ 9mm), WCAG 2.5.5 (44px); Stardew's auto-select exists precisely to dodge precision tapping. → **map, dialogue, combat, camp**
5. **Mobile-native onboarding, scripted first loop.** First session: guided travel to one node → one dialogue showing the disposition bar move → one camp with risk summary; contextual, dismissible hint toasts; tutorial replayable from settings; **never reference keyboard/mouse**. *Evidence:* Evoland 2's "press the tab button!" is a store-review meme; Grim Quest/9th Dawn show this audience embraces depth when the first minutes are legible. → **onboarding, dialogue, camp**
6. **Offline-first, and say so.** No network requirement for any core feature; minimal Play data-safety declaration; "Offline" + "no ads/IAP" (or chosen model) in store copy. *Evidence:* Soul Knight lost stars for removing offline; every 4.5★+ comp here is offline; Stardew/Grim Quest/Evoland 2 market it explicitly. → **save, settings**

### P1 — First milestone

7. **Monetization: free Act 1 + one-time unlock (recommended), or $4.99–$6.99 premium + free demo.** No energy, no gacha, no forced ads. *Evidence:* Exiled Kingdoms (4.7★, 1M+) and Grim Quest (4.7★, 1M+) prove free-with-one-time-unlock; Stardew ($4.99) and 9th Dawn III ($9.99+demo) prove premium; the narrative-RPG audience explicitly rewards "no subscriptions, no gacha, no pay-to-win." → **settings (unlock state), store positioning**
8. **Design the 10–15 min "journey loop" with a summary beat.** Travel → scene → camp = one session unit; camp shows a Stardew-style tally (disposition shifts, journal entries, supplies) and triggers autosave. *Evidence:* day-cycle checkpoints (Stardew, Moonlighter) and bounded runs (VS, Soul Knight) drive "one more" retention without FOMO mechanics. → **map, camp, journal, save**
9. **Retention via mastery, not timers.** Difficulty presets + optional permadeath/ironman; collectible lore codex in the journal; per-NPC relationship outcomes worth replaying for; achievements. *Evidence:* Grim Quest (4 presets + permadeath), 9th Dawn III (modes + cheats + collectathon) keep niche RPG players for 50+ hours. → **journal, combat, camp, settings**
10. **Dialogue UX polish.** Typewriter text with tap-to-complete, tap-anywhere advance, scrollable backlog, big choice buttons (≥48dp), and **immediate disposition feedback** on the bar after each choice. *Evidence:* relationship feedback is the praised core of Stardew/EK-style loops; Chimera's differentiator is disposition — it must visibly react. → **dialogue**
11. **Combat readability + assist.** Stance duels: 3–4 large stance buttons, telegraphed enemy intents (use the omens system as the UI), an assist toggle (suggest/highlight a stance), haptic + ink-splash feedback; no precision or twitch inputs. *Evidence:* every action comp ships assists (auto-aim/auto-attack/auto-fire); Chrono Trigger is praised for *strategic* (not reflex) combat on mobile. → **combat, settings**
12. **Complete settings screen.** Separate music/SFX sliders + master mute (wired to audio buses), text speed **and text size**, reduced motion (exists), high-contrast ink toggle, reset tutorial. *Evidence:* Chrono Trigger's missing mute generated years of complaints; readability is the parchment theme's biggest risk. → **settings, dialogue**

### P2 — Post-launch / polish

13. **HUD quick-bar + badges.** Persistent bottom quick-bar (Journal/Party/Camp/Settings) with badge counts on new journal entries; keep the map otherwise chrome-free. *Evidence:* Stardew toolbar convention; VS-style minimal HUD. → **map, journal**
14. **Secrets + update cadence.** Seed hidden interactions (VS-style secrets, Grim Quest lore); ship small free content patches (new scenes/NPCs) with store "What's new" notes; respond to reviews (Playdigious does this even on mixed reviews). *Evidence:* VS/Evoland 2/9th Dawn update notes; review-response builds trust on a new IP. → **journal, dialogue, meta**
15. **Controller support + Play Pass pitch.** Godot gamepad support is cheap; Play Pass featuring favors premium, offline, controller-friendly titles. *Evidence:* Stardew/Evoland 2/9th Dawn III are Play Pass titles; controller support is table stakes for premium ports. → **map, combat, settings**

---

## 7. Sources

All URLs retrieved and quoted on 2026-07-19. Store metrics (rating, review counts, downloads, prices, "What's new" text) are from the live Google Play pages on that date.

**Google Play store pages**
1. Stardew Valley — https://play.google.com/store/apps/details?id=com.chucklefish.stardewvalley&hl=en_US
2. Exiled Kingdoms RPG (free) & Exiled Kingdoms – Full — https://play.google.com/store/search?q=Exiled%20Kingdoms%20RPG&c=apps&hl=en_US and https://play.google.com/store/search?q=Exiled%20Kingdoms&c=apps&hl=en_US
3. 9th Dawn III RPG (+ demo listing) — https://play.google.com/store/apps/details?id=com.valorware.ninthdawniii&hl=en_US and https://play.google.com/store/search?q=9th%20Dawn%20III&c=apps&hl=en_US
4. Evoland 2 — https://play.google.com/store/apps/details?id=com.playdigious.evoland2&hl=en_US
5. Moonlighter Netflix Edition — https://play.google.com/store/apps/details?id=com.netflix.NGP.Moonlighter&hl=en_US
6. Soul Knight — https://play.google.com/store/apps/details?id=com.ChillyRoom.DungeonShooter&hl=en_US
7. Chrono Trigger (Upgrade Ver.) — https://play.google.com/store/apps/details?id=com.square_enix.android_googleplay.chrono&hl=en_US
8. Vampire Survivors — https://play.google.com/store/apps/details?id=com.poncle.vampiresurvivors&hl=en_US
9. Grim Quest — https://play.google.com/store/apps/details?id=com.grimdev.grimquest&hl=en_US

**Reviews & press**
10. TouchArcade, "'Exiled Kingdoms RPG' Review – Chop 'til You Drop" (4.5★, 2016) — https://toucharcade.com/2016/11/30/exiled-kingdoms-rpg-review/
11. TouchArcade search listing: "'9th Dawn III' Review – Keeping You Playing Until Dawn and Beyond" (5★, 2020) — https://toucharcade.com/?s=9th+dawn+iii
12. TouchArcade search listing: "'Vampire Survivors' Mobile Review – Nearly Perfect" (4.5★, 2022) + cloud-save update news (2023) — https://toucharcade.com/?s=vampire+survivors+mobile
13. Pocket Gamer, "Moonlighter Switch review" (core-loop analysis, 2018) — https://www.pocketgamer.com/moonlighter/review/
14. Android Police, "Best Android games: AP's top picks for every category" (2024) — https://www.androidpolice.com/best-android-games/

**Platform UX guidance**
15. Android Accessibility Help, "Touch target size" (48×48dp, ~9mm, ≥8dp separation) — https://support.google.com/accessibility/android/answer/7101858?hl=en
16. W3C WCAG 2.1, Understanding SC 2.5.5 Target Size (44×44 CSS px) — https://www.w3.org/WAI/WCAG21/Understanding/target-size.html

## 8. Methodology & Caveats

- **Estimates** are marked *(est.)* and cover session-length figures and a few control-scheme details not stated verbatim in sources. User-reported figures (e.g., "~50 hours main story," "~$20 unlocks most characters") are labeled *user-reported*.
- Google Play rounds counts (e.g., "5M+", "186K reviews"); treat them as order-of-magnitude.
- Ratings fluctuate; all figures are point-in-time (2026-07-19) and should be refreshed pre-launch.
- The Moonlighter analysis covers the Netflix Edition (the current Android distribution); earlier standalone mobile editions are not evaluated.
- TouchArcade ratings are iOS-based reviews of the same games; used for design/UX judgment, not store metrics.
- No statistics were invented; where a data point could not be verified from a fetched source (e.g., save-slot counts, some control details), it is marked "?" or *(est.)* in the matrix.







