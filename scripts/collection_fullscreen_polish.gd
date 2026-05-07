extends "res://scripts/collection_memory_badges.gd"

const FULLSCREEN_STATUS_BADGE_NAME: String = "FullscreenStatusBadge"

var fullscreen_tween: Tween = null

func _ready() -> void:
	super._ready()
	_setup_fullscreen_viewer_style()

func _setup_fullscreen_viewer_style() -> void:
	var hint: Label = get_node_or_null("FullscreenViewer/FullscreenHint") as Label
	if hint != null:
		hint.text = "CLICK / ESC  ·  CLOSE MEMORY"
		hint.add_theme_font_size_override("font_size", 20)
		hint.add_theme_color_override("font_color", UI_COLOR_MIST_BLUE)
		hint.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
		hint.add_theme_constant_override("outline_size", 4)
		hint.add_theme_stylebox_override("normal", _make_fullscreen_hint_style())

func _on_fullscreen_pressed() -> void:
	if still_ids.is_empty():
		return
	var still_id: String = str(still_ids[current_index])
	if not GameState.is_still_complete(still_id):
		return
	super._on_fullscreen_pressed()
	_rebuild_fullscreen_status_badge(still_id)
	_play_fullscreen_intro()

func _hide_fullscreen() -> void:
	if fullscreen_tween != null:
		fullscreen_tween.kill()
		fullscreen_tween = null
	_clear_fullscreen_status_badge()
	super._hide_fullscreen()

func _rebuild_fullscreen_status_badge(still_id: String) -> void:
	_clear_fullscreen_status_badge()
	var viewer: ColorRect = get_node_or_null("FullscreenViewer") as ColorRect
	if viewer == null:
		return
	var data: Dictionary = GameState.get_still_data(still_id)
	if data.is_empty():
		return
	var total_stages: int = int(data.get("total_stages", GameState.STILL_STAGE_COUNT))
	var is_perfect: bool = _rank_count(still_id, total_stages, "S") >= total_stages
	var status_text: String = "MEMORY COMPLETE"
	var edge_color: Color = UI_COLOR_MIRROR_CYAN
	var fill_color: Color = Color(0.02, 0.16, 0.22, 0.82)
	if is_perfect:
		status_text = "PERFECT MEMORY  ·  ALL S"
		edge_color = UI_COLOR_RESTORATION_GOLD
		fill_color = Color(0.22, 0.15, 0.04, 0.86)
	var badge: Label = Label.new()
	badge.name = FULLSCREEN_STATUS_BADGE_NAME
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.text = status_text
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 24)
	badge.add_theme_color_override("font_color", edge_color)
	badge.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	badge.add_theme_constant_override("outline_size", 5)
	badge.add_theme_stylebox_override("normal", _make_fullscreen_badge_style(edge_color, fill_color))
	badge.set_anchors_preset(Control.PRESET_TOP_WIDE)
	badge.offset_left = 420
	badge.offset_top = 22
	badge.offset_right = -420
	badge.offset_bottom = 78
	viewer.add_child(badge)
	viewer.move_child(badge, viewer.get_child_count() - 1)

func _clear_fullscreen_status_badge() -> void:
	var old_badge: Node = get_node_or_null("FullscreenViewer/%s" % FULLSCREEN_STATUS_BADGE_NAME)
	if old_badge != null:
		old_badge.queue_free()

func _play_fullscreen_intro() -> void:
	if fullscreen_tween != null:
		fullscreen_tween.kill()
	fullscreen_viewer.modulate = Color(1, 1, 1, 0)
	fullscreen_image.scale = Vector2(0.985, 0.985)
	fullscreen_tween = create_tween()
	fullscreen_tween.set_parallel(true)
	fullscreen_tween.tween_property(fullscreen_viewer, "modulate", Color(1, 1, 1, 1), 0.18)
	fullscreen_tween.tween_property(fullscreen_image, "scale", Vector2.ONE, 0.20)
	fullscreen_tween.set_parallel(false)
	fullscreen_tween.tween_callback(_on_fullscreen_intro_finished)

func _on_fullscreen_intro_finished() -> void:
	fullscreen_tween = null

func _make_fullscreen_hint_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.13, 0.76)
	style.border_color = Color(UI_COLOR_MIRROR_CYAN.r, UI_COLOR_MIRROR_CYAN.g, UI_COLOR_MIRROR_CYAN.b, 0.36)
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style

func _make_fullscreen_badge_style(edge_color: Color, fill_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = Color(edge_color.r, edge_color.g, edge_color.b, 0.86)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.shadow_color = Color(0, 0, 0, 0.44)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 4)
	return style
