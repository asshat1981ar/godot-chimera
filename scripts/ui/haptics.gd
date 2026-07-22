extends RefCounted
class_name Haptics
## Mobile haptic feedback helper. Guards against non-Android platforms and
## devices that do not expose vibrate_handheld(). Disabled when
## GameState.settings.haptics_enabled is false.

const DEFAULT_DURATION_MS := 20

static func play(duration_ms: int = DEFAULT_DURATION_MS) -> void:
	if not _enabled():
		return
	if not OS.has_feature("android"):
		return
	if not Input.has_method("vibrate_handheld"):
		return
	var duration_sec := clampf(duration_ms / 1000.0, 0.01, 0.5)
	# GDScript does not support try/catch; the feature + method guards above are
	# the equivalent safe fallback. Calling on an unsupported device would no-op.
	Input.vibrate_handheld(duration_sec)

static func _enabled() -> bool:
	if GameState == null or not is_instance_valid(GameState):
		return false
	return GameState.settings.get("haptics_enabled", true)

