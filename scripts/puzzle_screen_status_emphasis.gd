extends "res://scripts/puzzle_screen_character_messages.gd"

var moves_label_tween: Tween = null
var score_label_tween: Tween = null

func _setup_stage_info() -> void:
	super._setup_stage_info()
	_reset_moves_label_emphasis()
	_reset_score_label_emphasis()

func _on_retry_pressed() -> void:
	super._on_retry_pressed()
	_reset_moves_label_emphasis()
	_reset_score_label_emphasis()

func _clear_stage() -> void:
	super._clear_stage()
	_reset_moves_label_emphasis()

func _resolve_match(indices: Array[int]) -> bool:
	var did_clear: bool = super._resolve_match(indices)
	_play_score_label_emphasis()
	return did_clear

func _update_move_pressure_message() -> void:
	super._update_move_pressure_message()
	_update_moves_label_emphasis()

func _update_moves_label_emphasis() -> void:
	if moves <= 0:
		_play_moves_label_emphasis(Color(1.0, 0.56, 0.36, 1.0), 1.18)
	elif moves <= 5:
		_play_moves_label_emphasis(Color(1.0, 0.78, 0.42, 1.0), 1.10)
	else:
		_reset_moves_label_emphasis()

func _play_moves_label_emphasis(target_color: Color, target_scale: float) -> void:
	if moves_label == null:
		return
	if moves_label_tween != null:
		moves_label_tween.kill()
	moves_label.pivot_offset = moves_label.size * 0.5
	moves_label_tween = create_tween()
	moves_label_tween.set_parallel(true)
	moves_label_tween.tween_property(moves_label, "scale", Vector2(target_scale, target_scale), 0.08)
	moves_label_tween.tween_property(moves_label, "modulate", target_color, 0.08)
	moves_label_tween.set_parallel(false)
	moves_label_tween.tween_property(moves_label, "scale", Vector2.ONE, 0.12)
	moves_label_tween.tween_callback(_on_moves_label_emphasis_finished)

func _on_moves_label_emphasis_finished() -> void:
	moves_label_tween = null

func _reset_moves_label_emphasis() -> void:
	if moves_label_tween != null:
		moves_label_tween.kill()
		moves_label_tween = null
	if moves_label != null:
		moves_label.scale = Vector2.ONE
		moves_label.modulate = Color(1, 1, 1, 1)

func _play_score_label_emphasis() -> void:
	if score_label == null:
		return
	if score_label_tween != null:
		score_label_tween.kill()
	var target_scale: float = 1.08
	if combo_count >= 5:
		target_scale = 1.18
	elif combo_count >= 3:
		target_scale = 1.14
	score_label.pivot_offset = score_label.size * 0.5
	score_label_tween = create_tween()
	score_label_tween.set_parallel(true)
	score_label_tween.tween_property(score_label, "scale", Vector2(target_scale, target_scale), 0.08)
	score_label_tween.tween_property(score_label, "modulate", Color(1.0, 0.92, 0.48, 1.0), 0.08)
	score_label_tween.set_parallel(false)
	score_label_tween.tween_property(score_label, "scale", Vector2.ONE, 0.12)
	score_label_tween.tween_property(score_label, "modulate", Color(1, 1, 1, 1), 0.12)
	score_label_tween.tween_callback(_on_score_label_emphasis_finished)

func _on_score_label_emphasis_finished() -> void:
	score_label_tween = null

func _reset_score_label_emphasis() -> void:
	if score_label_tween != null:
		score_label_tween.kill()
		score_label_tween = null
	if score_label != null:
		score_label.scale = Vector2.ONE
		score_label.modulate = Color(1, 1, 1, 1)
