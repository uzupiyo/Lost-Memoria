extends Node

const STILL_STAGE_COUNT := 4

var selected_still_id: String = "rin_001"
var selected_stage_index: int = 0

var stills := {
	"rin_001": {
		"title": "First Memory",
		"image_path": "res://assets/stills/rin/rin_001.svg",
		"unlocked_stages": 0,
		"total_stages": STILL_STAGE_COUNT
	}
}

func _ready() -> void:
	SaveManager.load_game()

func get_still_data(still_id: String) -> Dictionary:
	return stills.get(still_id, {})

func get_unlock_percent(still_id: String) -> int:
	var data := get_still_data(still_id)
	if data.is_empty():
		return 0
	return int(float(data.get("unlocked_stages", 0)) / float(data.get("total_stages", STILL_STAGE_COUNT)) * 100.0)

func is_still_complete(still_id: String) -> bool:
	var data := get_still_data(still_id)
	return not data.is_empty() and int(data.get("unlocked_stages", 0)) >= int(data.get("total_stages", STILL_STAGE_COUNT))

func clear_selected_stage() -> void:
	unlock_stage(selected_still_id, selected_stage_index)

func unlock_stage(still_id: String, stage_index: int) -> void:
	if not stills.has(still_id):
		return
	var data: Dictionary = stills[still_id]
	var current := int(data.get("unlocked_stages", 0))
	var next_value = max(current, stage_index + 1)
	data["unlocked_stages"] = clamp(next_value, 0, int(data.get("total_stages", STILL_STAGE_COUNT)))
	stills[still_id] = data
	SaveManager.save_game()

func select_stage(still_id: String, stage_index: int) -> void:
	selected_still_id = still_id
	selected_stage_index = stage_index
