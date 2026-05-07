extends "res://scripts/puzzle_screen_character_messages.gd"

var moves_label_tween: Tween = null
var score_label_tween: Tween = null
var gauge_tween: Tween = null
var progress_label_tween: Tween = null
var preview_tween: Tween = null
var preview_frame_tween: Tween = null

func _setup_stage_info() -> void:
	super._setup_stage_info()
	_reset_moves_label_emphasis()
	_reset_score_label_emphasis()
	_reset_restore_gauge_emphasis()
	_reset_preview_emphasis()

func _on_retry_pressed() -> void:
	super._on_retry_pressed()
	_reset_moves_label_emphasis()
	_reset_score_label_emphasis()
	_reset_restore_gauge_emphasis()
	_reset_preview_emphasis()

func _clear_stage() -> void:
	super._clear_stage()
	_reset_moves_label_emphasis()

func _resolve_match(indices: Array[int]) -> bool:
	var did_clear: bool = super._resolve_match(indices)
	_play_score_label_emphasis()
	if score >= CLEAR_SCORE:
		_play_restore_complete_emphasis()
		_play_preview_complete_emphasis()
	else:
		_play_restore_gauge_emphasis()
		_play_preview_emphasis()
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

func _play_restore_gauge_emphasis() -> void:
	_play_restore_feedback(1.04, 1.08, Color(1.0, 0.92, 0.52, 1.0), 0.08, 0.14)

func _play_restore_complete_emphasis() -> void:
	_play_restore_feedback(1.10, 1.16, Color(1.0, 0.98, 0.62, 1.0), 0.12, 0.24)

func _play_restore_feedback(gauge_scale: float, label_scale: float, highlight_color: Color, up_duration: float, down_duration: float) -> void:
	if gauge != null:
		if gauge_tween != null:
			gauge_tween.kill()
		gauge.pivot_offset = gauge.size * 0.5
		gauge_tween = create_tween()
		gauge_tween.set_parallel(true)
		gauge_tween.tween_property(gauge, "scale", Vector2(gauge_scale, gauge_scale), up_duration)
		gauge_tween.tween_property(gauge, "modulate", highlight_color, up_duration)
		gauge_tween.set_parallel(false)
		gauge_tween.tween_property(gauge, "scale", Vector2.ONE, down_duration)
		gauge_tween.tween_property(gauge, "modulate", Color(1, 1, 1, 1), down_duration)
		gauge_tween.tween_callback(_on_restore_gauge_emphasis_finished)
	if progress_label != null:
		if progress_label_tween != null:
			progress_label_tween.kill()
		progress_label.pivot_offset = progress_label.size * 0.5
		progress_label_tween = create_tween()
		progress_label_tween.set_parallel(true)
		progress_label_tween.tween_property(progress_label, "scale", Vector2(label_scale, label_scale), up_duration)
		progress_label_tween.tween_property(progress_label, "modulate", highlight_color, up_duration)
		progress_label_tween.set_parallel(false)
		progress_label_tween.tween_property(progress_label, "scale", Vector2.ONE, down_duration)
		progress_label_tween.tween_property(progress_label, "modulate", Color(1, 1, 1, 1), down_duration)
		progress_label_tween.tween_callback(_on_progress_label_emphasis_finished)

func _on_restore_gauge_emphasis_finished() -> void:
	gauge_tween = null

func _on_progress_label_emphasis_finished() -> void:
	progress_label_tween = null

func _reset_restore_gauge_emphasis() -> void:
	if gauge_tween != null:
		gauge_tween.kill()
		gauge_tween = null
	if progress_label_tween != null:
		progress_label_tween.kill()
		progress_label_tween = null
	if gauge != null:
		gauge.scale = Vector2.ONE
		gauge.modulate = Color(1, 1, 1, 1)
	if progress_label != null:
		progress_label.scale = Vector2.ONE
		progress_label.modulate = Color(1, 1, 1, 1)

func _play_preview_emphasis() -> void:
	_play_preview_feedback(1.035, 1.04, Color(1.0, 0.92, 0.58, 1.0), 0.08, 0.16)

func _play_preview_complete_emphasis() -> void:
	_play_preview_feedback(1.08, 1.10, Color(1.0, 0.98, 0.66, 1.0), 0.12, 0.26)

func _play_preview_feedback(preview_scale: float, frame_scale: float, highlight_color: Color, up_duration: float, down_duration: float) -> void:
	if still_preview != null:
		if preview_tween != null:
			preview_tween.kill()
		still_preview.pivot_offset = still_preview.size * 0.5
		preview_tween = create_tween()
		preview_tween.set_parallel(true)
		preview_tween.tween_property(still_preview, "scale", Vector2(preview_scale, preview_scale), up_duration)
		preview_tween.tween_property(still_preview, "modulate", highlight_color, up_duration)
		preview_tween.set_parallel(false)
		preview_tween.tween_property(still_preview, "scale", Vector2.ONE, down_duration)
		preview_tween.tween_property(still_preview, "modulate", Color(1, 1, 1, 1), down_duration)
		preview_tween.tween_callback(_on_preview_emphasis_finished)
	if still_preview_frame != null:
		if preview_frame_tween != null:
			preview_frame_tween.kill()
		still_preview_frame.pivot_offset = still_preview_frame.size * 0.5
		preview_frame_tween = create_tween()
		preview_frame_tween.set_parallel(true)
		preview_frame_tween.tween_property(still_preview_frame, "scale", Vector2(frame_scale, frame_scale), up_duration)
		preview_frame_tween.tween_property(still_preview_frame, "modulate", highlight_color, up_duration)
		preview_frame_tween.set_parallel(false)
		preview_frame_tween.tween_property(still_preview_frame, "scale", Vector2.ONE, down_duration)
		preview_frame_tween.tween_property(still_preview_frame, "modulate", Color(1, 1, 1, 1), down_duration)
		preview_frame_tween.tween_callback(_on_preview_frame_emphasis_finished)

func _on_preview_emphasis_finished() -> void:
	preview_tween = null

func _on_preview_frame_emphasis_finished() -> void:
	preview_frame_tween = null

func _reset_preview_emphasis() -> void:
	if preview_tween != null:
		preview_tween.kill()
		preview_tween = null
	if preview_frame_tween != null:
		preview_frame_tween.kill()
		preview_frame_tween = null
	if still_preview != null:
		still_preview.scale = Vector2.ONE
		still_preview.modulate = Color(1, 1, 1, 1)
	if still_preview_frame != null:
		still_preview_frame.scale = Vector2.ONE
		still_preview_frame.modulate = Color(1, 1, 1, 1)
