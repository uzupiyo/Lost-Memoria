extends "res://scripts/puzzle_sd_panel_polish.gd"

const UI_COLOR_KAEDE_GREEN: Color = Color(0.55, 1.0, 0.60, 1.0)

func _character_accent_color(character_id: String) -> Color:
	match character_id:
		"Rin":
			return UI_COLOR_RESTORATION_GOLD
		"Moka":
			return UI_COLOR_FRAGMENT_PINK
		"Kaede":
			return UI_COLOR_KAEDE_GREEN
		_:
			return UI_COLOR_DREAM_VIOLET
