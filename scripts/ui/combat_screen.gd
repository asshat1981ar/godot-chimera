extends Control
## Touch-first stance duel screen. Uses Simulation.duel_round() with intent ids from combat_intents.json.

@onready var _opponent_name: Label = $VBox/TopBar/OpponentName
@onready var _player_resolve: ProgressBar = $VBox/Bars/PlayerResolve
@onready var _opponent_resolve: ProgressBar = $VBox/Bars/OpponentResolve
@onready var _omen_label: Label = $VBox/Bars/OmenLabel
@onready var _turn_log: RichTextLabel = $VBox/TurnLog
@onready var _intent_grid: HBoxContainer = $VBox/IntentGrid
@onready var _result_label: Label = $VBox/ResultLabel
@onready var _continue_button: Button = $VBox/ContinueButton

var _opponent_id: String = ""
var _intents: Array = []
var _selected_intent: String = ""
var _log_lines: Array[String] = []

func _ready() -> void:
	_opponent_id = Simulation.get_duel_opponent_id()
	if _opponent_id.is_empty():
		_opponent_id = SceneSwitcher.pending_payload.get("opponent_id", "warden")
		Simulation.start_duel(_opponent_id)
	var npc := Content.npc_by_id(_opponent_id)
	_opponent_name.text = npc.get("name", _opponent_id)
	_load_intents()
	_refresh_bars()
	_update_intent_buttons()
	_result_label.hide()
	_continue_button.hide()

func _load_intents() -> void:
	var library: Dictionary = Content.combat_intents()
	_intents = library.get("intents", {}).get("default", [])
	# Fall back to hard-coded stance intents if JSON is empty.
	if _intents.is_empty():
		_intents = [
			{"id": "strike", "label": "Strike", "description": "Press the attack."},
			{"id": "defend", "label": "Ward", "description": "Brace for impact."},
			{"id": "outmaneuver", "label": "Feint", "description": "Use cunning over force."},
		]

func _update_intent_buttons() -> void:
	for c in _intent_grid.get_children():
		c.free()
	for intent in _intents:
		var id: String = intent.get("id", "")
		var label: String = intent.get("label", id.capitalize())
		var desc: String = intent.get("description", "")
		var btn := Button.new()
		btn.text = label
		btn.custom_minimum_size = Vector2(120, 84)
		btn.tooltip_text = desc
		btn.disabled = _is_duel_over()
		btn.pressed.connect(_on_intent_pressed.bind(id))
		_intent_grid.add_child(btn)

func _is_duel_over() -> bool:
	return not Simulation.get_duel_winner().is_empty()

func _on_intent_pressed(intent_id: String) -> void:
	if _is_duel_over():
		return
	_selected_intent = intent_id
	var npc_intent := _pick_npc_intent()
	var summary: Dictionary = Simulation.duel_round(intent_id, npc_intent)
	_log_lines.append(summary.get("log", ""))
	if _log_lines.size() > 6:
		_log_lines.remove_at(0)
	_refresh_bars()
	_refresh_log()
	if not summary.get("winner", "").is_empty():
		_show_resolution(summary.get("winner", ""))

func _pick_npc_intent() -> String:
	# Deterministic opponent intent: use archetype-specific intent list if available.
	var archetype: String = Content.npc_archetype(_opponent_id)
	var library: Dictionary = Content.combat_intents()
	var set_name: String = archetype if archetype in library.get("intents", {}) else "default"
	var pool: Array = library.get("intents", {}).get(set_name, _intents)
	if pool.is_empty():
		return "strike"
	var index := Simulation.get_rng_index() % pool.size()
	return pool[index].get("id", "strike")

func _refresh_bars() -> void:
	var state: Dictionary = Simulation.get_duel_state()
	_player_resolve.max_value = 10
	_player_resolve.value = state.get("player_resolve", 10)
	_opponent_resolve.max_value = 10
	_opponent_resolve.value = state.get("opponent_resolve", 10)
	_omen_label.text = "Omen: %d" % state.get("player_omen", 0)

func _refresh_log() -> void:
	_turn_log.text = "\n".join(_log_lines)

func _show_resolution(winner: String) -> void:
	_update_intent_buttons()
	_continue_button.show()
	if winner == "player":
		_result_label.text = "Victory. The duel is yours."
		_result_label.modulate = Color(0.5, 0.85, 0.5)
	else:
		_result_label.text = "Defeat. The ash claims another round."
		_result_label.modulate = Color(0.85, 0.4, 0.4)
	_result_label.show()

func _on_continue_pressed() -> void:
	GameState.save_game()
	SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")
