extends Node2D
## 2.5D overhead map screen. Builds the act world from Content, renders connections,
## node tokens, and ambient NPC tokens. Sim authoritative: only sends travel intents.

const MAP_WIDTH := 1280
const MAP_HEIGHT := 720
const TILE_SIZE := 64
const NODE_SCALE := 96
const QUICK_BAR_WIDTH := 96.0
const BUTTON_MIN_SIZE := 84.0

@onready var _world: Node2D = $World
@onready var _camera: Camera2D = $Camera2D
@onready var _hud: CanvasLayer = $HUD
@onready var _node_info: RichTextLabel = $HUD/Panel/Margin/VBox/NodeInfoLabel
@onready var _act_label: Label = $HUD/TopBar/VBox/ActLabel
@onready var _objective_label: Label = $HUD/TopBar/VBox/ObjectiveLabel
@onready var _pause_menu: Control = $HUD/PauseMenu
@onready var _quick_bar: Control = $HUD/QuickBar
@onready var _camp_badge: Label = $HUD/QuickBar/Margin/VBox/CampButton/CampBadge
@onready var _journal_badge: Label = $HUD/QuickBar/Margin/VBox/JournalButton/JournalBadge

var _node_token_scene := preload("res://scenes/world/map_node_token.tscn")
var _npc_token_scene := preload("res://scenes/world/npc_token.tscn")
var _ui_adapt: UIAdapt = UIAdapt.new()
var _journal_pending := 0
var _camp_pending := 0

func _ready() -> void:
	GameState.current_phase = GameState.Phase.OVERWORLD
	_build_map()
	_place_nodes()
	_place_npcs()
	_camera.focus_on(_node_position(GameState.current_node_id), 1.0)
	EventBus.ui_request.connect(_on_ui_request)
	EventBus.node_visited.connect(_on_node_visited)
	EventBus.journal_updated.connect(_on_journal_updated)
	EventBus.state_changed.connect(_on_state_changed)
	EventBus.camp_night_started.connect(_on_camp_night_started)
	_act_label.text = "Act %d" % GameState.current_act
	_refresh_objective_label()
	add_child(_ui_adapt)
	_apply_safe_area()
	get_tree().root.size_changed.connect(_apply_safe_area)
	_refresh_journal_badge()
	_refresh_camp_badge()
	_pause_menu.hide()
	_setup_quick_bar_focus()

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
	# Connections are drawn as per-edge Line2D instances in _draw_connections().

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
	# Each edge gets its own Line2D so unrelated edges are never joined.
	for node in nodes:
		var from := _node_position(node.id)
		for target_id in node.get("connectedTo", []):
			var target := Content.node_by_id(target_id)
			if target.is_empty():
				continue
			var to := _node_position(target_id)
			var line := Line2D.new()
			line.default_color = Color(0.45, 0.38, 0.30, 0.55)
			line.width = 3.0
			line.z_index = 5
			line.add_point(from)
			line.add_point(to)
			_world.add_child(line)

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
	_maybe_show_onboarding()

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
	_toggle_pause_menu()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_back"):
		get_viewport().set_input_as_handled()
		if _pause_menu.visible:
			_toggle_pause_menu()
		else:
			_toggle_pause_menu()

func _toggle_pause_menu() -> void:
	_pause_menu.visible = not _pause_menu.visible

func _on_continue_button_pressed() -> void:
	_toggle_pause_menu()

func _on_pause_settings_pressed() -> void:
	GameState.save_game()
	SceneSwitcher.switch_to("res://scenes/screens/settings_screen.tscn")

func _on_pause_main_menu_pressed() -> void:
	GameState.save_game()
	SceneSwitcher.switch_to("res://scenes/screens/main_menu.tscn")

func _on_pause_quit_pressed() -> void:
	GameState.save_game()
	get_tree().quit()

func _on_quick_camp_pressed() -> void:
	GameState.save_game()
	Simulation.rest_at_camp()
	SceneSwitcher.switch_to("res://scenes/screens/camp_screen.tscn")

func _on_quick_party_pressed() -> void:
	GameState.save_game()
	SceneSwitcher.switch_to("res://scenes/screens/party_screen.tscn")

func _on_quick_journal_pressed() -> void:
	GameState.save_game()
	_journal_pending = 0
	_refresh_journal_badge()
	SceneSwitcher.switch_to("res://scenes/screens/journal_screen.tscn")

func _on_quick_settings_pressed() -> void:
	GameState.save_game()
	SceneSwitcher.switch_to("res://scenes/screens/settings_screen.tscn")

func _setup_quick_bar_focus() -> void:
	var bar := $HUD/QuickBar/Margin/VBox
	var names := ["CampButton", "PartyButton", "JournalButton", "MenuButton"]
	var nodes: Array = []
	for n in names:
		var btn := bar.get_node_or_null(n)
		if btn:
			btn.focus_mode = Control.FOCUS_ALL
			nodes.append(btn)
	for i in range(nodes.size()):
		if i > 0:
			nodes[i].focus_neighbor_top = nodes[i - 1].get_path()
			nodes[i - 1].focus_neighbor_bottom = nodes[i].get_path()
	if nodes.size() > 0:
		nodes[0].grab_focus()

func _on_journal_updated(_entry_id: String) -> void:
	_journal_pending += 1
	_refresh_journal_badge()

func _on_state_changed(key: String, _value: Variant) -> void:
	match key:
		"quest_states":
			_refresh_objective_label()
			_journal_pending += 1
			_refresh_journal_badge()
		"unlocked_lore":
			_journal_pending += 1
			_refresh_journal_badge()
		"completed_scenes":
			_refresh_objective_label()

func _on_camp_night_started(_risk: float) -> void:
	_camp_pending += 1
	_refresh_camp_badge()

func _refresh_journal_badge() -> void:
	_journal_badge.text = str(_journal_pending)
	_journal_badge.visible = _journal_pending > 0

func _refresh_camp_badge() -> void:
	_camp_badge.text = str(_camp_pending)
	_camp_badge.visible = _camp_pending > 0

func _refresh_objective_label() -> void:
	var title := _active_quest_title()
	_objective_label.text = "Objective: %s" % title if not title.is_empty() else "Objective: —"

func _active_quest_title() -> String:
	for q in Content.quests():
		var quest_id: String = q.get("id", "")
		var state: Dictionary = GameState.quest_states.get(quest_id, {})
		if state.get("status", "") == "active":
			return q.get("name", quest_id)
	return ""

func _apply_safe_area() -> void:
	var viewport_size := get_viewport_rect().size
	var safe: Rect2 = DisplayServer.get_display_safe_area()
	var full := get_window().get_visible_rect().size
	var sx := maxf(full.x, 1.0)
	var sy := maxf(full.y, 1.0)
	var left := (safe.position.x / sx) * viewport_size.x
	var top := (safe.position.y / sy) * viewport_size.y
	var right := ((sx - safe.end.x) / sx) * viewport_size.x
	var bottom := ((sy - safe.end.y) / sy) * viewport_size.y
	_ui_adapt.apply_margins($HUD/TopBar, left, top, right, 0.0)
	_ui_adapt.apply_margins($HUD/Panel, left, 0.0, right, bottom)
	_ui_adapt.apply_margins($HUD/QuickBar, left, top, right, bottom)
	_ui_adapt.apply_margins($HUD/PauseMenu, left, top, right, bottom)

func _maybe_show_onboarding() -> void:
	if GameState.settings.get("has_seen_onboarding", false):
		return
	if UIAdapt.is_reduced_motion():
		GameState.settings["has_seen_onboarding"] = true
		return
	var coach := preload("res://scripts/world/coach_marks.gd").new()
	coach.name = "CoachMarks"
	coach.dismissed.connect(_on_onboarding_dismissed)
	_hud.add_child(coach)

func _on_onboarding_dismissed() -> void:
	GameState.settings["has_seen_onboarding"] = true
	GameState.save_game("auto")

