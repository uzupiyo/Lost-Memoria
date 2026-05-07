extends "res://scripts/puzzle_screen_board_emphasis.gd"

const RIN_LONG_CHAIN_MIN: int = 5
const RIN_LONG_CHAIN_BONUS_PER_EXTRA: int = 2

var stage_clear_score: int = 30
var stage_move_limit: int = 25
var passive_message_tween: Tween = null
var passive_effect_tween: Tween = null
var moka_recovery_used: bool = false

func _setup_stage_info() -> void:
	_apply_stage_rules()
	moka_recovery_used = false
	super._setup_stage_info()
	_apply_stage_rule_labels()
	_apply_stage_opening_message()
	_play_passive_intro_message()

func _on_retry_pressed() -> void:
	super._on_retry_pressed()
	_apply_stage_rules()
	moka_recovery_used = false
	moves = stage_move_limit
	gauge.max_value = stage_clear_score
	gauge.value = 0
	moves_label.text = "MOVES\n%d" % moves
	score_label.text = "SCORE\n0"
	progress_label.text = "0% Restoration"
	_apply_stage_opening_message()
	_play_passive_intro_message()

func _on_hint_pressed() -> void:
	sd_message_label.text = _stage_hint_message(character_name_label.text, GameState.selected_stage_index)
	if character_name_label.text == "Kaede":
		_play_passive_effect_popup("おちつきヒント\n盤面をゆっくり見てみましょう", Color(0.72, 1.0, 0.78, 1.0))
		_play_board_frame_feedback(1.025, Color(0.80, 1.0, 0.82, 1.0), 0.10, 0.22)

func _clear_stage() -> void:
	var character_id: String = character_name_label.text
	var stage_index: int = GameState.selected_stage_index
	_clear_passive_intro_message()
	_clear_passive_effect_popup()
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

func _play_passive_intro_message() -> void:
	_clear_passive_intro_message()
	var text_value: String = _passive_intro_text(character_name_label.text)
	if text_value.is_empty():
		return
	var popup: Label = Label.new()
	popup.name = "PassiveIntroPopup"
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.text = text_value
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.add_theme_font_size_override("font_size", 24)
	popup.add_theme_color_override("font_color", Color(0.88, 0.96, 1.0, 1.0))
	popup.add_theme_color_override("font_outline_color", Color(0.08, 0.05, 0.16, 1.0))
	popup.add_theme_constant_override("outline_size", 6)
	popup.custom_minimum_size = Vector2(500, 80)
	popup.modulate = Color(1, 1, 1, 0)
	add_child(popup)
	move_child(popup, get_child_count() - 1)
	var center_position: Vector2 = board.global_position + board.size * 0.5
	popup.global_position = center_position - Vector2(250, 242)
	popup.pivot_offset = popup.custom_minimum_size * 0.5
	popup.scale = Vector2(0.92, 0.92)
	passive_message_tween = create_tween()
	passive_message_tween.set_parallel(true)
	passive_message_tween.tween_property(popup, "modulate", Color(1, 1, 1, 1), 0.18)
	passive_message_tween.tween_property(popup, "scale", Vector2.ONE, 0.18)
	passive_message_tween.set_parallel(false)
	passive_message_tween.tween_interval(1.10)
	passive_message_tween.tween_property(popup, "modulate", Color(1, 1, 1, 0), 0.28)
	passive_message_tween.tween_callback(_clear_passive_intro_message)

func _clear_passive_intro_message() -> void:
	if passive_message_tween != null:
		passive_message_tween.kill()
		passive_message_tween = null
	var popup: Node = get_node_or_null("PassiveIntroPopup")
	if popup != null:
		popup.queue_free()

func _play_passive_effect_popup(text_value: String, font_color: Color) -> void:
	_clear_passive_effect_popup()
	var popup: Label = Label.new()
	popup.name = "PassiveEffectPopup"
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.text = text_value
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.add_theme_font_size_override("font_size", 30)
	popup.add_theme_color_override("font_color", font_color)
	popup.add_theme_color_override("font_outline_color", Color(0.08, 0.05, 0.16, 1.0))
	popup.add_theme_constant_override("outline_size", 7)
	popup.custom_minimum_size = Vector2(380, 92)
	popup.modulate = Color(1, 1, 1, 0)
	add_child(popup)
	move_child(popup, get_child_count() - 1)
	var center_position: Vector2 = board.global_position + board.size * 0.5
	popup.global_position = center_position - Vector2(190, 198)
	popup.pivot_offset = popup.custom_minimum_size * 0.5
	popup.scale = Vector2(0.82, 0.82)
	passive_effect_tween = create_tween()
	passive_effect_tween.set_parallel(true)
	passive_effect_tween.tween_property(popup, "modulate", Color(1, 1, 1, 1), 0.10)
	passive_effect_tween.tween_property(popup, "scale", Vector2(1.08, 1.08), 0.12)
	passive_effect_tween.tween_property(popup, "position", popup.position + Vector2(0, -18), 0.46)
	passive_effect_tween.set_parallel(false)
	passive_effect_tween.tween_property(popup, "modulate", Color(1, 1, 1, 0), 0.24)
	passive_effect_tween.tween_callback(_clear_passive_effect_popup)

func _clear_passive_effect_popup() -> void:
	if passive_effect_tween != null:
		passive_effect_tween.kill()
		passive_effect_tween = null
	var popup: Node = get_node_or_null("PassiveEffectPopup")
	if popup != null:
		popup.queue_free()

func _passive_intro_text(character_id: String) -> String:
	match character_id:
		"Rin":
			return "Rin Passive: ロングチェインボーナス"
		"Moka":
			return "Moka Passive: ふわふわリカバー"
		"Kaede":
			return "Kaede Passive: おちつきヒント"
		_:
			return ""

func _get_rin_long_chain_bonus(match_count: int) -> int:
	if character_name_label.text != "Rin":
		return 0
	if match_count < RIN_LONG_CHAIN_MIN:
		return 0
	return (match_count - RIN_LONG_CHAIN_MIN + 1) * RIN_LONG_CHAIN_BONUS_PER_EXTRA

func _try_moka_recovery() -> bool:
	if character_name_label.text != "Moka":
		return false
	if moka_recovery_used:
		return false
	if moves > 0:
		return false
	if score >= stage_clear_score:
		return false
	moka_recovery_used = true
	moves += 1
	return true

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

func _stage_hint_message(character_id: String, stage_index: int) -> String:
	match character_id:
		"Rin":
			return _rin_stage_hint_message(stage_index)
		"Moka":
			return _moka_stage_hint_message(stage_index)
		"Kaede":
			return _kaede_stage_hint_message(stage_index)
		_:
			return "同じ色を3つ以上つなげましょう。ステージが進むほど、長いつながりが重要です。"

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

func _rin_stage_hint_message(stage_index: int) -> String:
	match stage_index:
		0:
			return "まずは3つ以上ね！ ななめも使って、気楽につなげよ！"
		1:
			return "目標ちょい高め！ 短く消すより、長めにまとめた方がいいかも！"
		2:
			return "でっかいチェイン狙お！ 端っこから見ると見つけやすいよ！"
		3:
			return "手数だいじ！ 1手でいっぱい消せる場所、先に探そ！"
		_:
			return "ここは効率勝負じゃん！ 5チェイン以上狙って一気にいこ！"

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
			return "えへへ、まずはゆっくりでいいよぉ。きらきら集めよ？"
		1:
			return "ちょっとだけむずかしいねぇ。でも、だいじょうぶだよぉ。"
		2:
			return "ふわぁ、欠片がいっぱいだね。ながーくつなげてみよ？"
		3:
			return "手数が少ないみたい……でも、あわてなくていいよぉ。"
		_:
			return "ここまで来たんだねぇ。モカもいっしょに、がんばるよぉ。"

func _moka_stage_hint_message(stage_index: int) -> String:
	match stage_index:
		0:
			return "おんなじ色を、みっつ以上だよぉ。ななめも、すーっとつながるよ。"
		1:
			return "ちょっとだけ多めに集めよぉ。ながくつなぐと、きらきら増えるよ。"
		2:
			return "はしっこから、そーっと見てみよ？ かくれた道があるかもぉ。"
		3:
			return "手数、だいじだねぇ。いちばん長い道を、ゆっくり探そ？"
		_:
			return "ふわぁ……大きなチェイン、見つけられたらすごいねぇ。"

func _moka_stage_clear_message(stage_index: int) -> String:
	match stage_index:
		0:
			return "わぁい、できたぁ。欠片、ひとつ戻ったねぇ。"
		1:
			return "えへへ、むずかしくてもできたねぇ。すごいすごい。"
		2:
			return "きらきら、いっぱい戻ってきたよぉ。なんだかぽかぽかするね。"
		3:
			return "手数少なかったのに、ちゃんとできたねぇ。えらいえらい。"
		_:
			return "ふわぁ……記憶の光、すごくきれい。もう少しだねぇ。"

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

func _kaede_stage_hint_message(stage_index: int) -> String:
	match stage_index:
		0:
			return "同じ色を3つ以上、ななめにもつなげられます。まずは基本を確認しましょう。"
		1:
			return "目標数が上がっています。短い連結より、長い連結を優先しましょう。"
		2:
			return "盤面の端から見ると、長い経路を見つけやすくなります。"
		3:
			return "残り手数を意識しましょう。一手あたりの回収量が重要です。"
		_:
			return "5連鎖以上のボーナスを狙うと、終盤の目標に届きやすくなります。"

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
	var rin_passive_bonus: int = _get_rin_long_chain_bonus(indices.size())
	var removed: Dictionary = {}
	var index_cursor: int = 0
	while index_cursor < indices.size():
		removed[indices[index_cursor]] = true
		index_cursor += 1
	score += indices.size() + combo_bonus + rin_passive_bonus
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
