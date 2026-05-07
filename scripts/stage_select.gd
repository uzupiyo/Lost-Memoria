extends Control

const UI_COLOR_BACKGROUND_PANEL: Color = Color(0.063, 0.098, 0.212, 0.88)
const UI_COLOR_PANEL_EDGE: Color = Color(0.56, 0.92, 1.0, 0.32)
const UI_COLOR_MEMORY_WHITE: Color = Color(0.96, 0.98, 1.0, 1.0)
const UI_COLOR_MIST_BLUE: Color = Color(0.75, 0.84, 0.95, 1.0)
const UI_COLOR_RESTORATION_GOLD: Color = Color(1.0, 0.85, 0.42, 1.0)
const UI_COLOR_MIRROR_CYAN: Color = Color(0.51, 0.96, 1.0, 1.0)
const UI_COLOR_DREAM_VIOLET: Color = Color(0.72, 0.61, 1.0, 1.0)
const UI_COLOR_LOCKED: Color = Color(0.48, 0.52, 0.62, 1.0)

@onready var still_list: VBoxContainer = %StillList
@onready var title_label: Label = %TitleLabel
@onready var hint_label: Label = %HintLabel

var panel_intro_tween: Tween = null
var header_intro_tween: Tween = null
var back_button_tween: Tween = null

func _ready() -> void:
	_setup_header_text()
	_setup_header_and_back_style()
	_build_stage_list()
	_play_header_intro()
	_play_panel_intro()

func _setup_header_text() -> void:
	title_label.text = "%s Stage Select" % GameState.selected_character_id
	title_label.add_theme_color_override("font_color", _character_accent_color(GameState.selected_character_id))
	title_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	title_label.add_theme_constant_override("outline_size", 5)
	hint_label.text = "Clear stages to restore %s's memories. Best ranks are saved per stage." % GameState.selected_character_id
	hint_label.add_theme_color_override("font_color", UI_COLOR_MIST_BLUE)
	hint_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	hint_label.add_theme_constant_override("outline_size", 3)

func _setup_header_and_back_style() -> void:
	title_label.add_theme_stylebox_override("normal", _make_label_card_style(_character_accent_color(GameState.selected_character_id), 0.18))
	hint_label.add_theme_stylebox_override("normal", _make_label_card_style(UI_COLOR_MIRROR_CYAN, 0.10))
	var back_button: Button = _get_back_button()
	if back_button != null:
		back_button.custom_minimum_size = Vector2(420, 66)
		back_button.text = "← BACK TO CHARACTER SELECT"
		back_button.add_theme_font_size_override("font_size", 20)
		back_button.add_theme_color_override("font_color", UI_COLOR_MIST_BLUE)
		back_button.add_theme_color_override("font_hover_color", UI_COLOR_MIRROR_CYAN)
		back_button.add_theme_color_override("font_pressed_color", UI_COLOR_RESTORATION_GOLD)
		back_button.add_theme_stylebox_override("normal", _make_nav_button_style(false))
		back_button.add_theme_stylebox_override("hover", _make_nav_button_style(true))
		back_button.add_theme_stylebox_override("pressed", _make_nav_button_style(true))
		back_button.pivot_offset = back_button.size * 0.5
		if not back_button.mouse_entered.is_connected(_on_back_button_mouse_entered):
			back_button.mouse_entered.connect(_on_back_button_mouse_entered)
		if not back_button.mouse_exited.is_connected(_on_back_button_mouse_exited):
			back_button.mouse_exited.connect(_on_back_button_mouse_exited)

func _get_back_button() -> Button:
	return get_node_or_null("MarginContainer/VBoxContainer/BackButton") as Button

func _make_label_card_style(edge_color: Color, edge_alpha: float) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.13, 0.34)
	style.border_color = Color(edge_color.r, edge_color.g, edge_color.b, edge_alpha)
	style.set_border_width_all(1)
	style.set_corner_radius_all(16)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _make_nav_button_style(is_hover: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.07, 0.13, 0.84) if not is_hover else Color(0.02, 0.16, 0.22, 0.86)
	style.border_color = Color(UI_COLOR_MIRROR_CYAN.r, UI_COLOR_MIRROR_CYAN.g, UI_COLOR_MIRROR_CYAN.b, 0.44 if not is_hover else 0.80)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.shadow_color = Color(0, 0, 0, 0.28)
	style.shadow_size = 8 if is_hover else 5
	style.shadow_offset = Vector2(0, 3)
	return style

func _play_header_intro() -> void:
	if header_intro_tween != null:
		header_intro_tween.kill()
	title_label.modulate = Color(1, 1, 1, 0)
	hint_label.modulate = Color(1, 1, 1, 0)
	var original_title_position: Vector2 = title_label.position
	var original_hint_position: Vector2 = hint_label.position
	title_label.position = original_title_position + Vector2(0, -10)
	hint_label.position = original_hint_position + Vector2(0, -6)
	header_intro_tween = create_tween()
	header_intro_tween.set_parallel(true)
	header_intro_tween.tween_property(title_label, "modulate", Color(1, 1, 1, 1), 0.22)
	header_intro_tween.tween_property(title_label, "position", original_title_position, 0.22)
	header_intro_tween.tween_property(hint_label, "modulate", Color(1, 1, 1, 1), 0.28).set_delay(0.04)
	header_intro_tween.tween_property(hint_label, "position", original_hint_position, 0.28).set_delay(0.04)
	header_intro_tween.set_parallel(false)
	header_intro_tween.tween_callback(_on_header_intro_finished)

func _on_header_intro_finished() -> void:
	header_intro_tween = null

func _on_back_button_mouse_entered() -> void:
	_tween_back_button(Vector2(1.025, 1.025), 0.10)

func _on_back_button_mouse_exited() -> void:
	_tween_back_button(Vector2.ONE, 0.12)

func _tween_back_button(target_scale: Vector2, duration: float) -> void:
	var back_button: Button = _get_back_button()
	if back_button == null:
		return
	if back_button_tween != null:
		back_button_tween.kill()
	back_button_tween = create_tween()
	back_button_tween.tween_property(back_button, "scale", target_scale, duration)
	back_button_tween.tween_callback(_on_back_button_tween_finished)

func _on_back_button_tween_finished() -> void:
	back_button_tween = null

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
		var total_stages: int = int(data.get("total_stages", GameState.STILL_STAGE_COUNT))
		var unlocked_stages: int = int(data.get("unlocked_stages", 0))
		var s_count: int = _rank_count(still_id, total_stages, "S")
		var is_perfect: bool = _is_perfect_memory(still_id, total_stages)
		var is_complete: bool = unlocked_stages >= total_stages

		var panel: PanelContainer = PanelContainer.new()
		panel.custom_minimum_size = Vector2(0, 190)
		panel.add_theme_stylebox_override("panel", _make_still_card_style(is_complete, is_perfect))
		panel.modulate = Color(1, 1, 1, 0)
		still_list.add_child(panel)

		var margin: MarginContainer = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 18)
		margin.add_theme_constant_override("margin_top", 14)
		margin.add_theme_constant_override("margin_right", 18)
		margin.add_theme_constant_override("margin_bottom", 14)
		panel.add_child(margin)

		var row: VBoxContainer = VBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		margin.add_child(row)

		var header_row: HBoxContainer = HBoxContainer.new()
		header_row.alignment = BoxContainer.ALIGNMENT_CENTER
		header_row.add_theme_constant_override("separation", 12)
		row.add_child(header_row)

		var label: Label = Label.new()
		label.text = "%s" % title
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 24)
		label.add_theme_color_override("font_color", _status_title_color(is_complete, is_perfect))
		label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
		label.add_theme_constant_override("outline_size", 4)
		header_row.add_child(label)

		var percent_badge: Label = _make_badge("%d%%" % percent, _status_title_color(is_complete, is_perfect), Color(0.04, 0.06, 0.13, 0.82))
		header_row.add_child(percent_badge)

		var badge_row: HBoxContainer = HBoxContainer.new()
		badge_row.alignment = BoxContainer.ALIGNMENT_CENTER
		badge_row.add_theme_constant_override("separation", 8)
		row.add_child(badge_row)
		_add_mastery_badges(badge_row, is_complete, is_perfect, s_count, total_stages)

		var unlock_label: Label = Label.new()
		unlock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		unlock_label.text = _unlock_status_text(unlocked_stages, total_stages)
		unlock_label.add_theme_font_size_override("font_size", 18)
		unlock_label.add_theme_color_override("font_color", _status_title_color(is_complete, is_perfect))
		unlock_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
		unlock_label.add_theme_constant_override("outline_size", 3)
		row.add_child(unlock_label)

		var mastery_label: Label = Label.new()
		mastery_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mastery_label.text = _mastery_status_text(still_id, unlocked_stages, total_stages)
		mastery_label.add_theme_font_size_override("font_size", 17)
		mastery_label.add_theme_color_override("font_color", UI_COLOR_MIST_BLUE)
		mastery_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
		mastery_label.add_theme_constant_override("outline_size", 3)
		row.add_child(mastery_label)

		var button_row: HBoxContainer = HBoxContainer.new()
		button_row.alignment = BoxContainer.ALIGNMENT_CENTER
		button_row.add_theme_constant_override("separation", 10)
		row.add_child(button_row)

		var stage_index: int = 0
		while stage_index < total_stages:
			var button: Button = Button.new()
			button.custom_minimum_size = Vector2(130, 42)
			button.text = _stage_button_text(still_id, stage_index, unlocked_stages)
			button.disabled = stage_index > unlocked_stages
			button.add_theme_stylebox_override("normal", _make_stage_button_style(still_id, stage_index, unlocked_stages, false))
			button.add_theme_stylebox_override("hover", _make_stage_button_style(still_id, stage_index, unlocked_stages, true))
			button.add_theme_stylebox_override("pressed", _make_stage_button_style(still_id, stage_index, unlocked_stages, true))
			button.add_theme_stylebox_override("disabled", _make_stage_button_style(still_id, stage_index, unlocked_stages, false))
			button.add_theme_color_override("font_color", _stage_button_text_color(still_id, stage_index, unlocked_stages))
			button.add_theme_color_override("font_disabled_color", UI_COLOR_LOCKED)
			button.add_theme_font_size_override("font_size", 16)
			button.pressed.connect(_start_stage.bind(still_id, stage_index))
			button_row.add_child(button)
			stage_index += 1
		still_index += 1

func _add_mastery_badges(parent: HBoxContainer, is_complete: bool, is_perfect: bool, s_count: int, total_stages: int) -> void:
	if is_perfect:
		parent.add_child(_make_badge("PERFECT MEMORY", UI_COLOR_RESTORATION_GOLD, Color(0.22, 0.15, 0.04, 0.86)))
	elif is_complete:
		parent.add_child(_make_badge("COMPLETE", UI_COLOR_MIRROR_CYAN, Color(0.02, 0.16, 0.22, 0.82)))
	else:
		parent.add_child(_make_badge("IN PROGRESS", UI_COLOR_MIST_BLUE, Color(0.05, 0.07, 0.13, 0.78)))
	parent.add_child(_make_badge("S %d/%d" % [s_count, total_stages], UI_COLOR_RESTORATION_GOLD if s_count > 0 else UI_COLOR_LOCKED, Color(0.04, 0.06, 0.13, 0.82)))

func _make_still_card_style(is_complete: bool, is_perfect: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = UI_COLOR_BACKGROUND_PANEL
	if is_perfect:
		style.border_color = Color(UI_COLOR_RESTORATION_GOLD.r, UI_COLOR_RESTORATION_GOLD.g, UI_COLOR_RESTORATION_GOLD.b, 0.78)
	elif is_complete:
		style.border_color = Color(UI_COLOR_MIRROR_CYAN.r, UI_COLOR_MIRROR_CYAN.g, UI_COLOR_MIRROR_CYAN.b, 0.52)
	else:
		style.border_color = UI_COLOR_PANEL_EDGE
	style.set_border_width_all(3 if is_perfect else 2)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0, 0, 0, 0.34)
	style.shadow_size = 12 if is_perfect else 8
	style.shadow_offset = Vector2(0, 4)
	return style

func _make_stage_button_style(still_id: String, stage_index: int, unlocked_stages: int, is_hover: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	var edge: Color = _stage_button_text_color(still_id, stage_index, unlocked_stages)
	if stage_index > unlocked_stages:
		style.bg_color = Color(0.04, 0.05, 0.08, 0.70)
		style.border_color = Color(UI_COLOR_LOCKED.r, UI_COLOR_LOCKED.g, UI_COLOR_LOCKED.b, 0.35)
	elif stage_index == unlocked_stages:
		style.bg_color = Color(0.02, 0.16, 0.22, 0.78)
		style.border_color = Color(UI_COLOR_MIRROR_CYAN.r, UI_COLOR_MIRROR_CYAN.g, UI_COLOR_MIRROR_CYAN.b, 0.72)
	else:
		style.bg_color = Color(0.05, 0.07, 0.13, 0.80)
		style.border_color = Color(edge.r, edge.g, edge.b, 0.68)
	if is_hover:
		style.bg_color = Color(style.bg_color.r + 0.04, style.bg_color.g + 0.04, style.bg_color.b + 0.04, style.bg_color.a)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	return style

func _make_badge(text_value: String, edge_color: Color, fill_color: Color) -> Label:
	var badge: Label = Label.new()
	badge.text = text_value
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 15)
	badge.add_theme_color_override("font_color", edge_color)
	badge.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	badge.add_theme_constant_override("outline_size", 3)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = edge_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	badge.add_theme_stylebox_override("normal", style)
	return badge

func _status_title_color(is_complete: bool, is_perfect: bool) -> Color:
	if is_perfect:
		return UI_COLOR_RESTORATION_GOLD
	if is_complete:
		return UI_COLOR_MIRROR_CYAN
	return UI_COLOR_MEMORY_WHITE

func _stage_button_text_color(still_id: String, stage_index: int, unlocked_stages: int) -> Color:
	if stage_index > unlocked_stages:
		return UI_COLOR_LOCKED
	if stage_index == unlocked_stages:
		return UI_COLOR_MIRROR_CYAN
	var rank: String = GameState.get_stage_rank(still_id, stage_index)
	match rank:
		"S":
			return UI_COLOR_RESTORATION_GOLD
		"A":
			return UI_COLOR_MIRROR_CYAN
		"B":
			return UI_COLOR_DREAM_VIOLET
		"C":
			return UI_COLOR_LOCKED
		_:
			return UI_COLOR_MEMORY_WHITE

func _character_accent_color(character_id: String) -> Color:
	match character_id:
		"Rin":
			return UI_COLOR_RESTORATION_GOLD
		"Moka":
			return Color(1.0, 0.62, 0.86, 1.0)
		"Kaede":
			return UI_COLOR_MIRROR_CYAN
		_:
			return UI_COLOR_DREAM_VIOLET

func _is_perfect_memory(still_id: String, total_stages: int) -> bool:
	if total_stages <= 0:
		return false
	var stage_index: int = 0
	while stage_index < total_stages:
		if GameState.get_stage_rank(still_id, stage_index) != "S":
			return false
		stage_index += 1
	return true

func _play_panel_intro() -> void:
	if panel_intro_tween != null:
		panel_intro_tween.kill()
	panel_intro_tween = create_tween()
	var index: int = 0
	for child in still_list.get_children():
		if child is Control:
			var panel: Control = child as Control
			var original_position: Vector2 = panel.position
			panel.position = original_position + Vector2(0, 14)
			panel.modulate = Color(1, 1, 1, 0)
			panel_intro_tween.set_parallel(true)
			panel_intro_tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.20).set_delay(float(index) * 0.04)
			panel_intro_tween.tween_property(panel, "position", original_position, 0.22).set_delay(float(index) * 0.04)
			panel_intro_tween.set_parallel(false)
			index += 1
	panel_intro_tween.tween_callback(_on_panel_intro_finished)

func _on_panel_intro_finished() -> void:
	panel_intro_tween = null

func _unlock_status_text(unlocked_stages: int, total_stages: int) -> String:
	if unlocked_stages >= total_stages:
		return "COMPLETE - Full memory unlocked"
	return "Next unlock: Stage %d" % (unlocked_stages + 1)

func _mastery_status_text(still_id: String, unlocked_stages: int, total_stages: int) -> String:
	if unlocked_stages <= 0:
		return "Mastery: Not started"
	var s_count: int = _rank_count(still_id, total_stages, "S")
	var cleared_count: int = min(unlocked_stages, total_stages)
	if cleared_count >= total_stages and s_count >= total_stages:
		return "Mastery: PERFECT MEMORY - All S"
	if cleared_count >= total_stages:
		return "Mastery: Complete / S Ranks %d/%d" % [s_count, total_stages]
	return "Mastery: S Ranks %d/%d" % [s_count, total_stages]

func _rank_count(still_id: String, total_stages: int, target_rank: String) -> int:
	var count: int = 0
	var stage_index: int = 0
	while stage_index < total_stages:
		if GameState.get_stage_rank(still_id, stage_index) == target_rank:
			count += 1
		stage_index += 1
	return count

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
