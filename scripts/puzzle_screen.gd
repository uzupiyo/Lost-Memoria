extends Control

const BOARD_SIZE: int = 6
const COLOR_COUNT: int = 4
const CLEAR_SCORE: int = 30
const MIN_MATCH: int = 3
const PIECE_SIZE: Vector2 = Vector2(82, 82)
const ORB_SIZE: Vector2 = Vector2(78, 78)
const SD_FRAME_PATH: String = "res://assets/puzzle/ui/sd_character_frame.png"
const BOARD_FRAME_PATH: String = "res://assets/puzzle/ui/puzzle_board_frame.png"
const STILL_PREVIEW_FRAME_PATH: String = "res://assets/puzzle/ui/still_preview_frame.png"
const PUZZLE_BACKGROUND_PATH: String = "res://assets/puzzle/ui/puzzle_scene_background.png"
const SD_IDLE_AMPLITUDE: float = 8.0
const SD_IDLE_SPEED: float = 2.4
const SD_FRAME_INTERVAL: float = 0.35
const SD_ACTION_FRAME_INTERVAL: float = 0.12
const SD_MATCH_BUMP_SCALE: Vector2 = Vector2(1.08, 1.08)
const SD_MAX_IDLE_FRAMES: int = 8
const SD_MAX_ACTION_FRAMES: int = 4
const CLEAR_FLASH_PEAK_ALPHA: float = 0.38
const MATCH_EFFECT_DELAY: float = 0.16
const MATCH_EFFECT_SCALE: Vector2 = Vector2(1.12, 1.12)
const REFILL_DROP_OFFSET_Y: float = -18.0
const REFILL_ROW_STAGGER: float = 0.018
const REFILL_ANIM_DURATION: float = 0.16

const DROP_PATHS: Array[String] = [
	"res://assets/puzzle/drops/memory_orb_red.png",
	"res://assets/puzzle/drops/memory_orb_blue.png",
	"res://assets/puzzle/drops/memory_orb_gold.png",
	"res://assets/puzzle/drops/memory_orb_green.png"
]

const DROP_PATHS_FALLBACK: Array[String] = [
	"res://assets/puzzle/drop/memory_orb_red.png",
	"res://assets/puzzle/drop/memory_orb_blue.png",
	"res://assets/puzzle/drop/memory_orb_gold.png",
	"res://assets/puzzle/drop/memory_orb_blue.png"
]

var score: int = 0
var moves: int = 25
var pieces: Array[int] = []
var piece_controls: Array[PanelContainer] = []
var selected_indices: Array[int] = []
var selected_color: int = -1
var is_selecting: bool = false
var is_resolving_match: bool = false
var has_cleared: bool = false
var pending_scene_change: bool = false
var drop_textures: Dictionary = {}
var sd_idle_time: float = 0.0
var sd_frame_timer: float = 0.0
var sd_idle_frame_index: int = 0
var sd_action_frame_index: int = 0
var sd_action_frame_timer: float = 0.0
var sd_action_playing: bool = false
var sd_idle_textures: Array[Texture2D] = []
var sd_match_textures: Array[Texture2D] = []
var sd_clear_textures: Array[Texture2D] = []
var sd_current_action_textures: Array[Texture2D] = []
var sd_base_position: Vector2 = Vector2.ZERO
var sd_has_base_position: bool = false

@onready var stage_label: Label = %StageLabel
@onready var target_label: Label = %TargetLabel
@onready var moves_label: Label = %MovesLabel
@onready var score_label: Label = %ScoreLabel
@onready var character_name_label: Label = %CharacterNameLabel
@onready var sd_frame: TextureRect = %SdFrame
@onready var sd_character: TextureRect = %SdCharacter
@onready var sd_message_label: Label = %SdMessageLabel
@onready var board_frame: TextureRect = %BoardFrame
@onready var still_preview_frame: TextureRect = %StillPreviewFrame
@onready var gauge: ProgressBar = %RestoreGauge
@onready var progress_label: Label = %ProgressLabel
@onready var board: GridContainer = %Board
@onready var still_preview: TextureRect = %StillPreview

func _ready() -> void:
	randomize()
	_setup_background()
	_load_drop_textures()
	_setup_stage_info()
	_setup_sd_animation_base()
	_generate_board()

func _setup_background() -> void:
	var background_texture: Texture2D = _load_texture_optional(PUZZLE_BACKGROUND_PATH)
	if background_texture == null:
		return
	var background_node: Control = get_node_or_null("Background") as Control
	if background_node == null:
		return
	var background_image: TextureRect = background_node.get_node_or_null("BackgroundImage") as TextureRect
	if background_image == null:
		background_image = TextureRect.new()
		background_image.name = "BackgroundImage"
		background_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		background_image.set_anchors_preset(Control.PRESET_FULL_RECT)
		background_image.grow_horizontal = Control.GROW_DIRECTION_BOTH
		background_image.grow_vertical = Control.GROW_DIRECTION_BOTH
		background_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		background_node.add_child(background_image)
		background_node.move_child(background_image, 0)
	background_image.texture = background_texture
	background_image.show()

func _setup_stage_info() -> void:
	var still_data: Dictionary = GameState.get_still_data(GameState.selected_still_id)
	var character_id: String = str(still_data.get("character", GameState.selected_character_id))
	var situation: String = str(still_data.get("situation", ""))
	var stage_number: int = GameState.selected_stage_index + 1
	stage_label.text = "%s / %s / Stage %d" % [character_id, situation, stage_number]
	target_label.text = "TARGET\nMirror Shards"
	moves_label.text = "MOVES\n%d" % moves
	score_label.text = "SCORE\n0"
	character_name_label.text = character_id
	sd_message_label.text = "一緒に、記憶の欠片を集めましょう。"
	gauge.max_value = CLEAR_SCORE
	gauge.value = 0
	progress_label.text = "0% Restoration"
	sd_frame.texture = _load_texture_optional(SD_FRAME_PATH)
	board_frame.texture = _load_texture_optional(BOARD_FRAME_PATH)
	still_preview_frame.texture = _load_texture_optional(STILL_PREVIEW_FRAME_PATH)
	_load_sd_character_textures(character_id)
	if not sd_idle_textures.is_empty():
		sd_character.texture = sd_idle_textures[0]
	else:
		sd_character.texture = null
	still_preview.texture = _load_texture_optional(str(still_data.get("image_path", "")))

func _setup_sd_animation_base() -> void:
	sd_base_position = sd_character.position
	sd_character.pivot_offset = sd_character.size * 0.5
	sd_character.scale = Vector2.ONE
	sd_has_base_position = true

func _load_drop_textures() -> void:
	drop_textures.clear()
	var index: int = 0
	while index < COLOR_COUNT:
		var texture: Texture2D = _load_texture_from_paths(DROP_PATHS[index], DROP_PATHS_FALLBACK[index])
		if texture != null:
			drop_textures[index] = texture
		index += 1

func _load_texture_optional(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var loaded: Resource = load(path)
	if loaded is Texture2D:
		return loaded as Texture2D
	return null

func _load_texture_from_candidates(candidate_paths: Array[String]) -> Texture2D:
	var i: int = 0
	while i < candidate_paths.size():
		var texture: Texture2D = _load_texture_optional(candidate_paths[i])
		if texture != null:
			return texture
		i += 1
	return null

func _load_texture_from_paths(primary_path: String, fallback_path: String) -> Texture2D:
	var primary: Texture2D = _load_texture_optional(primary_path)
	if primary != null:
		return primary
	return _load_texture_optional(fallback_path)

func _load_sd_character_textures(character_id: String) -> void:
	sd_idle_textures = _load_sd_textures_for_action(character_id, "idle", SD_MAX_IDLE_FRAMES)
	sd_match_textures = _load_sd_textures_for_action(character_id, "match", SD_MAX_ACTION_FRAMES)
	sd_clear_textures = _load_sd_textures_for_action(character_id, "clear", SD_MAX_ACTION_FRAMES)
	sd_idle_frame_index = 0
	sd_frame_timer = 0.0
	sd_action_playing = false
	if sd_idle_textures.is_empty():
		var portrait_texture: Texture2D = _load_texture_optional("res://assets/ui/characters/portraits/%s_portrait.webp" % character_id)
		if portrait_texture != null:
			sd_idle_textures.append(portrait_texture)

func _load_sd_textures_for_action(character_id: String, action_name: String, max_frames: int) -> Array[Texture2D]:
	var textures: Array[Texture2D] = []
	var frame_index: int = 1
	while frame_index <= max_frames:
		var frame_name: String = "%02d" % frame_index
		var png_path: String = "res://assets/ui/characters/sd/%s/%s_%s_%s.png" % [character_id, character_id, action_name, frame_name]
		var webp_path: String = "res://assets/ui/characters/sd/%s/%s_%s_%s.webp" % [character_id, character_id, action_name, frame_name]
		var sd_png_path: String = "res://assets/ui/characters/sd/%s/%s_sd_%s_%s.png" % [character_id, character_id, action_name, frame_name]
		var sd_webp_path: String = "res://assets/ui/characters/sd/%s/%s_sd_%s_%s.webp" % [character_id, character_id, action_name, frame_name]
		var texture: Texture2D = _load_texture_from_candidates([png_path, webp_path, sd_png_path, sd_webp_path])
		if texture != null:
			textures.append(texture)
		frame_index += 1
	return textures

func _process(delta: float) -> void:
	_update_sd_animation(delta)
	if has_cleared or is_resolving_match or not is_selecting:
		return
	var hovered_index: int = _get_piece_index_at_position(get_global_mouse_position())
	if hovered_index >= 0:
		_try_add_to_selection(hovered_index)

func _update_sd_animation(delta: float) -> void:
	if not sd_has_base_position:
		return
	sd_idle_time += delta
	var offset_y: float = sin(sd_idle_time * SD_IDLE_SPEED) * SD_IDLE_AMPLITUDE
	sd_character.position = sd_base_position + Vector2(0, offset_y)
	if sd_action_playing:
		_update_sd_action_animation(delta)
	else:
		_update_sd_idle_frames(delta)

func _update_sd_idle_frames(delta: float) -> void:
	if sd_idle_textures.size() <= 1:
		return
	sd_frame_timer += delta
	if sd_frame_timer < SD_FRAME_INTERVAL:
		return
	sd_frame_timer = 0.0
	sd_idle_frame_index = (sd_idle_frame_index + 1) % sd_idle_textures.size()
	sd_character.texture = sd_idle_textures[sd_idle_frame_index]

func _update_sd_action_animation(delta: float) -> void:
	if sd_current_action_textures.is_empty():
		_stop_sd_action_animation()
		return
	sd_action_frame_timer += delta
	if sd_action_frame_timer < SD_ACTION_FRAME_INTERVAL:
		return
	sd_action_frame_timer = 0.0
	sd_action_frame_index += 1
	if sd_action_frame_index >= sd_current_action_textures.size():
		_stop_sd_action_animation()
		return
	sd_character.texture = sd_current_action_textures[sd_action_frame_index]

func _play_sd_action_animation(action_textures: Array[Texture2D]) -> bool:
	if action_textures.is_empty():
		return false
	sd_current_action_textures = action_textures
	sd_action_frame_index = 0
	sd_action_frame_timer = 0.0
	sd_action_playing = true
	sd_character.texture = sd_current_action_textures[0]
	return true

func _stop_sd_action_animation() -> void:
	sd_action_playing = false
	sd_current_action_textures.clear()
	sd_action_frame_index = 0
	sd_action_frame_timer = 0.0
	if not sd_idle_textures.is_empty():
		sd_character.texture = sd_idle_textures[sd_idle_frame_index % sd_idle_textures.size()]

func _play_sd_match_feedback() -> void:
	if sd_character == null:
		return
	var has_action_texture: bool = _play_sd_action_animation(sd_match_textures)
	var tween: Tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(sd_character, "scale", SD_MATCH_BUMP_SCALE, 0.08)
	tween.tween_property(sd_character, "scale", Vector2.ONE, 0.12)
	if has_action_texture:
		sd_message_label.text = "いい感じです。記憶が少し戻りました。"

func _play_sd_clear_feedback() -> void:
	if sd_character == null:
		return
	_play_sd_action_animation(sd_clear_textures)
	var tween: Tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(sd_character, "scale", Vector2(1.12, 1.12), 0.10)
	tween.tween_property(sd_character, "scale", Vector2.ONE, 0.16)

func _play_clear_flash() -> void:
	var flash: ColorRect = ColorRect.new()
	flash.name = "ClearFlash"
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.color = Color(1.0, 0.92, 0.55, 0.0)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.grow_horizontal = Control.GROW_DIRECTION_BOTH
	flash.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(flash)
	move_child(flash, get_child_count() - 1)
	var tween: Tween = create_tween()
	tween.tween_property(flash, "color", Color(1.0, 0.92, 0.55, CLEAR_FLASH_PEAK_ALPHA), 0.08)
	tween.tween_property(flash, "color", Color(1.0, 0.92, 0.55, 0.0), 0.36)
	tween.tween_callback(flash.queue_free)

func _play_match_cell_effect(indices: Array[int]) -> void:
	var cursor: int = 0
	while cursor < indices.size():
		var effect_index: int = indices[cursor]
		if effect_index >= 0 and effect_index < piece_controls.size():
			var piece: PanelContainer = piece_controls[effect_index]
			piece.pivot_offset = piece.size * 0.5
			var tween: Tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(piece, "scale", MATCH_EFFECT_SCALE, 0.08)
			tween.tween_property(piece, "modulate", Color(1.8, 1.65, 0.85, 1.0), 0.08)
			tween.set_parallel(false)
			tween.tween_property(piece, "scale", Vector2.ONE, 0.08)
		cursor += 1

func _play_refill_effect() -> void:
	var i: int = 0
	while i < piece_controls.size():
		var piece: PanelContainer = piece_controls[i]
		var original_position: Vector2 = piece.position
		var row: int = int(i / BOARD_SIZE)
		piece.position = original_position + Vector2(0, REFILL_DROP_OFFSET_Y)
		piece.modulate = Color(1, 1, 1, 0.0)
		var tween: Tween = create_tween()
		tween.tween_interval(float(row) * REFILL_ROW_STAGGER)
		tween.set_parallel(true)
		tween.tween_property(piece, "position", original_position, REFILL_ANIM_DURATION)
		tween.tween_property(piece, "modulate", Color(1, 1, 1, 1), REFILL_ANIM_DURATION)
		i += 1

func _play_match_popup(match_count: int) -> void:
	var popup: Label = Label.new()
	popup.name = "MatchPopup"
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.text = _match_popup_text(match_count)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.add_theme_font_size_override("font_size", 42)
	popup.add_theme_color_override("font_color", Color(1.0, 0.92, 0.48, 1.0))
	popup.add_theme_color_override("font_outline_color", Color(0.08, 0.05, 0.16, 1.0))
	popup.add_theme_constant_override("outline_size", 8)
	popup.custom_minimum_size = Vector2(260, 80)
	popup.modulate = Color(1, 1, 1, 0)
	add_child(popup)
	move_child(popup, get_child_count() - 1)
	var center_position: Vector2 = board.global_position + board.size * 0.5
	popup.global_position = center_position - Vector2(130, 70)
	popup.pivot_offset = popup.custom_minimum_size * 0.5
	popup.scale = Vector2(0.85, 0.85)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "modulate", Color(1, 1, 1, 1), 0.08)
	tween.tween_property(popup, "scale", Vector2(1.08, 1.08), 0.10)
	tween.tween_property(popup, "position", popup.position + Vector2(0, -18), 0.34)
	tween.set_parallel(false)
	tween.tween_property(popup, "modulate", Color(1, 1, 1, 0), 0.20)
	tween.tween_callback(popup.queue_free)

func _match_popup_text(match_count: int) -> String:
	if match_count >= 7:
		return "%d MATCH!\nEXCELLENT" % match_count
	if match_count >= 5:
		return "%d MATCH!\nGREAT" % match_count
	return "%d MATCH" % match_count

func _finish_match_resolution(removed: Dictionary) -> void:
	_drop_and_refill(removed)
	is_resolving_match = false

func _generate_board() -> void:
	board.columns = BOARD_SIZE
	board.add_theme_constant_override("h_separation", 2)
	board.add_theme_constant_override("v_separation", 2)
	pieces.clear()
	piece_controls.clear()
	selected_indices.clear()
	var child_index: int = board.get_child_count() - 1
	while child_index >= 0:
		var child: Node = board.get_child(child_index)
		child.queue_free()
		child_index -= 1
	var create_index: int = 0
	while create_index < BOARD_SIZE * BOARD_SIZE:
		var piece_value: int = randi() % COLOR_COUNT
		pieces.append(piece_value)
		var piece: PanelContainer = _create_piece_control(create_index)
		piece_controls.append(piece)
		board.add_child(piece)
		create_index += 1
	_update_board_view()

func _create_piece_control(index: int) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = PIECE_SIZE
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.gui_input.connect(_on_piece_gui_input.bind(index))
	panel.mouse_entered.connect(_on_piece_mouse_entered.bind(index))
	var center: CenterContainer = CenterContainer.new()
	center.name = "PieceCenter"
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(center)
	var texture_rect: TextureRect = TextureRect.new()
	texture_rect.name = "DropImage"
	texture_rect.custom_minimum_size = ORB_SIZE
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(texture_rect)
	var label: Label = Label.new()
	label.name = "FallbackLabel"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.hide()
	center.add_child(label)
	return panel

func _input(event: InputEvent) -> void:
	if has_cleared or is_resolving_match or not is_selecting:
		return
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			_finish_selection()
	elif event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if not touch_event.pressed:
			_finish_selection()
	elif event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		var hovered_index: int = _get_piece_index_at_position(drag_event.position)
		if hovered_index >= 0:
			_try_add_to_selection(hovered_index)

func _on_piece_gui_input(event: InputEvent, index: int) -> void:
	if has_cleared or is_resolving_match:
		return
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_start_selection(index)
	elif event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			_start_selection(index)

func _on_piece_mouse_entered(index: int) -> void:
	if has_cleared or is_resolving_match:
		return
	if is_selecting:
		_try_add_to_selection(index)

func _start_selection(index: int) -> void:
	is_selecting = true
	selected_indices.clear()
	selected_indices.append(index)
	selected_color = pieces[index]
	_update_board_view()

func _try_add_to_selection(index: int) -> void:
	if selected_indices.is_empty():
		return
	if index < 0 or index >= pieces.size():
		return
	if pieces[index] != selected_color:
		return
	var last_index: int = selected_indices[selected_indices.size() - 1]
	if selected_indices.size() >= 2 and index == selected_indices[selected_indices.size() - 2]:
		selected_indices.pop_back()
		_update_board_view()
		return
	if selected_indices.has(index):
		return
	if not _is_adjacent_8way(last_index, index):
		return
	selected_indices.append(index)
	_update_board_view()

func _finish_selection() -> void:
	is_selecting = false
	var did_clear: bool = false
	if selected_indices.size() >= MIN_MATCH:
		did_clear = _resolve_match(selected_indices.duplicate())
	if did_clear:
		return
	selected_indices.clear()
	selected_color = -1
	_update_board_view()

func _resolve_match(indices: Array[int]) -> bool:
	var removed: Dictionary = {}
	var index_cursor: int = 0
	while index_cursor < indices.size():
		removed[indices[index_cursor]] = true
		index_cursor += 1
	score += indices.size()
	moves = max(0, moves - 1)
	gauge.value = min(score, CLEAR_SCORE)
	var percent: int = int(float(min(score, CLEAR_SCORE)) / float(CLEAR_SCORE) * 100.0)
	moves_label.text = "MOVES\n%d" % moves
	score_label.text = "SCORE\n%d" % score
	progress_label.text = "%d%% Restoration" % percent
	_play_sd_match_feedback()
	_play_match_cell_effect(indices)
	_play_match_popup(indices.size())
	if score >= CLEAR_SCORE:
		_clear_stage()
		return true
	is_resolving_match = true
	get_tree().create_timer(MATCH_EFFECT_DELAY).timeout.connect(_finish_match_resolution.bind(removed))
	return false

func _drop_and_refill(removed: Dictionary) -> void:
	selected_indices.clear()
	selected_color = -1
	var col: int = 0
	while col < BOARD_SIZE:
		var kept: Array[int] = []
		var row: int = BOARD_SIZE - 1
		while row >= 0:
			var check_index: int = _to_index(row, col)
			if not removed.has(check_index):
				kept.append(pieces[check_index])
			row -= 1
		row = BOARD_SIZE - 1
		while row >= 0:
			var fill_index: int = _to_index(row, col)
			if kept.size() > 0:
				pieces[fill_index] = kept.pop_front()
			else:
				pieces[fill_index] = randi() % COLOR_COUNT
			row -= 1
		col += 1
	_update_board_view()
	_play_refill_effect()

func _get_piece_index_at_position(global_position: Vector2) -> int:
	var i: int = 0
	while i < piece_controls.size():
		var piece: PanelContainer = piece_controls[i]
		var rect: Rect2 = Rect2(piece.global_position, piece.size)
		if rect.has_point(global_position):
			return i
		i += 1
	return -1

func _is_adjacent_8way(a: int, b: int) -> bool:
	var a_row: int = int(a / BOARD_SIZE)
	var a_col: int = a % BOARD_SIZE
	var b_row: int = int(b / BOARD_SIZE)
	var b_col: int = b % BOARD_SIZE
	var row_distance: int = abs(a_row - b_row)
	var col_distance: int = abs(a_col - b_col)
	return row_distance <= 1 and col_distance <= 1 and row_distance + col_distance > 0

func _to_index(row: int, col: int) -> int:
	return row * BOARD_SIZE + col

func _piece_symbol(index: int) -> String:
	match index:
		0:
			return "●\nRed"
		1:
			return "●\nBlue"
		2:
			return "●\nGold"
		_:
			return "●\nGreen"

func _update_board_view() -> void:
	if piece_controls.size() != pieces.size():
		return
	var i: int = 0
	while i < piece_controls.size():
		var piece: PanelContainer = piece_controls[i]
		var piece_color: int = pieces[i]
		var texture: Texture2D = _get_drop_texture(piece_color)
		var texture_rect: TextureRect = piece.get_node_or_null("PieceCenter/DropImage") as TextureRect
		var label: Label = piece.get_node_or_null("PieceCenter/FallbackLabel") as Label
		piece.scale = Vector2.ONE
		if texture_rect != null and label != null:
			if texture != null:
				texture_rect.texture = texture
				texture_rect.show()
				label.hide()
			else:
				texture_rect.texture = null
				texture_rect.hide()
				label.text = _piece_symbol(piece_color)
				label.add_theme_color_override("font_color", _piece_font_color(piece_color))
				label.show()
		if selected_indices.has(i):
			piece.modulate = Color(1.35, 1.35, 1.35)
		else:
			piece.modulate = Color(1, 1, 1)
		i += 1

func _piece_font_color(index: int) -> Color:
	match index:
		0:
			return Color(1, 0.2, 0.25)
		1:
			return Color(0.25, 0.65, 1)
		2:
			return Color(1, 0.85, 0.1)
		_:
			return Color(0.25, 1, 0.45)

func _get_drop_texture(index: int) -> Texture2D:
	if drop_textures.has(index):
		return drop_textures[index] as Texture2D
	return null

func _clear_stage() -> void:
	if has_cleared:
		return
	has_cleared = true
	is_selecting = false
	is_resolving_match = false
	selected_indices.clear()
	selected_color = -1
	sd_message_label.text = "記憶の欠片が、またひとつ戻りました。"
	_play_sd_clear_feedback()
	_play_clear_flash()
	GameState.clear_selected_stage()
	if not pending_scene_change:
		pending_scene_change = true
		get_tree().create_timer(0.45).timeout.connect(_go_to_collection)

func _go_to_collection() -> void:
	get_tree().change_scene_to_file("res://scenes/collection/collection.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/stage_select/stage_select.tscn")

func _on_retry_pressed() -> void:
	score = 0
	moves = 25
	has_cleared = false
	pending_scene_change = false
	is_resolving_match = false
	gauge.value = 0
	moves_label.text = "MOVES\n%d" % moves
	score_label.text = "SCORE\n0"
	progress_label.text = "0% Restoration"
	sd_message_label.text = "一緒に、記憶の欠片を集めましょう。"
	_generate_board()

func _on_hint_pressed() -> void:
	sd_message_label.text = "同じ色を3つ以上、ななめにもつなげられます。"
