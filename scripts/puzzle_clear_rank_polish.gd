extends "res://scripts/puzzle_character_colors.gd"

const CLEAR_RANK_POPUP_NAME: String = "ClearRankPopup"
const RANK_BADGE_TEXTURES: Dictionary = {
	"S": "res://assets/ui/badges/rank_s.png",
	"A": "res://assets/ui/badges/rank_a.png",
	"B": "res://assets/ui/badges/rank_b.png",
	"C": "res://assets/ui/badges/rank_c.png"
}

var polished_clear_rank_tween: Tween = null
var preview_pulse_tween: Tween = null

func _ready() -> void:
	super._ready()
	_setup_preview_panel_polish()

func _setup_stage_info() -> void:
	super._setup_stage_info()
	_setup_preview_panel_polish()

func _update_ui() -> void:
	super._update_ui()
	_refresh_preview_progress_color()

func _setup_preview_panel_polish() -> void:
	_apply_panel_style("MarginContainer/Root/MainRow/PreviewPanel", UI_COLOR_RESTORATION_GOLD)
	var preview_title: Label = get_node_or_null("MarginContainer/Root/MainRow/PreviewPanel/PreviewBox/PreviewTitle") as Label
	if preview_title != null:
		preview_title.text = "TARGET MEMORY"
		preview_title.add_theme_font_size_override("font_size", 23)
		preview_title.add_theme_color_override("font_color", UI_COLOR_RESTORATION_GOLD)
		preview_title.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
		preview_title.add_theme_constant_override("outline_size", 4)
	_setup_still_preview_frame_glow()
	_refresh_preview_progress_color()

func _setup_still_preview_frame_glow() -> void:
	var stack: Control = get_node_or_null("MarginContainer/Root/MainRow/PreviewPanel/PreviewBox/StillPreviewStack") as Control
	if stack == null:
		return
	var existing: Node = stack.get_node_or_null("PreviewAccentGlow")
	if existing == null:
		var glow: ColorRect = ColorRect.new()
		glow.name = "PreviewAccentGlow"
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glow.set_anchors_preset(Control.PRESET_FULL_RECT)
		glow.color = Color(UI_COLOR_RESTORATION_GOLD.r, UI_COLOR_RESTORATION_GOLD.g, UI_COLOR_RESTORATION_GOLD.b, 0.07)
		stack.add_child(glow)
		stack.move_child(glow, 0)

func _refresh_preview_progress_color() -> void:
	var progress_ratio: float = 0.0
	if stage_clear_score > 0:
		progress_ratio = clamp(float(score) / float(stage_clear_score), 0.0, 1.0)
	var progress_color: Color = UI_COLOR_MIST_BLUE
	if progress_ratio >= 1.0:
		progress_color = UI_COLOR_RESTORATION_GOLD
	elif progress_ratio >= 0.65:
		progress_color = UI_COLOR_MIRROR_CYAN
	progress_label.add_theme_color_override("font_color", progress_color)
	if restore_gauge != null:
		restore_gauge.add_theme_stylebox_override("fill", _make_colored_gauge_fill_style(progress_color))

func _make_colored_gauge_fill_style(fill_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.set_corner_radius_all(10)
	return style

func _clear_stage() -> void:
	_play_preview_clear_pulse()
	super._clear_stage()

func _play_preview_clear_pulse() -> void:
	var preview_stack: Control = get_node_or_null("MarginContainer/Root/MainRow/PreviewPanel/PreviewBox/StillPreviewStack") as Control
	if preview_stack == null:
		return
	if preview_pulse_tween != null:
		preview_pulse_tween.kill()
	preview_stack.pivot_offset = preview_stack.size * 0.5
	preview_pulse_tween = create_tween()
	preview_pulse_tween.tween_property(preview_stack, "scale", Vector2(1.035, 1.035), 0.12)
	preview_pulse_tween.tween_property(preview_stack, "scale", Vector2.ONE, 0.18)
	preview_pulse_tween.tween_callback(_on_preview_pulse_finished)

func _on_preview_pulse_finished() -> void:
	preview_pulse_tween = null

func _play_clear_rank_popup(rank: String = "") -> void:
	_clear_rank_popup()
	var resolved_rank: String = rank
	if resolved_rank.is_empty():
		resolved_rank = _get_clear_rank()
	var rank_color: Color = _rank_color(resolved_rank)
	var popup: PanelContainer = PanelContainer.new()
	popup.name = CLEAR_RANK_POPUP_NAME
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.custom_minimum_size = Vector2(520, 360)
	popup.add_theme_stylebox_override("panel", _make_rank_popup_style(rank_color, resolved_rank))
	popup.modulate = Color(1, 1, 1, 0)
	add_child(popup)
	move_child(popup, get_child_count() - 1)

	var box: VBoxContainer = VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 4)
	popup.add_child(box)

	var badge: TextureRect = TextureRect.new()
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.custom_minimum_size = Vector2(260, 260)
	badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	badge.texture = _load_rank_badge_texture(resolved_rank)
	box.add_child(badge)

	var rank_label: Label = Label.new()
	rank_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rank_label.text = "CLEAR RANK  %s" % resolved_rank
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rank_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rank_label.add_theme_font_size_override("font_size", 34)
	rank_label.add_theme_color_override("font_color", rank_color)
	rank_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	rank_label.add_theme_constant_override("outline_size", 6)
	box.add_child(rank_label)

	var comment_label: Label = Label.new()
	comment_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	comment_label.text = _get_clear_rank_comment(resolved_rank)
	comment_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	comment_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	comment_label.add_theme_font_size_override("font_size", 21)
	comment_label.add_theme_color_override("font_color", UI_COLOR_MEMORY_WHITE)
	comment_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	comment_label.add_theme_constant_override("outline_size", 4)
	comment_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(comment_label)

	var center_position: Vector2 = board.global_position + board.size * 0.5
	popup.global_position = center_position - Vector2(260, 180)
	popup.pivot_offset = popup.custom_minimum_size * 0.5
	popup.scale = Vector2(0.76, 0.76)
	polished_clear_rank_tween = create_tween()
	polished_clear_rank_tween.set_parallel(true)
	polished_clear_rank_tween.tween_property(popup, "modulate", Color(1, 1, 1, 1), 0.14)
	polished_clear_rank_tween.tween_property(popup, "scale", Vector2(1.10, 1.10), 0.18)
	polished_clear_rank_tween.set_parallel(false)
	polished_clear_rank_tween.tween_property(popup, "scale", Vector2.ONE, 0.16)
	polished_clear_rank_tween.tween_interval(0.88)
	polished_clear_rank_tween.tween_property(popup, "modulate", Color(1, 1, 1, 0), 0.20)
	polished_clear_rank_tween.tween_callback(_on_clear_rank_popup_finished)

func _load_rank_badge_texture(rank: String) -> Texture2D:
	var path: String = RANK_BADGE_TEXTURES.get(rank, "")
	if path.is_empty():
		return null
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D

func _clear_rank_popup() -> void:
	if polished_clear_rank_tween != null:
		polished_clear_rank_tween.kill()
		polished_clear_rank_tween = null
	super._clear_rank_popup()
	var popup: Node = get_node_or_null(CLEAR_RANK_POPUP_NAME)
	if popup != null:
		popup.queue_free()

func _on_clear_rank_popup_finished() -> void:
	polished_clear_rank_tween = null
	var popup: Node = get_node_or_null(CLEAR_RANK_POPUP_NAME)
	if popup != null:
		popup.queue_free()

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
			return UI_COLOR_MEMORY_WHITE

func _make_rank_popup_style(rank_color: Color, rank: String) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.13, 0.78)
	style.border_color = Color(rank_color.r, rank_color.g, rank_color.b, 0.70)
	style.set_border_width_all(3 if rank == "S" else 2)
	style.set_corner_radius_all(24)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	style.shadow_color = Color(0, 0, 0, 0.48)
	style.shadow_size = 16 if rank == "S" else 10
	style.shadow_offset = Vector2(0, 5)
	return style
