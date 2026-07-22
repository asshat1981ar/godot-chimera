extends Node
## Deterministic simulation engine (Godot reimplementation of chimera-core).
## All game-state mutation lives here; UI only sends intents and observes events.

enum Stance { STRIKE, WARD, FEINT }
enum DuelPhase { OPENING, EXCHANGE, RESOLUTION }

const STANCE_NAMES: Dictionary = {
	Stance.STRIKE: "strike",
	Stance.WARD: "ward",
	Stance.FEINT: "feint",
}

var _duel_state: Dictionary = {}
var _rng: RandomNumberGenerator = null
var _turn_count: int = 0

func _ready() -> void:
	_reseed()
	EventBus.state_changed.connect(_on_state_changed)

func _reseed() -> void:
	_rng = RandomNumberGenerator.new()
	var seed_value: int = GameState.rng_seed
	if seed_value == 0:
		seed_value = int(Time.get_unix_time_from_system())
	_rng.seed = seed_value

func _on_state_changed(key: String, _value: Variant) -> void:
	if key == "rng_seed":
		_reseed()

func travel_to(node_id: String) -> void:
	if not GameState.is_node_unlocked(node_id):
		# Connected nodes may be opened by traversal even before requirements are met.
		var current_node: Dictionary = Content.node_by_id(GameState.current_node_id)
		var connected: Array = current_node.get("connectedTo", [])
		if connected.has(node_id):
			GameState.unlocked_nodes.append(node_id)
			EventBus.emit_state_changed("unlocked_nodes", GameState.unlocked_nodes.duplicate())
		else:
			push_warning("Travel rejected: %s locked" % node_id)
			return
	var node: Dictionary = Content.node_by_id(node_id)
	if node.is_empty():
		return
	GameState.mark_node_visited(node_id)
	Content.advance_quest_progress("visit_node", node_id)
	var scene_id: String = node.get("sceneId", "")
	if not scene_id.is_empty():
		_enter_scene(scene_id)
	GameState.save_game("auto")
	EventBus.emit_state_changed("current_node", node_id)

func _enter_scene(scene_id: String) -> void:
	GameState.current_phase = GameState.Phase.SCENE
	EventBus.emit_scene_entered(scene_id)
	reveal_lore_at_scene(scene_id)
	var scene := Content.scene_by_id(scene_id)
	if scene.is_empty():
		return
	var npc_id: String = scene.get("npcId", "")
	var topic: String = scene.get("topic", "")
	if not npc_id.is_empty():
		EventBus.emit_dialogue_started(npc_id, topic)

func grant_item(item_id: String, amount: int = 1) -> void:
	## Canonical helper for giving the player items. Centralizes the inventory event.
	GameState.add_inventory(item_id, amount)

func reveal_lore_at_scene(scene_id: String) -> void:
	## Unlock lore entries authored to be revealed on scene entry.
	## Lore unlocked through dialogue choices is handled by DialogueEngine.
	for entry in Content.lore_entries_by_scene(scene_id):
		var entry_id: String = entry.get("id", "")
		if not entry_id.is_empty():
			GameState.unlock_lore(entry_id)

func apply_dialogue_choice(npc_id: String, choice_type: String) -> void:
	## Choice_type maps to disposition deltas authored per archetype.
	match choice_type:
		"defer", "help":
			GameState.adjust_disposition(npc_id, 0.05)
		"threaten", "demand":
			GameState.adjust_disposition(npc_id, -0.08)
		"empathize", "vow":
			GameState.adjust_disposition(npc_id, 0.10)
		"lie", "conceal":
			GameState.adjust_disposition(npc_id, -0.03)
		_:
			GameState.adjust_disposition(npc_id, 0.0)
	# Archetype feedback loop: shifting the burden may create delayed consequences.
	_archetype_feedback(npc_id, choice_type)

func _archetype_feedback(npc_id: String, choice_type: String) -> void:
	var archetype := Content.npc_archetype(npc_id)
	match archetype:
		"SHIFTING_THE_BURDEN":
			if choice_type == "defer":
				GameState.add_pending_disposition(npc_id, -0.12, 3)
		"ESCALATION":
			if choice_type in ["threaten", "demand"]:
				GameState.add_pending_disposition(npc_id, -0.06, 2)
		"GROWTH_AND_UNDERINVESTMENT":
			if choice_type == "help":
				GameState.add_pending_disposition(npc_id, 0.08, 2)
		"FIXES_THAT_FAIL":
			if choice_type == "lie":
				GameState.add_pending_disposition(npc_id, -0.10, 3)

func advance_simulation_turn() -> void:
	_turn_count += 1
	GameState.consume_pending_dispositions()

func start_duel(opponent_id: String) -> void:
	GameState.current_phase = GameState.Phase.DUEL
	_turn_count = 0
	_duel_state = {
		"opponent_id": opponent_id,
		"player_resolve": 10,
		"opponent_resolve": 10,
		"player_omen": 3,
		"opponent_omen": 3,
		"phase": DuelPhase.OPENING,
		"winner": "",
	}
	EventBus.emit_duel_started(opponent_id)

func submit_stance(player_stance: Stance) -> void:
	if _duel_state.is_empty():
		return
	_turn_count += 1
	var opponent_stance := _ai_stance()
	var outcome: Dictionary = _resolve_exchange(player_stance, opponent_stance)
	_duel_state.player_resolve += int(outcome.player_delta)
	_duel_state.opponent_resolve += int(outcome.opponent_delta)
	_duel_state.player_omen = clampi(_duel_state.player_omen + int(outcome.omen_delta), 0, 5)
	var turn_log := _turn_log_line(STANCE_NAMES[player_stance], STANCE_NAMES[opponent_stance], outcome)
	GameState.consume_pending_dispositions()
	EventBus.emit_duel_turn(STANCE_NAMES[player_stance], _duel_state.player_omen)
	_check_duel_end()
	_duel_state["last_turn_log"] = turn_log

func resolve_duel(player_id: String, opponent_id: String) -> Dictionary:
	## Headless deterministic duel resolution: returns { winner_id, turns }.
	start_duel(opponent_id)
	var turns := 0
	while _duel_state.winner.is_empty() and turns < 20:
		var stance: Stance = Stance.values()[_rng.randi() % Stance.values().size()]
		submit_stance(stance)
		turns += 1
	return {
		"winner_id": _duel_state.winner if not _duel_state.winner.is_empty() else opponent_id,
		"turns": turns,
	}

func set_rng_seed(seed_value: int) -> void:
	GameState.rng_seed = seed_value
	_reseed()

func _ai_stance() -> Stance:
	return Stance.values()[_rng.randi() % Stance.values().size()]

func _turn_log_line(player_stance: String, opponent_stance: String, outcome: Dictionary) -> String:
	var player_delta: int = int(outcome.player_delta)
	var opponent_delta: int = int(outcome.opponent_delta)
	var omen_delta: int = int(outcome.omen_delta)
	if player_delta < 0 and opponent_delta == 0:
		return "You strike %s, but they answer harder. You lose %d Resolve." % [opponent_stance, -player_delta]
	elif opponent_delta < 0 and player_delta == 0:
		return "Your %s finds its mark. Opponent loses %d Resolve." % [player_stance, -opponent_delta]
	elif omen_delta < 0:
		return "Stances mirror each other; the omen burns. Omen %d." % [omen_delta]
	return "Exchange settles without blood."

func duel_round(player_intent: String, npc_intent: String) -> Dictionary:
	## Data-driven intent wrapper for combat_intents.json.
	## Maps intent ids to STRIKE/WARD/FEINT stances, resolves, and returns a turn summary.
	var player_stance := _intent_to_stance(player_intent)
	var npc_stance := _intent_to_stance(npc_intent)
	var pre_player_resolve: int = _duel_state.get("player_resolve", 10)
	var pre_opponent_resolve: int = _duel_state.get("opponent_resolve", 10)
	submit_stance(player_stance)
	var summary := {
		"player_intent": player_intent,
		"npc_intent": npc_intent,
		"player_stance": STANCE_NAMES[player_stance],
		"npc_stance": STANCE_NAMES.get(npc_stance, "unknown"),
		"player_resolve": _duel_state.get("player_resolve", pre_player_resolve),
		"npc_resolve": _duel_state.get("opponent_resolve", pre_opponent_resolve),
		"player_omen": _duel_state.get("player_omen", 0),
		"log": _duel_state.get("last_turn_log", ""),
		"winner": _duel_state.get("winner", ""),
	}
	return summary

func _intent_to_stance(intent_id: String) -> Stance:
	match intent_id:
		"strike", "expose", "overwhelm", "patient_pressure", "match_their_fury":
			return Stance.STRIKE
		"defend", "absorb_and_wait", "hold_ground":
			return Stance.WARD
		"outmaneuver", "disrupt_rhythm", "offer_a_way_out", "negotiate", "parley":
			return Stance.FEINT
	return Stance.STRIKE

func _resolve_exchange(player: Stance, opponent: Stance) -> Dictionary:
	## Stance triangle: strike beats feint, feint beats ward, ward beats strike.
	## Winner deals resolve damage; ties cost both one omen.
	var beats: Dictionary = {
		Stance.STRIKE: Stance.FEINT,
		Stance.FEINT: Stance.WARD,
		Stance.WARD: Stance.STRIKE,
	}
	if beats[player] == opponent:
		return { "player_delta": 0, "opponent_delta": -2, "omen_delta": 0 }
	elif beats[opponent] == player:
		return { "player_delta": -2, "opponent_delta": 0, "omen_delta": 0 }
	else:
		return { "player_delta": 0, "opponent_delta": 0, "omen_delta": -1 }

func get_duel_state() -> Dictionary:
	return _duel_state.duplicate(true)

func get_duel_winner() -> String:
	return _duel_state.get("winner", "")

func get_duel_opponent_id() -> String:
	return _duel_state.get("opponent_id", "")

func get_rng_index() -> int:
	return _rng.randi()

func _check_duel_end() -> void:
	var winner := ""
	if _duel_state.player_resolve <= 0:
		winner = _duel_state.opponent_id
	elif _duel_state.opponent_resolve <= 0:
		winner = "player"
	if not winner.is_empty():
		_duel_state.winner = winner
		_duel_state.phase = DuelPhase.RESOLUTION
		EventBus.emit_duel_resolved(winner)
		Content.advance_quest_progress("duel", _duel_state.opponent_id)
		GameState.current_phase = GameState.Phase.OVERWORLD

func end_duel() -> void:
	## Cleanly close the active duel state so the scene/round-trip can continue.
	if _duel_state.is_empty():
		return
	_duel_state = {}
	if GameState.current_phase == GameState.Phase.DUEL:
		GameState.current_phase = GameState.Phase.SCENE

func end_scene(scene_id: String) -> void:
	GameState.mark_scene_completed(scene_id)
	Content.advance_quest_progress("scene", scene_id)
	advance_simulation_turn()
	GameState.current_phase = GameState.Phase.OVERWORLD
	_autosave()

func _autosave() -> void:
	if GameState.current_phase != GameState.Phase.MENU:
		GameState.save_game("auto")

func rest_at_camp() -> void:
	GameState.current_phase = GameState.Phase.CAMP
	advance_simulation_turn()
	Content.advance_quest_progress("camp", "rest_at_camp")
	Content.advance_quest_progress("scene", "camp")
	EventBus.emit_camp_night_started(_calculate_camp_risk())
	_autosave()

func _calculate_camp_risk() -> float:
	var risk := 0.0
	var party_ids := GameState.party
	for npc_id in party_ids:
		var disp := GameState.get_disposition(npc_id)
		if disp < -0.2:
			risk += 0.15
		elif disp > 0.3:
			risk -= 0.10
	return clampf(risk, 0.0, 1.0)

func resolve_finale() -> Dictionary:
	## Pick an ending from quests.json based on current state.
	## Returns { ending_id, title, text } or {} if no ending matches.
	var candidate: Dictionary = {}
	var fallback: Dictionary = {}
	for q in Content.quests():
		for ending in q.get("rewards", {}).get("endings", []):
			var requires: Dictionary = ending.get("requires", {})
			if _finale_requires_met(requires):
				candidate = ending
				break
			if fallback.is_empty():
				fallback = ending
		if not candidate.is_empty():
			break
	if candidate.is_empty():
		candidate = fallback
	if candidate.is_empty():
		return {
			"ending_id": "ending_default",
			"title": "The Ash Remembers",
			"text": "No ending was written for this road. The ash keeps walking."
		}
	return {
		"ending_id": candidate.get("id", ""),
		"title": candidate.get("title", "Ending"),
		"text": candidate.get("description", candidate.get("text", "The story ends here."))
	}

func _finale_requires_met(requires: Dictionary) -> bool:
	var items: Array = requires.get("items", [])
	for item_id in items:
		if int(GameState.inventory.get(item_id, 0)) <= 0:
			return false
	var scenes: Array = requires.get("completedScenes", [])
	for scene_id in scenes:
		if not GameState.is_scene_completed(scene_id):
			return false
	var reveals: Array = requires.get("reveals", [])
	for tag in reveals:
		var found := false
		for entry in Content.lore_entries_by_reveal(tag):
			if GameState.unlocked_lore.has(entry.get("id", "")):
				found = true
				break
		if not found:
			return false
	var min_disp: Dictionary = requires.get("minDisposition", {})
	for npc_id in min_disp:
		if GameState.get_disposition(npc_id) < float(min_disp[npc_id]):
			return false
	return true
