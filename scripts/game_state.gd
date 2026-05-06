extends Node

const STILL_STAGE_COUNT: int = 5

var selected_still_id: String = "rin_swimsuit_001"
var selected_stage_index: int = 0

var stills: Dictionary = {
	"rin_swimsuit_001": {
		"character": "Rin",
		"situation": "水着",
		"title": "Rin 水着 001",
		"image_path": "res://assets/stills/Rin/水着/Rin001.png",
		"unlocked_stages": 0,
		"total_stages": STILL_STAGE_COUNT
	},
	"rin_swimsuit_002": {
		"character": "Rin",
		"situation": "水着",
		"title": "Rin 水着 002",
		"image_path": "res://assets/stills/Rin/水着/Rin002.png",
		"unlocked_stages": 0,
		"total_stages": STILL_STAGE_COUNT
	},
	"rin_swimsuit_003": {
		"character": "Rin",
		"situation": "水着",
		"title": "Rin 水着 003",
		"image_path": "res://assets/stills/Rin/水着/Rin003.png",
		"unlocked_stages": 0,
		"total_stages": STILL_STAGE_COUNT
	},
	"rin_swimsuit_004": {
		"character": "Rin",
		"situation": "水着",
		"title": "Rin 水着 004",
		"image_path": "res://assets/stills/Rin/水着/Rin004.png",
		"unlocked_stages": 0,
		"total_stages": STILL_STAGE_COUNT
	},
	"rin_swimsuit_005": {
		"character": "Rin",
		"situation": "水着",
		"title": "Rin 水着 005",
		"image_path": "res://assets/stills/Rin/水着/Rin005.png",
		"unlocked_stages": 0,
		"total_stages": STILL_STAGE_COUNT
	},
	"rin_halloween_001": {
		"character": "Rin",
		"situation": "ハロウィン",
		"title": "Rin ハロウィン 001",
		"image_path": "res://assets/stills/Rin/ハロウィン/RinHalloween001.png",
		"unlocked_stages": 0,
		"total_stages": STILL_STAGE_COUNT
	},
	"moka_normal_001": {
		"character": "Moka",
		"situation": "通常",
		"title": "Moka 通常 001",
		"image_path": "res://assets/stills/Moka/通常/Moka001.png",
		"unlocked_stages": 0,
		"total_stages": STILL_STAGE_COUNT
	},
	"moka_swimsuit_001": {
		"character": "Moka",
		"situation": "水着",
		"title": "Moka 水着 001",
		"image_path": "res://assets/stills/Moka/水着/MokaSwimsuit001.png",
		"unlocked_stages": 0,
		"total_stages": STILL_STAGE_COUNT
	}
}

func _ready() -> void:
	SaveManager.load_game()

func get_still_data(still_id: String) -> Dictionary:
	return stills.get(still_id, {})

func get_all_still_ids() -> Array:
	return stills.keys()

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

func clear_selected_stage() -> void:
	unlock_stage(selected_still_id, selected_stage_index)

func unlock_stage(still_id: String, stage_index: int) -> void:
	if not stills.has(still_id):
		return
	var data: Dictionary = stills[still_id]
	var current: int = int(data.get("unlocked_stages", 0))
	var next_value: int = max(current, stage_index + 1)
	data["unlocked_stages"] = clamp(next_value, 0, int(data.get("total_stages", STILL_STAGE_COUNT)))
	stills[still_id] = data
	SaveManager.save_game()

func select_stage(still_id: String, stage_index: int) -> void:
	selected_still_id = still_id
	selected_stage_index = stage_index
