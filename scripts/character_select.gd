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
	button.custom_minimum_size = Vector2(380, 560)
	button.focus_mode = Control.FOCUS_NONE
	button.text = ""
	button.pressed.connect(_on_character_card_pressed.bind(character_id))

	var container: VBoxContainer = VBoxContainer.new()
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	button.add_child(container)

	var portrait: TextureRect = TextureRect.new()
	portrait.custom_minimum_size = Vector2(320, 410)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture = _load_character_portrait(character_id)
	container.add_child(portrait)

	var name_label: Label = Label.new()
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.text = str(data.get("display_name", character_id))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 34)
	container.add_child(name_label)

	var count_label: Label = Label.new()
	count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	count_label.text = "%d Memories" % GameState.get_still_ids_for_character(character_id).size()
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_label.add_theme_font_size_override("font_size", 20)
	container.add_child(count_label)

	return button

func _load_character_portrait(character_id: String) -> Texture2D:
	var data: Dictionary = GameState.get_character_data(character_id)
	var candidate_paths: Array[String] = []
	var portrait_path: String = str(data.get("portrait_path", ""))
	if not portrait_path.is_empty():
		candidate_paths.append(portrait_path)
	candidate_paths.append("res://assets/ui/characters/%s_portrait_card.webp" % character_id)
	candidate_paths.append("res://assets/ui/characters/%s_portrait_card.png" % character_id)
	candidate_paths.append("res://assets/ui/characters/%s_card.webp" % character_id)
	candidate_paths.append("res://assets/ui/characters/%s_card.png" % character_id)
	candidate_paths.append(_get_first_still_image_path(character_id))

	var i: int = 0
	while i < candidate_paths.size():
		var path: String = candidate_paths[i]
		if not path.is_empty() and ResourceLoader.exists(path):
			var loaded: Resource = load(path)
			if loaded is Texture2D:
				return loaded as Texture2D
		i += 1
	return null

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
