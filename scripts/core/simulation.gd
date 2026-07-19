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
	var scene_id: String = node.get("sceneId", "")
	if not scene_id.is_empty():
		_enter_scene(scene_id)
	EventBus.emit_state_changed("current_node", node_id)

func _enter_scene(scene_id: String) -> void:
	GameState.current_phase = GameState.Phase.SCENE
	EventBus.emit_scene_entered(scene_id)
	var scene := Content.scene_by_id(scene_id)
	if scene.is_empty():
		return
	var npc_id: String = scene.get("npcId", "")
	var topic: String = scene.get("topic", "")
	if not npc_id.is_empty():
		EventBus.emit_dialogue_started(npc_id, topic)

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
				_schedule_disposition(npc_id, -0.12, 3)
		"ESCALATION":
			if choice_type in ["threaten", "demand"]:
				_schedule_disposition(npc_id, -0.06, 2)
		"GROWTH_AND_UNDERINVESTMENT":
			if choice_type == "help":
				_schedule_disposition(npc_id, 0.08, 2)
		"FIXES_THAT_FAIL":
			if choice_type == "lie":
				_schedule_disposition(npc_id, -0.10, 3)

func _schedule_disposition(npc_id: String, delta: float, seconds: float) -> void:
	var timer := get_tree().create_timer(seconds)
	timer.timeout.connect(_apply_delayed_disposition.bind(npc_id, delta))

func _apply_delayed_disposition(npc_id: String, delta: float) -> void:
	GameState.adjust_disposition(npc_id, delta)

func start_duel(opponent_id: String) -> void:
	GameState.current_phase = GameState.Phase.DUEL
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
	var opponent_stance := _ai_stance()
	var outcome: Dictionary = _resolve_exchange(player_stance, opponent_stance)
	_duel_state.player_resolve += int(outcome.player_delta)
	_duel_state.opponent_resolve += int(outcome.opponent_delta)
	_duel_state.player_omen = clampi(_duel_state.player_omen + int(outcome.omen_delta), 0, 5)
	EventBus.emit_duel_turn(STANCE_NAMES[player_stance], _duel_state.player_omen)
	_check_duel_end()

func resolve_duel(player_id: String, opponent_id: String) -> Dictionary:
	## Headless deterministic duel resolution: returns { winner_id, turns }.
	start_duel(opponent_id)
	var turns := 0
	while _duel_state.winner.is_empty() and turns < 20:
		var stance: Stance = Stance.values().pick_random()
		submit_stance(stance)
		turns += 1
	return {
		"winner_id": _duel_state.winner if not _duel_state.winner.is_empty() else opponent_id,
		"turns": turns,
	}

func _ai_stance() -> Stance:
	return Stance.values().pick_random()

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
		GameState.current_phase = GameState.Phase.OVERWORLD

func end_scene(scene_id: String) -> void:
	GameState.mark_scene_completed(scene_id)
	GameState.current_phase = GameState.Phase.OVERWORLD

func rest_at_camp() -> void:
	GameState.current_phase = GameState.Phase.CAMP
	EventBus.emit_camp_night_started(_calculate_camp_risk())

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
