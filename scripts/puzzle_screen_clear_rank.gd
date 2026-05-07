extends "res://scripts/puzzle_screen_memory_burst.gd"

var clear_rank_tween: Tween = null
var last_clear_rank: String = ""

func _setup_stage_info() -> void:
	last_clear_rank = ""
	super._setup_stage_info()
	_clear_rank_popup()

func _on_retry_pressed() -> void:
	last_clear_rank = ""
	super._on_retry_pressed()
	_clear_rank_popup()

func _clear_stage() -> void:
	last_clear_rank = _get_clear_rank()
	GameState.clear_selected_stage_with_rank(last_clear_rank)
	super._clear_stage()
	_play_clear_rank_popup(last_clear_rank)

func _go_to_collection() -> void:
	if collection_transition_delay_started:
		return
	collection_transition_delay_started = true
	get_tree().create_timer(COLLECTION_TRANSITION_EXTRA_DELAY).timeout.connect(_go_to_collection_after_clear_delay)

func _get_clear_rank() -> String:
	var rank_points: int = 0
	if score >= int(float(stage_clear_score) * 1.35):
		rank_points += 2
	elif score >= int(float(stage_clear_score) * 1.15):
		rank_points += 1
	if moves >= max(3, int(float(stage_move_limit) * 0.25)):
		rank_points += 2
	elif moves >= 1:
		rank_points += 1
	match best_burst_name:
		"LUMINA BURST":
			rank_points += 3
		"PRISM BURST":
			rank_points += 2
		"MEMORY BURST":
			rank_points += 1
	if rank_points >= 6:
		return "S"
	if rank_points >= 4:
		return "A"
	if rank_points >= 2:
		return "B"
	return "C"

func _get_clear_rank_comment(rank: String) -> String:
	match character_name_label.text:
		"Rin":
			match rank:
				"S":
					return "やば、完璧じゃん！"
				"A":
					return "めっちゃいい感じ！"
				"B":
					return "いいじゃん、その調子！"
				_:
					return "クリアできたしOKっしょ！"
		"Moka":
			match rank:
				"S":
					return "ふわぁ……ぴかぴか満点だねぇ。"
				"A":
					return "えへへ、すごくきれいだよぉ。"
				"B":
					return "できたねぇ、えらいえらい。"
				_:
					return "だいじょうぶ、戻せたよぉ。"
		"Kaede":
			match rank:
				"S":
					return "見事です。理想的な復元でした。"
				"A":
					return "良い判断でした。安定しています。"
				"B":
					return "十分な成果です。次も丁寧に進めましょう。"
				_:
					return "復元は成功です。次は効率を意識しましょう。"
		_:
			return "Memory restored."

func _play_clear_rank_popup(rank: String = "") -> void:
	_clear_rank_popup()
	var resolved_rank: String = rank
	if resolved_rank.is_empty():
		resolved_rank = _get_clear_rank()
	var popup: Label = Label.new()
	popup.name = "ClearRankPopup"
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.text = "CLEAR RANK %s\n%s" % [resolved_rank, _get_clear_rank_comment(resolved_rank)]
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.add_theme_font_size_override("font_size", 34)
	popup.add_theme_color_override("font_color", Color(1.0, 0.94, 0.58, 1.0))
	popup.add_theme_color_override("font_outline_color", Color(0.08, 0.05, 0.16, 1.0))
	popup.add_theme_constant_override("outline_size", 8)
	popup.custom_minimum_size = Vector2(520, 128)
	popup.modulate = Color(1, 1, 1, 0)
	add_child(popup)
	move_child(popup, get_child_count() - 1)
	var center_position: Vector2 = board.global_position + board.size * 0.5
	popup.global_position = center_position - Vector2(260, -92)
	popup.pivot_offset = popup.custom_minimum_size * 0.5
	popup.scale = Vector2(0.76, 0.76)
	clear_rank_tween = create_tween()
	clear_rank_tween.set_parallel(true)
	clear_rank_tween.tween_property(popup, "modulate", Color(1, 1, 1, 1), 0.14)
	clear_rank_tween.tween_property(popup, "scale", Vector2(1.10, 1.10), 0.18)
	clear_rank_tween.set_parallel(false)
	clear_rank_tween.tween_property(popup, "scale", Vector2.ONE, 0.16)
	clear_rank_tween.tween_interval(0.72)
	clear_rank_tween.tween_callback(_on_clear_rank_popup_finished)

func _on_clear_rank_popup_finished() -> void:
	clear_rank_tween = null

func _clear_rank_popup() -> void:
	if clear_rank_tween != null:
		clear_rank_tween.kill()
		clear_rank_tween = null
	var popup: Node = get_node_or_null("ClearRankPopup")
	if popup != null:
		popup.queue_free()
