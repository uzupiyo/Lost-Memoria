extends "res://scripts/puzzle_screen.gd"

var no_moves_popup_played: bool = false
var stage_clear_popup_played: bool = false
var low_moves_popup_last_moves: int = -1

func _setup_stage_info() -> void:
	super._setup_stage_info()
	_clear_result_popups()
	no_moves_popup_played = false
	stage_clear_popup_played = false
	low_moves_popup_last_moves = -1
	sd_message_label.text = _opening_message(character_name_label.text)

func _on_retry_pressed() -> void:
	super._on_retry_pressed()
	_clear_result_popups()
	no_moves_popup_played = false
	stage_clear_popup_played = false
	low_moves_popup_last_moves = -1
	sd_message_label.text = _opening_message(character_name_label.text)

func _on_hint_pressed() -> void:
	sd_message_label.text = _hint_message(character_name_label.text)

func _clear_stage() -> void:
	var character_id: String = character_name_label.text
	super._clear_stage()
	sd_message_label.text = _clear_message(character_id)
	_play_stage_clear_popup()

func _finish_match_resolution(removed: Dictionary) -> void:
	super._finish_match_resolution(removed)
	_update_move_pressure_message()

func _update_move_pressure_message() -> void:
	if has_cleared:
		return
	var character_id: String = character_name_label.text
	if moves <= 0:
		is_resolving_match = true
		sd_message_label.text = _no_moves_message(character_id)
		_play_no_moves_popup()
		return
	if moves <= 5:
		sd_message_label.text = _low_moves_message(character_id, moves)
		_play_low_moves_popup(moves)

func _clear_result_popups() -> void:
	_clear_named_popup("LowMovesPopup")
	_clear_named_popup("NoMovesPopup")
	_clear_named_popup("StageClearPopup")

func _clear_named_popup(node_name: String) -> void:
	var popup: Node = get_node_or_null(node_name)
	if popup != null:
		popup.queue_free()

func _play_low_moves_popup(remaining_moves: int) -> void:
	if low_moves_popup_last_moves == remaining_moves:
		return
	low_moves_popup_last_moves = remaining_moves
	_clear_named_popup("LowMovesPopup")
	var popup: Label = Label.new()
	popup.name = "LowMovesPopup"
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.text = _low_moves_popup_text(character_name_label.text, remaining_moves)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.add_theme_font_size_override("font_size", 32)
	popup.add_theme_color_override("font_color", Color(1.0, 0.72, 0.38, 1.0))
	popup.add_theme_color_override("font_outline_color", Color(0.08, 0.05, 0.16, 1.0))
	popup.add_theme_constant_override("outline_size", 7)
	popup.custom_minimum_size = Vector2(340, 96)
	popup.modulate = Color(1, 1, 1, 0)
	add_child(popup)
	move_child(popup, get_child_count() - 1)
	var center_position: Vector2 = board.global_position + board.size * 0.5
	popup.global_position = center_position - Vector2(170, 16)
	popup.pivot_offset = popup.custom_minimum_size * 0.5
	popup.scale = Vector2(0.84, 0.84)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "modulate", Color(1, 1, 1, 1), 0.10)
	tween.tween_property(popup, "scale", Vector2(1.06, 1.06), 0.12)
	tween.tween_property(popup, "position", popup.position + Vector2(0, -14), 0.42)
	tween.set_parallel(false)
	tween.tween_property(popup, "modulate", Color(1, 1, 1, 0), 0.24)
	tween.tween_callback(popup.queue_free)

func _play_stage_clear_popup() -> void:
	if stage_clear_popup_played:
		return
	stage_clear_popup_played = true
	_clear_named_popup("StageClearPopup")
	var popup: Label = Label.new()
	popup.name = "StageClearPopup"
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.text = _stage_clear_popup_text(character_name_label.text)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.add_theme_font_size_override("font_size", 40)
	popup.add_theme_color_override("font_color", Color(1.0, 0.92, 0.48, 1.0))
	popup.add_theme_color_override("font_outline_color", Color(0.08, 0.05, 0.16, 1.0))
	popup.add_theme_constant_override("outline_size", 8)
	popup.custom_minimum_size = Vector2(400, 120)
	popup.modulate = Color(1, 1, 1, 0)
	add_child(popup)
	move_child(popup, get_child_count() - 1)
	var center_position: Vector2 = board.global_position + board.size * 0.5
	popup.global_position = center_position - Vector2(200, 86)
	popup.pivot_offset = popup.custom_minimum_size * 0.5
	popup.scale = Vector2(0.82, 0.82)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "modulate", Color(1, 1, 1, 1), 0.10)
	tween.tween_property(popup, "scale", Vector2(1.10, 1.10), 0.16)
	tween.set_parallel(false)
	tween.tween_property(popup, "scale", Vector2.ONE, 0.14)

func _play_no_moves_popup() -> void:
	if no_moves_popup_played:
		return
	no_moves_popup_played = true
	_clear_named_popup("NoMovesPopup")
	var popup: Label = Label.new()
	popup.name = "NoMovesPopup"
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.text = _no_moves_popup_text(character_name_label.text)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.add_theme_font_size_override("font_size", 42)
	popup.add_theme_color_override("font_color", Color(1.0, 0.78, 0.42, 1.0))
	popup.add_theme_color_override("font_outline_color", Color(0.08, 0.05, 0.16, 1.0))
	popup.add_theme_constant_override("outline_size", 8)
	popup.custom_minimum_size = Vector2(360, 120)
	popup.modulate = Color(1, 1, 1, 0)
	add_child(popup)
	move_child(popup, get_child_count() - 1)
	var center_position: Vector2 = board.global_position + board.size * 0.5
	popup.global_position = center_position - Vector2(180, 80)
	popup.pivot_offset = popup.custom_minimum_size * 0.5
	popup.scale = Vector2(0.82, 0.82)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "modulate", Color(1, 1, 1, 1), 0.12)
	tween.tween_property(popup, "scale", Vector2(1.08, 1.08), 0.16)
	tween.set_parallel(false)
	tween.tween_property(popup, "scale", Vector2.ONE, 0.12)

func _low_moves_popup_text(character_id: String, remaining_moves: int) -> String:
	match character_id:
		"Rin":
			return "LAST %d MOVES\nDON'T GIVE UP" % remaining_moves
		"Moka":
			return "LAST %d MOVES!\nGO GO!" % remaining_moves
		"Kaede":
			return "LAST %d MOVES\nSTAY CALM" % remaining_moves
		_:
			return "LAST %d MOVES" % remaining_moves

func _stage_clear_popup_text(character_id: String) -> String:
	match character_id:
		"Rin":
			return "STAGE CLEAR\nMEMORY RESTORED"
		"Moka":
			return "CLEAR!\nNICE MEMORY!"
		"Kaede":
			return "STAGE CLEAR\nMEMORY STABILIZED"
		_:
			return "STAGE CLEAR\nMEMORY RESTORED"

func _no_moves_popup_text(character_id: String) -> String:
	match character_id:
		"Rin":
			return "NO MOVES\nTRY AGAIN"
		"Moka":
			return "NO MOVES\nREVENGE!"
		"Kaede":
			return "NO MOVES\nRETRY CALMLY"
		_:
			return "NO MOVES\nRETRY?"

func _opening_message(character_id: String) -> String:
	match character_id:
		"Rin":
			return "一緒に、記憶の欠片を集めましょう。"
		"Moka":
			return "よーし、どんどん欠片を集めていこう！"
		"Kaede":
			return "落ち着いて進めましょう。ひとつずつ戻せば大丈夫です。"
		_:
			return "一緒に、記憶の欠片を集めましょう。"

func _hint_message(character_id: String) -> String:
	match character_id:
		"Rin":
			return "同じ色を3つ以上、ななめにもつなげられます。焦らず大きくつなげましょう。"
		"Moka":
			return "ななめもOKだよ！ いっぱいつなげたら一気に進めるかも！"
		"Kaede":
			return "同じ色はななめにも接続できます。盤面全体を見て、長い道を探しましょう。"
		_:
			return "同じ色を3つ以上、ななめにもつなげられます。"

func _clear_message(character_id: String) -> String:
	match character_id:
		"Rin":
			return "記憶の欠片が、またひとつ戻りました。"
		"Moka":
			return "やったね！ 記憶の欠片、ばっちり戻ったよ！"
		"Kaede":
			return "よくできました。記憶が静かに戻ってきています。"
		_:
			return "記憶の欠片が、またひとつ戻りました。"

func _low_moves_message(character_id: String, remaining_moves: int) -> String:
	match character_id:
		"Rin":
			return "残り%d手です。最後まであきらめず、いちばん大きくつなげましょう！" % remaining_moves
		"Moka":
			return "あと%d手！ ここから大逆転、狙っていこう！" % remaining_moves
		"Kaede":
			return "残り%d手です。無理に急がず、確実につながる場所を選びましょう。" % remaining_moves
		_:
			return "残り%d手です。大きくつなげられる場所を探しましょう。" % remaining_moves

func _no_moves_message(character_id: String) -> String:
	match character_id:
		"Rin":
			return "手数が尽きてしまいました。Retryで、もう一度いきましょう。"
		"Moka":
			return "うーん、今回はここまで！ Retryでリベンジしよ！"
		"Kaede":
			return "手数切れです。盤面を見直して、もう一度落ち着いて挑みましょう。"
		_:
			return "手数が尽きました。Retryでもう一度挑戦できます。"

func _update_sd_combo_message(current_combo: int) -> void:
	var character_id: String = character_name_label.text
	match character_id:
		"Rin":
			_update_rin_combo_message(current_combo)
		"Moka":
			_update_moka_combo_message(current_combo)
		"Kaede":
			_update_kaede_combo_message(current_combo)
		_:
			_update_default_combo_message(current_combo)

func _update_rin_combo_message(current_combo: int) -> void:
	if current_combo >= 5:
		sd_message_label.text = "すごい連鎖です！ この調子で一気に取り戻しましょう！"
	elif current_combo >= 3:
		sd_message_label.text = "いい流れです。記憶の光が強くなっています！"
	elif current_combo >= 2:
		sd_message_label.text = "連続成功です。今の流れ、逃さないでください！"

func _update_moka_combo_message(current_combo: int) -> void:
	if current_combo >= 5:
		sd_message_label.text = "すごいすごい！ この勢いなら全部思い出せそう！"
	elif current_combo >= 3:
		sd_message_label.text = "きてるよ！ 記憶の欠片がどんどん集まってる！"
	elif current_combo >= 2:
		sd_message_label.text = "やった、連続だね！ そのままいこう！"

func _update_kaede_combo_message(current_combo: int) -> void:
	if current_combo >= 5:
		sd_message_label.text = "ふふっ、すばらしい連鎖です。このまま押し切りましょう。"
	elif current_combo >= 3:
		sd_message_label.text = "落ち着いて続ければ、まだつながります。"
	elif current_combo >= 2:
		sd_message_label.text = "いい判断です。次も丁寧につなげましょう。"

func _update_default_combo_message(current_combo: int) -> void:
	if current_combo >= 5:
		sd_message_label.text = "すごい連鎖です。この調子で記憶を一気に戻しましょう。"
	elif current_combo >= 3:
		sd_message_label.text = "つながってきました。記憶の流れが強くなっています。"
	elif current_combo >= 2:
		sd_message_label.text = "連続成功です。今の流れ、逃さないでください。"
