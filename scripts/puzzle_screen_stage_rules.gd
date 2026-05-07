extends "res://scripts/puzzle_screen_board_emphasis.gd"

var stage_clear_score: int = 30
var stage_move_limit: int = 25

func _setup_stage_info() -> void:
	_apply_stage_rules()
	super._setup_stage_info()
	_apply_stage_rule_labels()
	_apply_stage_opening_message()

func _on_retry_pressed() -> void:
	super._on_retry_pressed()
	_apply_stage_rules()
	moves = stage_move_limit
	gauge.max_value = stage_clear_score
	gauge.value = 0
	moves_label.text = "MOVES\n%d" % moves
	score_label.text = "SCORE\n0"
	progress_label.text = "0% Restoration"
	_apply_stage_opening_message()

func _clear_stage() -> void:
	var character_id: String = character_name_label.text
	var stage_index: int = GameState.selected_stage_index
	super._clear_stage()
	sd_message_label.text = _stage_clear_message(character_id, stage_index)

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

func _apply_stage_opening_message() -> void:
	sd_message_label.text = _stage_opening_message(character_name_label.text, GameState.selected_stage_index)

func _stage_opening_message(character_id: String, stage_index: int) -> String:
	match character_id:
		"Rin":
			return _rin_stage_opening_message(stage_index)
		"Moka":
			return _moka_stage_opening_message(stage_index)
		"Kaede":
			return _kaede_stage_opening_message(stage_index)
		_:
			return "記憶の欠片を集めましょう。ステージが進むほど、少しずつ難しくなります。"

func _stage_clear_message(character_id: String, stage_index: int) -> String:
	match character_id:
		"Rin":
			return _rin_stage_clear_message(stage_index)
		"Moka":
			return _moka_stage_clear_message(stage_index)
		"Kaede":
			return _kaede_stage_clear_message(stage_index)
		_:
			return "記憶の欠片が、またひとつ戻りました。"

func _rin_stage_opening_message(stage_index: int) -> String:
	match stage_index:
		0:
			return "まずは感覚つかも！ 記憶の欠片、ウチと一緒に集めよ！"
		1:
			return "ちょい目標上がったけど、全然いけるっしょ！ 落ち着いてこ！"
		2:
			return "ここから本番じゃん！ 大きくつなげて一気に取り戻そ！"
		3:
			return "手数だいじにいこ！ 長くつながるとこ、見逃さないで！"
		_:
			return "最後まであきらめないから！ 記憶の光、絶対取り戻そ！"

func _rin_stage_clear_message(stage_index: int) -> String:
	match stage_index:
		0:
			return "やったじゃん！ まず一個、記憶戻せたね！"
		1:
			return "いい感じ！ ちょい難しくても余裕だったっしょ！"
		2:
			return "本番ステージもクリア！ この調子でガンガンいこ！"
		3:
			return "手数きつめでもいけたじゃん！ めっちゃいい流れ！"
		_:
			return "最高じゃん！ 記憶の光、かなり戻ってきてるよ！"

func _moka_stage_opening_message(stage_index: int) -> String:
	match stage_index:
		0:
			return "よーし、まずは気楽にいこ！ たくさんつなげてみよう！"
		1:
			return "ちょっと難しくなったね。でも勢いでいけるいける！"
		2:
			return "ここから盛り上がってきたよ！ 大きいチェイン狙ってこ！"
		3:
			return "手数少なめだよ！ でも大逆転、狙えるからね！"
		_:
			return "ここまで来たら全力だよ！ 最高のチェイン見せちゃお！"

func _moka_stage_clear_message(stage_index: int) -> String:
	match stage_index:
		0:
			return "やったー！ まずはばっちりクリアだね！"
		1:
			return "いいねいいね！ 難しくなっても全然いける！"
		2:
			return "すごい勢い！ チェインも記憶もいい感じ！"
		3:
			return "手数少なくても勝てたね！ 大逆転成功！"
		_:
			return "最高！ ここまで来たら次も全力でいこ！"

func _kaede_stage_opening_message(stage_index: int) -> String:
	match stage_index:
		0:
			return "まずは基本確認です。無理せず、確実につなげましょう。"
		1:
			return "目標が少し上がりました。盤面全体を見ることが大切です。"
		2:
			return "焦る必要はありません。長くつながる色を丁寧に探しましょう。"
		3:
			return "残り手数の管理が重要です。一手ごとの価値を意識しましょう。"
		_:
			return "難しい局面です。落ち着いて、最も効率の良い経路を選びましょう。"

func _kaede_stage_clear_message(stage_index: int) -> String:
	match stage_index:
		0:
			return "よくできました。基本はしっかり身についています。"
		1:
			return "安定した判断でした。次の記憶にも進めそうです。"
		2:
			return "難度が上がっても、落ち着いた選択ができています。"
		3:
			return "手数管理も十分です。とても良い進め方でした。"
		_:
			return "見事です。記憶の輪郭が、かなり鮮明になってきました。"

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
