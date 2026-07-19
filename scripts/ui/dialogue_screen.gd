extends Control
## Dialogue scene with portrait, ink-wash bubble, and disposition-aware choices.

@onready var _portrait: TextureRect = $HBox/PortraitPanel/Margin/VBox/Portrait
@onready var _name_label: Label = $HBox/PortraitPanel/Margin/VBox/NameLabel
@onready var _text_box: RichTextLabel = $HBox/DialoguePanel/Margin/VBox/TextBox
@onready var _choices: VBoxContainer = $HBox/DialoguePanel/Margin/VBox/Choices
@onready var _disposition_bar: ProgressBar = $HBox/PortraitPanel/Margin/VBox/DispositionBar

var _npc_id: String = ""
var _scene_id: String = ""
var _persona: Dictionary = {}
var _lines: Array[String] = []
var _line_index := 0

func _ready() -> void:
	var payload := SceneSwitcher.pending_payload
	_npc_id = payload.get("npc_id", "")
	# Discover npc from current scene if not set.
	var node := Content.node_by_id(GameState.current_node_id)
	if _npc_id.is_empty():
		var scene := Content.scene_by_id(node.get("sceneId", ""))
		_npc_id = scene.get("npcId", "")
	_scene_id = node.get("sceneId", "") if not node.is_empty() else ""
	_persona = Content.npc_persona(_npc_id)
	_setup_portrait()
	_advance_line()

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

func _advance_line() -> void:
	var patterns: Array = _persona.get("speechPatterns", ["..."])
	var pattern: String = patterns[_line_index % patterns.size()]
	var full := "%s %s" % [pattern, _generate_context_line()]
	_text_box.text = "[i]%s[/i]\n\n%s" % [_name_label.text, full]
	EventBus.emit_dialogue_line(_name_label.text, full)
	_present_choices()

func _generate_context_line() -> String:
	var node: Dictionary = Content.node_by_id(GameState.current_node_id)
	var location: String = node.get("name", "this place") if not node.is_empty() else "the ashes"
	return "You stand in %s. The air carries the weight of old oaths." % location

func _present_choices() -> void:
	for child in _choices.get_children():
		child.free()
	var options := [
		{"label": "Defer to their wisdom", "type": "defer"},
		{"label": "Offer help", "type": "help"},
		{"label": "Press them hard", "type": "demand"},
		{"label": "Threaten", "type": "threaten"},
		{"label": "Empathize", "type": "empathize"},
		{"label": "Lie", "type": "lie"},
	]
	for opt in options:
		var btn := Button.new()
		btn.text = opt.label
		btn.pressed.connect(_on_choice.bind(opt.type))
		_choices.add_child(btn)
	var leave := Button.new()
	leave.text = "Leave"
	leave.pressed.connect(_on_leave)
	_choices.add_child(leave)

func _on_choice(choice_type: String) -> void:
	Simulation.apply_dialogue_choice(_npc_id, choice_type)
	_refresh_disposition()
	_line_index += 1
	if _line_index >= 4:
		Simulation.end_scene(_scene_id)
		SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")
	else:
		_advance_line()

func _on_leave() -> void:
	Simulation.end_scene(_scene_id)
	SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")
