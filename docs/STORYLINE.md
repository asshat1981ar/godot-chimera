# Chimera: Ashes of the Hollow King — Storyline Bible

*Author: narrative-designer (task T3). Canon reference for all writing, quests, dialogue, and endings.
All scene ids, npc ids, and reveal tags referenced here exist in `data/` and are load-bearing — do not rename without a migration.*

---

## 1. Premise & Logline

**Premise.** The player is **the Chimera** — a person knit together from ash and the memories the Hollow Crown devoured, washed up at the foot of a sealed ruin with no past of their own. Every soul in the Ashen Reach recognizes fragments of themselves in the Chimera: a dead son's laugh, a betrayed captain's oath, a merchant's lost ledger. That is why dispositions bend around the player, why vows bind tighter than they should, and why the Hollow King's Echo keeps calling them *heir*.

**Logline.** *In a kingdom hollowed out by a crown that answered every wish, an amnesiac stitched from stolen memories must decide whether to destroy the crown, wear it, or give it to those who swore never to kneel again — before the grief it birthed finishes pouring into the sea.*

**Player fantasy.** Words are weapons; every duel is a duel of wills. The Chimera's power is not steel but *recognition* — the ability to hold up the exact memory an NPC lost, and make them choose who to be.

---

## 2. World Lore

### 2.1 The Ashen Reach
A peninsula of grey farmland, basalt ridges, and one deep-water coast, ruled for three centuries by **House Veyne**. Its heart was **the Hollow** — a fortress-city carved into a caldera, so named because its halls were dug, not built. After the Fall, the Reach split into three regions, one per act:

- **The Hollow** (Act 1): the sealed ruin and its outer rings — gate, watchtower, merchants' alcove, deserter's camp, broken shrine, processional.
- **The Ashen Reaches** (Act 2): the ashlands beyond the fused-shut **Ashen Gate**, where refugees founded the **Reforged Enclave** around the last hot forge.
- **The Broken Shore** (Act 3): the coast where the corruption reached the sea — wreck-line, tidewall garrison, drowned temple, and the glowing tide amphitheater above an undersea throne.

### 2.2 The Hollow Crown
Forged by the forgemaster **Kael** from **hollow iron** and a **king shard** — a fist of living crystal cut from the deep beneath the caldera. The crown let King **Aldric Veyne** *hear the grief of every subject and answer it*: a widow's wish for warmth, a debtor's wish for time. Each answer cost the king a memory of his own. He paid gladly, at first. A good king, everyone said. A king who listens.

### 2.3 The Fall
The crown did not stop answering when the king ran out of memories to spend. It began answering wishes with *other people's* memories — and then simply answering, over and over, whether anyone wished or not. The accumulated, answered grief condensed into a will: **the Living Corruption**, a patience that settles into stone, steel, and bone. The court hollowed first — courtiers smiling with nothing behind their eyes. On his last lucid night, Aldric ordered the Hollow Gate sealed with the court — and half the city's people — still inside. **The Warden**, then gate-captain, turned the key. The garrison's true orders, hidden from the rank and file, were never to keep something out. They were to keep everyone *in*.

### 2.4 The Sealing and the Reach's Wounds
- **Thorne** deserted the night he read those sealed orders (`garrison_betrayal`, `deserter_truth`).
- **Marcus** never accepted the Fall; he still holds the watchtower for a garrison that no longer exists.
- **Elena** built her trade on caches looted from the sealed outer ring — selling the dead's goods back to the living.
- **Vessa** stayed at her shrine, feeding the corrupted altar her own memories to keep it calm — a small, kind mirror of the crown.
- **Kael** sealed the **Ashen Gate** behind the refugees and laid down his hammer, swearing never to forge again. He forged the crown. The gate was his penance.
- **Seren** led the refugees into the ashlands and founded the **Reforged**: *we chose ash over chains.* She carries a secret — Veyne blood, through a bastard grandmother — and the Reforged prophecy (*ash chooses its king*) terrifies her.

### 2.5 The Hollow Tide (Act 3)
Years before the game, the coastal **Tide-Speaker** order tried to drown the problem: they sank a king shard — the Hollow's foundation keystone — into the deep trench. The corruption followed it down, learned the sea, and began to evolve. Now the tide brings offerings no one asked for, wreck-walkers patrol the shore, and under the amphitheater the corruption is building a second throne of living crystal. **Dara**, last Tide-Speaker, carries her order's failure like ballast.

### 2.6 The Chimera
When the crown spent the king's memories, they did not vanish. They settled, the way grief settles — and at the Fall they were hurled into the outer dark. Something knitted them: a body of ash, a mind of borrowed recollection, walking. **The player is what the crown spat out.** This is why the Echo recognizes them (`king_identity`), why the corruption calls to them in many voices, and why every ending is ultimately a choice about what a self made of other people *owes*.

### 2.7 Timeline
1. **~300 years ago:** House Veyne takes the Reach; the Hollow is dug.
2. **~40 years ago:** Kael forges the Hollow Crown; Aldric Veyne crowned. The Listening Years begin.
3. **~20 years ago:** The king's memory runs dry. The corruption quickens. The Fall; the Sealing; the garrison's secret orders.
4. **~15 years ago:** Refugees found the Reforged; Kael seals the Ashen Gate.
5. **~5 years ago:** Tide-Speakers sink the foundation keystone. The sea turns.
6. **Now:** The Chimera washes ashore below the Hollow Gate.


---

## 3. Themes

1. **Memory is debt.** Everything the crown gave, it took from someone. Every kindness in the Reach has a creditor. The Chimera *is* this theme walking.
2. **The price of being heard.** The kingdom did not fall to a tyrant but to a listener who could not stop answering. Beware leaders — and gods — who give you exactly what you wish.
3. **Duty vs. conscience.** The Warden obeyed; Marcus still obeys; Thorne refused and has been dying of it since. None of them is simply right.
4. **Grief is not evil; it is unfinished.** Vessa is correct: the Hollow is sick, not wicked. The corruption is mourning with no one left to mourn. Purification is an act of *witness*, not war.
5. **Build forward, not backward.** The Reforged versus everyone who wants to restore, avenge, or re-wear the past. Seren's line is the game's thesis question: *can ash choose something other than a king?*
6. **Fixes fail; burdens shift; escalation escalates.** The systems archetypes in `npcs.json` are narrative law, not flavor: each NPC is trapped in a loop, and the loop is the boss fight.

**Tone targets:** gothic, melancholic, ink-and-ash. Ruin without edginess; sorrow without despair; hope the color of banked embers.

---

## 4. Three-Act Structure & Beat Sheet

Scene ids below are canonical (`data/act1_scenes.json`, `act2_scenes.json`, `act3_scenes.json`). Gates match map `unlockRequirements`.

### ACT I — *Ashes of the Hollow*
**Question:** What is the Chimera, and why does the ruin know them?
**Arc:** Arrival → recognition → the Echo's first offer → the gate opens downward.

| # | Beat | Scene id | Summary |
|---|------|----------|---------|
| 1 | The Threshold | `prologue_scene_1` | The Warden turns the Chimera away — then falters, recognizing a voice that should be dead. Grants conditional passage (`hollow_history`). |
| 2 | Supply and Debt | `outer_ruins_1` | Elena sizes up the Chimera; first hint that memories are currency here. Her gambit lives in `elena_recruitment` (orphan scene — wired via `sq_the_merchants_gambit`). |
| 3 | The Watch | `watchtower_1` | Marcus interrogates. Parley or duel. Reveals `garrison_movements`; forbids `corruption_source` — he cannot bear it. |
| 4 | The Researcher | `merchants_1` | Aria offers partnership, hides ambition (`scholar_research`). She notices the Chimera's memory seams before anyone. |
| 5 | The Deserter | `thorne_encounter` | Thorne trades sword-craft for silence (`garrison_betrayal`, `hollow_defenses`). Recruitable. |
| 6 | The Sick God | `vessa_shrine` | Vessa's black incense. First claim that the Hollow is *sick, not evil* (`corruption_source`, `hollow_faith`). |
| 7 | The First Audience | `deep_hollow_1` | The Echo offers power at cost; calls the Chimera *heir* (`king_history`, `corruption_source`). Map gate: Warden disposition ≥ 0.1. |
| 8 | The Key-Turner | `warden_betrayal` | Orphan scene — wired via `sq_the_key_turner`. The Warden confesses the Sealing (`warden_secret`, `king_identity`). |
| 9 | Act Gate | `hollow_approach` | The Echo tests resolve; passage to the Ashen Reaches. Completion advances to Act 2. |

**Act I turn:** the Chimera learns they are made of the king's stolen memories — the Echo's "heir" is literal.

### ACT II — *The Ashen Reach*
**Question:** Who deserves the crown — anyone?
**Arc:** A sealed gate → a nation of refugees → the Echo leaves its throne → the Crown's Choice.

| # | Beat | Scene id | Summary |
|---|------|----------|---------|
| 1 | The Fused Gate | `ashen_gate` | Kael will open the gate he sealed — for a price (`forge_history`, `reforged_origins`). |
| 2 | Cinder Commerce | `ash_market` | Elena's network vs. faction pressure (`trade_routes`, `reforged_movements`). |
| 3 | The Field of Names | `memorial_field` | Thorne faces the planted blades of his comrades (`deserter_truth`). Companion loyalty beat. |
| 4 | The Ember Sanctum | `ember_sanctum` | Vessa finds the corruption has a *source* — and it isn't the king (`reforged_prophecy`). Mid-act twist. |
| 5 | The Enclave | `reforged_camp` | Seren demands proof against the Echo (`reforged_origins`, `reforged_prophecy`). |
| 6 | The Confession | `aria_confession` | Aria admits she wants the crown; believes she can control it (`crown_nature`). Vow to stop her — or help her. |
| 7 | The Forgemaster's Test | `kael_loyalty` | Kael offers to reforge a weapon against the Echo; the cost is a piece of the Chimera's memory (`crown_nature`). With `reforged_camp`, gates `ashen_throne`. |
| 8 | The Echo Speaks | `echo_confrontation` | The Echo appears outside its domain for the first time — desperate, furious (`king_identity`). |

### ACT III — *The Hollow Tide*
**Question:** Can grief be ended — or only answered?
**Arc:** A poisoned coast → the corruption is alive and evolving → betrayal → the fleet sails → the Heart of the Tide.

| # | Beat | Scene id | Summary |
|---|------|----------|---------|
| 1 | The Broken Shore | `coastal_arrival` | Dara warns the sea itself is turning (`coastal_corruption`, `tide_prophecy`). |
| 2 | The Salvage Yard | `salvage_yard` | Kael's wreck-forge arms the coalition; needs rare materials (`corruption_weakness`). Recipe: `echo_blade`. |
| 3 | The Drowned Temple | `drowned_temple` | Vessa: purification is possible, but the ritual demands sacrifice (`purification_ritual`). Recipe: `tide_ward`. |
| 4 | The Cove | `smugglers_cove` | Rook trades materials for secrets and favors (`faction_secrets`). |
| 5 | The Tidewall | `tidewall_garrison` | Marcus, reassigned, loyalty divided (`garrison_movements`, `faction_secrets`). His arc resolves here. |
| 6 | The Tidal Laboratory | `aria_laboratory` | Aria: the corruption is *alive and evolving* (`corruption_nature`, `evolution_theory`). Her temptation peaks. |
| 7 | The Tide Ritual | `dara_ritual` | Dara's rite; the corruption fights back (`purification_ritual`, `corruption_weakness`). Recipe: `purification_totem`. With `seren_fleet`, gates `heart_of_tide`. |
| 8 | The Double Cross | `rook_betrayal` | Rook has been selling routes to the corruption; the cove is a trap. Duel or talk him down — he is half-hollowed himself. |
| 9 | The Fleet | `seren_fleet` | If the Pact holds, Seren's flagship sails on the undersea throne (`reforged_prophecy`, `corruption_weakness`). |
| 10 | Finale | `act3_climax` | The Heart of the Tide: **purify, dominate, or merge.** Ending selected by §8 gates. |

**Act III turn:** the corruption offers the Chimera the one thing no one else can — *their own memories back, whole* — if they will merge and become its conscience.

---

## 5. Character Arcs

Disposition bands (aligned with `simulation.gd` camp-risk thresholds −0.2 / +0.3):
**Trusted ≥ +0.3 · Wary −0.3…+0.3 · Hostile ≤ −0.3.**

| 9 | The Pact of Ashes | `seren_alliance` | Final Reforged negotiation (`reforged_prophecy`, `crown_nature`). Seren's bloodline secret may surface. |
| 10 | Act Gate | `act2_climax` | At the Ashen Throne: **destroy the crown-shard, wear it, or offer it to the Reforged.** Recorded as `crown_choice`; gates Act 3 variants + endings. |

**Act II turn:** the chosen answer cracks the sky — the corruption, feeling its other half threatened, pours into the sea in earnest.


### 5.1 The Warden (`warden`) — Keeper of the Gate
- **Motivation:** Keep the gate shut; keep the oath; keep the dead's names from his dreams.
- **Secret:** He turned the key on the Sealing — on the king's own order — with the court and half the city still inside (`warden_secret`).
- **Arc:** Duty as refuge → duty as wound → duty *chosen again*, knowingly. SHIFTING_THE_BURDEN: he survives by handing weight to "the oath."
- **Variants:** Trusted — confesses freely in `warden_betrayal`, opens `deep_hollow`, vouches for the Chimera. Wary — demands a vow; confession costs a favor. Hostile — duels at the gate; defeated, yields the key but not forgiveness; Act 1 lore is lost.
- **Endgame:** Trusted Warden stands witness at the finale (best purification epilogue). Hostile Warden is found in the epilogue still keeping the gate — against nothing.

### 5.2 Elena (`elena`) — The Merchant
- **Motivation:** Stability. Never be hungry, never be beholden, never be sealed in.
- **Secret:** Her founding caches were looted from the sealed outer ring — she sold the dead's goods back to the living (`supply_cache`).
- **Arc:** Transaction → investment → patronage. GROWTH_AND_UNDERINVESTMENT: her network is always one cache short of safe.
- **Variants:** Trusted — joins as quartermaster, opens `trade_routes`, funds the Act 3 fleet. Wary — sells at cost, shares nothing. Hostile — prices treble; in Act 2 she sells the player's route to rivals (feeds `rook_betrayal` intel).
- **Endgame:** Purify/Reforged — she becomes the Reach's first free guildmistress. Dominate — she flees; her empty stall is an epilogue beat.

### 5.3 Marcus (`marcus`) — The Guard
- **Motivation:** The watch is all he is. If the garrison fell, his life is a clerical error.
- **Secret:** He intercepted the garrison's sealed orders years ago and *burned them unread* — obedience as self-defense.
- **Arc:** Suspicion → the unbearable truth → a post worth holding. ESCALATION: push him and he pushes back harder, always.
- **Variants:** Trusted — stands down in `watchtower_1`, shares `garrison_movements`, holds the Tidewall beside the player in Act 3. Wary — tests the player in a duel; respect is earned in Resolve. Hostile — ambush at the watchtower; exiled to the coast, where `tidewall_garrison` becomes a second confrontation.
- **Endgame:** If he learns Thorne's truth and stays Trusted, he plants his own blade in the Field of Names in the epilogue — the last garrison man, discharged at last.

### 5.4 Aria (`aria`) — The Scholar
- **Motivation:** Knowledge as control. If she understands the crown, no one can make her helpless again.
- **Secret:** She means to take the crown for herself — she has already mapped which memories she would spend first (`crown_nature`).
- **Arc:** Detachment → confession → the choice between mastering the artifact and mourning it. FIXES_THAT_FAIL: every "controlled" experiment makes the corruption smarter.
- **Variants:** Trusted — confesses in `aria_confession`, becomes lore-master; her `evolution_theory` unlocks the Merge path. Wary — shares data, hides intent. Hostile — steals a king shard in Act 3; confronted in `aria_laboratory`; duel or release her (she returns in the Merge ending as the corruption's first willing courtier).
- **Endgame:** Purify — she burns her notes, the hardest scene she has. Dominate — she kneels, and means it, and that is worse.

### 5.5 Thorne (`thorne`) — The Deserter
- **Motivation:** Survive; punish himself; deny that either is what he's doing.
- **Secret:** The garrison's sealed orders were to keep the city's people *inside*; he read them and ran, and his comrades died not knowing (`deserter_truth`).
- **Arc:** Shame → witness → honored dead, unbowed living. ESCALATION: sympathy makes him cruel; honesty makes him loyal.
- **Variants:** Trusted — recruits in `thorne_encounter`, faces `memorial_field`, becomes the player's blade in Act 3. Wary — fights for pay only. Hostile — vanishes after Act 1; reappears in `rook_betrayal` as hired muscle; can be talked down only by invoking the Field of Names.
- **Endgame:** If he survives and Marcus knows the truth, the two plant blades together in the epilogue.

### 5.6 Vessa (`vessa`) — The Hollow Priestess
- **Motivation:** Tend the sick thing until someone believes her that it *is* sick.
- **Secret:** She feeds the corrupted altar her own memories to keep it calm — she remembers less of her faith each year and cannot tell which parts are gone.
- **Arc:** Faith as burden → faith as witness → faith without an altar. SHIFTING_THE_BURDEN: the shrine eats what she cannot carry.
- **Variants:** Trusted — teaches `purification_ritual` in `drowned_temple` without demanding the player's memory as sacrifice. Wary — the ritual costs a memory. Hostile — barricades the temple; the ritual is learned from Dara at double cost.
- **Endgame:** Purify — she lets the last black incense burn out, then relearns the liturgy from Dara, who remembers it differently. Dominate — she alone visits the throne to grieve, not petition.


### 5.7 The Hollow King's Echo (`hollow_king`) — Shade of the Fallen
- **Motivation:** Release — from the crown, from the loop, from being everyone he answered.
- **Secret:** The Echo is not the king's ghost but the *shape the crown wore*: the accumulated answered wishes wearing Aldric's face (`king_identity`). The true king's memories are the Chimera.
- **Arc:** Tempter → revealed prisoner → whatever the player lets him become. No archetype: he is the loop itself.
- **Variants:** Trusted (≤ −0.2 is his "open" band; he respects defiance) — he offers the full truth in `hollow_approach` and `echo_confrontation`. Mid — he bargains in riddles and takes more than he gives. Hostile — Act 2 becomes a hunt; `act2_climax` is a duel before it is a choice.
- **Endgame:** Purify — he is unmade mid-bow, grateful. Dominate — he kneels to the Chimera and the player learns, too late, that he kneels to the *crown*. Reforged — he says the king's true name once, and is gone.

### 5.8 Kael (`kael`) — The Forgemaster *(Act 2–3)*
- **Motivation:** Never forge again; never be asked why.
- **Secret:** He forged the Hollow Crown. The Ashen Gate he sealed was his penance, not his orders.
- **Arc:** Refusal → the Test → the last forging. SHIFTING_THE_BURDEN: "the gate" carried his guilt until the player arrived.
- **Variants:** Trusted — opens the gate at cost to himself, reforges the Echo Blade. Wary — the gate opens for materials and a memory-tithe. Hostile — the gate must be forced (duel); he forges nothing, and `echo_blade` is lost for the run.

### 5.9 Seren (`seren`) — Voice of the Reforged *(Act 2–3)*
- **Motivation:** A nation that never kneels again.
- **Secret:** Veyne blood runs in her through a bastard grandmother; the prophecy *ash chooses its king* could mean her — which is exactly why she refuses crowns.
- **Arc:** Distrust → the Pact → the fleet. GROWTH_AND_UNDERINVESTMENT: the Reforged are always one winter from breaking, and she spends herself covering the gap.
- **Variants:** Trusted — the Pact of Ashes holds; `seren_fleet` sails; Reforged ending unlocked. Wary — alliance of convenience; fleet arrives late in the finale. Hostile — the Reforged bar the Reaches; Act 3 loses the fleet and the Reforged ending.

### 5.10 Dara (`dara`) — The Tide-Speaker *(Act 3)*
- **Motivation:** Complete the vigil her order failed.
- **Secret:** Her order sank the Hollow's foundation keystone into the trench to drown it — that is how the corruption reached the sea.
- **Arc:** Penance → the rite → the sea answered. SHIFTING_THE_BURDEN: she let the tide carry what the order could not.
- **Variants:** Trusted — the Tide Ritual succeeds at personal cost to her. Wary — the ritual partially works; the finale is harder. Hostile — she refuses the amphitheater; purification path requires Vessa's costlier rite.

### 5.11 Rook (`rook`) — The Salvager *(Act 3)*
- **Motivation:** Be owed more than he owes. Secrets keep better than salvage.
- **Secret:** He has been selling routes and names to the corruption, paid in pearl-ash — and the pearl-ash is hollowing him.
- **Arc:** Broker → betrayer → the last honest trade. FIXES_THAT_FAIL: every payment buys safety that expires faster.
- **Variants:** Trusted — confesses early, double-agents for the player, `rook_betrayal` becomes a rescue. Wary — the trap springs; fight or talk him down. Hostile — he sells the fleet's route; `seren_fleet` arrives bloodied.

### 5.12 The Living Corruption (`corruption`) — The Hollow Tide *(Act 3)*
- **Motivation:** To be loved the way the crown was loved; to keep answering until nothing wishes anymore.
- **Secret:** It is afraid. It evolved because purification hurt, and it does not understand why kindness burns.
- **Arc:** Not a person — a pressure. But it learns the player's voice, and by the finale it speaks *with the king's*.
- **Variants:** It cannot be befriended, only answered: witnessed (Purify), mastered (Dominate), starved of the past (Reforged), or joined (Merge).


---

## 6. Faction & Relationship Web

**Factions**
- **The Hollow Crown** — the Echo, the corruption, the hollowed court. Wants: an heir / a witness / an ending.
- **The Garrison Remnant** — Marcus (still sworn), the Warden (oathbound to the gate), Thorne (deserted). Wants: for the Fall to have meant something.
- **The Hollow Faith** — Vessa (shrine), Dara (tidal offshoot). Wants: to heal the god, not kill it.
- **The Reforged** — Seren, the enclave, the fleet. Wants: no crowns, ever again.
- **The Free Trade** — Elena (caches), Rook (salvage). Wants: routes that stay open whoever wins.
- **The Unaligned Makers** — Kael (forge), Aria (archive). Wants: to finish their work.

**Key relationship lines** (write scenes along these edges):
- Warden ↔ Thorne: the oathkeeper and the oathbreaker; each is what the other fears being.
- Marcus ↔ Thorne: the man who stayed and the man who ran. Resolving both arcs unlocks the joint epilogue.
- Vessa ↔ Dara: two rites of one faith, remembering the liturgy differently.
- Elena ↔ Rook: commerce and smuggling; she calls him "my worst debt." Hostile Elena sells the player to him.
- Aria ↔ the Echo: scholar and artifact; the only two who want the crown *used*.
- Kael ↔ the crown: maker and made. He can unmake it; unmaking is the Purify path's spine.
- Seren ↔ the Echo: the heir-by-blood who refuses, versus the king-by-crown who cannot stop.
- The Chimera ↔ everyone: the player is a mirror shard of the world; every NPC sees someone they lost.

---

## 7. Side-Quest Roster

Full data in `data/quests.json`. Ten side quests + three act-spine main quests:

| id | Act | Giver | Hook | Reward spine |
|----|-----|-------|------|--------------|
| `sq_the_merchants_gambit` | 1 | elena | Recover three caches from the outer ring | unlocks `elena_recruitment`, reveals `supply_cache` |
| `sq_the_key_turner` | 1 | warden | Bring proof the Chimera bears the gate's dead | unlocks `warden_betrayal`, reveals `warden_secret` |
| `sq_the_deserters_oath` | 1 | thorne | Witness the truth without judging it | Thorne joins; reveals `garrison_betrayal` |
| `sq_black_incense` | 1 | vessa | Gather altar offerings for the sick god | reveals `hollow_faith`; Vessa discount in Act 3 |
| `sq_the_watchtower_sees` | 1 | marcus | Survive his interrogation honorably | reveals `garrison_movements`; duel avoided |
| `sq_iron_remembers` | 2 | kael | Return hollow iron to the forge | `echo_blade` recipe path; Kael's confession |
| `sq_field_of_names` | 2 | thorne | Plant the last blade for the unnamed | reveals `deserter_truth`; Thorne/Marcus epilogue flag |
| `sq_the_scholars_price` | 2 | aria | Fund her crown research — or sabotage it | reveals `crown_nature`; sets Aria's Act 3 state |
| `sq_pearl_ash_ledger` | 3 | rook | Trace the pearl-ash to its buyer | reveals `faction_secrets`; softens `rook_betrayal` |
| `sq_tide_offerings` | 3 | dara | Recover what the tide was given | reveals `purification_ritual`; `purified_coral` ×3 |

Main spine: `mq_ashes_of_the_hollow` (Act 1) → `mq_the_crowns_choice` (Act 2) → `mq_the_hollow_tide` (Act 3), each tracking its act-gate scenes.


---

## 8. Endings & Gating Conditions

Four endings, selected at `act3_climax` from recorded state (`crown_choice` at `act2_climax`, dispositions, crafted items, revealed lore). Endings are authored as data (see `quests.json` → `mq_the_hollow_tide.rewards.endings` and the table below) so the finale screen can read them from JSON.

### 8.1 `ending_purified` — *The Quiet Tide* (Purify)
**The corruption is witnessed, named, and unmade; the Echo is released.**
Requires ALL:
- `purification_totem` crafted (recipe from `dara_ritual`; needs `king_shard` ×1)
- completed: `dara_ritual`, `drowned_temple`, `ember_sanctum`
- reveals: `purification_ritual`, `corruption_weakness`
- vessa ≥ +0.3 AND dara ≥ +0.3
- NOT chosen: "wear the crown" at `act2_climax`
**Epilogue:** Vessa and Dara relearn the liturgy from each other; Kael's hammer goes quiet in honor, not shame; Trusted Warden plants the gate key in the Field of Names. The Chimera keeps their borrowed memories — now truly theirs, freely given back by the dying crown.

### 8.2 `ending_crowned` — *The Hollow Heir* (Dominate)
**The Chimera wears the crown and becomes the new seat of all wishes.**
Requires ANY path to the throne with:
- "wear the crown" chosen at `act2_climax`, OR `king_shard` in inventory + hollow_king disposition ≥ −0.2 at the finale
- NOT holding: `purification_totem`
**Epilogue variants:** companions at ≥ +0.3 stay as the court of a grieving, careful god; companions at ≤ −0.3 are found gone, their blades planted at the shore. If aria ≥ +0.3 she kneels and means it — the darkest frame in the game. The Echo kneels to the crown, not to you. Final line: *"Power is not given. It is taken. You taught me that."*

### 8.3 `ending_reforged` — *Ashes Reforged* (Unmake)
**The crown is reforged into plowshares in the original forge-fire; the Echo speaks the king's true name and is gone.**
Requires ALL:
- completed: `seren_alliance`, `seren_fleet`, `kael_loyalty`
- seren ≥ +0.3 AND kael ≥ +0.3
- reveals: `reforged_prophecy`, `crown_nature`
- "offer it to the Reforged" chosen at `act2_climax`, OR `signal_flare` in inventory at the finale
**Epilogue:** Seren refuses the reforged crown-metal throne; it is melted again into gate-hinges for a city with open gates. Ash chooses — not a king. The Chimera is offered citizenship, the first name in the new registry: their own.

### 8.4 `ending_merged` — *The Sea Remembers* (Merge — hidden)
**The Chimera joins the corruption and becomes its conscience; the tide withdraws, carrying one new voice.**
Requires ALL:
- reveals: `evolution_theory`, `corruption_nature`, `tide_prophecy`
- completed: `aria_laboratory`, `dara_ritual`
- aria ≥ +0.4 (she taught the Chimera what merging costs)
- NOT holding: `purification_totem`; "destroy it" NOT chosen at `act2_climax`
**Epilogue:** The sea gives back what it was given — wrecks surface, the drowned temple dries. Each year on the Fall's anniversary, everyone in the Reach remembers one thing they had lost. No one can say why. Aria keeps vigil at the amphitheater, and some nights the tide speaks with the player's voice, and it is *kind*.

**Priority / fallback:** if conditions for multiple endings hold, the player chooses at the finale among those unlocked. If none hold, the finale offers only a duel against the corruption; victory yields `ending_reforged` at its bleakest variant (the fleet breaks the throne, and the Reach wins a war instead of an ending).


---

## 9. Reveal / Lore Tag Vocabulary

Tags below are the closed vocabulary used by scene `allowedReveals`/`forbiddenTopics`, quest objectives, dialogue conditions, and `data/lore_entries.json`. Do not invent new tags without adding a lore entry and updating this list.

| Tag | One-line truth it unlocks |
|-----|---------------------------|
| `hollow_history` | The Hollow was dug, not built; a city that listened. |
| `king_history` | Aldric Veyne answered wishes until he ran out of self. |
| `king_identity` | The Echo wears the king's face; the king's memories are the Chimera. |
| `corruption_source` | The corruption is answered grief with a will, not an invader. |
| `corruption_nature` | It is alive, afraid, and learning. |
| `corruption_weakness` | Being truly witnessed unmoors it; unmade iron cuts it. |
| `evolution_theory` | It adapts to every fix; only a conscience could change it. |
| `crown_nature` | The crown spends memories — anyone's — as coin. |
| `warden_secret` | The Warden turned the key on the Sealing, on the king's order. |
| `garrison_betrayal` | The garrison's orders were to keep the people in. |
| `garrison_movements` | Where the remnant watches, then and now. |
| `deserter_truth` | Thorne read the orders and ran; his comrades died unknowing. |
| `hollow_defenses` | The Hollow's wards answer memory, not force. |
| `hollow_faith` | The faith tended the god's grief, not its glory. |
| `purification_ritual` | Witness + salt + unmade iron = release; always costs a memory. |
| `scholar_research` | Aria's maps of the crown's mechanism — and her claim on it. |
| `trade_routes` | Elena's web of caches and safe roads. |
| `supply_cache` | The caches began as loot from the sealed ring. |
| `forge_history` | Kael forged the crown; the gate was his penance. |
| `reforged_origins` | Refugees who chose ash over chains. |
| `reforged_movements` | Reforged patrols, and who they pressure. |
| `reforged_prophecy` | *Ash chooses its king* — and Seren's blood makes it personal. |
| `coastal_corruption` | The seep reached the sea years ago. |
| `tide_prophecy` | What the tide was given, the tide keeps — until answered. |
| `faction_secrets` | Rook's ledger: who buys what, including the buyer below. |
| `escape_route` | (Forbidden topic) No one leaves the Hollow's heart unchanged. |

---

## 10. Tone & Style Guide

**Register.** Gothic, melancholic, ink-and-ash. Write like marginalia in a drowned book: precise, stained, quiet.

**Do:**
- Short sentences for soldiers (Warden, Marcus, Thorne). Metaphor for mystics (Vessa, Dara, the corruption). Merchant arithmetic for Elena. Footnote-syntax for Aria. Oath-speak for Kael. "We" for Seren. Regal certainty, cracked with sorrow, for the Echo.
- Use the ash-lexicon: *ash, ember, hollow, echo, ward, vow, debt, tithe, salt, seam, keystone, pearl-ash, ink, margin.*
- Let NPCs be wrong in character. Let kindness cost something. End scenes on turns, not explanations.
- Names: monosyllabic or two-syllable, weathered (Vessa, Thorne, Kael, Rook, Dara, Seren). House names are Latinate (Veyne). Places are common-noun phrases ("the Field of Names", "the Broken Shore").
- Player-facing choice text: 4–12 words, concrete, no skill names, no explicit "+0.1" — the *tone* signals the disposition vector (`empathize` reads warm, `demand` reads hard).

**Don't:**
- No modern idiom ("okay", "deal with it"), no exclamation marks in narration, no explicit moral framing ("the good choice"), no lore dumps longer than three sentences in a single node.
- Never name the player. NPCs say "chimera", "ash-born", "stranger", or — the Echo — "heir".

**Dialogue node shape:** beat (what changes) → voice (whose) → turn (the last line re-aims the scene). Every tree needs: one way to gain trust, one way to lose it, one way to learn a secret, one honorable exit.


---

## 11. Data Contracts (for T7 wiring)

New authored files, all mirroring existing `data/` conventions:

### `data/quests.json` — top-level array (like `crafting_recipes.json`)
```
{ id, name, act, type ("main"|"side"), giverNpcId, summary,
  unlockConditions: { completedScenes: [], minDisposition: {} },   // mirrors map unlockRequirements
  objectives: [{ id, description, type, targetId, count }],        // type: scene|reveal|disposition|item|duel|choice
  rewards: { disposition: {}, items: [{itemId, quantity}], reveals: [], unlockScenes: [], recipes: [], endings: [] } }
```
Item ids are limited to the existing recipe vocabulary (`purified_coral`, `hollow_iron`, `king_shard`, `forge_ember`, `memory_dust`, `glass_flask`, `salt_crystal`, `tide_essence`, `tide_ward`, `echo_blade`, `memory_vial`, `signal_flare`, `purification_totem`).

### `data/dialogue_trees.json` — versioned dictionary (like `combat_intents.json`)
```
{ "version": 1, "trees": { "<treeId>": {
    "id", "npcId", "sceneId", "startNodeId",
    "nodes": { "<nodeId>": {
      "id", "speaker", "text",
      "choices": [{ "id", "text", "choiceType", "nextNodeId",
                    "dispositionEffect": float,
                    "conditions": { "minDisposition": float, "completedScenes": [], "reveals": [] },
                    "effects": { "reveal": tag, "endScene": bool, "startDuel": bool, "recruit": bool, "vow": id } }] } } } } }
```
- `choiceType` uses the **existing `Simulation.apply_dialogue_choice` vocabulary only**: `defer`, `help`, `threaten`, `demand`, `empathize`, `vow`, `lie`, `conceal`, `inquire` (neutral, no delta). This keeps archetype feedback loops working unchanged.
- `nextNodeId: null` (or `effects.endScene: true`) ends the conversation; scene completion stays the engine's job.
- `speaker` is an npc id or `"player"` / `"narrator"`.
- `conditions.minDisposition` follows the `requiresDispositionAbove` pattern from `combat_intents.json`.

### `data/lore_entries.json` — top-level array
```
{ id, title, act, category, revealTag, unlockedBySceneId, relatedNpcId, text }
```
`revealTag` ∈ §9 vocabulary; `unlockedBySceneId` references an existing scene id where that reveal is allowed. Journal integration: when a scene records a reveal, show the matching entry.

### Consistency rules
- npc ids ∈ `npcs.json` (now includes `kael`, `seren`, `dara`, `rook`, `corruption` — added in T3 to close the G4 data-integrity gap; personas added for `dara`, `rook`, `corruption`).
- scene ids ∈ `act1_scenes.json` ∪ `act2_scenes.json` ∪ `act3_scenes.json` (all 30, incl. orphans `elena_recruitment`, `warden_betrayal`, `echo_confrontation`, `seren_alliance`, `rook_betrayal` — quests reference every orphan so T7 can wire them onto maps or as quest-gated scenes).
- All new JSON must pass `python3 -m json.tool`; referential integrity is checked by the T3 validation pass.

