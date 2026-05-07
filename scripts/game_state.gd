extends Node

const STILL_STAGE_COUNT: int = 5

var selected_character_id: String = "Rin"
var selected_still_id: String = "rin_normal_001"
var selected_stage_index: int = 0
var collection_focus_still_id: String = "rin_normal_001"

var characters: Dictionary = {
	"Rin": {
		"name": "Rin",
		"display_name": "Rin",
		"portrait_path": "res://assets/ui/characters/portraits/Rin_portrait.webp",
		"frame_path": "res://assets/ui/characters/frames/frame_01_blue.png",
		"effect_path": "res://assets/ui/characters/effects/portrait_effect_01_blue.png",
		"description": "Fragments of a bright memory sealed beyond the mirror."
	},
	"Moka": {
		"name": "Moka",
		"display_name": "Moka",
		"portrait_path": "res://assets/ui/characters/portraits/Moka_portrait.webp",
		"frame_path": "res://assets/ui/characters/frames/frame_06_purple.png",
		"effect_path": "res://assets/ui/characters/effects/portrait_effect_06_purple.png",
		"description": "A quiet record waiting inside the archive."
	},
	"Kaede": {
		"name": "Kaede",
		"display_name": "Kaede",
		"portrait_path": "res://assets/ui/characters/portraits/Kaede_portrait.webp",
		"frame_path": "res://assets/ui/characters/frames/frame_04_green.png",
		"effect_path": "res://assets/ui/characters/effects/portrait_effect_04_green.png",
		"description": "A newly opened record waiting to be restored."
	}
}

var stills: Dictionary = {}

func _ready() -> void:
	_build_stills()
	SaveManager.load_game()

func _build_stills() -> void:
	stills.clear()
	_add_still_series("Rin", "normal", 5)
	_add_still_series("Rin", "swimsuit", 5)
	_add_still_series("Rin", "halloween", 5)
	_add_still_series("Moka", "normal", 5)
	_add_still_series("Moka", "swimsuit", 5)
	_add_still_series("Kaede", "normal", 5)
	_add_still_series("Kaede", "swimsuit", 5)

func _add_still_series(character: String, situation: String, count: int) -> void:
	var index: int = 1
	while index <= count:
		var number_text: String = "%03d" % index
		var still_id: String = "%s_%s_%s" % [character.to_lower(), situation, number_text]
		stills[still_id] = {
			"character": character,
			"situation": situation,
			"title": "%s %s %s" % [character, situation, number_text],
			"image_path": "res://assets/stills/%s/%s/%s_%s_%s.webp" % [character, situation, character, situation, number_text],
			"unlocked_stages": 0,
			"stage_ranks": {},
			"total_stages": STILL_STAGE_COUNT
		}
		index += 1

func get_character_ids() -> Array:
	return characters.keys()

func get_character_data(character_id: String) -> Dictionary:
	return characters.get(character_id, {})

func select_character(character_id: String) -> void:
	if not characters.has(character_id):
		return
	selected_character_id = character_id
	var ids: Array = get_still_ids_for_character(character_id)
	if not ids.is_empty():
		selected_still_id = str(ids[0])
		collection_focus_still_id = selected_still_id

func get_still_data(still_id: String) -> Dictionary:
	return stills.get(still_id, {})

func get_all_still_ids() -> Array:
	return stills.keys()

func get_still_ids_for_character(character_id: String) -> Array:
	var result: Array = []
	var ids: Array = get_all_still_ids()
	var i: int = 0
	while i < ids.size():
		var still_id: String = str(ids[i])
		var data: Dictionary = get_still_data(still_id)
		if str(data.get("character", "")) == character_id:
			result.append(still_id)
		i += 1
	return result

func get_unlock_percent(still_id: String) -> int:
	var data: Dictionary = get_still_data(still_id)
	if data.is_empty():
		return 0
	var unlocked_stages: int = int(data.get("unlocked_stages", 0))
	var total_stages: int = int(data.get("total_stages", STILL_STAGE_COUNT))
	return int(float(unlocked_stages) / float(total_stages) * 100.0)

func is_still_complete(still_id: String) -> bool:
	var data: Dictionary = get_still_data(still_id)
	if data.is_empty():
		return false
	return int(data.get("unlocked_stages", 0)) >= int(data.get("total_stages", STILL_STAGE_COUNT))

func set_collection_focus(still_id: String) -> void:
	if stills.has(still_id):
		collection_focus_still_id = still_id
		var data: Dictionary = get_still_data(still_id)
		var character: String = str(data.get("character", selected_character_id))
		if characters.has(character):
			selected_character_id = character

func clear_selected_stage() -> void:
	unlock_stage(selected_still_id, selected_stage_index)
	set_collection_focus(selected_still_id)

func clear_selected_stage_with_rank(rank: String) -> void:
	unlock_stage_with_rank(selected_still_id, selected_stage_index, rank)
	set_collection_focus(selected_still_id)

func unlock_stage(still_id: String, stage_index: int) -> void:
	unlock_stage_with_rank(still_id, stage_index, "")

func unlock_stage_with_rank(still_id: String, stage_index: int, rank: String) -> void:
	if not stills.has(still_id):
		return
	var data: Dictionary = stills[still_id]
	var current: int = int(data.get("unlocked_stages", 0))
	var next_value: int = max(current, stage_index + 1)
	data["unlocked_stages"] = clamp(next_value, 0, int(data.get("total_stages", STILL_STAGE_COUNT)))
	if not rank.is_empty():
		var stage_ranks: Dictionary = data.get("stage_ranks", {})
		var key: String = str(stage_index)
		var previous_rank: String = str(stage_ranks.get(key, ""))
		stage_ranks[key] = _better_rank(previous_rank, rank)
		data["stage_ranks"] = stage_ranks
	stills[still_id] = data
	SaveManager.save_game()

func get_stage_rank(still_id: String, stage_index: int) -> String:
	var data: Dictionary = get_still_data(still_id)
	if data.is_empty():
		return ""
	var stage_ranks: Dictionary = data.get("stage_ranks", {})
	return str(stage_ranks.get(str(stage_index), ""))

func _better_rank(old_rank: String, new_rank: String) -> String:
	if old_rank.is_empty():
		return new_rank
	if _rank_value(new_rank) > _rank_value(old_rank):
		return new_rank
	return old_rank

func _rank_value(rank: String) -> int:
	match rank:
		"S":
			return 4
		"A":
			return 3
		"B":
			return 2
		"C":
			return 1
		_:
			return 0

func select_stage(still_id: String, stage_index: int) -> void:
	selected_still_id = still_id
	selected_stage_index = stage_index
	set_collection_focus(still_id)
