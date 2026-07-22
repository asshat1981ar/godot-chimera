extends Node
## UI adaptation helper: safe-area insets, dp scaling, reduced-motion query.
## Registered as the UIAdapt autoload; screens call it directly, never instantiate it.

const BASE_HEIGHT := 720.0

func apply_safe_area(root: Control) -> void:
	## Inset a full-rect root Control so it stays inside the display safe area.
	## Call from _ready and on get_tree().root.size_changed.
	if root == null:
		return
	var window := root.get_window()
	if window == null:
		return
	var safe: Rect2 = DisplayServer.get_display_safe_area()
	var full: Rect2i = window.get_visible_rect()
	var full_size := Vector2(full.size)
	if safe.size.x <= 0 or safe.size.y <= 0 or safe == Rect2(Vector2.ZERO, full_size):
		return
	var viewport_size := root.get_viewport_rect().size
	var sx := maxf(full_size.x, 1.0)
	var sy := maxf(full_size.y, 1.0)
	var left := (safe.position.x / sx) * viewport_size.x
	var top := (safe.position.y / sy) * viewport_size.y
	var right := ((sx - safe.end.x) / sx) * viewport_size.x
	var bottom := ((sy - safe.end.y) / sy) * viewport_size.y
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = left
	root.offset_top = top
	root.offset_right = -right
	root.offset_bottom = -bottom

func apply_margins(control: Control, left: float, top: float, right: float, bottom: float) -> void:
	## Add extra margins to a Control that already has anchors_preset set.
	if control == null:
		return
	control.offset_left += left
	control.offset_top += top
	control.offset_right -= right
	control.offset_bottom -= bottom

static func is_reduced_motion() -> bool:
	return GameState.settings.get("reduced_motion", false)

static func scale_for_height(base_value: float) -> float:
	## Scale a logical-px baseline (720p) to the current logical viewport height.
	var viewport: Rect2 = Engine.get_main_loop().get_root().get_viewport_rect()
	return base_value * (viewport.size.y / BASE_HEIGHT)
