extends Node2D

@export var main_title_curve: Curve
@export var ranbow_shader: Shader

static var _intro_played := false

@onready var main_title: CenterContainer = $CanvasLayer/Control/CenterContainer
@onready var main_title_label: Label = %MainTitle
@onready var content: Control = $CanvasLayer/Control/Content
@onready var latest_date: Label = %LatestScore/VBoxContainer/Date
@onready var latest_scores: VBoxContainer = %LatestScore/VBoxContainer/ScoreInformations/Scores
@onready var latest_ratings: VBoxContainer = %LatestScore/VBoxContainer/ScoreInformations/Ratings


func _ready() -> void:
	_refresh_latest_score()
	main_title_label.material.set("shader", ranbow_shader)
	if not _intro_played:
		_intro_played = true
		_play_intro()
	else:
		_show_static()


func _format_date(date_key: String) -> String:
	var parts := date_key.split("-")
	if parts.size() < 3:
		return "日期：%s" % date_key
	return "日期：%s 年 %s 月 %s 日" % [parts[0], parts[1], parts[2]]


func _main_title_curve_value(value: float) -> float:
	return main_title_curve.sample_baked(value)


func _on_add_score_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/add_score/add_score.tscn")


func _on_check_score_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/query_score/query_score.tscn")


func _play_intro() -> void:
	main_title.position.y = (800.0 - main_title.size.y) / 2.0
	main_title.modulate.a = 0.0
	content.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(main_title, ^"modulate:a", 1.0, 2.0)
	tween.tween_property(main_title, ^"position:y", 0.0, 2.0).set_custom_interpolator(_main_title_curve_value)
	tween.tween_interval(1.0)
	tween.tween_property(content, ^"modulate:a", 1.0, 1.0)


func _refresh_latest_score() -> void:
	var date_key := ScoreDatabase.get_latest_date_key()
	if date_key.is_empty():
		latest_date.text = "暂无成绩记录"
		for i in ScoreDatabase.SUBJECTS.size():
			(latest_scores.get_child(i) as Label).text = "-"
			(latest_ratings.get_child(i) as Label).text = "-"
		return
	var record := ScoreDatabase.get_record(date_key)
	var scores: Dictionary = record.get("scores", {})
	var ratings: Dictionary = record.get("ratings", {})
	latest_date.text = _format_date(date_key)
	for i in ScoreDatabase.SUBJECTS.size():
		var subject := ScoreDatabase.SUBJECTS[i]
		(latest_scores.get_child(i) as Label).text = str(scores.get(subject, "-"))
		(latest_ratings.get_child(i) as Label).text = str(ratings.get(subject, "-"))


func _show_static() -> void:
	main_title.position.y = 0.0
	main_title.modulate.a = 1.0
	content.modulate.a = 1.0
