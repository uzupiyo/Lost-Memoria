extends Control

@onready var still_list: VBoxContainer = %StillList
@onready var title_label: Label = %TitleLabel
@onready var hint_label: Label = %HintLabel

func _ready() -> void:
	title_label.text = "%s Stage Select" % GameState.selected_character_id
	hint_label.text = "Clear stages to restore %s's memories. Best ranks are saved per stage." % GameState.selected_character_id
	_build_stage_list()

func _build_stage_list() -> void:
	var child_index: int = still_list.get_child_count() - 1
	while child_index >= 0:
		var child: Node = still_list.get_child(child_index)
		child.queue_free()
		child_index -= 1

	var still_ids: Array = GameState.get_still_ids_for_character(GameState.selected_character_id)
	var still_index: int = 0
	while still_index < still_ids.size():
		var still_id: String = str(still_ids[still_index])
		var data: Dictionary = GameState.get_still_data(still_id)
		var title: String = str(data.get("title", still_id))
		var percent: int = GameState.get_unlock_percent(still_id)

		var panel: PanelContainer = PanelContainer.new()
		panel.custom_minimum_size = Vector2(0, 132)
		still_list.add_child(panel)

		var row: VBoxContainer = VBoxContainer.new()
		panel.add_child(row)

		var label: Label = Label.new()
		label.text = "%s - %d%% restored" % [title, percent]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(label)

		var unlock_label: Label = Label.new()
		unlock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(unlock_label)

		var button_row: HBoxContainer = HBoxContainer.new()
		button_row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_child(button_row)

		var total_stages: int = int(data.get("total_stages", GameState.STILL_STAGE_COUNT))
		var unlocked_stages: int = int(data.get("unlocked_stages", 0))
		if unlocked_stages >= total_stages:
			unlock_label.text = "COMPLETE - Full memory unlocked"
		else:
			unlock_label.text = "Next unlock: Stage %d" % (unlocked_stages + 1)
		var stage_index: int = 0
		while stage_index < total_stages:
			var button: Button = Button.new()
			button.text = _stage_button_text(still_id, stage_index, unlocked_stages)
			button.disabled = stage_index > unlocked_stages
			button.pressed.connect(_start_stage.bind(still_id, stage_index))
			button_row.add_child(button)
			stage_index += 1
		still_index += 1

func _stage_button_text(still_id: String, stage_index: int, unlocked_stages: int) -> String:
	var rank: String = GameState.get_stage_rank(still_id, stage_index)
	if stage_index < unlocked_stages:
		if rank.is_empty():
			return "Stage %d ✓" % (stage_index + 1)
		return "Stage %d ✓ %s" % [stage_index + 1, rank]
	if stage_index == unlocked_stages:
		return "Stage %d ▶" % (stage_index + 1)
	return "Stage %d 🔒" % (stage_index + 1)

func _start_stage(still_id: String, stage_index: int) -> void:
	GameState.select_stage(still_id, stage_index)
	get_tree().change_scene_to_file("res://scenes/puzzle/puzzle.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_select/character_select.tscn")
