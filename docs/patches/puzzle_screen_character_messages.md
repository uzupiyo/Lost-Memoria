# Puzzle screen character message patch

Replace `_update_sd_combo_message(current_combo)` in `scripts/puzzle_screen.gd` with the functions below.

```gdscript
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
```
