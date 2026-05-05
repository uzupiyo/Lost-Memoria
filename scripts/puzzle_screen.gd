extends Control

const BOARD_SIZE := 6
const COLOR_COUNT := 4
const CLEAR_SCORE := 30

var score := 0

@onready var stage_label: Label = %StageLabel
@onready var gauge: ProgressBar = %RestoreGauge
@onready var board: GridContainer = %Board

func _ready() -> void:
	stage_label.text = "Stage %d" % (GameState.selected_stage_index + 1)
	gauge.max_value = CLEAR_SCORE
	gauge.value = 0
	_generate_board()

func _generate_board() -> void:
	board.columns = BOARD_SIZE
	for child in board.get_children():
		child.queue_free()
	for i in BOARD_SIZE * BOARD_SIZE:
		var button := Button.new()
		button.custom_minimum_size = Vector2(72, 72)
		button.text = _piece_text(randi() % COLOR_COUNT)
		button.pressed.connect(_on_piece_pressed.bind(button))
		board.add_child(button)

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

func _on_piece_pressed(button: Button) -> void:
	# Temporary prototype rule:
	# Each click counts as one matched piece until the drag-match system is implemented.
	button.text = _piece_text(randi() % COLOR_COUNT)
	score += 1
	gauge.value = score
	if score >= CLEAR_SCORE:
		_clear_stage()

func _clear_stage() -> void:
	GameState.clear_selected_stage()
	get_tree().change_scene_to_file("res://scenes/collection/collection.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/stage_select/stage_select.tscn")
