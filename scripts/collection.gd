extends Control

@onready var title_label: Label = %StillTitle
@onready var progress_label: Label = %ProgressLabel
@onready var status_label: Label = %StatusLabel
@onready var still_image: TextureRect = %StillImage
@onready var lock_overlay: ColorRect = %LockOverlay
@onready var overlay_label: Label = %OverlayLabel

func _ready() -> void:
	_update_collection_view("rin_001")

func _update_collection_view(still_id: String) -> void:
	var data := GameState.get_still_data(still_id)
	title_label.text = str(data.get("title", "Unknown Memory"))
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
		return
	var texture := load(path)
	if texture is Texture2D:
		still_image.texture = texture

func _apply_unlock_mask(percent: int) -> void:
	var clamped_percent := clamp(percent, 0, 100)
	var alpha := 0.82 - (float(clamped_percent) / 100.0) * 0.82
	lock_overlay.color = Color(0, 0, 0, alpha)
	still_image.modulate = Color(0.35 + float(clamped_percent) / 100.0 * 0.65, 0.35 + float(clamped_percent) / 100.0 * 0.65, 0.35 + float(clamped_percent) / 100.0 * 0.65, 1.0)
	if clamped_percent <= 0:
		overlay_label.text = "LOCKED"
		overlay_label.visible = true
	elif clamped_percent < 100:
		overlay_label.text = "%d%% RESTORED" % clamped_percent
		overlay_label.visible = true
	else:
		overlay_label.visible = false

func _on_stage_select_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/stage_select/stage_select.tscn")

func _on_title_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")
