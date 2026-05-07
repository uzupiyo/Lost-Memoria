extends Control

const UI_COLOR_BACKGROUND_PANEL: Color = Color(0.063, 0.098, 0.212, 0.86)
const UI_COLOR_PANEL_EDGE: Color = Color(0.56, 0.92, 1.0, 0.32)
const UI_COLOR_SELECTED_EDGE: Color = Color(1.0, 0.85, 0.42, 0.90)
const UI_COLOR_MEMORY_WHITE: Color = Color(0.96, 0.98, 1.0, 1.0)
const UI_COLOR_MIST_BLUE: Color = Color(0.75, 0.84, 0.95, 1.0)
const UI_COLOR_RESTORATION_GOLD: Color = Color(1.0, 0.85, 0.42, 1.0)
const UI_COLOR_MIRROR_CYAN: Color = Color(0.51, 0.96, 1.0, 1.0)
const UI_COLOR_FRAGMENT_PINK: Color = Color(1.0, 0.62, 0.86, 1.0)
const UI_COLOR_DREAM_VIOLET: Color = Color(0.72, 0.61, 1.0, 1.0)

@onready var character_grid: HBoxContainer = %CharacterGrid
@onready var selected_name_label: Label = %SelectedNameLabel
@onready var selected_description_label: Label = %SelectedDescriptionLabel

var selected_character_id: String = "Rin"
var character_cards: Dictionary = {}
var card_tweens: Dictionary = {}

func _ready() -> void:
	selected_character_id = GameState.selected_character_id
	_build_character_cards()
	_update_selected_info()
	_update_card_selection_styles()

func _build_character_cards() -> void:
	character_cards.clear()
	var child_index: int = character_grid.get_child_count() - 1
	while child_index >= 0:
		var child: Node = character_grid.get_child(child_index)
		child.queue_free()
		child_index -= 1

	var ids: Array = GameState.get_character_ids()
	var i: int = 0
	while i < ids.size():
		var character_id: String = str(ids[i])
		var card: Button = _create_character_card(character_id)
		character_grid.add_child(card)
		character_cards[character_id] = card
		i += 1

func _create_character_card(character_id: String) -> Button:
	var data: Dictionary = GameState.get_character_data(character_id)
	var button: Button = Button.new()
	button.name = "%sCard" % character_id
	button.custom_minimum_size = Vector2(420, 800)
	button.focus_mode = Control.FOCUS_NONE
	button.text = ""
	button.add_theme_stylebox_override("normal", _make_card_style(false, _character_accent_color(character_id)))
	button.add_theme_stylebox_override("hover", _make_card_style(true, _character_accent_color(character_id)))
	button.add_theme_stylebox_override("pressed", _make_card_style(true, UI_COLOR_SELECTED_EDGE))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.pressed.connect(_on_character_card_pressed.bind(character_id))
	button.mouse_entered.connect(_on_character_card_mouse_entered.bind(button))
	button.mouse_exited.connect(_on_character_card_mouse_exited.bind(button))

	var margin: MarginContainer = MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	button.add_child(margin)

	var root: VBoxContainer = VBoxContainer.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	var card_stack: Control = Control.new()
	card_stack.custom_minimum_size = Vector2(380, 620)
	card_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_stack.clip_contents = true
	root.add_child(card_stack)

	var portrait: TextureRect = TextureRect.new()
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait.texture = _load_character_texture(character_id, "portrait")
	card_stack.add_child(portrait)

	var effect: TextureRect = TextureRect.new()
	effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect.set_anchors_preset(Control.PRESET_FULL_RECT)
	effect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	effect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	effect.texture = _load_character_texture(character_id, "effect")
	card_stack.add_child(effect)

	var selected_badge: Label = Label.new()
	selected_badge.name = "SelectedBadge"
	selected_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selected_badge.text = "SELECTED"
	selected_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selected_badge.add_theme_font_size_override("font_size", 16)
	selected_badge.add_theme_color_override("font_color", UI_COLOR_RESTORATION_GOLD)
	selected_badge.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 1.0))
	selected_badge.add_theme_constant_override("outline_size", 4)
	selected_badge.add_theme_stylebox_override("normal", _make_badge_style(UI_COLOR_RESTORATION_GOLD, Color(0.20, 0.13, 0.03, 0.82)))
	selected_badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	selected_badge.offset_left = -132
	selected_badge.offset_top = 14
	selected_badge.offset_right = -14
	selected_badge.offset_bottom = 48
	selected_badge.visible = false
	card_stack.add_child(selected_badge)

	var info_box: PanelContainer = PanelContainer.new()
	info_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_box.custom_minimum_size = Vector2(380, 142)
	info_box.add_theme_stylebox_override("panel", _make_info_style(_character_accent_color(character_id)))
	root.add_child(info_box)

	var info_inner: VBoxContainer = VBoxContainer.new()
	info_inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_inner.alignment = BoxContainer.ALIGNMENT_CENTER
	info_inner.add_theme_constant_override("separation", 4)
	info_box.add_child(info_inner)

	var name_label: Label = Label.new()
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.text = str(data.get("display_name", character_id))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 34)
	name_label.add_theme_color_override("font_color", _character_accent_color(character_id))
	name_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	name_label.add_theme_constant_override("outline_size", 4)
	info_inner.add_child(name_label)

	var count_label: Label = Label.new()
	count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	count_label.text = _character_progress_text(character_id)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_label.add_theme_font_size_override("font_size", 17)
	count_label.add_theme_color_override("font_color", UI_COLOR_MEMORY_WHITE)
	count_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	count_label.add_theme_constant_override("outline_size", 3)
	count_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_inner.add_child(count_label)

	return button

func _make_card_style(selected: bool, accent: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = UI_COLOR_BACKGROUND_PANEL
	style.border_color = UI_COLOR_SELECTED_EDGE if selected else UI_COLOR_PANEL_EDGE
	style.set_border_width_all(3 if selected else 2)
	style.set_corner_radius_all(22)
	style.shadow_color = Color(0, 0, 0, 0.40)
	style.shadow_size = 14 if selected else 8
	style.shadow_offset = Vector2(0, 5)
	return style

func _make_info_style(accent: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.13, 0.82)
	style.border_color = Color(accent.r, accent.g, accent.b, 0.34)
	style.set_border_width_all(1)
	style.set_corner_radius_all(16)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _make_badge_style(edge_color: Color, fill_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = edge_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 4
	style.content_margin_bottom = 4
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

func _on_character_card_mouse_entered(button: Button) -> void:
	_tween_card_scale(button, Vector2(1.025, 1.025), 0.12)

func _on_character_card_mouse_exited(button: Button) -> void:
	_tween_card_scale(button, Vector2.ONE, 0.14)

func _tween_card_scale(button: Button, target_scale: Vector2, duration: float) -> void:
	if card_tweens.has(button):
		var old_tween: Tween = card_tweens[button]
		if old_tween != null:
			old_tween.kill()
	var tween: Tween = create_tween()
	card_tweens[button] = tween
	tween.tween_property(button, "scale", target_scale, duration)
	tween.tween_callback(_on_card_tween_finished.bind(button))

func _on_card_tween_finished(button: Button) -> void:
	card_tweens.erase(button)

func _update_card_selection_styles() -> void:
	for character_id in character_cards.keys():
		var card: Button = character_cards[character_id]
		var is_selected: bool = str(character_id) == selected_character_id
		var accent: Color = _character_accent_color(str(character_id))
		card.add_theme_stylebox_override("normal", _make_card_style(is_selected, accent))
		var selected_badge: Label = card.find_child("SelectedBadge", true, false) as Label
		if selected_badge != null:
			selected_badge.visible = is_selected

func _character_progress_text(character_id: String) -> String:
	var ids: Array = GameState.get_still_ids_for_character(character_id)
	var total_memories: int = ids.size()
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
	return "%d Memories\nRestored %d%%   Complete %d/%d\nPerfect %d/%d" % [total_memories, percent, complete_memories, total_memories, perfect_memories, total_memories]

func _is_perfect_memory(still_id: String, total_stages: int) -> bool:
	var stage_index: int = 0
	while stage_index < total_stages:
		if GameState.get_stage_rank(still_id, stage_index) != "S":
			return false
		stage_index += 1
	return true

func _load_character_texture(character_id: String, texture_kind: String) -> Texture2D:
	var candidate_paths: Array[String] = _get_character_asset_candidates(character_id, texture_kind)
	var i: int = 0
	while i < candidate_paths.size():
		var path: String = candidate_paths[i]
		if not path.is_empty() and ResourceLoader.exists(path):
			var loaded: Resource = load(path)
			if loaded is Texture2D:
				return loaded as Texture2D
		i += 1
	return null

func _get_character_asset_candidates(character_id: String, texture_kind: String) -> Array[String]:
	var data: Dictionary = GameState.get_character_data(character_id)
	var paths: Array[String] = []
	match texture_kind:
		"portrait":
			paths.append(str(data.get("portrait_path", "")))
			paths.append("res://assets/ui/characters/portraits/%s_portrait.webp" % character_id)
			paths.append("res://assets/ui/characters/portraits/%s_portrait.png" % character_id)
			paths.append("res://assets/ui/characters/portraits/%s.webp" % character_id)
			paths.append("res://assets/ui/characters/portraits/%s.png" % character_id)
			paths.append("res://assets/ui/characters/%s_portrait_card.webp" % character_id)
			paths.append("res://assets/ui/characters/%s_portrait_card.png" % character_id)
			paths.append(_get_first_still_image_path(character_id))
		"effect":
			paths.append(str(data.get("effect_path", "")))
			paths.append("res://assets/ui/characters/effects/%s_effect.png" % character_id)
			paths.append("res://assets/ui/characters/effects/%s_effect.webp" % character_id)
	return paths

func _get_first_still_image_path(character_id: String) -> String:
	var still_ids: Array = GameState.get_still_ids_for_character(character_id)
	if still_ids.is_empty():
		return ""
	var first_data: Dictionary = GameState.get_still_data(str(still_ids[0]))
	return str(first_data.get("image_path", ""))

func _on_character_card_pressed(character_id: String) -> void:
	selected_character_id = character_id
	GameState.select_character(character_id)
	_update_selected_info()
	_update_card_selection_styles()

func _update_selected_info() -> void:
	var data: Dictionary = GameState.get_character_data(selected_character_id)
	selected_name_label.text = str(data.get("display_name", selected_character_id))
	selected_name_label.add_theme_color_override("font_color", _character_accent_color(selected_character_id))
	selected_name_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	selected_name_label.add_theme_constant_override("outline_size", 4)
	selected_description_label.text = "%s\n%s" % [str(data.get("description", "")), _character_progress_text(selected_character_id)]
	selected_description_label.add_theme_color_override("font_color", UI_COLOR_MEMORY_WHITE)
	selected_description_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	selected_description_label.add_theme_constant_override("outline_size", 3)

func _on_start_pressed() -> void:
	GameState.select_character(selected_character_id)
	get_tree().change_scene_to_file("res://scenes/stage_select/stage_select.tscn")

func _on_collection_pressed() -> void:
	GameState.select_character(selected_character_id)
	get_tree().change_scene_to_file("res://scenes/collection/collection.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")
