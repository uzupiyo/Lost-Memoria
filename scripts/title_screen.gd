extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/stage_select/stage_select.tscn")

func _on_collection_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/collection/collection.tscn")
