extends "res://scripts/puzzle_screen_clear_rank.gd"

const UI_COLOR_BACKGROUND_PANEL: Color = Color(0.063, 0.098, 0.212, 0.88)
const UI_COLOR_PANEL_EDGE: Color = Color(0.56, 0.92, 1.0, 0.32)
const UI_COLOR_MEMORY_WHITE: Color = Color(0.96, 0.98, 1.0, 1.0)
const UI_COLOR_MIST_BLUE: Color = Color(0.75, 0.84, 0.95, 1.0)
const UI_COLOR_RESTORATION_GOLD: Color = Color(1.0, 0.85, 0.42, 1.0)
const UI_COLOR_MIRROR_CYAN: Color = Color(0.51, 0.96, 1.0, 1.0)
const UI_COLOR_FRAGMENT_PINK: Color = Color(1.0, 0.62, 0.86, 1.0)
const UI_COLOR_DREAM_VIOLET: Color = Color(0.72, 0.61, 1.0, 1.0)
const UI_COLOR_LOCKED: Color = Color(0.48, 0.52, 0.62, 1.0)
const UI_COLOR_WARNING: Color = Color(1.0, 0.68, 0.36, 1.0)

var hud_intro_tween: Tween = null
var nav_button_tweens: Dictionary = {}

func _ready() -> void:
	super._ready()
	_setup_puzzle_hud_style()
	_play_hud_intro()

func _setup_stage_info() -> void:
	super._setup_stage_info()
	_refresh_hud_status_colors()

func _update_ui() -> void:
	super._update_ui()
	_refresh_hud_status_colors()

func _setup_puzzle_hud_style() -> void:
	_apply_panel_style("MarginContainer/Root/TopStatusBar", UI_COLOR_MIRROR_CYAN)
	_apply_panel_style("MarginContainer/Root/MainRow/CharacterPanel", _character_accent_color(character_name_label.text))
	_apply_panel_style("MarginContainer/Root/MainRow/BoardPanel", UI_COLOR_MIRROR_CYAN)
	_apply_panel_style("MarginContainer/Root/MainRow/PreviewPanel", UI_COLOR_RESTORATION_GOLD)
	_setup_text_styles()
	_setup_footer_buttons()
	_setup_restore_gauge_style()

func _setup_text_styles() -> void:
	stage_label.add_theme_font_size_override("font_size", 26)
	stage_label.add_theme_color_override("font_color", UI_COLOR_RESTORATION_GOLD)
	stage_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	stage_label.add_theme_constant_override("outline_size", 5)
	_target_status_label_style(target_label, UI_COLOR_MIRROR_CYAN)
	_target_status_label_style(moves_label, UI_COLOR_MIST_BLUE)
	_target_status_label_style(score_label, UI_COLOR_RESTORATION_GOLD)
	character_name_label.add_theme_font_size_override("font_size", 34)
	character_name_label.add_theme_color_override("font_color", _character_accent_color(character_name_label.text))
	character_name_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	character_name_label.add_theme_constant_override("outline_size", 5)
	sd_message_label.add_theme_color_override("font_color", UI_COLOR_MEMORY_WHITE)
	sd_message_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	sd_message_label.add_theme_constant_override("outline_size", 3)
	progress_label.add_theme_color_override("font_color", UI_COLOR_RESTORATION_GOLD)
	progress_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	progress_label.add_theme_constant_override("outline_size", 4)
	var preview_title: Label = get_node_or_null("MarginContainer/Root/MainRow/PreviewPanel/PreviewBox/PreviewTitle") as Label
	if preview_title != null:
		preview_title.add_theme_font_size_override("font_size", 22)
		preview_title.add_theme_color_override("font_color", UI_COLOR_RESTORATION_GOLD)
		preview_title.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
		preview_title.add_theme_constant_override("outline_size", 4)

func _target_status_label_style(label: Label, accent: Color) -> void:
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", accent)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_stylebox_override("normal", _make_status_chip_style(accent, 0.26))

func _refresh_hud_status_colors() -> void:
	var move_color: Color = UI_COLOR_MIST_BLUE
	if moves <= max(3, int(float(stage_move_limit) * 0.20)):
		move_color = UI_COLOR_WARNING
	moves_label.add_theme_color_override("font_color", move_color)
	score_label.add_theme_color_override("font_color", UI_COLOR_RESTORATION_GOLD)
	progress_label.add_theme_color_override("font_color", UI_COLOR_RESTORATION_GOLD)

func _setup_footer_buttons() -> void:
	var button_paths: Array[String] = [
		"MarginContainer/Root/FooterRow/BackButton",
		"MarginContainer/Root/FooterRow/RetryButton",
		"MarginContainer/Root/FooterRow/HintButton"
	]
	for path in button_paths:
		var base_button: BaseButton = get_node_or_null(path) as BaseButton
		if base_button == null:
			continue
		base_button.pivot_offset = base_button.size * 0.5
		if base_button is Button:
			var button: Button = base_button as Button
			button.add_theme_font_size_override("font_size", 20)
			button.add_theme_color_override("font_color", UI_COLOR_MIST_BLUE)
			button.add_theme_color_override("font_hover_color", UI_COLOR_MIRROR_CYAN)
			button.add_theme_color_override("font_pressed_color", UI_COLOR_RESTORATION_GOLD)
			button.add_theme_stylebox_override("normal", _make_nav_button_style(false))
			button.add_theme_stylebox_override("hover", _make_nav_button_style(true))
			button.add_theme_stylebox_override("pressed", _make_nav_button_style(true))
		if not base_button.mouse_entered.is_connected(_on_nav_button_mouse_entered.bind(base_button)):
			base_button.mouse_entered.connect(_on_nav_button_mouse_entered.bind(base_button))
		if not base_button.mouse_exited.is_connected(_on_nav_button_mouse_exited.bind(base_button)):
			base_button.mouse_exited.connect(_on_nav_button_mouse_exited.bind(base_button))

func _setup_restore_gauge_style() -> void:
	restore_gauge.add_theme_stylebox_override("background", _make_gauge_background_style())
	restore_gauge.add_theme_stylebox_override("fill", _make_gauge_fill_style())

func _apply_panel_style(path: String, edge_color: Color) -> void:
	var panel: PanelContainer = get_node_or_null(path) as PanelContainer
	if panel != null:
		panel.add_theme_stylebox_override("panel", _make_panel_style(edge_color))

func _make_panel_style(edge_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = UI_COLOR_BACKGROUND_PANEL
	style.border_color = Color(edge_color.r, edge_color.g, edge_color.b, 0.42)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	style.shadow_color = Color(0, 0, 0, 0.34)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 4)
	return style

func _make_status_chip_style(edge_color: Color, edge_alpha: float) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.13, 0.68)
	style.border_color = Color(edge_color.r, edge_color.g, edge_color.b, edge_alpha)
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style

func _make_nav_button_style(is_hover: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.07, 0.13, 0.84) if not is_hover else Color(0.02, 0.16, 0.22, 0.86)
	style.border_color = Color(UI_COLOR_MIRROR_CYAN.r, UI_COLOR_MIRROR_CYAN.g, UI_COLOR_MIRROR_CYAN.b, 0.42 if not is_hover else 0.78)
	style.set_border_width_all(2)
	style.set_corner_radius_all(16)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.shadow_color = Color(0, 0, 0, 0.25)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0, 3)
	return style

func _make_gauge_background_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.10, 0.88)
	style.border_color = Color(UI_COLOR_MIRROR_CYAN.r, UI_COLOR_MIRROR_CYAN.g, UI_COLOR_MIRROR_CYAN.b, 0.32)
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	return style

func _make_gauge_fill_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = UI_COLOR_RESTORATION_GOLD
	style.set_corner_radius_all(10)
	return style

func _character_accent_color(character_id: String) -> Color:
	match character_id:
		"Rin":
			return UI_COLOR_RESTORATION_GOLD
		"Moka":
			return UI_COLOR_FRAGMENT_PINK
		"Kaede":
			return UI_COLOR_MIRROR_CYAN
		_:
			return UI_COLOR_DREAM_VIOLET

func _play_hud_intro() -> void:
	if hud_intro_tween != null:
		hud_intro_tween.kill()
	var root: Control = get_node_or_null("MarginContainer/Root") as Control
	if root == null:
		return
	var original_position: Vector2 = root.position
	root.modulate = Color(1, 1, 1, 0)
	root.position = original_position + Vector2(0, 10)
	hud_intro_tween = create_tween()
	hud_intro_tween.set_parallel(true)
	hud_intro_tween.tween_property(root, "modulate", Color(1, 1, 1, 1), 0.22)
	hud_intro_tween.tween_property(root, "position", original_position, 0.22)
	hud_intro_tween.set_parallel(false)
	hud_intro_tween.tween_callback(_on_hud_intro_finished)

func _on_hud_intro_finished() -> void:
	hud_intro_tween = null

func _on_nav_button_mouse_entered(button: BaseButton) -> void:
	_tween_nav_button(button, Vector2(1.025, 1.025), 0.10)

func _on_nav_button_mouse_exited(button: BaseButton) -> void:
	_tween_nav_button(button, Vector2.ONE, 0.12)

func _tween_nav_button(button: BaseButton, target_scale: Vector2, duration: float) -> void:
	if nav_button_tweens.has(button):
		var old_tween: Tween = nav_button_tweens[button]
		if old_tween != null:
			old_tween.kill()
	var tween: Tween = create_tween()
	nav_button_tweens[button] = tween
	tween.tween_property(button, "scale", target_scale, duration)
	tween.tween_callback(_on_nav_button_tween_finished.bind(button))

func _on_nav_button_tween_finished(button: BaseButton) -> void:
	nav_button_tweens.erase(button)
