extends Control

const UI_COLOR_BACKGROUND_PANEL: Color = Color(0.063, 0.098, 0.212, 0.88)
const UI_COLOR_PANEL_EDGE: Color = Color(0.56, 0.92, 1.0, 0.32)
const UI_COLOR_MEMORY_WHITE: Color = Color(0.96, 0.98, 1.0, 1.0)
const UI_COLOR_MIST_BLUE: Color = Color(0.75, 0.84, 0.95, 1.0)
const UI_COLOR_RESTORATION_GOLD: Color = Color(1.0, 0.85, 0.42, 1.0)
const UI_COLOR_MIRROR_CYAN: Color = Color(0.51, 0.96, 1.0, 1.0)
const UI_COLOR_FRAGMENT_PINK: Color = Color(1.0, 0.62, 0.86, 1.0)
const UI_COLOR_DREAM_VIOLET: Color = Color(0.72, 0.61, 1.0, 1.0)
const UI_COLOR_LOCKED: Color = Color(0.48, 0.52, 0.62, 1.0)

var still_ids: Array = []
var current_index: int = 0
var shard_overlays: Array[Polygon2D] = []
var current_unlocked_stages: int = 0
var current_total_stages: int = 5
var unlock_notice_tween: Tween = null
var collection_intro_tween: Tween = null
var button_tweens: Dictionary = {}

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
@onready var character_portrait_effect: TextureRect = %CharacterPortraitEffect
@onready var character_name_label: Label = %CharacterNameLabel
@onready var character_situation_label: Label = %CharacterSituationLabel

func _ready() -> void:
	shard_layer.resized.connect(_on_shard_layer_resized)
	_setup_base_ui_style()
	_setup_navigation_button_style()
	_setup_shards()
	_reload_character_collection(GameState.selected_character_id, GameState.collection_focus_still_id)
	_play_collection_intro()

func _input(event: InputEvent) -> void:
	if fullscreen_viewer.visible and event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and key_event.keycode == KEY_ESCAPE:
			_hide_fullscreen()

func _setup_base_ui_style() -> void:
	collection_title_label.add_theme_color_override("font_color", UI_COLOR_RESTORATION_GOLD)
	collection_title_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	collection_title_label.add_theme_constant_override("outline_size", 5)
	title_label.add_theme_color_override("font_color", UI_COLOR_MEMORY_WHITE)
	title_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	title_label.add_theme_constant_override("outline_size", 4)
	counter_label.add_theme_color_override("font_color", UI_COLOR_MIST_BLUE)
	counter_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	counter_label.add_theme_constant_override("outline_size", 3)
	progress_label.add_theme_color_override("font_color", UI_COLOR_MEMORY_WHITE)
	progress_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	progress_label.add_theme_constant_override("outline_size", 3)
	progress_label.add_theme_stylebox_override("normal", _make_label_card_style(UI_COLOR_MIRROR_CYAN, 0.24))
	status_label.add_theme_color_override("font_color", UI_COLOR_MIST_BLUE)
	status_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	status_label.add_theme_constant_override("outline_size", 3)
	status_label.add_theme_stylebox_override("normal", _make_label_card_style(UI_COLOR_RESTORATION_GOLD, 0.18))
	overlay_label.add_theme_font_size_override("font_size", 42)
	overlay_label.add_theme_color_override("font_color", UI_COLOR_LOCKED)
	overlay_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	overlay_label.add_theme_constant_override("outline_size", 6)
	_apply_panel_style("Root/MainRow/CharacterPanel", UI_COLOR_PANEL_EDGE)
	_apply_panel_style("Root/MainRow/StillFrame", UI_COLOR_PANEL_EDGE)
	_apply_footer_card_style()

func _setup_navigation_button_style() -> void:
	var button_paths: Array[String] = [
		"Root/MainRow/CharacterPanel/CharacterBox/CharacterSwitchRow/PreviousCharacterButton",
		"Root/MainRow/CharacterPanel/CharacterBox/CharacterSwitchRow/NextCharacterButton",
		"Root/Footer/NavigationRow/PreviousButton",
		"Root/Footer/NavigationRow/NextButton",
		"Root/Footer/NavigationRow/FullscreenButton",
		"Root/Footer/StageSelectButton",
		"Root/Footer/CharacterSelectButton",
		"Root/Footer/TitleButton"
	]
	for path in button_paths:
		var button: Button = get_node_or_null(path) as Button
		if button != null:
			button.add_theme_font_size_override("font_size", 18)
			button.add_theme_color_override("font_color", UI_COLOR_MIST_BLUE)
			button.add_theme_color_override("font_hover_color", UI_COLOR_MIRROR_CYAN)
			button.add_theme_color_override("font_pressed_color", UI_COLOR_RESTORATION_GOLD)
			button.add_theme_color_override("font_disabled_color", UI_COLOR_LOCKED)
			button.add_theme_stylebox_override("normal", _make_nav_button_style(false))
			button.add_theme_stylebox_override("hover", _make_nav_button_style(true))
			button.add_theme_stylebox_override("pressed", _make_nav_button_style(true))
			button.add_theme_stylebox_override("disabled", _make_nav_button_style(false))
			button.mouse_entered.connect(_on_nav_button_mouse_entered.bind(button))
			button.mouse_exited.connect(_on_nav_button_mouse_exited.bind(button))

func _apply_panel_style(path: String, edge_color: Color) -> void:
	var panel: PanelContainer = get_node_or_null(path) as PanelContainer
	if panel != null:
		panel.add_theme_stylebox_override("panel", _make_panel_style(edge_color))

func _apply_footer_card_style() -> void:
	var footer: VBoxContainer = get_node_or_null("Root/Footer") as VBoxContainer
	if footer != null:
		footer.add_theme_constant_override("separation", 8)
	var navigation_row: HBoxContainer = get_node_or_null("Root/Footer/NavigationRow") as HBoxContainer
	if navigation_row != null:
		navigation_row.add_theme_constant_override("separation", 12)

func _make_panel_style(edge_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = UI_COLOR_BACKGROUND_PANEL
	style.border_color = edge_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.shadow_color = Color(0, 0, 0, 0.36)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 4)
	return style

func _make_label_card_style(edge_color: Color, edge_alpha: float) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.13, 0.50)
	style.border_color = Color(edge_color.r, edge_color.g, edge_color.b, edge_alpha)
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	return style

func _make_nav_button_style(is_hover: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.07, 0.13, 0.82) if not is_hover else Color(0.02, 0.16, 0.22, 0.86)
	style.border_color = Color(UI_COLOR_MIRROR_CYAN.r, UI_COLOR_MIRROR_CYAN.g, UI_COLOR_MIRROR_CYAN.b, 0.42 if not is_hover else 0.76)
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _on_nav_button_mouse_entered(button: Button) -> void:
	if button.disabled:
		return
	_tween_button(button, Vector2(1.025, 1.025), 0.10)

func _on_nav_button_mouse_exited(button: Button) -> void:
	_tween_button(button, Vector2.ONE, 0.12)

func _tween_button(button: Button, target_scale: Vector2, duration: float) -> void:
	if button_tweens.has(button):
		var old_tween: Tween = button_tweens[button]
		if old_tween != null:
			old_tween.kill()
	var tween: Tween = create_tween()
	button_tweens[button] = tween
	tween.tween_property(button, "scale", target_scale, duration)
	tween.tween_callback(_on_button_tween_finished.bind(button))

func _on_button_tween_finished(button: Button) -> void:
	button_tweens.erase(button)

func _play_collection_intro() -> void:
	if collection_intro_tween != null:
		collection_intro_tween.kill()
	var root: Control = get_node_or_null("Root") as Control
	if root == null:
		return
	var original_position: Vector2 = root.position
	root.modulate = Color(1, 1, 1, 0)
	root.position = original_position + Vector2(0, 12)
	collection_intro_tween = create_tween()
	collection_intro_tween.set_parallel(true)
	collection_intro_tween.tween_property(root, "modulate", Color(1, 1, 1, 1), 0.24)
	collection_intro_tween.tween_property(root, "position", original_position, 0.24)
	collection_intro_tween.set_parallel(false)
	collection_intro_tween.tween_callback(_on_collection_intro_finished)

func _on_collection_intro_finished() -> void:
	collection_intro_tween = null

func _reload_character_collection(character_id: String, focus_still_id: String = "") -> void:
	GameState.select_character(character_id)
	still_ids = GameState.get_still_ids_for_character(GameState.selected_character_id)
	collection_title_label.text = "%s Collection" % GameState.selected_character_id
	collection_title_label.add_theme_color_override("font_color", _character_accent_color(GameState.selected_character_id))
	current_index = 0
	if still_ids.is_empty():
		title_label.text = "No memories"
		counter_label.text = "0 / 0"
		still_image.texture = null
		overlay_label.text = "NO IMAGE"
		overlay_label.visible = true
		progress_label.text = "Mirror Shards: 0 / 0"
		status_label.text = "No stills registered"
		return
	var resolved_focus: String = focus_still_id
	if resolved_focus.is_empty():
		resolved_focus = GameState.collection_focus_still_id
	var focus_index: int = still_ids.find(resolved_focus)
	if focus_index >= 0:
		current_index = focus_index
	_update_collection_view(str(still_ids[current_index]))

func _switch_character(step: int) -> void:
	var character_ids: Array = GameState.get_character_ids()
	if character_ids.is_empty():
		return
	var current_character: String = GameState.selected_character_id
	var index: int = character_ids.find(current_character)
	if index < 0:
		index = 0
	var next_index: int = (index + step + character_ids.size()) % character_ids.size()
	var next_character: String = str(character_ids[next_index])
	_reload_character_collection(next_character)

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
	var is_complete: bool = GameState.is_still_complete(still_id)
	var is_perfect: bool = _rank_count(still_id, total_stages, "S") >= total_stages
	progress_label.text = _collection_progress_text(still_id, unlocked_stages, total_stages)
	progress_label.add_theme_color_override("font_color", _status_color(is_complete, is_perfect))
	status_label.add_theme_color_override("font_color", _status_color(is_complete, is_perfect))
	_apply_still_frame_style(is_complete, is_perfect)
	_load_still_texture(str(data.get("image_path", "")))
	_refresh_shard_polygons()
	_apply_shard_mask(unlocked_stages, total_stages)
	fullscreen_button.disabled = not is_complete
	if is_complete:
		status_label.text = "COMPLETE - Fullscreen available / %s" % _mastery_summary_text(still_id, total_stages)
		_show_unlock_notice(_complete_notice_text(still_id, total_stages))
	elif unlocked_stages > 0:
		status_label.text = "NEW MEMORY SHARD - %d%% restored / %s" % [percent, _mastery_summary_text(still_id, total_stages)]
		_show_unlock_notice("NEW MEMORY SHARD")
	else:
		status_label.text = "LOCKED - Clear stages to restore"

func _apply_still_frame_style(is_complete: bool, is_perfect: bool) -> void:
	var frame: PanelContainer = get_node_or_null("Root/MainRow/StillFrame") as PanelContainer
	if frame != null:
		frame.add_theme_stylebox_override("panel", _make_panel_style(_status_color(is_complete, is_perfect)))

func _status_color(is_complete: bool, is_perfect: bool) -> Color:
	if is_perfect:
		return UI_COLOR_RESTORATION_GOLD
	if is_complete:
		return UI_COLOR_MIRROR_CYAN
	return UI_COLOR_MEMORY_WHITE

func _collection_progress_text(still_id: String, unlocked_stages: int, total_stages: int) -> String:
	var rank_line: String = _rank_progress_text(still_id, total_stages)
	var mastery_line: String = _mastery_summary_text(still_id, total_stages)
	if rank_line.is_empty():
		return "Mirror Shards: %d / %d" % [unlocked_stages, total_stages]
	return "Mirror Shards: %d / %d\nRanks: %s\n%s" % [unlocked_stages, total_stages, rank_line, mastery_line]

func _rank_progress_text(still_id: String, total_stages: int) -> String:
	var parts: Array[String] = []
	var stage_index: int = 0
	while stage_index < total_stages:
		var rank: String = GameState.get_stage_rank(still_id, stage_index)
		if rank.is_empty():
			parts.append("%d:-" % (stage_index + 1))
		else:
			parts.append("%d:%s" % [stage_index + 1, rank])
		stage_index += 1
	return "  ".join(parts)

func _mastery_summary_text(still_id: String, total_stages: int) -> String:
	var best_rank: String = _best_rank(still_id, total_stages)
	var s_count: int = _rank_count(still_id, total_stages, "S")
	if s_count >= total_stages:
		return "PERFECT MEMORY - All S"
	if best_rank.is_empty():
		return "Best Rank: - / S Ranks 0/%d" % total_stages
	return "Best Rank: %s / S Ranks %d/%d" % [best_rank, s_count, total_stages]

func _complete_notice_text(still_id: String, total_stages: int) -> String:
	if _rank_count(still_id, total_stages, "S") >= total_stages:
		return "PERFECT MEMORY"
	return "MEMORY COMPLETE"

func _best_rank(still_id: String, total_stages: int) -> String:
	var best_rank: String = ""
	var stage_index: int = 0
	while stage_index < total_stages:
		var rank: String = GameState.get_stage_rank(still_id, stage_index)
		if _rank_value(rank) > _rank_value(best_rank):
			best_rank = rank
		stage_index += 1
	return best_rank

func _rank_count(still_id: String, total_stages: int, target_rank: String) -> int:
	var count: int = 0
	var stage_index: int = 0
	while stage_index < total_stages:
		if GameState.get_stage_rank(still_id, stage_index) == target_rank:
			count += 1
		stage_index += 1
	return count

func _rank_value(rank: String) -> int:
	match rank:
		"S":
			return 4
		"A":
			return 3
		"B":
			return 2
		"C":
			return 1
		_:
			return 0

func _show_unlock_notice(text_value: String) -> void:
	if unlock_notice_tween != null:
		unlock_notice_tween.kill()
		unlock_notice_tween = null
	status_label.pivot_offset = status_label.size * 0.5
	status_label.text = text_value + " / " + status_label.text
	unlock_notice_tween = create_tween()
	unlock_notice_tween.set_parallel(true)
	unlock_notice_tween.tween_property(status_label, "scale", Vector2(1.08, 1.08), 0.10)
	unlock_notice_tween.tween_property(status_label, "modulate", Color(1.0, 0.94, 0.58, 1.0), 0.10)
	unlock_notice_tween.set_parallel(false)
	unlock_notice_tween.tween_property(status_label, "scale", Vector2.ONE, 0.16)
	unlock_notice_tween.tween_property(status_label, "modulate", Color(1, 1, 1, 1), 0.22)
	unlock_notice_tween.tween_callback(_on_unlock_notice_finished)

func _on_unlock_notice_finished() -> void:
	unlock_notice_tween = null

func _update_character_panel(character_id: String, situation: String) -> void:
	var character_data: Dictionary = GameState.get_character_data(character_id)
	var accent: Color = _character_accent_color(character_id)
	character_name_label.text = str(character_data.get("display_name", character_id))
	character_name_label.add_theme_color_override("font_color", accent)
	character_name_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	character_name_label.add_theme_constant_override("outline_size", 4)
	character_situation_label.text = situation
	character_situation_label.add_theme_color_override("font_color", UI_COLOR_MIST_BLUE)
	character_situation_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 1.0))
	character_situation_label.add_theme_constant_override("outline_size", 3)
	character_portrait.texture = _load_character_texture(character_id, "portrait")
	character_portrait_effect.texture = _load_character_texture(character_id, "effect")
	_apply_panel_style("Root/MainRow/CharacterPanel", Color(accent.r, accent.g, accent.b, 0.42))

func _character_accent_color(character_id: String) -> Color:
	match character_id:
		"Rin":
			return UI_COLOR_RESTORATION_GOLD
		"Moka":
			return UI_COLOR_FRAGMENT_PINK
		"Kaede":
			return UI_COLOR_MIRROR_CYAN
		_:
			return UI_COLOR_DREAM_VIOLET

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
			paths.append("res://assets/ui/characters/%s_portrait_card.webp" % character_id)
			paths.append("res://assets/ui/characters/%s_portrait_card.png" % character_id)
			paths.append("res://assets/ui/characters/%s_card.webp" % character_id)
			paths.append("res://assets/ui/characters/%s_card.png" % character_id)
			paths.append(_get_first_still_image_path(character_id))
		"effect":
			paths.append(str(data.get("effect_path", "")))
			paths.append("res://assets/ui/characters/effects/%s_effect.png" % character_id)
			paths.append("res://assets/ui/characters/effects/%s_effect.webp" % character_id)
	return paths

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

func _on_previous_character_pressed() -> void:
	_switch_character(-1)

func _on_next_character_pressed() -> void:
	_switch_character(1)

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
