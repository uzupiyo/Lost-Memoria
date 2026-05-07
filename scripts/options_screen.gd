extends Control

const UI_COLOR_BACKGROUND_PANEL: Color = Color(0.063, 0.098, 0.212, 0.90)
const UI_COLOR_PANEL_EDGE: Color = Color(0.56, 0.92, 1.0, 0.42)
const UI_COLOR_MEMORY_WHITE: Color = Color(0.96, 0.98, 1.0, 1.0)
const UI_COLOR_MIST_BLUE: Color = Color(0.75, 0.84, 0.95, 1.0)
const UI_COLOR_RESTORATION_GOLD: Color = Color(1.0, 0.85, 0.42, 1.0)
const UI_COLOR_MIRROR_CYAN: Color = Color(0.51, 0.96, 1.0, 1.0)
const UI_COLOR_WARNING: Color = Color(1.0, 0.68, 0.36, 1.0)
const UI_COLOR_DANGER: Color = Color(1.0, 0.38, 0.46, 1.0)

@onready var title_label: Label = %TitleLabel
@onready var help_label: Label = %HelpLabel
@onready var reset_confirm_panel: PanelContainer = %ResetConfirmPanel
@onready var reset_message_label: Label = %ResetMessageLabel

var intro_tween: Tween = null
var confirm_tween: Tween = null
var button_tweens: Dictionary = {}

func _ready() -> void:
	_setup_style()
	_show_reset_confirm(false)
	_play_intro()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and key_event.keycode == KEY_ESCAPE:
			if reset_confirm_panel.visible:
				_on_cancel_reset_pressed()
			else:
				_on_back_pressed()

func _setup_style() -> void:
	title_label.add_theme_color_override("font_color", UI_COLOR_RESTORATION_GOLD)
	title_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	title_label.add_theme_constant_override("outline_size", 6)
	help_label.add_theme_color_override("font_color", UI_COLOR_MEMORY_WHITE)
	help_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	help_label.add_theme_constant_override("outline_size", 3)
	reset_message_label.add_theme_color_override("font_color", UI_COLOR_MIST_BLUE)
	reset_message_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	reset_message_label.add_theme_constant_override("outline_size", 3)
	_apply_panel_style("Root/ContentPanel", UI_COLOR_PANEL_EDGE)
	_apply_panel_style("Root/ResetConfirmPanel", UI_COLOR_DANGER)
	_setup_confirm_text_style()
	_setup_buttons()

func _setup_confirm_text_style() -> void:
	var confirm_title: Label = get_node_or_null("Root/ResetConfirmPanel/ConfirmBox/ConfirmTitle") as Label
	var confirm_body: Label = get_node_or_null("Root/ResetConfirmPanel/ConfirmBox/ConfirmBody") as Label
	if confirm_title != null:
		confirm_title.add_theme_color_override("font_color", UI_COLOR_DANGER)
		confirm_title.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
		confirm_title.add_theme_constant_override("outline_size", 5)
	if confirm_body != null:
		confirm_body.add_theme_color_override("font_color", UI_COLOR_MEMORY_WHITE)
		confirm_body.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
		confirm_body.add_theme_constant_override("outline_size", 3)

func _setup_buttons() -> void:
	var button_paths: Array[String] = [
		"Root/ContentPanel/ContentBox/ResetSaveButton",
		"Root/ContentPanel/ContentBox/BackButton",
		"Root/ResetConfirmPanel/ConfirmBox/ConfirmRow/CancelResetButton",
		"Root/ResetConfirmPanel/ConfirmBox/ConfirmRow/ConfirmResetButton"
	]
	for path in button_paths:
		var button: Button = get_node_or_null(path) as Button
		if button != null:
			var is_danger: bool = path.ends_with("ConfirmResetButton") or path.ends_with("ResetSaveButton")
			button.add_theme_font_size_override("font_size", 20)
			button.add_theme_color_override("font_color", UI_COLOR_DANGER if is_danger else UI_COLOR_MIST_BLUE)
			button.add_theme_color_override("font_hover_color", UI_COLOR_DANGER if is_danger else UI_COLOR_MIRROR_CYAN)
			button.add_theme_color_override("font_pressed_color", UI_COLOR_RESTORATION_GOLD)
			button.add_theme_stylebox_override("normal", _make_button_style(false, is_danger))
			button.add_theme_stylebox_override("hover", _make_button_style(true, is_danger))
			button.add_theme_stylebox_override("pressed", _make_button_style(true, is_danger))
			if not button.mouse_entered.is_connected(_on_button_mouse_entered.bind(button)):
				button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
			if not button.mouse_exited.is_connected(_on_button_mouse_exited.bind(button)):
				button.mouse_exited.connect(_on_button_mouse_exited.bind(button))

func _apply_panel_style(path: String, edge_color: Color) -> void:
	var panel: PanelContainer = get_node_or_null(path) as PanelContainer
	if panel != null:
		panel.add_theme_stylebox_override("panel", _make_panel_style(edge_color))

func _make_panel_style(edge_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = UI_COLOR_BACKGROUND_PANEL
	style.border_color = Color(edge_color.r, edge_color.g, edge_color.b, 0.52)
	style.set_border_width_all(2)
	style.set_corner_radius_all(22)
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 22
	style.content_margin_bottom = 22
	style.shadow_color = Color(0, 0, 0, 0.38)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 4)
	return style

func _make_button_style(is_hover: bool, is_danger: bool) -> StyleBoxFlat:
	var edge: Color = UI_COLOR_DANGER if is_danger else UI_COLOR_MIRROR_CYAN
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.04, 0.06, 0.86) if is_danger else Color(0.05, 0.07, 0.13, 0.84)
	if is_hover:
		style.bg_color = Color(0.18, 0.06, 0.09, 0.88) if is_danger else Color(0.02, 0.16, 0.22, 0.88)
	style.border_color = Color(edge.r, edge.g, edge.b, 0.44 if not is_hover else 0.82)
	style.set_border_width_all(2)
	style.set_corner_radius_all(16)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 9
	style.content_margin_bottom = 9
	return style

func _play_intro() -> void:
	var root: Control = get_node_or_null("Root") as Control
	if root == null:
		return
	var original_position: Vector2 = root.position
	root.modulate = Color(1, 1, 1, 0)
	root.position = original_position + Vector2(0, 12)
	intro_tween = create_tween()
	intro_tween.set_parallel(true)
	intro_tween.tween_property(root, "modulate", Color(1, 1, 1, 1), 0.24)
	intro_tween.tween_property(root, "position", original_position, 0.24)
	intro_tween.set_parallel(false)
	intro_tween.tween_callback(_on_intro_finished)

func _on_intro_finished() -> void:
	intro_tween = null

func _show_reset_confirm(show: bool) -> void:
	if confirm_tween != null:
		confirm_tween.kill()
		confirm_tween = null
	reset_confirm_panel.visible = show
	if show:
		reset_confirm_panel.modulate = Color(1, 1, 1, 0)
		reset_confirm_panel.scale = Vector2(0.98, 0.98)
		confirm_tween = create_tween()
		confirm_tween.set_parallel(true)
		confirm_tween.tween_property(reset_confirm_panel, "modulate", Color(1, 1, 1, 1), 0.16)
		confirm_tween.tween_property(reset_confirm_panel, "scale", Vector2.ONE, 0.16)
		confirm_tween.set_parallel(false)
		confirm_tween.tween_callback(_on_confirm_tween_finished)

func _on_confirm_tween_finished() -> void:
	confirm_tween = null

func _on_reset_save_pressed() -> void:
	reset_message_label.text = "This will delete all restored memories and saved ranks."
	reset_message_label.add_theme_color_override("font_color", UI_COLOR_WARNING)
	_show_reset_confirm(true)

func _on_cancel_reset_pressed() -> void:
	_show_reset_confirm(false)
	reset_message_label.text = "Reset Save deletes restored memories and saved ranks."
	reset_message_label.add_theme_color_override("font_color", UI_COLOR_MIST_BLUE)

func _on_confirm_reset_pressed() -> void:
	SaveManager.reset_save()
	_show_reset_confirm(false)
	reset_message_label.text = "Save data has been reset. Return to Title and start again."
	reset_message_label.add_theme_color_override("font_color", UI_COLOR_RESTORATION_GOLD)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")

func _on_button_mouse_entered(button: Button) -> void:
	_tween_button(button, Vector2(1.025, 1.025), 0.10)

func _on_button_mouse_exited(button: Button) -> void:
	_tween_button(button, Vector2.ONE, 0.12)

func _tween_button(button: Button, target_scale: Vector2, duration: float) -> void:
	if button_tweens.has(button):
		var old_tween: Tween = button_tweens[button]
		if old_tween != null:
			old_tween.kill()
	var tween: Tween = create_tween()
	button_tweens[button] = tween
	tween.tween_property(button, "scale", target_scale, duration)
	tween.tween_callback(_on_button_tween_finished.bind(button))

func _on_button_tween_finished(button: Button) -> void:
	button_tweens.erase(button)
