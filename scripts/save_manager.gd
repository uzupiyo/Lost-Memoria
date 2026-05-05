extends Node

const SAVE_PATH := "user://lost_memoria_save.json"

func save_game() -> void:
	var save_data := {
		"stills": GameState.stills
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not open save file for writing.")
		return
	file.store_string(JSON.stringify(save_data, "\t"))

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Could not open save file for reading.")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Save data was invalid.")
		return
	var saved_stills = parsed.get("stills", {})
	if typeof(saved_stills) == TYPE_DICTIONARY:
		for still_id in saved_stills.keys():
			if GameState.stills.has(still_id):
				var current: Dictionary = GameState.stills[still_id]
				var saved: Dictionary = saved_stills[still_id]
				current["unlocked_stages"] = int(saved.get("unlocked_stages", current.get("unlocked_stages", 0)))
				GameState.stills[still_id] = current

func reset_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	for still_id in GameState.stills.keys():
		GameState.stills[still_id]["unlocked_stages"] = 0
