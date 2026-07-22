extends Camera2D
## Pan/zoom camera for the 2.5D overhead map. Touch-first: drag pan, pinch zoom,
## tap select. Keeps keyboard/mouse fallback (WASD, wheel, middle drag).

@export var min_zoom := 0.5
@export var max_zoom := 2.5
@export var zoom_step := 0.1
@export var pan_speed := 420.0
@export var drag_smooth := 12.0
@export var tap_max_distance := 24.0
@export var tap_max_duration := 0.35

var _dragging := false
var _drag_start := Vector2.ZERO
var _target_position := Vector2.ZERO

# Touch state
var _touch_active := false
var _touch_index := -1
var _touch_start_screen := Vector2.ZERO
var _touch_start_time := 0.0
var _touch_start_world := Vector2.ZERO

func _ready() -> void:
	_target_position = global_position

func _unhandled_input(event: InputEvent) -> void:
	# Mouse wheel zoom (desktop fallback).
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at(get_global_mouse_position(), zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at(get_global_mouse_position(), -zoom_step)
		elif event.button_index == MOUSE_BUTTON_MIDDLE or event.is_action("map_drag"):
			if event.pressed:
				_dragging = true
				_drag_start = get_global_mouse_position()
			else:
				_dragging = false
		return

	# Middle-mouse drag (desktop fallback).
	if event is InputEventMouseMotion and _dragging:
		var delta := get_global_mouse_position() - _drag_start
		_target_position -= delta
		_drag_start = get_global_mouse_position()
		return

	# Single-finger pan and tap.
	if event is InputEventScreenTouch:
		if event.pressed and not _touch_active:
			_touch_active = true
			_touch_index = event.index
			_touch_start_screen = event.position
			_touch_start_time = Time.get_ticks_msec() / 1000.0
			_touch_start_world = _target_position
		elif not event.pressed and event.index == _touch_index:
			var duration := Time.get_ticks_msec() / 1000.0 - _touch_start_time
			var distance := _touch_start_screen.distance_to(event.position)
			if distance < tap_max_distance and duration < tap_max_duration:
				_select_at_screen(event.position)
			_touch_active = false
			_touch_index = -1
		return

	if event is InputEventScreenDrag and _touch_active and event.index == _touch_index:
		var screen_delta: Vector2 = event.position - _touch_start_screen
		var world_delta: Vector2 = screen_delta / zoom
		_target_position = _touch_start_world - world_delta
		return

	# Pinch zoom around the gesture focal point.
	if event is InputEventMagnifyGesture:
		var focal_world: Vector2 = get_canvas_transform().affine_inverse() * event.position
		var factor: float = (event.factor - 1.0) * zoom_step * 4.0
		_zoom_at(focal_world, factor)
		return

func _process(delta: float) -> void:
	var input := Input.get_vector("map_pan_left", "map_pan_right", "map_pan_up", "map_pan_down")
	if input.length() > 0:
		_target_position += input * pan_speed * delta / zoom.x
	global_position = global_position.lerp(_target_position, clampf(delta * drag_smooth, 0.0, 1.0))

func _zoom_at(world_point: Vector2, factor: float) -> void:
	var old_zoom := zoom.x
	var new_zoom := clampf(old_zoom + factor, min_zoom, max_zoom)
	if is_equal_approx(old_zoom, new_zoom):
		return
	var ratio := new_zoom / old_zoom
	var new_position := world_point + (global_position - world_point) / ratio
	zoom = Vector2(new_zoom, new_zoom)
	_target_position = new_position

func focus_on(world_pos: Vector2, target_zoom: float = 1.0) -> void:
	_target_position = world_pos
	zoom = Vector2(target_zoom, target_zoom)

func _select_at_screen(screen_pos: Vector2) -> void:
	var world_pos := get_canvas_transform().affine_inverse() * screen_pos
	var space := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collision_mask = 2
	query.max_results = 1
	var results := space.intersect_point(query)
	for hit in results:
		var body: Node2D = hit.get("collider", null)
		if body and body.has_method("select"):
			body.select()
			return
	# Tap on empty map clears the tooltip.
	EventBus.emit_ui_request("show_tooltip", {"text": "Select a node to travel."})
