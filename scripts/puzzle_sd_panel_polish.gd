extends "res://scripts/puzzle_hud_polish.gd"

var sd_idle_tween: Tween = null
var message_tween: Tween = null

func _ready() -> void:
	super._ready()
	_setup_sd_panel_polish()
	_play_sd_idle()

func _setup_stage_info() -> void:
	super._setup_stage_info()
	_setup_sd_panel_polish()

func _setup_sd_panel_polish() -> void:
	var accent: Color = _character_accent_color(character_name_label.text)
	_apply_panel_style("MarginContainer/Root/MainRow/CharacterPanel", accent)
	_setup_sd_message_style(accent)
	_setup_sd_frame_glow(accent)

func _setup_sd_message_style(accent: Color) -> void:
	sd_message_label.add_theme_font_size_override("font_size", 19)
	sd_message_label.add_theme_color_override("font_color", UI_COLOR_MEMORY_WHITE)
	sd_message_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	sd_message_label.add_theme_constant_override("outline_size", 4)
	sd_message_label.add_theme_stylebox_override("normal", _make_message_bubble_style(accent))
	sd_message_label.pivot_offset = sd_message_label.size * 0.5

func _setup_sd_frame_glow(accent: Color) -> void:
	var sd_frame_stack: Control = get_node_or_null("MarginContainer/Root/MainRow/CharacterPanel/CharacterBox/SdFrameStack") as Control
	if sd_frame_stack == null:
		return
	var existing: Node = sd_frame_stack.get_node_or_null("SdAccentGlow")
	if existing == null:
		var glow: ColorRect = ColorRect.new()
		glow.name = "SdAccentGlow"
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glow.set_anchors_preset(Control.PRESET_FULL_RECT)
		glow.color = Color(accent.r, accent.g, accent.b, 0.08)
		sd_frame_stack.add_child(glow)
		sd_frame_stack.move_child(glow, 0)
	else:
		var glow_rect: ColorRect = existing as ColorRect
		if glow_rect != null:
			glow_rect.color = Color(accent.r, accent.g, accent.b, 0.08)

func _make_message_bubble_style(accent: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.13, 0.82)
	style.border_color = Color(accent.r, accent.g, accent.b, 0.50)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.shadow_color = Color(0, 0, 0, 0.32)
	style.shadow_size = 7
	style.shadow_offset = Vector2(0, 3)
	return style

func _play_sd_idle() -> void:
	var sd_character: TextureRect = get_node_or_null("MarginContainer/Root/MainRow/CharacterPanel/CharacterBox/SdFrameStack/SdCharacter") as TextureRect
	if sd_character == null:
		return
	if sd_idle_tween != null:
		sd_idle_tween.kill()
	sd_character.pivot_offset = sd_character.size * 0.5
	var original_position: Vector2 = sd_character.position
	sd_idle_tween = create_tween()
	sd_idle_tween.set_loops()
	sd_idle_tween.set_parallel(true)
	sd_idle_tween.tween_property(sd_character, "position", original_position + Vector2(0, -7), 1.05)
	sd_idle_tween.tween_property(sd_character, "rotation_degrees", 1.2, 1.05)
	sd_idle_tween.set_parallel(false)
	sd_idle_tween.set_parallel(true)
	sd_idle_tween.tween_property(sd_character, "position", original_position, 1.05)
	sd_idle_tween.tween_property(sd_character, "rotation_degrees", -1.0, 1.05)

func _update_ui() -> void:
	super._update_ui()
	_play_message_feedback_when_low_moves()

func _play_message_feedback_when_low_moves() -> void:
	if moves > max(3, int(float(stage_move_limit) * 0.20)):
		return
	if message_tween != null:
		return
	sd_message_label.pivot_offset = sd_message_label.size * 0.5
	message_tween = create_tween()
	message_tween.tween_property(sd_message_label, "scale", Vector2(1.035, 1.035), 0.10)
	message_tween.tween_property(sd_message_label, "scale", Vector2.ONE, 0.14)
	message_tween.tween_interval(0.60)
	message_tween.tween_callback(_on_message_feedback_finished)

func _on_message_feedback_finished() -> void:
	message_tween = null

func _clear_stage() -> void:
	_stop_sd_idle_for_clear()
	super._clear_stage()

func _on_retry_pressed() -> void:
	if sd_idle_tween != null:
		sd_idle_tween.kill()
		sd_idle_tween = null
	super._on_retry_pressed()
	_play_sd_idle()

func _stop_sd_idle_for_clear() -> void:
	if sd_idle_tween != null:
		sd_idle_tween.kill()
		sd_idle_tween = null
	var sd_character: TextureRect = get_node_or_null("MarginContainer/Root/MainRow/CharacterPanel/CharacterBox/SdFrameStack/SdCharacter") as TextureRect
	if sd_character != null:
		sd_character.rotation_degrees = 0
