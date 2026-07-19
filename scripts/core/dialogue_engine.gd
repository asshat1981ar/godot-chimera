class_name DialogueEngine
## Deterministic, data-driven dialogue interpreter for Chimera.
## Starts from a tree id and yields nodes until a choice ends the scene or starts a duel.
## Choice effects mutate GameState (disposition via Simulation.apply_dialogue_choice,
## lore via GameState.unlock_lore, party/recruit, vows) and maintain a local reveals[] list
## so reveal conditions can be evaluated within the same scene before the tree is saved.
##
## Local reveals vs GameState.unlocked_lore:
## - "reveal" effect marks lore in GameState immediately (so journal persists it)
##   AND pushes the reveal tag to _session_reveals so subsequent choices can test it.
## - Choice conditions.reveals are checked against _session_reveals (session-local) because
##   some reveals are not yet serialized as distinct lore entries. After the session,
##   the tags remain in GameState.unlocked_lore via the matching lore_entries mapping.

const CHOICE_TYPES: Array[String] = ["defer", "help", "threaten", "demand", "empathize", "vow", "lie", "conceal", "inquire"]

var tree_id: String = ""
var npc_id: String = ""
var scene_id: String = ""
var current_node_id: String = ""
var current_node: Dictionary = {}

var _session_reveals: Array[String] = []
var _session_vows: Array[String] = []

signal node_presented(node: Dictionary)
signal duel_requested(opponent_id: String)
signal scene_ended(scene_id: String)

func start(tree: Dictionary) -> void:
	reset()
	if tree.is_empty():
		return
	tree_id = tree.get("id", "")
	npc_id = tree.get("npcId", "")
	scene_id = tree.get("sceneId", "")
	current_node_id = tree.get("startNodeId", "")
	_present_current()

func reset() -> void:
	tree_id = ""
	npc_id = ""
	scene_id = ""
	current_node_id = ""
	current_node = {}
	_session_reveals.clear()
	_session_vows.clear()

func is_active() -> bool:
	return not current_node.is_empty()

func speaker_name() -> String:
	var speaker: String = current_node.get("speaker", "")
	if speaker == "player":
		return "You"
	if speaker == "narrator" or speaker.is_empty():
		return ""
	return Content.npc_by_id(speaker).get("name", speaker)

func choose(choice_index: int) -> Dictionary:
	var choices: Array = current_node.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		return {"result": "invalid"}

	var choice: Dictionary = choices[choice_index]
	var choice_type: String = choice.get("choiceType", "inquire")
	if not CHOICE_TYPES.has(choice_type):
		push_warning("Unknown choiceType '%s' in tree '%s'; using inquire." % [choice_type, tree_id])
		choice_type = "inquire"

	Simulation.apply_dialogue_choice(npc_id, choice_type)

	var custom_delta: float = float(choice.get("dispositionEffect", 0.0))
	if custom_delta != 0.0:
		GameState.adjust_disposition(npc_id, custom_delta)

	var effects: Dictionary = choice.get("effects", {})
	var vow: String = effects.get("vow", "")
	if not vow.is_empty():
		GameState.active_vows.append(vow)
		_session_vows.append(vow)

	if effects.get("recruit", false):
		GameState.add_to_party(npc_id)

	var reveal_tag: String = effects.get("reveal", "")
	if not reveal_tag.is_empty():
		_session_reveals.append(reveal_tag)
		_unlock_lore_for_reveal(reveal_tag)

	var next_node_id: Variant = choice.get("nextNodeId")
	var result := {"result": "continue"}

	if effects.get("endScene", false):
		result.result = "scene_end"
		current_node = {}
		current_node_id = ""
		scene_ended.emit(scene_id)
		return result

	if effects.get("startDuel", false):
		result.result = "duel"
		result.opponent_id = npc_id if not npc_id.is_empty() else scene_id
		current_node = {}
		current_node_id = ""
		duel_requested.emit(result.opponent_id)
		return result

	if next_node_id == null or (next_node_id is String and (next_node_id as String).is_empty()):
		result.result = "scene_end"
		current_node = {}
		current_node_id = ""
		scene_ended.emit(scene_id)
		return result

	current_node_id = str(next_node_id)
	_present_current()
	return result

func visible_choices() -> Array:
	var raw: Array = current_node.get("choices", [])
	var out: Array = []
	for choice in raw:
		if _conditions_met(choice.get("conditions", {})):
			out.append(choice)
	return out

func _present_current() -> void:
	var tree: Dictionary = Content.dialogue_tree(tree_id)
	var nodes: Dictionary = tree.get("nodes", {})
	current_node = nodes.get(current_node_id, {})
	if current_node.is_empty():
		push_warning("Dialogue tree '%s' missing node '%s'." % [tree_id, current_node_id])
		scene_ended.emit(scene_id)
		return
	node_presented.emit(current_node)

func _conditions_met(conditions: Dictionary) -> bool:
	var min_disp: float = float(conditions.get("minDisposition", -999.0))
	if GameState.get_disposition(npc_id) < min_disp:
		return false
	var completed: Array = conditions.get("completedScenes", [])
	for scene_id_req in completed:
		if not GameState.is_scene_completed(scene_id_req):
			return false
	var reveal_reqs: Array = conditions.get("reveals", [])
	for tag in reveal_reqs:
		if not _session_reveals.has(tag) and not _is_lore_revealed(tag):
			return false
	return true

func _is_lore_revealed(tag: String) -> bool:
	for entry in Content.lore_entries_by_reveal(tag):
		if GameState.unlocked_lore.has(entry.get("id", "")):
			return true
	return false

func _unlock_lore_for_reveal(reveal_tag: String) -> void:
	var matched := false
	for entry in Content.lore_entries_by_reveal(reveal_tag):
		var entry_id: String = entry.get("id", "")
		if not entry_id.is_empty():
			GameState.unlock_lore(entry_id)
			EventBus.emit_journal_updated(entry_id)
			matched = true
	if not matched:
		EventBus.emit_journal_updated("reveal:%s" % reveal_tag)

