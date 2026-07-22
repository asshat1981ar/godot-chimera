extends Control
## Dialogue scene with portrait, ink-wash bubble, and authored dialogue-tree support.
## Falls back to the legacy procedural path if no tree exists for the current scene/npc.

@onready var _portrait: TextureRect = $HBox/PortraitPanel/Margin/VBox/Portrait
@onready var _name_label: Label = $HBox/PortraitPanel/Margin/VBox/NameLabel
@onready var _text_box: RichTextLabel = $HBox/DialoguePanel/Margin/VBox/TextBox
@onready var _choices: VBoxContainer = $HBox/DialoguePanel/Margin/VBox/Choices
@onready var _disposition_bar: ProgressBar = $HBox/PortraitPanel/Margin/VBox/DispositionBar

var _npc_id: String = ""
var _scene_id: String = ""
var _persona: Dictionary = {}
var _engine: DialogueEngine = null

# Legacy procedural state (kept for fallback).
var _lines: Array[String] = []
var _line_index := 0
var _use_legacy := false

# Typewriter state.
var _typewriter_target: String = ""
var _typewriter_visible: int = 0
var _typewriter_timer: SceneTreeTimer = null
var _typewriter_active := false
var _typewriter_skip_requested := false

func _ready() -> void:
	var payload := SceneSwitcher.pending_payload
	_npc_id = payload.get("npc_id", "")
	var node := Content.node_by_id(GameState.current_node_id)
	if _npc_id.is_empty():
		var scene := Content.scene_by_id(node.get("sceneId", ""))
		_npc_id = scene.get("npcId", "")
	_scene_id = node.get("sceneId", "") if not node.is_empty() else ""
	_persona = Content.npc_persona(_npc_id)
	_setup_portrait()
	_attempt_tree_start()

func _setup_portrait() -> void:
	var tex_path := "res://assets/images/npcs/portraits/portrait_%s.png" % _npc_id
	if ResourceLoader.exists(tex_path):
		_portrait.texture = load(tex_path)
	var npc := Content.npc_by_id(_npc_id)
	_name_label.text = npc.get("name", _npc_id)
	_refresh_disposition()

func _refresh_disposition() -> void:
	var disp := GameState.get_disposition(_npc_id)
	_disposition_bar.value = (disp + 1.0) * 50.0
	_disposition_bar.modulate = Color(0.8, 0.3, 0.3) if disp < -0.2 else Color(0.4, 0.7, 0.4) if disp > 0.2 else Color.WHITE

# --- Tree mode ----------------------------------------------------------------

func _attempt_tree_start() -> void:
	var tree := Content.dialogue_tree_for(_scene_id, _npc_id)
	if not tree.is_empty():
		_use_legacy = false
		_engine = DialogueEngine.new()
		_engine.node_presented.connect(_on_node_presented)
		_engine.scene_ended.connect(_on_scene_ended)
		_engine.duel_requested.connect(_on_duel_requested)
		_engine.act_gate_triggered.connect(_on_act_gate_triggered)
		_engine.start(tree)
		_advance_quests_on_entry()
	else:
		_use_legacy = true
		_advance_line_legacy()

func _advance_quests_on_entry() -> void:
	# Activate any quests whose unlock conditions are now met at scene entry.
	for q in Content.quests():
		var quest_id: String = q.get("id", "")
		var state: Dictionary = GameState.quest_states.get(quest_id, {})
		if not state.is_empty() and state.get("status", "") != "active":
			continue
		var unlock: Dictionary = q.get("unlockConditions", {})
		if _unlock_conditions_met(unlock):
			GameState.set_quest_status(quest_id, "active")
	# Progress visit/scene objectives for the current scene.
	if not _scene_id.is_empty():
		Content.advance_quest_progress("scene", _scene_id)

func _unlock_conditions_met(unlock: Dictionary) -> bool:
	var min_disp: Dictionary = unlock.get("minDisposition", {})
	for npc_id in min_disp:
		if GameState.get_disposition(npc_id) < float(min_disp[npc_id]):
			return false
	var completed: Array = unlock.get("completedScenes", [])
	for scene_id in completed:
		if not GameState.is_scene_completed(scene_id):
			return false
	return true


func _on_node_presented(node: Dictionary) -> void:
	var speaker := _engine.speaker_name()
	if speaker.is_empty():
		_name_label.text = Content.npc_by_id(_npc_id).get("name", _npc_id)
	else:
		_name_label.text = speaker
	var text: String = node.get("text", "...")
	_start_typewriter(text)
	_present_tree_choices()

func _present_tree_choices() -> void:
	_clear_choices()
	var options: Array = _engine.visible_choices()
	var first_btn: Button = null
	var previous: Button = null
	for i in range(options.size()):
		var opt: Dictionary = options[i]
		var btn := _create_choice_button(opt.get("text", "..."))
		btn.focus_mode = Control.FOCUS_ALL
		btn.pressed.connect(_on_tree_choice.bind(i))
		_choices.add_child(btn)
		if first_btn == null:
			first_btn = btn
		if previous != null:
			previous.focus_neighbor_bottom = btn.get_path()
			btn.focus_neighbor_top = previous.get_path()
		previous = btn
	if first_btn:
		first_btn.grab_focus()

func _on_tree_choice(choice_index: int) -> void:
	_stop_typewriter()
	var result: Dictionary = _engine.choose(choice_index)
	_refresh_disposition()
	match result.get("result", ""):
		"continue":
			_present_tree_choices()
		"scene_end":
			Simulation.end_scene(_scene_id)
			SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")
		"duel":
			Simulation.start_duel(result.get("opponent_id", _npc_id))
			SceneSwitcher.switch_to("res://scenes/screens/combat_screen.tscn")

# --- Legacy procedural mode ---------------------------------------------------

func _advance_line_legacy() -> void:
	var patterns: Array = _persona.get("speechPatterns", ["..."])
	var pattern: String = patterns[_line_index % patterns.size()]
	var full := "%s %s" % [pattern, _generate_context_line()]
	_name_label.text = Content.npc_by_id(_npc_id).get("name", _npc_id)
	_start_typewriter(full)
	EventBus.emit_dialogue_line(_name_label.text, full)
	_present_legacy_choices()

func _present_legacy_choices() -> void:
	_clear_choices()
	var options := [
		{"label": "Defer to their wisdom", "type": "defer"},
		{"label": "Offer help", "type": "help"},
		{"label": "Press them hard", "type": "demand"},
		{"label": "Threaten", "type": "threaten"},
		{"label": "Empathize", "type": "empathize"},
		{"label": "Lie", "type": "lie"},
	]
	var first_btn: Button = null
	var previous: Button = null
	for opt in options:
		var btn := _create_choice_button(opt.label)
		btn.focus_mode = Control.FOCUS_ALL
		btn.pressed.connect(_on_legacy_choice.bind(opt.type))
		_choices.add_child(btn)
		if first_btn == null:
			first_btn = btn
		if previous != null:
			previous.focus_neighbor_bottom = btn.get_path()
			btn.focus_neighbor_top = previous.get_path()
		previous = btn
	var leave := _create_choice_button("Leave")
	leave.focus_mode = Control.FOCUS_ALL
	leave.pressed.connect(_on_leave)
	_choices.add_child(leave)
	if previous != null:
		previous.focus_neighbor_bottom = leave.get_path()
		leave.focus_neighbor_top = previous.get_path()
	if first_btn:
		first_btn.grab_focus()

func _on_legacy_choice(choice_type: String) -> void:
	_stop_typewriter()
	Simulation.apply_dialogue_choice(_npc_id, choice_type)
	_refresh_disposition()
	_line_index += 1
	if _line_index >= 4:
		Simulation.end_scene(_scene_id)
		SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")
	else:
		_advance_line_legacy()

func _on_leave() -> void:
	_stop_typewriter()
	Simulation.end_scene(_scene_id)
	SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")

func _on_scene_ended(_scene: String) -> void:
	Simulation.end_scene(_scene_id)
	SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")

func _on_act_gate_triggered(_scene_id: String, next_act: int) -> void:
	# NAR wires the trigger; the act_transition screen is SYS-owned, so we emit a UI request.
	Simulation.advance_act(next_act)
	EventBus.emit_ui_request("res://scenes/screens/act_transition.tscn", {"next_act": next_act})

func _on_duel_requested(opponent_id: String) -> void:
	Simulation.start_duel(opponent_id)
	SceneSwitcher.switch_to("res://scenes/screens/combat_screen.tscn", {
		"opponent_id": opponent_id,
		"return_screen": "res://scenes/screens/dialogue_screen.tscn",
		"return_payload": {
			"npc_id": _npc_id,
			"scene_id": _scene_id,
		},
	})

## Public method called by combat_screen.gd after a duel resolves.
## Payload set here carries the dialogue state so combat_screen can resume.
func resume_dialogue_after_duel() -> void:
	Simulation.end_duel()
	if _engine == null or _engine.current_node.is_empty():
		Simulation.end_scene(_scene_id)
		SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")
	else:
		_setup_portrait()
		_on_node_presented(_engine.current_node)

# --- Shared UI helpers --------------------------------------------------------

func _clear_choices() -> void:
	for child in _choices.get_children():
		child.free()

func _create_choice_button(label: String) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(0, 84)
	return btn

# --- Typewriter ---------------------------------------------------------------

func _start_typewriter(full_text: String) -> void:
	_stop_typewriter()
	_typewriter_target = full_text
	_typewriter_skip_requested = false
	# Reduced motion: reveal the full text immediately without animation.
	if UIAdapt.is_reduced_motion():
		_text_box.text = full_text
		_typewriter_visible = full_text.length()
		_typewriter_active = false
		return
	_typewriter_visible = 0
	_typewriter_active = true
	_update_typewriter_text()
	_schedule_next_character()

func _schedule_next_character() -> void:
	if not _typewriter_active or _typewriter_visible >= _typewriter_target.length():
		_typewriter_active = false
		return
	var speed: float = float(GameState.settings.get("text_speed", 0.04))
	# Clamp so zero does not hang and very large values are still usable.
	speed = clampf(speed, 0.001, 0.5)
	# Slightly longer pause after punctuation for readability.
	var next_char := _typewriter_target[_typewriter_visible]
	if next_char in [".", ",", "!", "?", ";", ":"]:
		speed *= 2.5
	_typewriter_timer = get_tree().create_timer(speed)
	_typewriter_timer.timeout.connect(_on_typewriter_tick)

func _on_typewriter_tick() -> void:
	if _typewriter_skip_requested:
		_typewriter_visible = _typewriter_target.length()
		_typewriter_skip_requested = false
	else:
		_typewriter_visible = mini(_typewriter_visible + 1, _typewriter_target.length())
	_update_typewriter_text()
	if _typewriter_visible < _typewriter_target.length():
		_schedule_next_character()
	else:
		_typewriter_active = false

func _update_typewriter_text() -> void:
	_text_box.text = _typewriter_target.substr(0, _typewriter_visible)
	# Fit text to the label width so it wraps instead of overflowing on small screens.
	_text_box.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_box.fit_content = true

func _stop_typewriter() -> void:
	_typewriter_active = false
	if _typewriter_timer and is_instance_valid(_typewriter_timer):
		if _typewriter_timer.timeout.is_connected(_on_typewriter_tick):
			_typewriter_timer.timeout.disconnect(_on_typewriter_tick)
	_typewriter_timer = null
	_update_typewriter_text()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if _typewriter_active:
			_typewriter_skip_requested = true
	elif event is InputEventMouseButton and event.pressed:
		if _typewriter_active:
			_typewriter_skip_requested = true

func _input(event: InputEvent) -> void:
	# Global tap/click to skip typewriter; otherwise let it pass through.
	if _typewriter_active and (event is InputEventScreenTouch or event is InputEventMouseButton):
		if event.pressed:
			_typewriter_skip_requested = true
			get_viewport().set_input_as_handled()

