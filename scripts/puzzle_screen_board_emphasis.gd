extends "res://scripts/puzzle_screen_status_emphasis.gd"

const COLLECTION_TRANSITION_EXTRA_DELAY: float = 0.85

var board_frame_tween: Tween = null
var retry_button_tween: Tween = null
var chain_burst_tween: Tween = null
var collection_transition_delay_started: bool = false

func _setup_stage_info() -> void:
	super._setup_stage_info()
	collection_transition_delay_started = false
	_reset_board_frame_emphasis()
	_reset_retry_button_emphasis()
	_clear_chain_burst_popup()

func _on_retry_pressed() -> void:
	super._on_retry_pressed()
	collection_transition_delay_started = false
	_reset_board_frame_emphasis()
	_reset_retry_button_emphasis()
	_clear_chain_burst_popup()

func _clear_stage() -> void:
	super._clear_stage()
	_reset_board_frame_emphasis()
	_reset_retry_button_emphasis()
	_clear_chain_burst_popup()

func _go_to_collection() -> void:
	if collection_transition_delay_started:
		return
	collection_transition_delay_started = true
	get_tree().create_timer(COLLECTION_TRANSITION_EXTRA_DELAY).timeout.connect(_go_to_collection_after_clear_delay)

func _go_to_collection_after_clear_delay() -> void:
	get_tree().change_scene_to_file("res://scenes/collection/collection.tscn")

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
	if combo_count >= 5 and not did_clear:
		_play_chain_burst_popup()
	return did_clear

func _play_chain_burst_popup() -> void:
	_clear_chain_burst_popup()
	var popup: Label = Label.new()
	popup.name = "ChainBurstPopup"
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.text = _chain_burst_text(character_name_label.text)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.add_theme_font_size_override("font_size", 38)
	popup.add_theme_color_override("font_color", Color(1.0, 0.96, 0.58, 1.0))
	popup.add_theme_color_override("font_outline_color", Color(0.08, 0.05, 0.16, 1.0))
	popup.add_theme_constant_override("outline_size", 8)
	popup.custom_minimum_size = Vector2(360, 108)
	popup.modulate = Color(1, 1, 1, 0)
	add_child(popup)
	move_child(popup, get_child_count() - 1)
	var center_position: Vector2 = board.global_position + board.size * 0.5
	popup.global_position = center_position - Vector2(180, 132)
	popup.pivot_offset = popup.custom_minimum_size * 0.5
	popup.scale = Vector2(0.76, 0.76)
	chain_burst_tween = create_tween()
	chain_burst_tween.set_parallel(true)
	chain_burst_tween.tween_property(popup, "modulate", Color(1, 1, 1, 1), 0.10)
	chain_burst_tween.tween_property(popup, "scale", Vector2(1.12, 1.12), 0.14)
	chain_burst_tween.tween_property(popup, "position", popup.position + Vector2(0, -20), 0.46)
	chain_burst_tween.set_parallel(false)
	chain_burst_tween.tween_property(popup, "scale", Vector2.ONE, 0.10)
	chain_burst_tween.tween_property(popup, "modulate", Color(1, 1, 1, 0), 0.22)
	chain_burst_tween.tween_callback(_clear_chain_burst_popup)

func _chain_burst_text(character_id: String) -> String:
	match character_id:
		"Rin":
			return "CHAIN BURST!\nKEEP GOING!"
		"Moka":
			return "BIG CHAIN!\nGO GO!"
		"Kaede":
			return "CHAIN FLOW\nSTAY FOCUSED"
		_:
			return "CHAIN BURST!"

func _clear_chain_burst_popup() -> void:
	if chain_burst_tween != null:
		chain_burst_tween.kill()
		chain_burst_tween = null
	var popup: Node = get_node_or_null("ChainBurstPopup")
	if popup != null:
		popup.queue_free()

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
