extends Control

const BOARD_SIZE: int = 6
const COLOR_COUNT: int = 4
const CLEAR_SCORE: int = 30
const MIN_MATCH: int = 3

var score: int = 0
var pieces: Array[int] = []
var piece_buttons: Array[Button] = []
var selected_indices: Array[int] = []
var selected_color: int = -1
var is_selecting: bool = false
var has_cleared: bool = false
var pending_scene_change: bool = false

@onready var stage_label: Label = %StageLabel
@onready var gauge: ProgressBar = %RestoreGauge
@onready var board: GridContainer = %Board

func _ready() -> void:
	randomize()
	stage_label.text = "Stage %d - Drag same colors, release at 3+ / diagonal OK" % (GameState.selected_stage_index + 1)
	gauge.max_value = CLEAR_SCORE
	gauge.value = 0
	_generate_board()

func _process(_delta: float) -> void:
	if has_cleared or not is_selecting:
		return
	var hovered_index: int = _get_piece_index_at_position(get_global_mouse_position())
	if hovered_index >= 0:
		_try_add_to_selection(hovered_index)

func _generate_board() -> void:
	board.columns = BOARD_SIZE
	pieces.clear()
	piece_buttons.clear()
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
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(72, 72)
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.gui_input.connect(_on_piece_gui_input.bind(create_index))
		piece_buttons.append(button)
		board.add_child(button)
		create_index += 1
	_update_board_view()

func _input(event: InputEvent) -> void:
	if has_cleared or not is_selecting:
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
	if has_cleared:
		return
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_start_selection(index)
	elif event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			_start_selection(index)

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
		var remove_index: int = indices[index_cursor]
		removed[remove_index] = true
		index_cursor += 1
	score += indices.size()
	gauge.value = min(score, CLEAR_SCORE)
	if score >= CLEAR_SCORE:
		_clear_stage()
		return true
	_drop_and_refill(removed)
	return false

func _drop_and_refill(removed: Dictionary) -> void:
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

func _get_piece_index_at_position(global_position: Vector2) -> int:
	var i: int = 0
	while i < piece_buttons.size():
		var button: Button = piece_buttons[i]
		var rect: Rect2 = Rect2(button.global_position, button.size)
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

func _piece_text(index: int) -> String:
	match index:
		0:
			return "Red"
		1:
			return "Blue"
		2:
			return "Gold"
		_:
			return "Green"

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
	if piece_buttons.size() != pieces.size():
		return
	var i: int = 0
	while i < piece_buttons.size():
		var button: Button = piece_buttons[i]
		var piece_color: int = pieces[i]
		button.text = _piece_symbol(piece_color)
		if selected_indices.has(i):
			button.text = "✓\n" + _piece_text(piece_color)
			button.modulate = Color(1.25, 1.25, 1.25)
		else:
			button.modulate = _piece_modulate(piece_color)
		i += 1

func _piece_modulate(index: int) -> Color:
	match index:
		0:
			return Color(1.0, 0.55, 0.55)
		1:
			return Color(0.55, 0.75, 1.0)
		2:
			return Color(1.0, 0.88, 0.45)
		_:
			return Color(0.55, 1.0, 0.65)

func _clear_stage() -> void:
	if has_cleared:
		return
	has_cleared = true
	is_selecting = false
	selected_indices.clear()
	selected_color = -1
	GameState.clear_selected_stage()
	if not pending_scene_change:
		pending_scene_change = true
		get_tree().create_timer(0.25).timeout.connect(_go_to_collection)

func _go_to_collection() -> void:
	get_tree().change_scene_to_file("res://scenes/collection/collection.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/stage_select/stage_select.tscn")
