extends Control

@onready var still_list: VBoxContainer = %StillList

func _ready() -> void:
	_build_stage_list()

func _build_stage_list() -> void:
	for child in still_list.get_children():
		child.queue_free()
	for still_id in GameState.get_all_still_ids():
		var data := GameState.get_still_data(still_id)
		var title := str(data.get("title", still_id))
		var percent := GameState.get_unlock_percent(still_id)

		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(0, 96)
		still_list.add_child(panel)

		var row := VBoxContainer.new()
		panel.add_child(row)

		var label := Label.new()
		label.text = "%s - %d%% restored" % [title, percent]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(label)

		var button_row := HBoxContainer.new()
		button_row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_child(button_row)

		var total_stages := int(data.get("total_stages", GameState.STILL_STAGE_COUNT))
		for stage_index in total_stages:
			var button := Button.new()
			button.text = "Stage %d" % (stage_index + 1)
			button.disabled = stage_index > int(data.get("unlocked_stages", 0))
			button.pressed.connect(_start_stage.bind(still_id, stage_index))
			button_row.add_child(button)

func _start_stage(still_id: String, stage_index: int) -> void:
	GameState.select_stage(still_id, stage_index)
	get_tree().change_scene_to_file("res://scenes/puzzle/puzzle.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")
