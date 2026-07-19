extends Node
## Headless smoke-test suite for the Godot simulation.
## Run from the editor or via:
##   godot --headless --path . --script res://scripts/tests/simulation_tests.gd

var _passed := 0
var _failed := 0

func _ready() -> void:
	print("=== Chimera Godot Simulation Tests ===")
	_test_new_game_initializes()
	_test_travel_unlocks_node()
	_test_disposition_feedback()
	_test_party_management()
	_test_duel_resolution()
	_test_scene_completion_unlocks_gates()
	print("=== Results: %d passed, %d failed ===" % [_passed, _failed])
	get_tree().quit(_failed)

func _assert(condition: bool, name: String) -> void:
	if condition:
		_passed += 1
		print("  OK   %s" % name)
	else:
		_failed += 1
		push_error("  FAIL %s" % name)

func _test_new_game_initializes() -> void:
	print("Test: new game initializes")
	GameState.new_game()
	_assert(GameState.current_phase == GameState.Phase.OVERWORLD, "phase is overworld")
	_assert(GameState.current_act == 1, "act is 1")
	_assert(GameState.current_node_id == "hollow_gate", "starts at hollow_gate")

func _test_travel_unlocks_node() -> void:
	print("Test: travel unlocks connected node")
	GameState.new_game()
	Simulation.travel_to("outer_ruins")
	_assert(GameState.current_node_id == "outer_ruins", "current node updated")
	_assert(GameState.is_node_unlocked("outer_ruins"), "outer_ruins unlocked")

func _test_disposition_feedback() -> void:
	print("Test: dialogue choice affects disposition")
	GameState.new_game()
	var before := GameState.get_disposition("warden")
	Simulation.apply_dialogue_choice("warden", "empathize")
	var after := GameState.get_disposition("warden")
	_assert(after > before, "empathize raises warden disposition")

func _test_party_management() -> void:
	print("Test: party add/remove")
	GameState.new_game()
	GameState.add_to_party("aria")
	_assert(GameState.party.has("aria"), "aria in party")
	GameState.party.erase("aria")
	_assert(not GameState.party.has("aria"), "aria removed")

func _test_duel_resolution() -> void:
	print("Test: duel returns a winner")
	var result: Dictionary = Simulation.resolve_duel("warden", "aria")
	_assert(result.has("winner_id"), "duel result has winner_id")
	_assert(result["winner_id"] is String, "winner_id is string")

func _test_scene_completion_unlocks_gates() -> void:
	print("Test: scene completion unlocks deep hollow gate")
	GameState.new_game()
	Simulation.travel_to("hollow_gate")
	Simulation.apply_dialogue_choice("warden", "empathize")
	Simulation.apply_dialogue_choice("warden", "empathize")
	Simulation.apply_dialogue_choice("warden", "empathize")
	Simulation.apply_dialogue_choice("warden", "empathize")
	Simulation.end_scene("prologue_scene_1")
	_assert(GameState.is_scene_completed("prologue_scene_1"), "prologue completed")
	_assert(GameState.is_node_unlocked("deep_hollow"), "deep_hollow unlocked by disposition+scene")
