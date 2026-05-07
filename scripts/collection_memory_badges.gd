extends "res://scripts/collection_rank_badges.gd"

const MEMORY_STATUS_BADGE_NAME: String = "MemoryStatusBadge"
const MEMORY_PERCENT_BADGE_NAME: String = "MemoryPercentBadge"

var memory_badge_tween: Tween = null

func _ready() -> void:
	super._ready()
	_refresh_memory_badges_for_current()

func _update_collection_view(still_id: String) -> void:
	super._update_collection_view(still_id)
	_rebuild_memory_badges(still_id)

func _show_current() -> void:
	super._show_current()
	_refresh_memory_badges_for_current()

func _refresh_memory_badges_for_current() -> void:
	if still_ids.is_empty():
		_clear_memory_badges()
		return
	_rebuild_memory_badges(str(still_ids[current_index]))

func _rebuild_memory_badges(still_id: String) -> void:
	_clear_memory_badges()
	var still_stack: Control = get_node_or_null("Root/MainRow/StillFrame/StillStack") as Control
	if still_stack == null:
		return
	var data: Dictionary = GameState.get_still_data(still_id)
	if data.is_empty():
		return
	var unlocked_stages: int = int(data.get("unlocked_stages", 0))
	var total_stages: int = int(data.get("total_stages", GameState.STILL_STAGE_COUNT))
	var percent: int = GameState.get_unlock_percent(still_id)
	var is_complete: bool = unlocked_stages >= total_stages
	var is_perfect: bool = _rank_count(still_id, total_stages, "S") >= total_stages

	var status_text: String = "LOCKED"
	var status_color: Color = UI_COLOR_LOCKED
	var status_fill: Color = Color(0.03, 0.04, 0.07, 0.76)
	if is_perfect:
		status_text = "PERFECT MEMORY"
		status_color = UI_COLOR_RESTORATION_GOLD
		status_fill = Color(0.22, 0.15, 0.04, 0.86)
	elif is_complete:
		status_text = "MEMORY COMPLETE"
		status_color = UI_COLOR_MIRROR_CYAN
		status_fill = Color(0.02, 0.16, 0.22, 0.84)
	elif unlocked_stages > 0:
		status_text = "SHARD %d/%d" % [unlocked_stages, total_stages]
		status_color = UI_COLOR_MIST_BLUE
		status_fill = Color(0.05, 0.07, 0.13, 0.82)

	var status_badge: Label = _make_memory_overlay_badge(status_text, status_color, status_fill, 20, Vector2(300, 46))
	status_badge.name = MEMORY_STATUS_BADGE_NAME
	status_badge.set_anchors_preset(Control.PRESET_TOP_LEFT)
	status_badge.offset_left = 20
	status_badge.offset_top = 20
	status_badge.offset_right = 320
	status_badge.offset_bottom = 66
	still_stack.add_child(status_badge)
	still_stack.move_child(status_badge, still_stack.get_child_count() - 1)

	var percent_badge: Label = _make_memory_overlay_badge("%d%% RESTORED" % percent, status_color, Color(0.04, 0.06, 0.13, 0.82), 18, Vector2(210, 42))
	percent_badge.name = MEMORY_PERCENT_BADGE_NAME
	percent_badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	percent_badge.offset_left = -230
	percent_badge.offset_top = 20
	percent_badge.offset_right = -20
	percent_badge.offset_bottom = 62
	still_stack.add_child(percent_badge)
	still_stack.move_child(percent_badge, still_stack.get_child_count() - 1)

	_play_memory_badge_intro(status_badge, percent_badge)

func _clear_memory_badges() -> void:
	if memory_badge_tween != null:
		memory_badge_tween.kill()
		memory_badge_tween = null
	var old_status: Node = get_node_or_null("Root/MainRow/StillFrame/StillStack/%s" % MEMORY_STATUS_BADGE_NAME)
	if old_status != null:
		old_status.queue_free()
	var old_percent: Node = get_node_or_null("Root/MainRow/StillFrame/StillStack/%s" % MEMORY_PERCENT_BADGE_NAME)
	if old_percent != null:
		old_percent.queue_free()

func _make_memory_overlay_badge(text_value: String, edge_color: Color, fill_color: Color, font_size: int, min_size: Vector2) -> Label:
	var badge: Label = Label.new()
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.text = text_value
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.custom_minimum_size = min_size
	badge.add_theme_font_size_override("font_size", font_size)
	badge.add_theme_color_override("font_color", edge_color)
	badge.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	badge.add_theme_constant_override("outline_size", 4)
	badge.add_theme_stylebox_override("normal", _make_memory_badge_style(edge_color, fill_color))
	badge.modulate = Color(1, 1, 1, 0)
	return badge

func _make_memory_badge_style(edge_color: Color, fill_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = Color(edge_color.r, edge_color.g, edge_color.b, 0.82)
	style.set_border_width_all(2)
	style.set_corner_radius_all(16)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	style.shadow_color = Color(0, 0, 0, 0.36)
	style.shadow_size = 7
	style.shadow_offset = Vector2(0, 3)
	return style

func _play_memory_badge_intro(status_badge: Label, percent_badge: Label) -> void:
	if memory_badge_tween != null:
		memory_badge_tween.kill()
	status_badge.scale = Vector2(0.96, 0.96)
	percent_badge.scale = Vector2(0.96, 0.96)
	memory_badge_tween = create_tween()
	memory_badge_tween.set_parallel(true)
	memory_badge_tween.tween_property(status_badge, "modulate", Color(1, 1, 1, 1), 0.16)
	memory_badge_tween.tween_property(status_badge, "scale", Vector2.ONE, 0.16)
	memory_badge_tween.tween_property(percent_badge, "modulate", Color(1, 1, 1, 1), 0.18).set_delay(0.04)
	memory_badge_tween.tween_property(percent_badge, "scale", Vector2.ONE, 0.18).set_delay(0.04)
	memory_badge_tween.set_parallel(false)
	memory_badge_tween.tween_callback(_on_memory_badge_intro_finished)

func _on_memory_badge_intro_finished() -> void:
	memory_badge_tween = null
