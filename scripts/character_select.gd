extends Control

@onready var character_grid: HBoxContainer = %CharacterGrid
@onready var selected_name_label: Label = %SelectedNameLabel
@onready var selected_description_label: Label = %SelectedDescriptionLabel

var selected_character_id: String = "Rin"

func _ready() -> void:
	selected_character_id = GameState.selected_character_id
	_build_character_cards()
	_update_selected_info()

func _build_character_cards() -> void:
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
		i += 1

func _create_character_card(character_id: String) -> Button:
	var data: Dictionary = GameState.get_character_data(character_id)
	var button: Button = Button.new()
	button.custom_minimum_size = Vector2(520, 760)
	button.focus_mode = Control.FOCUS_NONE
	button.text = ""
	button.pressed.connect(_on_character_card_pressed.bind(character_id))

	var root: VBoxContainer = VBoxContainer.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 8)
	button.add_child(root)

	var card_stack: Control = Control.new()
	card_stack.custom_minimum_size = Vector2(510, 640)
	card_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(card_stack)

	var portrait: TextureRect = TextureRect.new()
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait.offset_left = 70.0
	portrait.offset_top = 90.0
	portrait.offset_right = -70.0
	portrait.offset_bottom = -92.0
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait.texture = _load_character_texture(character_id, "portrait")
	card_stack.add_child(portrait)

	var effect: TextureRect = TextureRect.new()
	effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect.set_anchors_preset(Control.PRESET_FULL_RECT)
	effect.offset_left = 70.0
	effect.offset_top = 90.0
	effect.offset_right = -70.0
	effect.offset_bottom = -92.0
	effect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	effect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	effect.texture = _load_character_texture(character_id, "effect")
	card_stack.add_child(effect)

	var frame: TextureRect = TextureRect.new()
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	frame.texture = _load_character_texture(character_id, "frame")
	card_stack.add_child(frame)

	var info_box: PanelContainer = PanelContainer.new()
	info_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_box.custom_minimum_size = Vector2(510, 96)
	root.add_child(info_box)

	var info_inner: VBoxContainer = VBoxContainer.new()
	info_inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_inner.alignment = BoxContainer.ALIGNMENT_CENTER
	info_inner.add_theme_constant_override("separation", 2)
	info_box.add_child(info_inner)

	var name_label: Label = Label.new()
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.text = str(data.get("display_name", character_id))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 34)
	info_inner.add_child(name_label)

	var count_label: Label = Label.new()
	count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	count_label.text = "%d Memories" % GameState.get_still_ids_for_character(character_id).size()
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_label.add_theme_font_size_override("font_size", 20)
	info_inner.add_child(count_label)

	return button

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
		"frame":
			paths.append(str(data.get("frame_path", "")))
			paths.append("res://assets/ui/characters/frames/%s_frame.png" % character_id)
			paths.append("res://assets/ui/characters/frames/%s_frame.webp" % character_id)
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

func _update_selected_info() -> void:
	var data: Dictionary = GameState.get_character_data(selected_character_id)
	selected_name_label.text = str(data.get("display_name", selected_character_id))
	selected_description_label.text = str(data.get("description", ""))

func _on_start_pressed() -> void:
	GameState.select_character(selected_character_id)
	get_tree().change_scene_to_file("res://scenes/stage_select/stage_select.tscn")

func _on_collection_pressed() -> void:
	GameState.select_character(selected_character_id)
	get_tree().change_scene_to_file("res://scenes/collection/collection.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")
