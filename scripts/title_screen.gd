extends Control

const UI_COLOR_BACKGROUND_PANEL: Color = Color(0.063, 0.098, 0.212, 0.88)
const UI_COLOR_PANEL_EDGE: Color = Color(0.56, 0.92, 1.0, 0.34)
const UI_COLOR_MEMORY_WHITE: Color = Color(0.96, 0.98, 1.0, 1.0)
const UI_COLOR_MIST_BLUE: Color = Color(0.75, 0.84, 0.95, 1.0)
const UI_COLOR_RESTORATION_GOLD: Color = Color(1.0, 0.85, 0.42, 1.0)
const UI_COLOR_MIRROR_CYAN: Color = Color(0.51, 0.96, 1.0, 1.0)

var progress_panel: PanelContainer = null
var title_panel_tween: Tween = null
var menu_intro_tween: Tween = null
var logo_intro_tween: Tween = null
var logo_idle_tween: Tween = null
var veil_tween: Tween = null
var icon_row_tween: Tween = null
var crystal_tween: Tween = null
var button_tweens: Dictionary = {}

func _ready() -> void:
	_add_global_progress_panel()
	_setup_title_screen_polish()

func _add_global_progress_panel() -> void:
	_clear_global_progress_panel()
	var summary: Dictionary = _progress_summary_for_all()
	progress_panel = PanelContainer.new()
	progress_panel.name = "GlobalProgressPanel"
	progress_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	progress_panel.offset_left = -600.0
	progress_panel.offset_top = 500.0
	progress_panel.offset_right = -58.0
	progress_panel.offset_bottom = 805.0
	progress_panel.add_theme_stylebox_override("panel", _make_status_panel_style())
	progress_panel.modulate = Color(1, 1, 1, 0)
	add_child(progress_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 18)
	progress_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var title: Label = Label.new()
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.text = "RESTORATION STATUS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", UI_COLOR_RESTORATION_GOLD)
	title.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	title.add_theme_constant_override("outline_size", 5)
	box.add_child(title)

	var achievement_badge: Label = Label.new()
	achievement_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	achievement_badge.text = "ACHIEVEMENT  ·  %s" % _achievement_title(summary)
	achievement_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	achievement_badge.add_theme_font_size_override("font_size", 18)
	achievement_badge.add_theme_color_override("font_color", UI_COLOR_RESTORATION_GOLD)
	achievement_badge.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 1.0))
	achievement_badge.add_theme_constant_override("outline_size", 4)
	achievement_badge.add_theme_stylebox_override("normal", _make_badge_style(UI_COLOR_RESTORATION_GOLD, Color(0.22, 0.15, 0.04, 0.78)))
	box.add_child(achievement_badge)

	var divider: ColorRect = ColorRect.new()
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	divider.custom_minimum_size = Vector2(0, 2)
	divider.color = Color(0.56, 0.92, 1.0, 0.28)
	box.add_child(divider)

	var body: Label = Label.new()
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.text = _global_progress_text(summary)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_size_override("font_size", 20)
	body.add_theme_color_override("font_color", UI_COLOR_MEMORY_WHITE)
	body.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	body.add_theme_constant_override("outline_size", 3)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body)

	var character_line: Label = Label.new()
	character_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_line.text = _character_progress_line()
	character_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	character_line.add_theme_font_size_override("font_size", 17)
	character_line.add_theme_color_override("font_color", UI_COLOR_MIRROR_CYAN)
	character_line.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	character_line.add_theme_constant_override("outline_size", 3)
	character_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(character_line)

	_play_status_panel_intro()

func _setup_title_screen_polish() -> void:
	_setup_logo_intro()
	_setup_background_veil_idle()
	_setup_title_menu_polish()
	_setup_icon_row_intro()

func _setup_logo_intro() -> void:
	var logo: TextureRect = get_node_or_null("TitleLogo") as TextureRect
	var tagline: TextureRect = get_node_or_null("Tagline") as TextureRect
	if logo != null:
		logo.modulate = Color(1, 1, 1, 0)
		logo.position += Vector2(0, -10)
		logo.pivot_offset = logo.size * 0.5
	if tagline != null:
		tagline.modulate = Color(1, 1, 1, 0)
		tagline.position += Vector2(0, -6)
	logo_intro_tween = create_tween()
	logo_intro_tween.set_parallel(true)
	if logo != null:
		logo_intro_tween.tween_property(logo, "modulate", Color(1, 1, 1, 1), 0.32)
		logo_intro_tween.tween_property(logo, "position", logo.position - Vector2(0, -10), 0.32)
	if tagline != null:
		logo_intro_tween.tween_property(tagline, "modulate", Color(1, 1, 1, 1), 0.44)
		logo_intro_tween.tween_property(tagline, "position", tagline.position - Vector2(0, -6), 0.44)
	logo_intro_tween.set_parallel(false)
	logo_intro_tween.tween_callback(_on_logo_intro_finished)

func _on_logo_intro_finished() -> void:
	logo_intro_tween = null
	_play_logo_idle()

func _play_logo_idle() -> void:
	var logo: TextureRect = get_node_or_null("TitleLogo") as TextureRect
	if logo == null:
		return
	if logo_idle_tween != null:
		logo_idle_tween.kill()
	logo_idle_tween = create_tween()
	logo_idle_tween.set_loops()
	logo_idle_tween.tween_property(logo, "modulate", Color(1.0, 0.96, 0.82, 1.0), 1.25)
	logo_idle_tween.tween_property(logo, "modulate", Color(1, 1, 1, 1), 1.25)

func _setup_background_veil_idle() -> void:
	var veil: ColorRect = get_node_or_null("DarkVeil") as ColorRect
	if veil == null:
		return
	if veil_tween != null:
		veil_tween.kill()
	veil.color = Color(0, 0, 0, 0.08)
	veil_tween = create_tween()
	veil_tween.set_loops()
	veil_tween.tween_property(veil, "color", Color(0.01, 0.02, 0.06, 0.15), 2.4)
	veil_tween.tween_property(veil, "color", Color(0, 0, 0, 0.08), 2.4)

func _setup_title_menu_polish() -> void:
	var menu_root: Control = get_node_or_null("MenuRoot") as Control
	if menu_root != null:
		menu_root.modulate = Color(1, 1, 1, 0)
		menu_root.position += Vector2(0, 14)
		menu_intro_tween = create_tween()
		menu_intro_tween.set_parallel(true)
		menu_intro_tween.tween_property(menu_root, "modulate", Color(1, 1, 1, 1), 0.28)
		menu_intro_tween.tween_property(menu_root, "position", menu_root.position - Vector2(0, 14), 0.28)
		menu_intro_tween.set_parallel(false)
		menu_intro_tween.tween_callback(_on_menu_intro_finished)
	_setup_title_button_hover("MenuRoot/StartButton")
	_setup_title_button_hover("MenuRoot/CollectionButton")
	_setup_title_button_hover("MenuRoot/OptionsButton")
	_play_selected_crystal_idle()

func _setup_icon_row_intro() -> void:
	var icon_row: HBoxContainer = get_node_or_null("IconRow") as HBoxContainer
	if icon_row == null:
		return
	icon_row.modulate = Color(1, 1, 1, 0)
	icon_row.position += Vector2(0, 10)
	icon_row_tween = create_tween()
	icon_row_tween.set_parallel(true)
	icon_row_tween.tween_property(icon_row, "modulate", Color(1, 1, 1, 0.86), 0.42)
	icon_row_tween.tween_property(icon_row, "position", icon_row.position - Vector2(0, 10), 0.42)
	icon_row_tween.set_parallel(false)
	icon_row_tween.tween_callback(_on_icon_row_intro_finished)

func _on_icon_row_intro_finished() -> void:
	icon_row_tween = null

func _setup_title_button_hover(button_path: String) -> void:
	var button: TextureButton = get_node_or_null(button_path) as TextureButton
	if button == null:
		return
	button.pivot_offset = button.size * 0.5
	if not button.mouse_entered.is_connected(_on_title_button_mouse_entered.bind(button)):
		button.mouse_entered.connect(_on_title_button_mouse_entered.bind(button))
	if not button.mouse_exited.is_connected(_on_title_button_mouse_exited.bind(button)):
		button.mouse_exited.connect(_on_title_button_mouse_exited.bind(button))

func _on_title_button_mouse_entered(button: TextureButton) -> void:
	if button.disabled:
		return
	_tween_button_scale(button, Vector2(1.035, 1.035), 0.10)

func _on_title_button_mouse_exited(button: TextureButton) -> void:
	_tween_button_scale(button, Vector2.ONE, 0.12)

func _tween_button_scale(button: TextureButton, target_scale: Vector2, duration: float) -> void:
	if button_tweens.has(button):
		var old_tween: Tween = button_tweens[button]
		if old_tween != null:
			old_tween.kill()
	var tween: Tween = create_tween()
	button_tweens[button] = tween
	tween.tween_property(button, "scale", target_scale, duration)
	tween.tween_callback(_on_button_tween_finished.bind(button))

func _on_button_tween_finished(button: TextureButton) -> void:
	button_tweens.erase(button)

func _play_selected_crystal_idle() -> void:
	var crystal: TextureRect = get_node_or_null("MenuRoot/SelectedCrystal") as TextureRect
	if crystal == null:
		return
	if crystal_tween != null:
		crystal_tween.kill()
	crystal.pivot_offset = crystal.size * 0.5
	crystal_tween = create_tween()
	crystal_tween.set_loops()
	crystal_tween.set_parallel(true)
	crystal_tween.tween_property(crystal, "position", crystal.position + Vector2(0, -7), 0.95)
	crystal_tween.tween_property(crystal, "modulate", Color(1.0, 0.94, 0.72, 0.88), 0.95)
	crystal_tween.set_parallel(false)
	crystal_tween.set_parallel(true)
	crystal_tween.tween_property(crystal, "position", crystal.position, 0.95)
	crystal_tween.tween_property(crystal, "modulate", Color(1, 1, 1, 1), 0.95)

func _on_menu_intro_finished() -> void:
	menu_intro_tween = null

func _make_status_panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = UI_COLOR_BACKGROUND_PANEL
	style.border_color = UI_COLOR_PANEL_EDGE
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.40)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 4)
	return style

func _make_badge_style(edge_color: Color, fill_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = edge_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style

func _play_status_panel_intro() -> void:
	if title_panel_tween != null:
		title_panel_tween.kill()
	progress_panel.scale = Vector2(0.97, 0.97)
	progress_panel.pivot_offset = Vector2(270, 150)
	title_panel_tween = create_tween()
	title_panel_tween.set_parallel(true)
	title_panel_tween.tween_property(progress_panel, "modulate", Color(1, 1, 1, 1), 0.22)
	title_panel_tween.tween_property(progress_panel, "scale", Vector2.ONE, 0.22)
	title_panel_tween.set_parallel(false)
	title_panel_tween.tween_callback(_on_status_panel_intro_finished)

func _on_status_panel_intro_finished() -> void:
	title_panel_tween = null

func _clear_global_progress_panel() -> void:
	if title_panel_tween != null:
		title_panel_tween.kill()
		title_panel_tween = null
	var existing: Node = get_node_or_null("GlobalProgressPanel")
	if existing != null:
		existing.queue_free()
	progress_panel = null

func _global_progress_text(summary: Dictionary) -> String:
	return "Restored %d%%\nComplete Memories %d/%d\nPerfect Memories %d/%d" % [
		int(summary.get("percent", 0)),
		int(summary.get("complete_memories", 0)),
		int(summary.get("total_memories", 0)),
		int(summary.get("perfect_memories", 0)),
		int(summary.get("total_memories", 0))
	]

func _achievement_title(summary: Dictionary) -> String:
	var percent: int = int(summary.get("percent", 0))
	var complete_memories: int = int(summary.get("complete_memories", 0))
	var total_memories: int = max(1, int(summary.get("total_memories", 0)))
	var perfect_memories: int = int(summary.get("perfect_memories", 0))
	if perfect_memories >= total_memories:
		return "Memory Master"
	if complete_memories >= total_memories:
		return "Full Restorer"
	if perfect_memories >= 5:
		return "Perfect Hunter"
	if percent >= 75:
		return "Light Collector"
	if percent >= 50:
		return "Mirror Restorer"
	if percent >= 25:
		return "Shard Seeker"
	if percent > 0:
		return "First Memory"
	return "New Awakening"

func _character_progress_line() -> String:
	var parts: Array[String] = []
	var ids: Array = GameState.get_character_ids()
	var i: int = 0
	while i < ids.size():
		var character_id: String = str(ids[i])
		var summary: Dictionary = _progress_summary_for_character(character_id)
		parts.append("%s %d%%" % [character_id, int(summary.get("percent", 0))])
		i += 1
	return " / ".join(parts)

func _progress_summary_for_all() -> Dictionary:
	return _progress_summary_for_still_ids(GameState.get_all_still_ids())

func _progress_summary_for_character(character_id: String) -> Dictionary:
	return _progress_summary_for_still_ids(GameState.get_still_ids_for_character(character_id))

func _progress_summary_for_still_ids(ids: Array) -> Dictionary:
	var total_memories: int = 0
	var complete_memories: int = 0
	var perfect_memories: int = 0
	var total_stages: int = 0
	var restored_stages: int = 0
	var i: int = 0
	while i < ids.size():
		var still_id: String = str(ids[i])
		var data: Dictionary = GameState.get_still_data(still_id)
		var still_total: int = int(data.get("total_stages", GameState.STILL_STAGE_COUNT))
		var unlocked: int = int(data.get("unlocked_stages", 0))
		total_memories += 1
		total_stages += still_total
		restored_stages += min(unlocked, still_total)
		if unlocked >= still_total:
			complete_memories += 1
			if _is_perfect_memory(still_id, still_total):
				perfect_memories += 1
		i += 1
	var percent: int = 0
	if total_stages > 0:
		percent = int(float(restored_stages) / float(total_stages) * 100.0)
	return {
		"percent": percent,
		"total_memories": total_memories,
		"complete_memories": complete_memories,
		"perfect_memories": perfect_memories
	}

func _is_perfect_memory(still_id: String, total_stages: int) -> bool:
	var stage_index: int = 0
	while stage_index < total_stages:
		if GameState.get_stage_rank(still_id, stage_index) != "S":
			return false
		stage_index += 1
	return true

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_select/character_select.tscn")

func _on_collection_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/collection/collection.tscn")
