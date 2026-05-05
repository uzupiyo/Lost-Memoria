extends Control

@onready var title_label: Label = %StillTitle
@onready var progress_label: Label = %ProgressLabel
@onready var status_label: Label = %StatusLabel

func _ready() -> void:
	var data := GameState.get_still_data("rin_001")
	title_label.text = str(data.get("title", "Unknown Memory"))
	var percent := GameState.get_unlock_percent("rin_001")
	progress_label.text = "Restoration: %d%%" % percent
	if GameState.is_still_complete("rin_001"):
		status_label.text = "Unlocked"
	else:
		status_label.text = "Locked / In Progress"

func _on_stage_select_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/stage_select/stage_select.tscn")

func _on_title_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")
