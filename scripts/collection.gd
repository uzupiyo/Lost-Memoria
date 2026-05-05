extends Control

var still_ids: Array = []
var current_index: int = 0
var shard_overlays: Array[Polygon2D] = []

@onready var title_label: Label = %StillTitle
@onready var progress_label: Label = %ProgressLabel
@onready var status_label: Label = %StatusLabel
@onready var still_image: TextureRect = %StillImage
@onready var shard_layer: Control = %ShardLayer
@onready var overlay_label: Label = %OverlayLabel
@onready var counter_label: Label = %CounterLabel

func _ready() -> void:
	_setup_shards()
	still_ids = GameState.get_all_still_ids()
	if still_ids.is_empty():
		return
	_update_collection_view(str(still_ids[current_index]))

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
		shard.color = Color(0.12, 0.12, 0.14, 0.88)
		shard.polygon = _get_shard_polygon(shard_index)
		shard_layer.add_child(shard)
		shard_overlays.append(shard)
		shard_index += 1

func _get_shard_polygon(index: int) -> PackedVector2Array:
	match index:
		0:
			return PackedVector2Array([Vector2(0, 0), Vector2(355, 0), Vector2(300, 210), Vector2(0, 275)])
		1:
			return PackedVector2Array([Vector2(355, 0), Vector2(720, 0), Vector2(720, 170), Vector2(455, 250), Vector2(300, 210)])
		2:
			return PackedVector2Array([Vector2(0, 275), Vector2(300, 210), Vector2(360, 405), Vector2(0, 405)])
		3:
			return PackedVector2Array([Vector2(300, 210), Vector2(455, 250), Vector2(500, 405), Vector2(360, 405)])
		_:
			return PackedVector2Array([Vector2(455, 250), Vector2(720, 170), Vector2(720, 405), Vector2(500, 405)])

func _update_collection_view(still_id: String) -> void:
	var data: Dictionary = GameState.get_still_data(still_id)
	title_label.text = str(data.get("title", "Unknown Memory"))
	counter_label.text = "%d / %d" % [current_index + 1, still_ids.size()]
	var unlocked_stages: int = int(data.get("unlocked_stages", 0))
	var total_stages: int = int(data.get("total_stages", GameState.STILL_STAGE_COUNT))
	var percent: int = GameState.get_unlock_percent(still_id)
	progress_label.text = "Mirror Shards: %d / %d" % [unlocked_stages, total_stages]
	_load_still_texture(str(data.get("image_path", "")))
	_apply_shard_mask(unlocked_stages)
	if GameState.is_still_complete(still_id):
		status_label.text = "Unlocked"
	else:
		status_label.text = "%d%% restored" % percent

func _load_still_texture(path: String) -> void:
	if path.is_empty() or not ResourceLoader.exists(path):
		still_image.texture = null
		overlay_label.text = "NO IMAGE"
		overlay_label.visible = true
		return
	var loaded_resource: Resource = load(path)
	if loaded_resource is Texture2D:
		still_image.texture = loaded_resource as Texture2D

func _apply_shard_mask(unlocked_stages: int) -> void:
	var shard_index: int = 0
	while shard_index < shard_overlays.size():
		var shard: Polygon2D = shard_overlays[shard_index]
		shard.visible = shard_index >= unlocked_stages
		shard_index += 1
	still_image.modulate = Color(1, 1, 1, 1)
	if unlocked_stages <= 0:
		overlay_label.text = "LOCKED"
		overlay_label.visible = true
	elif unlocked_stages < shard_overlays.size():
		overlay_label.text = "%d / %d SHARDS RESTORED" % [unlocked_stages, shard_overlays.size()]
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

func _on_stage_select_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/stage_select/stage_select.tscn")

func _on_title_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")
