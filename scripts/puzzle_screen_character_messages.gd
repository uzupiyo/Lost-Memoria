extends "res://scripts/puzzle_screen.gd"

func _setup_stage_info() -> void:
	super._setup_stage_info()
	sd_message_label.text = _opening_message(character_name_label.text)

func _on_retry_pressed() -> void:
	super._on_retry_pressed()
	sd_message_label.text = _opening_message(character_name_label.text)

func _on_hint_pressed() -> void:
	sd_message_label.text = _hint_message(character_name_label.text)

func _clear_stage() -> void:
	var character_id: String = character_name_label.text
	super._clear_stage()
	sd_message_label.text = _clear_message(character_id)

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
