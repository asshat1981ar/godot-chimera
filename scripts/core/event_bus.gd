extends Node
## Observable event bus for decoupled UI/simulation communication.
## Mirrors com.chimera.core.events.GameEventBus from the Android codebase.

signal state_changed(key: String, value: Variant)
signal scene_entered(scene_id: String)
signal node_visited(node_id: String)
signal disposition_changed(npc_id: String, delta: float, new_value: float)
signal dialogue_started(npc_id: String, topic: String)
signal dialogue_line_added(speaker: String, text: String)
signal dialogue_choice_presented(choices: Array)
signal duel_started(opponent_id: String)
signal duel_turn(stance: String, omen: int)
signal duel_resolved(winner_id: String)
signal camp_night_started(risk_level: float)
signal journal_updated(entry_id: String)
signal inventory_changed(item_id: String, quantity: int)
signal quest_objective_updated(objective_id: String, status: String)
signal ui_request(screen_name: String, payload: Dictionary)

func emit_state_changed(key: String, value: Variant) -> void:
	state_changed.emit(key, value)

func emit_node_visited(node_id: String) -> void:
	node_visited.emit(node_id)

func emit_disposition_changed(npc_id: String, delta: float, new_value: float) -> void:
	disposition_changed.emit(npc_id, delta, new_value)

func emit_dialogue_started(npc_id: String, topic: String) -> void:
	dialogue_started.emit(npc_id, topic)

func emit_dialogue_line(speaker: String, text: String) -> void:
	dialogue_line_added.emit(speaker, text)

func emit_dialogue_choice(choices: Array) -> void:
	dialogue_choice_presented.emit(choices)

func emit_journal_updated(entry_id: String) -> void:
	journal_updated.emit(entry_id)

func emit_ui_request(screen_name: String, payload: Dictionary = {}) -> void:
	ui_request.emit(screen_name, payload)

func emit_inventory_changed(item_id: String, quantity: int) -> void:
	inventory_changed.emit(item_id, quantity)

func emit_scene_entered(scene_id: String) -> void:
	scene_entered.emit(scene_id)

func emit_duel_started(opponent_id: String) -> void:
	duel_started.emit(opponent_id)

func emit_duel_turn(stance: String, omen: int) -> void:
	duel_turn.emit(stance, omen)

func emit_duel_resolved(winner_id: String) -> void:
	duel_resolved.emit(winner_id)

func emit_camp_night_started(risk_level: float) -> void:
	camp_night_started.emit(risk_level)

func emit_quest_objective_updated(objective_id: String, status: String) -> void:
	quest_objective_updated.emit(objective_id, status)
