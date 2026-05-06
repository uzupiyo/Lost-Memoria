extends Control

var still_ids: Array = []
var current_index: int = 0
var shard_overlays: Array[Polygon2D] = []
var current_unlocked_stages: int = 0
var current_total_stages: int = 5

@onready var title_label: Label = %StillTitle
@onready var collection_title_label: Label = %TitleLabel
@onready var progress_label: Label = %ProgressLabel
@onready var status_label: Label = %StatusLabel
@onready var still_image: TextureRect = %StillImage
@onready var locked_overlay: ColorRect = %LockedOverlay
@onready var shard_layer: Control = %ShardLayer
@onready var overlay_label: Label = %OverlayLabel
@onready var counter_label: Label = %CounterLabel
@onready var fullscreen_button: Button = %FullscreenButton
@onready var fullscreen_viewer: ColorRect = %FullscreenViewer
@onready var fullscreen_image: TextureRect = %FullscreenImage
@onready var character_portrait: TextureRect = %CharacterPortrait
@onready var character_name_label: Label = %CharacterNameLabel
@onready var character_situation_label: Label = %CharacterSituationLabel

func _ready() -> void:
	shard_layer.resized.connect(_on_shard_layer_resized)
	_setup_shards()
	still_ids = GameState.get_still_ids_for_character(GameState.selected_character_id)
	collection_title_label.text = "%s Collection" % GameState.selected_character_id
	if still_ids.is_empty():
		return
	var focus_index: int = still_ids.find(GameState.collection_focus_still_id)
	if focus_index >= 0:
		current_index = focus_index
	_update_collection_view(str(still_ids[current_index]))

func _input(event: InputEvent) -> void:
	if fullscreen_viewer.visible and event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and key_event.keycode == KEY_ESCAPE:
			_hide_fullscreen()

func _on_shard_layer_resized() -> void:
	_refresh_shard_polygons()
	_apply_shard_mask(current_unlocked_stages, current_total_stages)

func _setup_shards() -> void:
	var child_index: int = shard_layer.get_child_count() - 1
	while child_index >= 0:
		var child: Node = shard_layer.get_child(child_index)
		child.queue_free()
		child_index -= 1
	shard_overlays.clear()

	var shard_index: int = 0
	while shard_index < GameState.STILL_STAGE_COUNT:
		var shard: Polygon2D = Polygon2D.new()
		shard.color = Color(0, 0, 0, 1)
		shard_layer.add_child(shard)
		shard_overlays.append(shard)
		shard_index += 1
	_refresh_shard_polygons()

func _refresh_shard_polygons() -> void:
	var shard_index: int = 0
	while shard_index < shard_overlays.size():
		var shard: Polygon2D = shard_overlays[shard_index]
		shard.polygon = _get_shard_polygon(shard_index)
		shard_index += 1

func _get_shard_polygon(index: int) -> PackedVector2Array:
	var w: float = max(shard_layer.size.x, 1.0)
	var h: float = max(shard_layer.size.y, 1.0)
	match index:
		0:
			return PackedVector2Array([Vector2(0, 0), Vector2(w * 0.44, 0), Vector2(w * 0.37, h * 0.46), Vector2(0, h * 0.62)])
		1:
			return PackedVector2Array([Vector2(w * 0.44, 0), Vector2(w, 0), Vector2(w, h * 0.42), Vector2(w * 0.68, h * 0.58), Vector2(w * 0.37, h * 0.46)])
		2:
			return PackedVector2Array([Vector2(0, h * 0.62), Vector2(w * 0.37, h * 0.46), Vector2(w * 0.48, h), Vector2(0, h)])
		3:
			return PackedVector2Array([Vector2(w * 0.37, h * 0.46), Vector2(w * 0.68, h * 0.58), Vector2(w * 0.72, h), Vector2(w * 0.48, h)])
		_:
			return PackedVector2Array([Vector2(w * 0.68, h * 0.58), Vector2(w, h * 0.42), Vector2(w, h), Vector2(w * 0.72, h)])

func _update_collection_view(still_id: String) -> void:
	GameState.set_collection_focus(still_id)
	var data: Dictionary = GameState.get_still_data(still_id)
	title_label.text = str(data.get("title", "Unknown Memory"))
	counter_label.text = "%d / %d" % [current_index + 1, still_ids.size()]
	var character_id: String = str(data.get("character", GameState.selected_character_id))
	var situation: String = str(data.get("situation", ""))
	_update_character_panel(character_id, situation)
	var unlocked_stages: int = int(data.get("unlocked_stages", 0))
	var total_stages: int = int(data.get("total_stages", GameState.STILL_STAGE_COUNT))
	current_unlocked_stages = unlocked_stages
	current_total_stages = total_stages
	var percent: int = GameState.get_unlock_percent(still_id)
	progress_label.text = "Mirror Shards: %d / %d" % [unlocked_stages, total_stages]
	_load_still_texture(str(data.get("image_path", "")))
	_refresh_shard_polygons()
	_apply_shard_mask(unlocked_stages, total_stages)
	fullscreen_button.disabled = not GameState.is_still_complete(still_id)
	if GameState.is_still_complete(still_id):
		status_label.text = "Unlocked - Fullscreen available"
	else:
		status_label.text = "%d%% restored" % percent

func _update_character_panel(character_id: String, situation: String) -> void:
	var character_data: Dictionary = GameState.get_character_data(character_id)
	character_name_label.text = str(character_data.get("display_name", character_id))
	character_situation_label.text = situation
	character_portrait.texture = _load_character_portrait(character_id)

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
	var ids: Array = GameState.get_still_ids_for_character(character_id)
	if ids.is_empty():
		return ""
	var first_data: Dictionary = GameState.get_still_data(str(ids[0]))
	return str(first_data.get("image_path", ""))

func _load_still_texture(path: String) -> void:
	if path.is_empty() or not ResourceLoader.exists(path):
		still_image.texture = null
		overlay_label.text = "NO IMAGE"
		overlay_label.visible = true
		locked_overlay.visible = true
		return
	var loaded_resource: Resource = load(path)
	if loaded_resource is Texture2D:
		still_image.texture = loaded_resource as Texture2D

func _apply_shard_mask(unlocked_stages: int, total_stages: int) -> void:
	still_image.modulate = Color(1, 1, 1, 1)
	locked_overlay.visible = false
	shard_layer.visible = true
	var shard_index: int = 0
	while shard_index < shard_overlays.size():
		var shard: Polygon2D = shard_overlays[shard_index]
		shard.color = Color(0, 0, 0, 1)
		shard.visible = shard_index >= unlocked_stages
		shard_index += 1
	if unlocked_stages <= 0:
		overlay_label.text = "LOCKED"
		overlay_label.visible = true
	elif unlocked_stages < total_stages:
		overlay_label.text = "%d / %d SHARDS RESTORED" % [unlocked_stages, total_stages]
		overlay_label.visible = true
	else:
		overlay_label.visible = false

func _show_current() -> void:
	if still_ids.is_empty():
		return
	_update_collection_view(str(still_ids[current_index]))

func _on_previous_pressed() -> void:
	if still_ids.is_empty():
		return
	current_index = (current_index - 1 + still_ids.size()) % still_ids.size()
	_show_current()

func _on_next_pressed() -> void:
	if still_ids.is_empty():
		return
	current_index = (current_index + 1) % still_ids.size()
	_show_current()

func _on_fullscreen_pressed() -> void:
	if still_ids.is_empty():
		return
	var still_id: String = str(still_ids[current_index])
	if not GameState.is_still_complete(still_id):
		return
	fullscreen_image.texture = still_image.texture
	fullscreen_viewer.visible = true
	fullscreen_viewer.move_to_front()

func _on_fullscreen_viewer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_hide_fullscreen()

func _hide_fullscreen() -> void:
	fullscreen_viewer.visible = false

func _on_stage_select_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/stage_select/stage_select.tscn")

func _on_character_select_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_select/character_select.tscn")

func _on_title_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")
