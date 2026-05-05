extends Control

const BOARD_SIZE := 6
const COLOR_COUNT := 4
const CLEAR_SCORE := 30
const MIN_MATCH := 3

var score := 0
var pieces: Array = []
var piece_buttons: Array = []
var selected_indices: Array = []
var selected_color := -1
var is_selecting := false
var has_cleared := false

@onready var stage_label: Label = %StageLabel
@onready var gauge: ProgressBar = %RestoreGauge
@onready var board: GridContainer = %Board

func _ready() -> void:
	randomize()
	stage_label.text = "Stage %d - Drag same colors, release at 3+" % (GameState.selected_stage_index + 1)
	gauge.max_value = CLEAR_SCORE
	gauge.value = 0
	_generate_board()

func _generate_board() -> void:
	board.columns = BOARD_SIZE
	pieces.clear()
	piece_buttons.clear()
	selected_indices.clear()
	for child in board.get_children():
		child.queue_free()
	for i in BOARD_SIZE * BOARD_SIZE:
		pieces.append(randi() % COLOR_COUNT)
		var button := Button.new()
		button.custom_minimum_size = Vector2(72, 72)
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.gui_input.connect(_on_piece_gui_input.bind(i))
		button.mouse_entered.connect(_on_piece_mouse_entered.bind(i))
		piece_buttons.append(button)
		board.add_child(button)
	_update_board_view()

func _input(event: InputEvent) -> void:
	if has_cleared or not is_selecting:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_finish_selection()
	elif event is InputEventScreenTouch and not event.pressed:
		_finish_selection()

func _on_piece_gui_input(event: InputEvent, index: int) -> void:
	if has_cleared:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_start_selection(index)
	elif event is InputEventScreenTouch and event.pressed:
		_start_selection(index)

func _on_piece_mouse_entered(index: int) -> void:
	if has_cleared:
		return
	if is_selecting:
		_try_add_to_selection(index)

func _start_selection(index: int) -> void:
	is_selecting = true
	selected_indices = [index]
	selected_color = int(pieces[index])
	_update_board_view()

func _try_add_to_selection(index: int) -> void:
	if selected_indices.is_empty():
		return
	if int(pieces[index]) != selected_color:
		return
	var last_index := int(selected_indices[selected_indices.size() - 1])
	if selected_indices.size() >= 2 and index == int(selected_indices[selected_indices.size() - 2]):
		selected_indices.pop_back()
		_update_board_view()
		return
	if selected_indices.has(index):
		return
	if not _is_adjacent(last_index, index):
		return
	selected_indices.append(index)
	_update_board_view()

func _finish_selection() -> void:
	is_selecting = false
	var cleared_now := false
	if selected_indices.size() >= MIN_MATCH:
		cleared_now = _resolve_match(selected_indices.duplicate())
	if cleared_now:
		return
	selected_indices.clear()
	selected_color = -1
	_update_board_view()

func _resolve_match(indices: Array) -> bool:
	var removed := {}
	for index in indices:
		removed[int(index)] = true
	score += indices.size()
	gauge.value = score
	_drop_and_refill(removed)
	if score >= CLEAR_SCORE:
		_clear_stage()
		return true
	return false

func _drop_and_refill(removed: Dictionary) -> void:
	for col in range(BOARD_SIZE):
		var kept: Array = []
		for row in range(BOARD_SIZE - 1, -1, -1):
			var index := _to_index(row, col)
			if not removed.has(index):
				kept.append(int(pieces[index]))
		for row in range(BOARD_SIZE - 1, -1, -1):
			var index := _to_index(row, col)
			if kept.size() > 0:
				pieces[index] = kept.pop_front()
			else:
				pieces[index] = randi() % COLOR_COUNT

func _is_adjacent(a: int, b: int) -> bool:
	var a_row := int(a / BOARD_SIZE)
	var a_col := a % BOARD_SIZE
	var b_row := int(b / BOARD_SIZE)
	var b_col := b % BOARD_SIZE
	var row_distance := abs(a_row - b_row)
	var col_distance := abs(a_col - b_col)
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
	for i in range(piece_buttons.size()):
		var button: Button = piece_buttons[i]
		var piece_color := int(pieces[i])
		button.text = _piece_symbol(piece_color)
		if selected_indices.has(i):
			button.text = "✓\n" + _piece_text(piece_color)
			button.modulate = Color(1.25, 1.25, 1.25)
		else:
			button.modulate = _piece_modulate(piece_color)

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
	GameState.clear_selected_stage()
	call_deferred("_go_to_collection")

func _go_to_collection() -> void:
	get_tree().change_scene_to_file("res://scenes/collection/collection.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/stage_select/stage_select.tscn")
