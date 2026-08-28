extends Node2D
## 查询成绩界面。
## 供用户选择考试日期展示成绩，并提供所选单科的成绩稳定性折线图分析。

const HEADER_COLOR: Color = Color(1, 1, 0, 1)

@onready var date_option: OptionButton = %DateOption
@onready var result_grid: GridContainer = %ResultGrid
@onready var feedback: Label = %Feedback
@onready var back_button: Button = %BackButton
@onready var subject_option: OptionButton = %SubjectOption
@onready var stability_chart: Control = %StabilityChart
@onready var stability_info: Label = %StabilityInfo


func _ready() -> void:
	_populate_date_options()
	_populate_subject_options()
	date_option.item_selected.connect(_on_date_selected)
	subject_option.item_selected.connect(_on_subject_selected)
	back_button.pressed.connect(_on_back_button_pressed)
	_update_stability_chart()
	if date_option.item_count > 0:
		date_option.select(0)
		_on_date_selected(0)
	else:
		feedback.text = "暂无已保存的成绩记录"


func _add_cell(text: String, color := Color(1, 1, 1, 1), font_size := 30) -> void:
	var label := Label.new()
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	result_grid.add_child(label)


func _build_header() -> void:
	for title in ["科目", "分数", "满分", "等级"]:
		_add_cell(title, HEADER_COLOR, 28)


func _build_result_grid(date_key: String) -> void:
	_clear_result_grid()
	var record := ScoreDatabase.get_record(date_key)
	if record.is_empty():
		feedback.text = "未找到该日期的成绩"
		return
	feedback.text = ""
	_build_header()
	var scores: Dictionary = record.get("scores", {})
	var ratings: Dictionary = record.get("ratings", {})
	for subject in ScoreDatabase.SUBJECTS:
		_add_cell(subject, ScoreDatabase.get_subject_color(subject))
		_add_cell(str(scores.get(subject, "-")))
		_add_cell(str(ScoreDatabase.MAX_SCORES[subject]))
		_add_cell(str(ratings.get(subject, "-")))


func _clear_result_grid() -> void:
	for child in result_grid.get_children():
		child.queue_free()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _on_date_selected(index: int) -> void:
	_build_result_grid(date_option.get_item_text(index))


func _on_subject_selected(_index: int) -> void:
	_update_stability_chart()


func _populate_date_options() -> void:
	var dates := ScoreDatabase.get_saved_dates()
	dates.sort()
	for date in dates:
		date_option.add_item(date)


func _populate_subject_options() -> void:
	for subject in ScoreDatabase.SUBJECTS:
		subject_option.add_item(subject)


func _update_stability_chart() -> void:
	var subject := subject_option.get_item_text(subject_option.selected)
	var dates := ScoreDatabase.get_saved_dates()
	dates.sort()
	var scores: Array[float] = []
	for date in dates:
		var record := ScoreDatabase.get_record(date)
		var subject_scores: Dictionary = record.get("scores", {})
		scores.append(float(subject_scores.get(subject, 0.0)))
	stability_chart.call("set_data", dates, scores, float(ScoreDatabase.MAX_SCORES[subject]))
	_update_stability_info(scores)


func _update_stability_info(scores: Array[float]) -> void:
	if scores.size() < 2:
		stability_info.text = "需至少两次考试才能分析稳定性"
		return
	var total := 0.0
	for value in scores:
		total += value
	var average := total / scores.size()
	var variance := 0.0
	for value in scores:
		variance += (value - average) * (value - average)
	variance /= scores.size()
	var deviation := sqrt(variance)
	stability_info.text = "均值 %.1f ｜ 标准差 %.1f" % [average, deviation]
