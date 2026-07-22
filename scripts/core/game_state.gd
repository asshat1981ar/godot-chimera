extends Node
## Canonical, deterministic game state for Chimera.
## This is the Godot equivalent of the serialized save-state in the Android core-model.

const SAVE_PATH := "user://chimera_save.json"
const SCHEMA_VERSION := 1

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
var quest_states: Dictionary = {} # quest_id -> {"status": "active"|"completed", "objectives": {objective_id: int}}
var unlocked_lore: Array[String] = [] # lore entry ids from data/lore_entries.json
## Deterministic RNG seed; 0 means "derive from unix time at new_game".
var rng_seed: int = 0
## Pending delayed-disposition changes as turn counters (turn_remaining -> Array[{npc_id,delta}]).
var pending_dispositions: Dictionary = {}
## Dev/debug flags. Never autosaved and always reset on new_game. Harmless in release.
var dev_flags: Dictionary = {}
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
	_autosave()

func mark_node_visited(node_id: String) -> void:
	current_node_id = node_id
	EventBus.emit_node_visited(node_id)
	_autosave()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		_autosave()

func _autosave() -> void:
	# Session-safe autosave on natural boundaries and Android lifecycle pause.
	if current_phase != Phase.MENU:
		save_game("auto")

func save_game(slot_name: String = "auto") -> void:
	var path := _slot_path(slot_name)
	var payload := {
		"schema_version": SCHEMA_VERSION,
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
		"quest_states": quest_states,
		"unlocked_lore": unlocked_lore,
		"rng_seed": rng_seed,
		"pending_dispositions": pending_dispositions,
		"settings": settings,
	}
	var tmp_path := path + ".tmp"
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if not file:
		push_error("Save failed: could not open %s" % tmp_path)
		return
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	var err := DirAccess.rename_absolute(tmp_path, path)
	if err != OK:
		push_error("Save rename failed: %d" % err)

func load_game(slot_name: String = "auto") -> bool:
	var path := _slot_path(slot_name)
	if not FileAccess.file_exists(path):
		# Backward-compat: one-time load from the legacy single-slot save.
		if slot_name == "auto" and FileAccess.file_exists(SAVE_PATH):
			var ok := _load_legacy()
			if ok:
				save_game("auto")
				var dir := DirAccess.open("user://")
				if dir:
					dir.remove(SAVE_PATH)
			return ok
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return false
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		_deserialize(parsed)
		return true
	return false

func _load_legacy() -> bool:
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

func _slot_path(slot_name: String) -> String:
	return "user://save_%s.json" % slot_name

func list_save_slots() -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open("user://")
	if not dir:
		return out
	dir.list_dir_begin()
	var fname := dir.get_next()
	while not fname.is_empty():
		if fname.begins_with("save_") and fname.ends_with(".json"):
			var slot := fname.get_basename().trim_prefix("save_")
			if not slot.is_empty() and not out.has(slot):
				out.append(slot)
		fname = dir.get_next()
	dir.list_dir_end()
	return out

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
	quest_states.clear()
	unlocked_lore.clear()
	pending_dispositions.clear()
	dev_flags.clear()
	rng_seed = int(Time.get_unix_time_from_system())
	_unlock_gates()
	_activate_unlocked_quests()
	EventBus.emit_state_changed("new_game", true)
	_autosave()

func _load_or_init() -> void:
	if not load_game("auto"):
		new_game()

func _deserialize(data: Dictionary) -> void:
	var schema: int = int(data.get("schema_version", 0))
	data = _migrate(data, schema)
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
	quest_states = data.get("quest_states", {})
	_assign_string_array(unlocked_lore, data.get("unlocked_lore", []))
	rng_seed = int(data.get("rng_seed", 0))
	pending_dispositions = data.get("pending_dispositions", {})
	settings.merge(data.get("settings", {}), true)
	# dev_flags are intentionally not restored from save.
	# Re-activate any quests whose unlock conditions are met after loading.
	_activate_unlocked_quests()

func _activate_unlocked_quests() -> void:
	for q in Content.quests():
		var quest_id: String = q.get("id", "")
		if quest_states.has(quest_id):
			continue
		var unlock: Dictionary = q.get("unlockConditions", {})
		if unlock.is_empty():
			quest_states[quest_id] = {"status": "active", "objectives": {}}

func _migrate(data: Dictionary, schema: int) -> Dictionary:
	if schema < 1:
		# Legacy saves had no rng_seed or pending_dispositions.
		if not data.has("rng_seed"):
			data["rng_seed"] = int(Time.get_unix_time_from_system())
		if not data.has("pending_dispositions"):
			data["pending_dispositions"] = {}
		data["schema_version"] = SCHEMA_VERSION
	return data

func set_quest_status(quest_id: String, status: String) -> void:
	var state: Dictionary = quest_states.get(quest_id, {"status": "active", "objectives": {}})
	state.status = status
	quest_states[quest_id] = state
	EventBus.emit_state_changed("quest_states", quest_states.duplicate(true))

func is_quest_active(quest_id: String) -> bool:
	return quest_states.get(quest_id, {}).get("status", "") == "active"

func is_quest_completed(quest_id: String) -> bool:
	return quest_states.get(quest_id, {}).get("status", "") == "completed"

func unlock_lore(entry_id: String) -> void:
	if not unlocked_lore.has(entry_id):
		unlocked_lore.append(entry_id)
		EventBus.emit_state_changed("unlocked_lore", unlocked_lore.duplicate())

func set_dev_flag(key: String, value: Variant) -> void:
	dev_flags[key] = value

func get_dev_flag(key: String, default: Variant = false) -> Variant:
	return dev_flags.get(key, default)

func has_dev_flag(key: String) -> bool:
	return dev_flags.has(key) and dev_flags[key]

func _assign_string_array(target: Array[String], source: Array) -> void:
	target.clear()
	for item in source:
		if item is String:
			target.append(item)

func advance_act(next_act: int) -> void:
	current_act = next_act
	current_node_id = ""
	_unlock_gates()
	_activate_unlocked_quests()
	EventBus.emit_state_changed("current_act", current_act)
	EventBus.emit_act_advanced(current_act)
	_autosave()

func add_pending_disposition(npc_id: String, delta: float, turns: int) -> void:
	if turns <= 0:
		adjust_disposition(npc_id, delta)
		return
	var key := str(turns)
	var list: Array = pending_dispositions.get(key, [])
	list.append({"npc_id": npc_id, "delta": delta})
	pending_dispositions[key] = list

func consume_pending_dispositions() -> void:
	var keys: Array = pending_dispositions.keys()
	if keys.is_empty():
		return
	keys.sort()
	var merged: Array[Dictionary] = []
	for key in keys:
		var turns: int = int(key)
		var list: Array = pending_dispositions.get(key, [])
		for entry in list:
			if entry is Dictionary:
				entry["turns"] = turns
				merged.append(entry)
	pending_dispositions.clear()
	for entry in merged:
		var t: int = int(entry.get("turns", 1)) - 1
		if t <= 0:
			adjust_disposition(entry.get("npc_id", ""), float(entry.get("delta", 0.0)))
		else:
			var new_key := str(t)
			var new_list: Array = pending_dispositions.get(new_key, [])
			new_list.append({"npc_id": entry.get("npc_id", ""), "delta": float(entry.get("delta", 0.0))})
			pending_dispositions[new_key] = new_list

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
