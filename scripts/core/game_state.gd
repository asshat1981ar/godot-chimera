extends Node
## Canonical, deterministic game state for Chimera.
## This is the Godot equivalent of the serialized save-state in the Android core-model.

const SAVE_PATH := "user://chimera_save.json"

enum Phase { MENU, OVERWORLD, SCENE, CAMP, DUEL, ACT_TRANSITION, SETTINGS }

var current_phase: Phase = Phase.MENU
var current_act: int = 1
var current_node_id: String = ""
var party: Array[String] = []
var inventory: Dictionary = {} # item_id -> quantity
var completed_scenes: Array[String] = []
var unlocked_nodes: Array[String] = []
var dispositions: Dictionary = {} # npc_id -> float in [-1,1]
var journal_entries: Array[Dictionary] = []
var active_vows: Array[String] = []
var settings: Dictionary = {
	"music_enabled": true,
	"sfx_enabled": true,
	"reduced_motion": false,
	"ai_enabled": false,
	"text_speed": 0.04,
}

func _ready() -> void:
	# Defer so all autoloads (especially Content) have finished _ready.
	call_deferred("_load_or_init")

func is_node_unlocked(node_id: String) -> bool:
	return unlocked_nodes.has(node_id) or Content.is_node_default_unlocked(node_id)

func is_scene_completed(scene_id: String) -> bool:
	return completed_scenes.has(scene_id)

func get_disposition(npc_id: String) -> float:
	return dispositions.get(npc_id, Content.npc_initial_disposition(npc_id))

func set_disposition(npc_id: String, value: float) -> void:
	var old := get_disposition(npc_id)
	var clamped := clampf(value, -1.0, 1.0)
	dispositions[npc_id] = clamped
	EventBus.emit_disposition_changed(npc_id, clamped - old, clamped)

func adjust_disposition(npc_id: String, delta: float) -> void:
	set_disposition(npc_id, get_disposition(npc_id) + delta)

func add_to_party(npc_id: String) -> void:
	if not party.has(npc_id):
		party.append(npc_id)
		EventBus.emit_state_changed("party", party.duplicate())

func add_inventory(item_id: String, amount: int = 1) -> void:
	inventory[item_id] = inventory.get(item_id, 0) + amount
	EventBus.emit_inventory_changed(item_id, inventory[item_id])

func mark_scene_completed(scene_id: String) -> void:
	if not completed_scenes.has(scene_id):
		completed_scenes.append(scene_id)
		EventBus.emit_state_changed("completed_scenes", completed_scenes.duplicate())
	_unlock_gates()

func mark_node_visited(node_id: String) -> void:
	current_node_id = node_id
	EventBus.emit_node_visited(node_id)

func advance_act(next_act: int) -> void:
	current_act = next_act
	current_node_id = ""
	EventBus.emit_state_changed("current_act", current_act)

func save_game(slot_name: String = "auto") -> void:
	var payload := {
		"slot": slot_name,
		"timestamp": Time.get_unix_time_from_system(),
		"current_phase": current_phase,
		"current_act": current_act,
		"current_node_id": current_node_id,
		"party": party,
		"inventory": inventory,
		"completed_scenes": completed_scenes,
		"unlocked_nodes": unlocked_nodes,
		"dispositions": dispositions,
		"journal_entries": journal_entries,
		"active_vows": active_vows,
		"settings": settings,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(payload, "\t"))
		file.close()

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		_deserialize(parsed)
		return true
	return false

func new_game() -> void:
	current_phase = Phase.OVERWORLD
	current_act = 1
	current_node_id = "hollow_gate"
	party.clear()
	inventory.clear()
	completed_scenes.clear()
	unlocked_nodes.clear()
	dispositions.clear()
	journal_entries.clear()
	active_vows.clear()
	_unlock_gates()
	EventBus.emit_state_changed("new_game", true)

func _load_or_init() -> void:
	if not load_game():
		new_game()

func _deserialize(data: Dictionary) -> void:
	current_phase = int(data.get("current_phase", Phase.MENU))
	current_act = int(data.get("current_act", 1))
	current_node_id = data.get("current_node_id", "")
	_assign_string_array(party, data.get("party", []))
	inventory = data.get("inventory", {})
	_assign_string_array(completed_scenes, data.get("completed_scenes", []))
	_assign_string_array(unlocked_nodes, data.get("unlocked_nodes", []))
	dispositions = data.get("dispositions", {})
	journal_entries.clear()
	for entry in data.get("journal_entries", []):
		if entry is Dictionary:
			journal_entries.append(entry)
	_assign_string_array(active_vows, data.get("active_vows", []))
	settings.merge(data.get("settings", {}), true)

func _assign_string_array(target: Array[String], source: Array) -> void:
	target.clear()
	for item in source:
		if item is String:
			target.append(item)

func _unlock_gates() -> void:
	# Refresh unlockable nodes based on current disposition/scene state.
	for node in Content.all_nodes():
		var node_dict: Dictionary = node
		var reqs: Dictionary = Content.node_unlock_requirements(node_dict.id)
		if reqs.is_empty():
			continue
		if _requirements_met(reqs) and not unlocked_nodes.has(node_dict.id):
			unlocked_nodes.append(node_dict.id)
			EventBus.emit_state_changed("unlocked_nodes", unlocked_nodes.duplicate())

func _requirements_met(reqs: Dictionary) -> bool:
	var min_disp: Dictionary = reqs.get("minDisposition", {})
	for npc_id in min_disp:
		if get_disposition(npc_id) < float(min_disp[npc_id]):
			return false
	var completed: Array = reqs.get("completedScenes", [])
	for scene_id in completed:
		if not is_scene_completed(scene_id):
			return false
	return true
