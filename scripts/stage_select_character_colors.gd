extends "res://scripts/stage_select.gd"

const UI_COLOR_KAEDE_GREEN: Color = Color(0.55, 1.0, 0.60, 1.0)

func _character_accent_color(character_id: String) -> Color:
	match character_id:
		"Rin":
			return UI_COLOR_RESTORATION_GOLD
		"Moka":
			return Color(1.0, 0.62, 0.86, 1.0)
		"Kaede":
			return UI_COLOR_KAEDE_GREEN
		_:
			return UI_COLOR_DREAM_VIOLET
