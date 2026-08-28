extends Node
## 成绩数据管理器（全局单例）。
## 负责各科目成绩记录的增、删、查与 JSON 持久化。

const SAVE_PATH: String = "user://score_data.json"

const SUBJECTS: Array[String] = [
	"语文", "数学", "外语", "物理", "化学", "生物", "历史", "政治", "地理",
]

const MAX_SCORES: Dictionary = {
	"语文": 150, "数学": 150, "外语": 150,
	"物理": 100, "化学": 100, "生物": 100,
	"历史": 100, "政治": 100, "地理": 100,
}

const SUBJECT_GROUP_COLORS: Dictionary = {
	"语文": Color(1, 1, 0.5372549, 1),
	"数学": Color(1, 1, 0.5372549, 1),
	"外语": Color(1, 1, 0.5372549, 1),
	"物理": Color(0.7882353, 1, 0.6745098, 1),
	"化学": Color(0.7882353, 1, 0.6745098, 1),
	"生物": Color(0.7882353, 1, 0.6745098, 1),
	"历史": Color(1, 0.39113033, 0.6530963, 1),
	"政治": Color(1, 0.39113033, 0.6530963, 1),
	"地理": Color(1, 0.39113033, 0.6530963, 1),
}

var _records: Dictionary = {}


func _ready() -> void:
	load_data()


func add_record(date_key: String, scores: Dictionary, ratings: Dictionary) -> void:
	_records[date_key] = {
		"scores": scores,
		"ratings": ratings,
	}
	save_data()


func get_latest_date_key() -> String:
	var dates := get_saved_dates()
	if dates.is_empty():
		return ""
	dates.sort()
	return dates[dates.size() - 1]


func get_record(date_key: String) -> Dictionary:
	return _records.get(date_key, {})


func get_saved_dates() -> Array[String]:
	var dates: Array[String] = []
	for date_key: String in _records.keys():
		dates.append(date_key)
	return dates


func get_subject_color(subject: String) -> Color:
	return SUBJECT_GROUP_COLORS.get(subject, Color(1, 1, 1, 1))


func has_record(date_key: String) -> bool:
	return _records.has(date_key)


func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		_records = parsed


func save_data() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("无法打开成绩文件进行写入：%s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(_records))
	file.close()
