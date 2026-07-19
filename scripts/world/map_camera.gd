extends Camera2D
## Pan/zoom camera for the 2.5D overhead map. Keeps inside world bounds.

@export var min_zoom := 0.5
@export var max_zoom := 2.5
@export var zoom_step := 0.1
@export var pan_speed := 420.0
@export var drag_smooth := 12.0

var _dragging := false
var _drag_start := Vector2.ZERO
var _target_position := Vector2.ZERO

func _ready() -> void:
	_target_position = global_position

func _unhandled_input(event: InputEvent) -> void:
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
	elif event is InputEventMouseMotion and _dragging:
		var delta := get_global_mouse_position() - _drag_start
		_target_position -= delta
		_drag_start = get_global_mouse_position()

func _process(delta: float) -> void:
	var input := Input.get_vector("map_pan_left", "map_pan_right", "map_pan_up", "map_pan_down")
	if input.length() > 0:
		_target_position += input * pan_speed * delta / zoom.x
	global_position = global_position.lerp(_target_position, clampf(delta * drag_smooth, 0.0, 1.0))

func _zoom_at(world_point: Vector2, factor: float) -> void:
	var old_zoom := zoom.x
	var new_zoom := clampf(old_zoom + factor, min_zoom, max_zoom)
	var ratio := new_zoom / old_zoom
	var new_position := world_point + (global_position - world_point) / ratio
	zoom = Vector2(new_zoom, new_zoom)
	_target_position = new_position

func focus_on(world_pos: Vector2, target_zoom: float = 1.0) -> void:
	_target_position = world_pos
	zoom = Vector2(target_zoom, target_zoom)
