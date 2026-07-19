extends Area2D
## Interactive token for a map node on the overhead map.

@export var node_id: String = ""
@export var node_name: String = ""
@export var node_type: String = "ruins"
@export var texture: Texture2D

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _label: Label = $Label

func _ready() -> void:
	if texture:
		_sprite.texture = texture
	_label.text = node_name
	body_entered.connect(_on_body_entered)
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_refresh_state()
	EventBus.state_changed.connect(_on_state_changed)

func _on_state_changed(key: String, _value: Variant) -> void:
	if key in ["current_node", "unlocked_nodes", "completed_scenes"]:
		_refresh_state()

func _refresh_state() -> void:
	var unlocked := GameState.is_node_unlocked(node_id)
	var visited := GameState.current_node_id == node_id
	var completed := GameState.is_scene_completed(Content.node_by_id(node_id).get("sceneId", ""))
	modulate = Color(0.35, 0.35, 0.35, 1) if not unlocked else Color.WHITE
	if completed:
		modulate = Color(0.7, 0.8, 0.7, 1)
	if visited:
		_sprite.scale = Vector2(1.15, 1.15)
	else:
		_sprite.scale = Vector2(1.0, 1.0)

func _on_body_entered(_body: Node2D) -> void:
	pass

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not GameState.is_node_unlocked(node_id):
			EventBus.emit_ui_request("node_locked", {"node_id": node_id})
			return
		var node := Content.node_by_id(node_id)
		var scene := Content.scene_by_id(node.get("sceneId", ""))
		var npc_id: String = scene.get("npcId", "") if not scene.is_empty() else ""
		if not npc_id.is_empty():
			Simulation.travel_to(node_id)
			SceneSwitcher.switch_to("res://scenes/screens/dialogue_screen.tscn", {"npc_id": npc_id})
		else:
			Simulation.travel_to(node_id)

func _on_mouse_entered() -> void:
	EventBus.emit_ui_request("show_tooltip", {"text": node_name})
	_sprite.scale *= 1.1

func _on_mouse_exited() -> void:
	_refresh_state()
