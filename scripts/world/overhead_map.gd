extends Node2D
## 2.5D overhead map screen. Builds the act world from Content, renders connections,
## node tokens, and ambient NPC tokens. Sim authoritative: only sends travel intents.

const MAP_WIDTH := 1280
const MAP_HEIGHT := 720
const TILE_SIZE := 64
const NODE_SCALE := 96

@onready var _world: Node2D = $World
@onready var _camera: Camera2D = $Camera2D
@onready var _hud: CanvasLayer = $HUD
@onready var _node_info: RichTextLabel = $HUD/Panel/Margin/VBox/NodeInfoLabel
@onready var _act_label: Label = $HUD/TopBar/ActLabel

var _node_token_scene := preload("res://scenes/world/map_node_token.tscn")
var _npc_token_scene := preload("res://scenes/world/npc_token.tscn")
var _connections: Line2D

func _ready() -> void:
	GameState.current_phase = GameState.Phase.OVERWORLD
	_build_map()
	_place_nodes()
	_place_npcs()
	_camera.focus_on(_node_position(GameState.current_node_id), 1.0)
	EventBus.ui_request.connect(_on_ui_request)
	EventBus.node_visited.connect(_on_node_visited)
	_act_label.text = "Act %d" % GameState.current_act

func _build_map() -> void:
	# Procedural tile grid using simple colored parchment tiles.
	var tiles := Content.map_nodes(GameState.current_act)
	var rng := RandomNumberGenerator.new()
	rng.seed = GameState.current_act * 1000
	for x in range(0, MAP_WIDTH, TILE_SIZE):
		for y in range(0, MAP_HEIGHT, TILE_SIZE):
			var sprite := Sprite2D.new()
			sprite.position = Vector2(x + TILE_SIZE / 2, y + TILE_SIZE / 2)
			sprite.scale = Vector2(TILE_SIZE / 128.0, TILE_SIZE / 128.0)
			sprite.texture = _pick_terrain_tile(rng)
			sprite.modulate = Color(0.55, 0.50, 0.44, 1)
			_world.add_child(sprite)
	# Draw connections behind nodes.
	_connections = Line2D.new()
	_connections.default_color = Color(0.45, 0.38, 0.30, 0.55)
	_connections.width = 3.0
	_connections.z_index = 5
	_world.add_child(_connections)

func _pick_terrain_tile(rng: RandomNumberGenerator) -> Texture2D:
	var r := rng.randf()
	if r < 0.6:
		return load("res://assets/images/map_tiles/tile_ash.png")
	elif r < 0.85:
		return load("res://assets/images/map_tiles/tile_stone.png")
	else:
		return load("res://assets/images/map_tiles/tile_parchment.png")

func _place_nodes() -> void:
	var nodes := Content.map_nodes(GameState.current_act)
	for node in nodes:
		var id: String = node.id
		var pos := _node_position(id)
		var token: Area2D = _node_token_scene.instantiate()
		token.node_id = id
		token.node_name = node.get("name", id)
		token.position = pos
		var state := _node_state(id)
		token.texture = load("res://assets/images/map/map_ruins_%s.png" % state)
		_world.add_child(token)
	# Connect after all nodes exist so positions are resolved.
	_draw_connections(nodes)

func _node_position(id: String) -> Vector2:
	var node := Content.node_by_id(id)
	if node.is_empty():
		return Vector2(MAP_WIDTH / 2, MAP_HEIGHT / 2)
	var fx := float(node.get("xFraction", 0.5))
	var fy := float(node.get("yFraction", 0.5))
	# Apply a slight isometric 2.5D shear.
	var x := fx * MAP_WIDTH
	var y := fy * MAP_HEIGHT * 0.75 + MAP_HEIGHT * 0.12
	return Vector2(x, y)

func _node_state(id: String) -> String:
	if GameState.current_node_id == id:
		return "active"
	if GameState.is_scene_completed(Content.node_by_id(id).get("sceneId", "")):
		return "completed"
	if not GameState.is_node_unlocked(id):
		return "blocked"
	return "neutral"

func _draw_connections(nodes: Array) -> void:
	for node in nodes:
		var from := _node_position(node.id)
		for target_id in node.get("connectedTo", []):
			var target := Content.node_by_id(target_id)
			if target.is_empty():
				continue
			var to := _node_position(target_id)
			_connections.add_point(from)
			_connections.add_point(to)

func _place_npcs() -> void:
	for npc in Content.npcs():
		var id: String = npc.get("id", "")
		var home := _find_home_node_for_npc(id)
		if home.is_empty():
			continue
		var token := _npc_token_scene.instantiate()
		token.npc_id = id
		token.global_position = _node_position(home)
		var tex_path := "res://assets/images/npcs/tokens/token_%s.png" % id
		if ResourceLoader.exists(tex_path):
			token.texture = load(tex_path)
		_world.add_child(token)

func _find_home_node_for_npc(npc_id: String) -> String:
	var nodes := Content.map_nodes(GameState.current_act)
	for node in nodes:
		var scene_id: String = node.get("sceneId", "")
		if scene_id.to_lower().find(npc_id) != -1:
			return node.id
	return "" if nodes.is_empty() else nodes[0].id

func _on_node_visited(node_id: String) -> void:
	_camera.focus_on(_node_position(node_id), 1.0)
	var node := Content.node_by_id(node_id)
	_node_info.text = "[center]%s[/center]\n%s" % [node.get("name", node_id), node.get("description", "")]

func _on_ui_request(screen_name: String, payload: Dictionary) -> void:
	match screen_name:
		"show_tooltip":
			_node_info.text = payload.get("text", "")
		"node_locked":
			_node_info.text = "The path to %s is sealed." % payload.get("node_id", "")

func _on_camp_button_pressed() -> void:
	Simulation.rest_at_camp()
	SceneSwitcher.switch_to("res://scenes/screens/camp_screen.tscn")

func _on_party_button_pressed() -> void:
	SceneSwitcher.switch_to("res://scenes/screens/party_screen.tscn")

func _on_journal_button_pressed() -> void:
	SceneSwitcher.switch_to("res://scenes/screens/journal_screen.tscn")

func _on_menu_button_pressed() -> void:
	GameState.save_game()
	SceneSwitcher.switch_to("res://scenes/screens/main_menu.tscn")
