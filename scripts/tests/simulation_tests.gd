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
	_test_save_slot_roundtrip()
	_test_seeded_determinism()
	_test_delayed_disposition_turn_counter()
	_test_data_integrity()
	_test_grant_item_helper()
	_test_lore_reveal_at_scene()
	_test_duel_round_trip_payload()
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
	var before: float = GameState.get_disposition("warden")
	Simulation.apply_dialogue_choice("warden", "empathize")
	var after: float = GameState.get_disposition("warden")
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

func _test_save_slot_roundtrip() -> void:
	print("Test: save slot roundtrip")
	GameState.new_game()
	GameState.add_to_party("aria")
	GameState.adjust_disposition("warden", 0.25)
	GameState.add_inventory("purified_coral", 3)
	GameState.rng_seed = 12345
	GameState.add_pending_disposition("warden", -0.05, 2)
	GameState.save_game("test")

	GameState.new_game()
	var loaded: bool = GameState.load_game("test")
	_assert(loaded, "test slot loads")
	_assert(GameState.party.has("aria"), "party persists")
	_assert(absf(GameState.get_disposition("warden") - 0.25) < 0.001, "disposition persists")
	_assert(int(GameState.inventory.get("purified_coral", 0)) == 3, "inventory persists")
	_assert(GameState.rng_seed == 12345, "rng_seed persists")
	_assert(GameState.pending_dispositions.has("2"), "pending_dispositions persist")
	# Cleanup.
	var dir := DirAccess.open("user://")
	if dir:
		dir.remove("save_test.json")

func _test_seeded_determinism() -> void:
	print("Test: seeded duel determinism")
	GameState.new_game()
	Simulation.set_rng_seed(777)
	Simulation.start_duel("warden")
	var result_a: Dictionary = Simulation.duel_round("strike", "defend")
	var winner_a: String = Simulation.get_duel_winner()

	GameState.new_game()
	Simulation.set_rng_seed(777)
	Simulation.start_duel("warden")
	var result_b: Dictionary = Simulation.duel_round("strike", "defend")
	var winner_b: String = Simulation.get_duel_winner()

	_assert(result_a.get("log", "") == result_b.get("log", ""), "first turn log matches")
	_assert(result_a.get("player_resolve", -1) == result_b.get("player_resolve", -2), "player resolve matches")
	_assert(winner_a == winner_b, "winner state matches")

func _test_delayed_disposition_turn_counter() -> void:
	print("Test: delayed disposition uses turn counters")
	GameState.new_game()
	GameState.add_pending_disposition("warden", -0.1, 2)
	var before: float = GameState.get_disposition("warden")
	GameState.consume_pending_dispositions()
	var mid: float = GameState.get_disposition("warden")
	GameState.consume_pending_dispositions()
	var after: float = GameState.get_disposition("warden")
	_assert(mid == before, "disposition unchanged after first turn")
	_assert(after < before - 0.05, "disposition applied after second turn")

func _test_data_integrity() -> void:
	print("Test: data integrity -- all referenced ids resolve")
	var item_ids := {}
	for item in Content.items():
		item_ids[item.get("id", "")] = true

	var recipe_count := 0
	for recipe in Content.recipes():
		recipe_count += 1
		var result_id: String = recipe.get("resultItemId", "")
		# Result id is intentionally also an item id.
		_assert(item_ids.has(result_id), "recipe result '%s' exists in items" % result_id)
		var raw: Variant = recipe.get("ingredientsJson", "")
		var ingredients: Array = []
		if raw is String and not (raw as String).is_empty():
			var parsed: Variant = JSON.parse_string(raw as String)
			if parsed is Array:
				ingredients = parsed
		elif raw is Array:
			ingredients = raw
		for ingredient in ingredients:
			var ing_id: String = ingredient.get("itemId", "")
			_assert(item_ids.has(ing_id), "recipe ingredient '%s' exists in items" % ing_id)
	_assert(recipe_count > 0, "at least one recipe loaded")

func _test_grant_item_helper() -> void:
	print("Test: Simulation.grant_item helper")
	GameState.new_game()
	Simulation.grant_item("memory_dust", 2)
	_assert(int(GameState.inventory.get("memory_dust", 0)) == 2, "grant_item adds correct amount")
	Simulation.grant_item("memory_dust", 1)
	_assert(int(GameState.inventory.get("memory_dust", 0)) == 3, "grant_item stacks")

func _test_lore_reveal_at_scene() -> void:
	print("Test: lore reveal at scene entry")
	GameState.new_game()
	var scene_id := "prologue_scene_1"
	var expected_entry := "lore_the_dug_city"
	if GameState.unlocked_lore.has(expected_entry):
		GameState.unlocked_lore.erase(expected_entry)
	Simulation.reveal_lore_at_scene(scene_id)
	_assert(GameState.unlocked_lore.has(expected_entry), "scene entry unlocks lore_the_dug_city")

func _test_duel_round_trip_payload() -> void:
	print("Test: dialogue combat return payload")
	GameState.new_game()
	var payload: Dictionary = {
		"opponent_id": "warden",
		"return_screen": "res://scenes/screens/dialogue_screen.tscn",
		"return_payload": {"npc_id": "warden", "scene_id": "prologue_scene_1"},
	}
	SceneSwitcher.pending_payload = payload
	var return_screen: String = SceneSwitcher.pending_payload.get("return_screen", "")
	var return_payload: Dictionary = SceneSwitcher.pending_payload.get("return_payload", {})
	_assert(return_screen == "res://scenes/screens/dialogue_screen.tscn", "return_screen stored")
	_assert(return_payload.get("scene_id", "") == "prologue_scene_1", "return_payload stored scene_id")
