extends Control

var progress_panel: PanelContainer = null

func _ready() -> void:
	_add_global_progress_panel()

func _add_global_progress_panel() -> void:
	_clear_global_progress_panel()
	progress_panel = PanelContainer.new()
	progress_panel.name = "GlobalProgressPanel"
	progress_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	progress_panel.offset_left = -560.0
	progress_panel.offset_top = 540.0
	progress_panel.offset_right = -70.0
	progress_panel.offset_bottom = 790.0
	add_child(progress_panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 8)
	progress_panel.add_child(box)

	var title: Label = Label.new()
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.text = "RESTORATION STATUS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1.0, 0.92, 0.58, 1.0))
	box.add_child(title)

	var body: Label = Label.new()
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.text = _global_progress_text()
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_size_override("font_size", 20)
	body.add_theme_color_override("font_color", Color(0.90, 0.96, 1.0, 1.0))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body)

func _clear_global_progress_panel() -> void:
	var existing: Node = get_node_or_null("GlobalProgressPanel")
	if existing != null:
		existing.queue_free()
	progress_panel = null

func _global_progress_text() -> String:
	var summary: Dictionary = _progress_summary_for_all()
	return "Restored %d%%\nComplete Memories %d/%d\nPerfect Memories %d/%d\n%s" % [
		int(summary.get("percent", 0)),
		int(summary.get("complete_memories", 0)),
		int(summary.get("total_memories", 0)),
		int(summary.get("perfect_memories", 0)),
		int(summary.get("total_memories", 0)),
		_character_progress_line()
	]

func _character_progress_line() -> String:
	var parts: Array[String] = []
	var ids: Array = GameState.get_character_ids()
	var i: int = 0
	while i < ids.size():
		var character_id: String = str(ids[i])
		var summary: Dictionary = _progress_summary_for_character(character_id)
		parts.append("%s %d%%" % [character_id, int(summary.get("percent", 0))])
		i += 1
	return " / ".join(parts)

func _progress_summary_for_all() -> Dictionary:
	return _progress_summary_for_still_ids(GameState.get_all_still_ids())

func _progress_summary_for_character(character_id: String) -> Dictionary:
	return _progress_summary_for_still_ids(GameState.get_still_ids_for_character(character_id))

func _progress_summary_for_still_ids(ids: Array) -> Dictionary:
	var total_memories: int = 0
	var complete_memories: int = 0
	var perfect_memories: int = 0
	var total_stages: int = 0
	var restored_stages: int = 0
	var i: int = 0
	while i < ids.size():
		var still_id: String = str(ids[i])
		var data: Dictionary = GameState.get_still_data(still_id)
		var still_total: int = int(data.get("total_stages", GameState.STILL_STAGE_COUNT))
		var unlocked: int = int(data.get("unlocked_stages", 0))
		total_memories += 1
		total_stages += still_total
		restored_stages += min(unlocked, still_total)
		if unlocked >= still_total:
			complete_memories += 1
			if _is_perfect_memory(still_id, still_total):
				perfect_memories += 1
		i += 1
	var percent: int = 0
	if total_stages > 0:
		percent = int(float(restored_stages) / float(total_stages) * 100.0)
	return {
		"percent": percent,
		"total_memories": total_memories,
		"complete_memories": complete_memories,
		"perfect_memories": perfect_memories
	}

func _is_perfect_memory(still_id: String, total_stages: int) -> bool:
	var stage_index: int = 0
	while stage_index < total_stages:
		if GameState.get_stage_rank(still_id, stage_index) != "S":
			return false
		stage_index += 1
	return true

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_select/character_select.tscn")

func _on_collection_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/collection/collection.tscn")
