extends "res://scripts/puzzle_screen_board_emphasis.gd"

var stage_clear_score: int = 30
var stage_move_limit: int = 25

func _setup_stage_info() -> void:
	_apply_stage_rules()
	super._setup_stage_info()
	_apply_stage_rule_labels()

func _on_retry_pressed() -> void:
	super._on_retry_pressed()
	_apply_stage_rules()
	moves = stage_move_limit
	gauge.max_value = stage_clear_score
	gauge.value = 0
	moves_label.text = "MOVES\n%d" % moves
	score_label.text = "SCORE\n0"
	progress_label.text = "0% Restoration"

func _apply_stage_rules() -> void:
	var stage_index: int = GameState.selected_stage_index
	match stage_index:
		0:
			stage_clear_score = 30
			stage_move_limit = 25
		1:
			stage_clear_score = 38
			stage_move_limit = 24
		2:
			stage_clear_score = 45
			stage_move_limit = 22
		3:
			stage_clear_score = 52
			stage_move_limit = 21
		_:
			stage_clear_score = 58
			stage_move_limit = 20

func _apply_stage_rule_labels() -> void:
	moves = stage_move_limit
	gauge.max_value = stage_clear_score
	gauge.value = min(score, stage_clear_score)
	target_label.text = "TARGET\n%d Shards" % stage_clear_score
	moves_label.text = "MOVES\n%d" % moves
	progress_label.text = "0% Restoration"

func _resolve_match(indices: Array[int]) -> bool:
	var current_combo: int = _register_combo()
	var combo_bonus: int = max(0, current_combo - 1) * COMBO_SCORE_BONUS_PER_STEP
	var removed: Dictionary = {}
	var index_cursor: int = 0
	while index_cursor < indices.size():
		removed[indices[index_cursor]] = true
		index_cursor += 1
	score += indices.size() + combo_bonus
	moves = max(0, moves - 1)
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
