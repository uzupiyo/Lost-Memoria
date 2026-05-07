extends "res://scripts/puzzle_screen_status_emphasis.gd"

var board_frame_tween: Tween = null
var retry_button_tween: Tween = null

func _setup_stage_info() -> void:
	super._setup_stage_info()
	_reset_board_frame_emphasis()
	_reset_retry_button_emphasis()

func _on_retry_pressed() -> void:
	super._on_retry_pressed()
	_reset_board_frame_emphasis()
	_reset_retry_button_emphasis()

func _clear_stage() -> void:
	super._clear_stage()
	_reset_board_frame_emphasis()
	_reset_retry_button_emphasis()

func _update_move_pressure_message() -> void:
	super._update_move_pressure_message()
	if has_cleared:
		_reset_retry_button_emphasis()
		return
	if moves <= 0:
		_play_retry_button_emphasis()
	else:
		_reset_retry_button_emphasis()

func _resolve_match(indices: Array[int]) -> bool:
	var did_clear: bool = super._resolve_match(indices)
	if score >= CLEAR_SCORE:
		_play_board_frame_complete_emphasis()
	else:
		_play_board_frame_match_emphasis()
	return did_clear

func _play_board_frame_match_emphasis() -> void:
	var target_scale: float = 1.015
	var highlight_color: Color = Color(1.0, 0.92, 0.58, 1.0)
	if combo_count >= 5:
		target_scale = 1.045
		highlight_color = Color(1.0, 0.98, 0.68, 1.0)
	elif combo_count >= 3:
		target_scale = 1.03
		highlight_color = Color(1.0, 0.95, 0.62, 1.0)
	_play_board_frame_feedback(target_scale, highlight_color, 0.08, 0.18)

func _play_board_frame_complete_emphasis() -> void:
	_play_board_frame_feedback(1.06, Color(1.0, 1.0, 0.72, 1.0), 0.12, 0.28)

func _play_board_frame_feedback(target_scale: float, highlight_color: Color, up_duration: float, down_duration: float) -> void:
	if board_frame == null:
		return
	if board_frame_tween != null:
		board_frame_tween.kill()
	board_frame.pivot_offset = board_frame.size * 0.5
	board_frame_tween = create_tween()
	board_frame_tween.set_parallel(true)
	board_frame_tween.tween_property(board_frame, "scale", Vector2(target_scale, target_scale), up_duration)
	board_frame_tween.tween_property(board_frame, "modulate", highlight_color, up_duration)
	board_frame_tween.set_parallel(false)
	board_frame_tween.tween_property(board_frame, "scale", Vector2.ONE, down_duration)
	board_frame_tween.tween_property(board_frame, "modulate", Color(1, 1, 1, 1), down_duration)
	board_frame_tween.tween_callback(_on_board_frame_emphasis_finished)

func _on_board_frame_emphasis_finished() -> void:
	board_frame_tween = null

func _reset_board_frame_emphasis() -> void:
	if board_frame_tween != null:
		board_frame_tween.kill()
		board_frame_tween = null
	if board_frame != null:
		board_frame.scale = Vector2.ONE
		board_frame.modulate = Color(1, 1, 1, 1)

func _get_retry_button() -> Button:
	return get_node_or_null("MarginContainer/Root/FooterRow/RetryButton") as Button

func _play_retry_button_emphasis() -> void:
	var retry_button: Button = _get_retry_button()
	if retry_button == null:
		return
	if retry_button_tween != null:
		return
	retry_button.pivot_offset = retry_button.size * 0.5
	retry_button_tween = create_tween()
	retry_button_tween.set_loops()
	retry_button_tween.set_parallel(true)
	retry_button_tween.tween_property(retry_button, "scale", Vector2(1.08, 1.08), 0.28)
	retry_button_tween.tween_property(retry_button, "modulate", Color(1.0, 0.86, 0.46, 1.0), 0.28)
	retry_button_tween.set_parallel(false)
	retry_button_tween.tween_property(retry_button, "scale", Vector2.ONE, 0.28)
	retry_button_tween.tween_property(retry_button, "modulate", Color(1, 1, 1, 1), 0.28)

func _reset_retry_button_emphasis() -> void:
	if retry_button_tween != null:
		retry_button_tween.kill()
		retry_button_tween = null
	var retry_button: Button = _get_retry_button()
	if retry_button != null:
		retry_button.scale = Vector2.ONE
		retry_button.modulate = Color(1, 1, 1, 1)
