extends "res://scripts/puzzle_screen_stage_rules.gd"

const MEMORY_BURST_MIN_MATCH: int = 5
const MEMORY_BURST_BONUS_PER_EXTRA: int = 1

var memory_burst_tween: Tween = null
var memory_burst_tip_tween: Tween = null

func _setup_stage_info() -> void:
	super._setup_stage_info()
	_clear_memory_burst_popup()
	_play_memory_burst_tip()

func _on_retry_pressed() -> void:
	super._on_retry_pressed()
	_clear_memory_burst_popup()
	_play_memory_burst_tip()

func _on_hint_pressed() -> void:
	super._on_hint_pressed()
	_play_memory_burst_hint()

func _clear_stage() -> void:
	_clear_memory_burst_popup()
	_clear_memory_burst_tip()
	super._clear_stage()

func _get_memory_burst_bonus(match_count: int) -> int:
	if match_count < MEMORY_BURST_MIN_MATCH:
		return 0
	return (match_count - MEMORY_BURST_MIN_MATCH + 1) * MEMORY_BURST_BONUS_PER_EXTRA

func _resolve_match(indices: Array[int]) -> bool:
	var current_combo: int = _register_combo()
	var combo_bonus: int = max(0, current_combo - 1) * COMBO_SCORE_BONUS_PER_STEP
	var rin_passive_bonus: int = _get_rin_long_chain_bonus(indices.size())
	var memory_burst_bonus: int = _get_memory_burst_bonus(indices.size())
	var removed: Dictionary = {}
	var index_cursor: int = 0
	while index_cursor < indices.size():
		removed[indices[index_cursor]] = true
		index_cursor += 1
	score += indices.size() + combo_bonus + rin_passive_bonus + memory_burst_bonus
	moves = max(0, moves - 1)
	var recovered_by_moka: bool = _try_moka_recovery()
	gauge.value = min(score, stage_clear_score)
	var percent: int = int(float(min(score, stage_clear_score)) / float(stage_clear_score) * 100.0)
	moves_label.text = "MOVES\n%d" % moves
	score_label.text = "SCORE\n%d" % score
	progress_label.text = "%d%% Restoration" % percent
	_play_sd_match_feedback()
	_update_sd_combo_message(current_combo)
	_play_match_cell_effect(indices)
	_play_match_popup(indices.size())
	_play_combo_popup(current_combo)
	_play_score_label_emphasis()
	_play_sd_combo_emphasis()
	if memory_burst_bonus > 0:
		_play_memory_burst_popup(memory_burst_bonus)
	if rin_passive_bonus > 0:
		_play_passive_effect_popup("ロングチェインボーナス\n+%d" % rin_passive_bonus, Color(1.0, 0.94, 0.54, 1.0))
	if recovered_by_moka:
		_play_passive_effect_popup("ふわふわリカバー\n+1 MOVE", Color(0.76, 0.94, 1.0, 1.0))
		_play_moves_label_emphasis(Color(0.76, 0.94, 1.0, 1.0), 1.18)
	if score >= stage_clear_score:
		_clear_stage()
		_play_restore_complete_emphasis()
		_play_preview_complete_emphasis()
		_play_board_frame_complete_emphasis()
		if combo_count >= 5:
			_play_final_chain_bonus_popup()
		return true
	_play_restore_gauge_emphasis()
	_play_preview_emphasis()
	_play_board_frame_match_emphasis()
	if combo_count >= 5:
		_play_chain_burst_popup()
		_play_chain_bonus_popup()
	is_resolving_match = true
	get_tree().create_timer(MATCH_EFFECT_DELAY).timeout.connect(_finish_match_resolution.bind(removed))
	return false

func _play_memory_burst_tip() -> void:
	_clear_memory_burst_tip()
	var popup: Label = Label.new()
	popup.name = "MemoryBurstTip"
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.text = "TIP: 5つ以上つなげると MEMORY BURST"
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.add_theme_font_size_override("font_size", 22)
	popup.add_theme_color_override("font_color", Color(1.0, 0.90, 0.58, 1.0))
	popup.add_theme_color_override("font_outline_color", Color(0.08, 0.05, 0.16, 1.0))
	popup.add_theme_constant_override("outline_size", 6)
	popup.custom_minimum_size = Vector2(520, 64)
	popup.modulate = Color(1, 1, 1, 0)
	add_child(popup)
	move_child(popup, get_child_count() - 1)
	var center_position: Vector2 = board.global_position + board.size * 0.5
	popup.global_position = center_position - Vector2(260, 286)
	popup.pivot_offset = popup.custom_minimum_size * 0.5
	popup.scale = Vector2(0.94, 0.94)
	memory_burst_tip_tween = create_tween()
	memory_burst_tip_tween.set_parallel(true)
	memory_burst_tip_tween.tween_property(popup, "modulate", Color(1, 1, 1, 1), 0.18)
	memory_burst_tip_tween.tween_property(popup, "scale", Vector2.ONE, 0.18)
	memory_burst_tip_tween.set_parallel(false)
	memory_burst_tip_tween.tween_interval(1.35)
	memory_burst_tip_tween.tween_property(popup, "modulate", Color(1, 1, 1, 0), 0.30)
	memory_burst_tip_tween.tween_callback(_clear_memory_burst_tip)

func _play_memory_burst_hint() -> void:
	_play_passive_effect_popup("MEMORY BURST TIP\n5つ以上を長くつなげると追加ボーナス", Color(1.0, 0.90, 0.58, 1.0))
	_play_board_frame_feedback(1.025, Color(1.0, 0.92, 0.60, 1.0), 0.10, 0.22)

func _clear_memory_burst_tip() -> void:
	if memory_burst_tip_tween != null:
		memory_burst_tip_tween.kill()
		memory_burst_tip_tween = null
	var popup: Node = get_node_or_null("MemoryBurstTip")
	if popup != null:
		popup.queue_free()

func _play_memory_burst_popup(bonus_score: int) -> void:
	_clear_memory_burst_popup()
	_play_screen_shake(3.5)
	var popup: Label = Label.new()
	popup.name = "MemoryBurstPopup"
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.text = "MEMORY BURST\n+%d" % bonus_score
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.add_theme_font_size_override("font_size", 34)
	popup.add_theme_color_override("font_color", Color(1.0, 0.88, 0.48, 1.0))
	popup.add_theme_color_override("font_outline_color", Color(0.08, 0.05, 0.16, 1.0))
	popup.add_theme_constant_override("outline_size", 8)
	popup.custom_minimum_size = Vector2(360, 100)
	popup.modulate = Color(1, 1, 1, 0)
	add_child(popup)
	move_child(popup, get_child_count() - 1)
	var center_position: Vector2 = board.global_position + board.size * 0.5
	popup.global_position = center_position - Vector2(180, 180)
	popup.pivot_offset = popup.custom_minimum_size * 0.5
	popup.scale = Vector2(0.80, 0.80)
	memory_burst_tween = create_tween()
	memory_burst_tween.set_parallel(true)
	memory_burst_tween.tween_property(popup, "modulate", Color(1, 1, 1, 1), 0.10)
	memory_burst_tween.tween_property(popup, "scale", Vector2(1.10, 1.10), 0.12)
	memory_burst_tween.tween_property(popup, "position", popup.position + Vector2(0, -24), 0.48)
	memory_burst_tween.set_parallel(false)
	memory_burst_tween.tween_property(popup, "scale", Vector2.ONE, 0.10)
	memory_burst_tween.tween_property(popup, "modulate", Color(1, 1, 1, 0), 0.24)
	memory_burst_tween.tween_callback(_clear_memory_burst_popup)

func _clear_memory_burst_popup() -> void:
	if memory_burst_tween != null:
		memory_burst_tween.kill()
		memory_burst_tween = null
	var popup: Node = get_node_or_null("MemoryBurstPopup")
	if popup != null:
		popup.queue_free()
