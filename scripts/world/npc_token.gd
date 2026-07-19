extends Marker2D
## Ambient NPC token that wanders near its home node.

@export var npc_id: String = ""
@export var texture: Texture2D
@export var wander_radius := 40.0
@export var wander_speed := 18.0

var _home: Vector2
var _target: Vector2

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_home = global_position
	_pick_new_target()
	if texture:
		_sprite.texture = texture
	var npc := Content.npc_by_id(npc_id)
	if not npc.is_empty():
		modulate = _disposition_tint(GameState.get_disposition(npc_id))
	EventBus.disposition_changed.connect(_on_disposition_changed)

func _on_disposition_changed(changed_npc_id: String, _delta: float, _new_value: float) -> void:
	if changed_npc_id == npc_id:
		modulate = _disposition_tint(_new_value)

func _disposition_tint(disposition: float) -> Color:
	if disposition > 0.2:
		return Color(0.9, 1.0, 0.85, 1)
	elif disposition < -0.2:
		return Color(1.0, 0.75, 0.75, 1)
	return Color.WHITE

func _process(delta: float) -> void:
	var dir := _target - global_position
	if dir.length() < 4.0:
		_pick_new_target()
	else:
		global_position += dir.normalized() * wander_speed * delta

func _pick_new_target() -> void:
	var angle := randf() * TAU
	var dist := randf() * wander_radius
	_target = _home + Vector2(cos(angle), sin(angle)) * dist
