extends Control

@onready var progress_label: Label = %ProgressLabel

func _ready() -> void:
	_update_progress()

func _update_progress() -> void:
	progress_label.text = "First Memory: %d%% restored" % GameState.get_unlock_percent("rin_001")

func _on_stage_1_pressed() -> void:
	_start_stage(0)

func _on_stage_2_pressed() -> void:
	_start_stage(1)

func _on_stage_3_pressed() -> void:
	_start_stage(2)

func _on_stage_4_pressed() -> void:
	_start_stage(3)

func _start_stage(stage_index: int) -> void:
	GameState.select_stage("rin_001", stage_index)
	get_tree().change_scene_to_file("res://scenes/puzzle/puzzle.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")
