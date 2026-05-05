extends Control

var still_ids: Array = []
var current_index := 0

@onready var title_label: Label = %StillTitle
@onready var progress_label: Label = %ProgressLabel
@onready var status_label: Label = %StatusLabel
@onready var still_image: TextureRect = %StillImage
@onready var lock_overlay: ColorRect = %LockOverlay
@onready var overlay_label: Label = %OverlayLabel
@onready var counter_label: Label = %CounterLabel

func _ready() -> void:
	still_ids = GameState.get_all_still_ids()
	if still_ids.is_empty():
		return
	_update_collection_view(str(still_ids[current_index]))

func _update_collection_view(still_id: String) -> void:
	var data := GameState.get_still_data(still_id)
	title_label.text = str(data.get("title", "Unknown Memory"))
	counter_label.text = "%d / %d" % [current_index + 1, still_ids.size()]
	var percent := GameState.get_unlock_percent(still_id)
	progress_label.text = "Restoration: %d%%" % percent
	_load_still_texture(str(data.get("image_path", "")))
	_apply_unlock_mask(percent)
	if GameState.is_still_complete(still_id):
		status_label.text = "Unlocked"
	else:
		status_label.text = "Locked / In Progress"

func _load_still_texture(path: String) -> void:
	if path.is_empty() or not ResourceLoader.exists(path):
		still_image.texture = null
		overlay_label.text = "NO IMAGE"
		overlay_label.visible = true
		return
	var texture := load(path)
	if texture is Texture2D:
		still_image.texture = texture

func _apply_unlock_mask(percent: int) -> void:
	var clamped_percent := clamp(percent, 0, 100)
	var alpha := 0.82 - (float(clamped_percent) / 100.0) * 0.82
	lock_overlay.color = Color(0, 0, 0, alpha)
	var brightness := 0.35 + float(clamped_percent) / 100.0 * 0.65
	still_image.modulate = Color(brightness, brightness, brightness, 1.0)
	if clamped_percent <= 0:
		overlay_label.text = "LOCKED"
		overlay_label.visible = true
	elif clamped_percent < 100:
		overlay_label.text = "%d%% RESTORED" % clamped_percent
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
