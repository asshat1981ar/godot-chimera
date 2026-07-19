extends Node
## Content loader / lookup singleton. Migrates the Android JSON data into Godot dictionaries.
## In production this could be replaced by Resource-based imports; JSON keeps parity with the
## existing authored data pipeline.

const NPCS_PATH := "res://data/npcs.json"
const PERSONAS_PATH := "res://data/npc_personas.json"
const ACT1_MAP_PATH := "res://data/act1_map.json"
const ACT2_MAP_PATH := "res://data/act2_map.json"
const ACT3_MAP_PATH := "res://data/act3_map.json"
const ACT1_SCENES_PATH := "res://data/act1_scenes.json"
const ACT2_SCENES_PATH := "res://data/act2_scenes.json"
const ACT3_SCENES_PATH := "res://data/act3_scenes.json"
const RECIPES_PATH := "res://data/crafting_recipes.json"
const COMBAT_INTENTS_PATH := "res://data/combat_intents.json"

var _npcs: Array = []
var _personas: Dictionary = {}
var _maps: Dictionary = {1: [], 2: [], 3: []}
var _scenes: Dictionary = {1: [], 2: [], 3: []}
const QUESTS_PATH := "res://data/quests.json"
const DIALOGUE_TREES_PATH := "res://data/dialogue_trees.json"
const LORE_ENTRIES_PATH := "res://data/lore_entries.json"
const ITEMS_PATH := "res://data/items.json"

var _quests: Array = []
var _dialogue_trees: Dictionary = {}
var _lore_entries: Array = []
var _items: Array = []
var _recipes: Array = []
var _combat_intents: Dictionary = {}


func _ready() -> void:
	_load_json()

func _load_json() -> void:
	_npcs = _read_json(NPCS_PATH)
	_personas = _read_json(PERSONAS_PATH)
	_maps[1] = _read_json(ACT1_MAP_PATH)
	_maps[2] = _read_json(ACT2_MAP_PATH)
	_maps[3] = _read_json(ACT3_MAP_PATH)
	_scenes[1] = _read_json(ACT1_SCENES_PATH)
	_scenes[2] = _read_json(ACT2_SCENES_PATH)
	_scenes[3] = _read_json(ACT3_SCENES_PATH)
	_recipes = _read_json(RECIPES_PATH)
	_combat_intents = _read_json(COMBAT_INTENTS_PATH)
	# New authored narrative content. Items.json may not exist yet (SYS authors in parallel).
	_quests = _read_json(QUESTS_PATH)
	_dialogue_trees = _read_json(DIALOGUE_TREES_PATH)
	_lore_entries = _read_json(LORE_ENTRIES_PATH)
	_items = _read_json(ITEMS_PATH) if FileAccess.file_exists(ITEMS_PATH) else []

func _read_json(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_warning("Could not read content JSON: %s" % path)
		return _default_for_path(path)
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	return parsed if parsed != null else _default_for_path(path)

func _default_for_path(path: String) -> Variant:
	# Keep downstream lookup stable when a file is missing.
	if path == DIALOGUE_TREES_PATH:
		return {"version": 1, "trees": {}}
	return []

func npcs() -> Array:
	return _npcs

func npc_by_id(id: String) -> Dictionary:
	for npc in _npcs:
		if npc.get("id", "") == id:
			return npc
	return {}

func npc_persona(id: String) -> Dictionary:
	return _personas.get(id, {})

func npc_initial_disposition(id: String) -> float:
	var npc := npc_by_id(id)
	return float(npc.get("initialDisposition", 0.0))

func npc_archetype(id: String) -> String:
	var npc := npc_by_id(id)
	var arch = npc.get("archetype", "")
	return "" if arch == null else str(arch)

func map_nodes(act: int) -> Array:
	return _maps.get(act, [])

func node_by_id(id: String) -> Dictionary:
	for act in _maps:
		for node in _maps[act]:
			if node.get("id", "") == id:
				return node
	return {}

func is_node_default_unlocked(id: String) -> bool:
	var node := node_by_id(id)
	return bool(node.get("isUnlocked", false))

func node_unlock_requirements(id: String) -> Dictionary:
	var node := node_by_id(id)
	return node.get("unlockRequirements", {})

func all_nodes() -> Array:
	var out: Array = []
	for act in _maps:
		out.append_array(_maps[act])
	return out

func scene_by_id(scene_id: String) -> Dictionary:
	for act in _scenes:
		for scene in _scenes[act]:
			if scene.get("id", "") == scene_id or scene.get("sceneId", "") == scene_id:
				return scene
	return {}

func act_scenes(act: int) -> Array:
	return _scenes.get(act, [])

func recipes() -> Array:
	return _recipes

func combat_intents() -> Dictionary:
	return _combat_intents

func quests() -> Array:
	return _quests

func quest(id: String) -> Dictionary:
	for q in _quests:
		if q.get("id", "") == id:
			return q
	return {}

func dialogue_tree(id: String) -> Dictionary:
	return _dialogue_trees.get("trees", {}).get(id, {})

func dialogue_tree_for(scene_id: String, npc_id: String) -> Dictionary:
	var trees: Dictionary = _dialogue_trees.get("trees", {})
	for tree_id in trees:
		var tree: Dictionary = trees[tree_id]
		if tree.get("sceneId", "") == scene_id and tree.get("npcId", "") == npc_id:
			return tree
	return {}

func lore_entries() -> Array:
	return _lore_entries

func lore_entry(id: String) -> Dictionary:
	for entry in _lore_entries:
		if entry.get("id", "") == id:
			return entry
	return {}

func lore_entries_by_reveal(reveal_tag: String) -> Array:
	var out: Array = []
	for entry in _lore_entries:
		if entry.get("revealTag", "") == reveal_tag:
			out.append(entry)
	return out

func lore_entries_by_scene(scene_id: String) -> Array:
	var out: Array = []
	for entry in _lore_entries:
		if entry.get("unlockedBySceneId", "") == scene_id:
			out.append(entry)
	return out

func items() -> Array:
	return _items

func item(id: String) -> Dictionary:
	for it in _items:
		if it.get("id", "") == id:
			return it
	return {}
