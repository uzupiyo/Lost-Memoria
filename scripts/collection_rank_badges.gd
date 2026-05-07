extends "res://scripts/collection.gd"

const RANK_BADGE_ROW_NAME: String = "RankBadgeRow"
const RANK_BADGE_TITLE_NAME: String = "RankBadgeTitle"

func _ready() -> void:
	super._ready()
	_refresh_rank_badges_for_current()

func _update_collection_view(still_id: String) -> void:
	super._update_collection_view(still_id)
	_rebuild_rank_badges(still_id)

func _show_current() -> void:
	super._show_current()
	_refresh_rank_badges_for_current()

func _refresh_rank_badges_for_current() -> void:
	if still_ids.is_empty():
		_clear_rank_badges()
		return
	_rebuild_rank_badges(str(still_ids[current_index]))

func _rebuild_rank_badges(still_id: String) -> void:
	_clear_rank_badges()
	var footer: VBoxContainer = get_node_or_null("Root/Footer") as VBoxContainer
	if footer == null:
		return
	var data: Dictionary = GameState.get_still_data(still_id)
	if data.is_empty():
		return
	var total_stages: int = int(data.get("total_stages", GameState.STILL_STAGE_COUNT))
	var unlocked_stages: int = int(data.get("unlocked_stages", 0))

	var title: Label = Label.new()
	title.name = RANK_BADGE_TITLE_NAME
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.text = "STAGE RANKS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", UI_COLOR_MIST_BLUE)
	title.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	title.add_theme_constant_override("outline_size", 3)

	var row: HBoxContainer = HBoxContainer.new()
	row.name = RANK_BADGE_ROW_NAME
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)

	var stage_index: int = 0
	while stage_index < total_stages:
		row.add_child(_make_rank_badge(still_id, stage_index, unlocked_stages))
		stage_index += 1

	var insert_index: int = footer.get_child_count()
	var status_index: int = _child_index_by_name(footer, "StatusLabel")
	if status_index >= 0:
		insert_index = status_index
	footer.add_child(title)
	footer.move_child(title, insert_index)
	footer.add_child(row)
	footer.move_child(row, insert_index + 1)

func _clear_rank_badges() -> void:
	var old_title: Node = get_node_or_null("Root/Footer/%s" % RANK_BADGE_TITLE_NAME)
	if old_title != null:
		old_title.queue_free()
	var old_row: Node = get_node_or_null("Root/Footer/%s" % RANK_BADGE_ROW_NAME)
	if old_row != null:
		old_row.queue_free()

func _child_index_by_name(parent: Node, child_name: String) -> int:
	var i: int = 0
	while i < parent.get_child_count():
		if parent.get_child(i).name == child_name:
			return i
		i += 1
	return -1

func _make_rank_badge(still_id: String, stage_index: int, unlocked_stages: int) -> Label:
	var rank: String = GameState.get_stage_rank(still_id, stage_index)
	var label_text: String = "%d:-" % (stage_index + 1)
	var edge_color: Color = UI_COLOR_LOCKED
	var fill_color: Color = Color(0.04, 0.05, 0.08, 0.78)
	if stage_index >= unlocked_stages and rank.is_empty():
		label_text = "%d:LOCK" % (stage_index + 1)
		edge_color = UI_COLOR_LOCKED
		fill_color = Color(0.03, 0.04, 0.07, 0.72)
	elif not rank.is_empty():
		label_text = "%d:%s" % [stage_index + 1, rank]
		edge_color = _rank_color(rank)
		fill_color = _rank_fill_color(rank)
	else:
		label_text = "%d:--" % (stage_index + 1)
		edge_color = UI_COLOR_MIST_BLUE
		fill_color = Color(0.05, 0.07, 0.13, 0.78)
	var badge: Label = Label.new()
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.text = label_text
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.custom_minimum_size = Vector2(86, 34)
	badge.add_theme_font_size_override("font_size", 15)
	badge.add_theme_color_override("font_color", edge_color)
	badge.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	badge.add_theme_constant_override("outline_size", 3)
	badge.add_theme_stylebox_override("normal", _make_rank_badge_style(edge_color, fill_color))
	return badge

func _rank_color(rank: String) -> Color:
	match rank:
		"S":
			return UI_COLOR_RESTORATION_GOLD
		"A":
			return UI_COLOR_MIRROR_CYAN
		"B":
			return UI_COLOR_DREAM_VIOLET
		"C":
			return UI_COLOR_LOCKED
		_:
			return UI_COLOR_MIST_BLUE

func _rank_fill_color(rank: String) -> Color:
	match rank:
		"S":
			return Color(0.22, 0.15, 0.04, 0.84)
		"A":
			return Color(0.02, 0.16, 0.22, 0.82)
		"B":
			return Color(0.11, 0.08, 0.22, 0.82)
		"C":
			return Color(0.08, 0.09, 0.12, 0.82)
		_:
			return Color(0.05, 0.07, 0.13, 0.78)

func _make_rank_badge_style(edge_color: Color, fill_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = Color(edge_color.r, edge_color.g, edge_color.b, 0.78)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style
