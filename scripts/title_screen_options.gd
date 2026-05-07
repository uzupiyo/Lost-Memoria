extends "res://scripts/title_screen.gd"

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options/options.tscn")
