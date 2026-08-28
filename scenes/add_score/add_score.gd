extends Node2D
## 添加成绩界面。
## 供用户录入考试日期，以及各个科目的分数与等级。

const GRADES: Array[String] = ["A", "B", "C", "D", "E", "F"]
const HEADER_COLOR: Color = Color(1, 1, 0, 1)

var _score_spins: Dictionary = {}
var _rating_options: Dictionary = {}

@onready var year_spin: SpinBox = %YearSpin
@onready var month_spin: SpinBox = %MonthSpin
@onready var day_spin: SpinBox = %DaySpin
@onready var score_grid: GridContainer = %ScoreGrid
@onready var feedback: Label = %Feedback
@onready var save_button: Button = %SaveButton
@onready var back_button: Button = %BackButton


func _ready() -> void:
	_setup_date_inputs()
	_build_subject_grid()
	save_button.pressed.connect(_on_save_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)


func _add_cell(text: String, color := Color(1, 1, 1, 1)) -> void:
	var label := Label.new()
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", color)
	score_grid.add_child(label)


func _build_date_key() -> String:
	var year := int(year_spin.value)
	var month := int(month_spin.value)
	var day := int(day_spin.value)
	return "%04d-%02d-%02d" % [year, month, day]


func _build_subject_grid() -> void:
	_add_cell("科目", HEADER_COLOR)
	_add_cell("分数", HEADER_COLOR)
	_add_cell("等级", HEADER_COLOR)
	for subject in ScoreDatabase.SUBJECTS:
		_add_cell(subject, ScoreDatabase.get_subject_color(subject))
		var score_spin := SpinBox.new()
		score_spin.min_value = 0.0
		score_spin.max_value = ScoreDatabase.MAX_SCORES[subject]
		score_spin.step = 0.5
		score_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		score_grid.add_child(score_spin)
		_score_spins[subject] = score_spin

		var rating_option := OptionButton.new()
		rating_option.add_item("请选择")
		for grade in GRADES:
			rating_option.add_item(grade)
		rating_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		score_grid.add_child(rating_option)
		_rating_options[subject] = rating_option


func _days_in_month(year: int, month: int) -> int:
	var days := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if month == 2 and _is_leap_year(year):
		return 29
	return days[month - 1]


func _is_leap_year(year: int) -> bool:
	return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)


func _is_valid_day() -> bool:
	var day := int(day_spin.value)
	var month := int(month_spin.value)
	var year := int(year_spin.value)
	return day <= _days_in_month(year, month)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _on_save_button_pressed() -> void:
	if not _is_valid_day():
		feedback.text = "日期无效，请检查"
		return
	for subject in ScoreDatabase.SUBJECTS:
		if _rating_options[subject].selected == 0:
			feedback.text = "请为所有科目选择等级"
			return
	var date_key := _build_date_key()
	var existed := ScoreDatabase.has_record(date_key)
	var scores := {}
	var ratings := {}
	for subject in ScoreDatabase.SUBJECTS:
		scores[subject] = _score_spins[subject].value
		ratings[subject] = _rating_options[subject].text
	ScoreDatabase.add_record(date_key, scores, ratings)
	if existed:
		feedback.text = "该日期已有记录，已覆盖"
	else:
		feedback.text = "保存成功"


func _setup_date_inputs() -> void:
	var today := Time.get_datetime_dict_from_system()
	year_spin.value = today["year"]
	month_spin.value = today["month"]
	day_spin.value = today["day"]
