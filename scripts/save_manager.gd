extends Node

const SAVE_PATH := "user://lost_memoria_save.json"

func save_game() -> void:
	var progress := {}
	for still_id in GameState.stills.keys():
		var data: Dictionary = GameState.stills[still_id]
		progress[still_id] = int(data.get("unlocked_stages", 0))
	var save_data := {
		"version": 1,
		"progress": progress
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
	var progress = parsed.get("progress", {})
	if typeof(progress) != TYPE_DICTIONARY:
		# Backward compatibility for earlier prototype saves.
		progress = _convert_legacy_still_save(parsed.get("stills", {}))
	if typeof(progress) == TYPE_DICTIONARY:
		for still_id in progress.keys():
			if GameState.stills.has(still_id):
				var current: Dictionary = GameState.stills[still_id]
				var total := int(current.get("total_stages", GameState.STILL_STAGE_COUNT))
				current["unlocked_stages"] = clamp(int(progress[still_id]), 0, total)
				GameState.stills[still_id] = current

func _convert_legacy_still_save(saved_stills) -> Dictionary:
	var progress := {}
	if typeof(saved_stills) != TYPE_DICTIONARY:
		return progress
	for still_id in saved_stills.keys():
		var saved = saved_stills[still_id]
		if typeof(saved) == TYPE_DICTIONARY:
			progress[still_id] = int(saved.get("unlocked_stages", 0))
	return progress

func reset_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	for still_id in GameState.stills.keys():
		var data: Dictionary = GameState.stills[still_id]
		data["unlocked_stages"] = 0
		GameState.stills[still_id] = data
