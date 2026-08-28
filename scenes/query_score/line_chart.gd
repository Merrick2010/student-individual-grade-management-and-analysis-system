class_name StabilityLineChart
extends Control
## 自绘成绩稳定性折线图。
## 横轴为考试日期，纵轴为所选科目的得分；绘制坐标轴、网格线、数据折线与均值线。

const PADDING_LEFT: float = 56.0
const PADDING_RIGHT: float = 18.0
const PADDING_TOP: float = 16.0
const PADDING_BOTTOM: float = 36.0
const GRIDLINE_GAP: float = 8.0
const LINE_WIDTH: float = 3.0
const POINT_RADIUS: float = 5.0
const SCORE_FONT_SIZE: int = 16
const DATE_FONT_SIZE: int = 13
const AVERAGE_FONT_SIZE: int = 13

const BACKGROUND_COLOR: Color = Color(0.16, 0.16, 0.16, 0.45)
const GRID_COLOR: Color = Color(1, 1, 1, 0.12)
const AXIS_COLOR: Color = Color(1, 1, 1, 0.4)
const TEXT_COLOR: Color = Color(1, 1, 1, 0.85)
const LINE_COLOR: Color = Color(1, 0.53333336, 0.5529412, 1)
const AVERAGE_COLOR: Color = Color(1, 1, 0, 0.85)

var _dates: Array[String] = []
var _scores: Array[float] = []
var _max_score: float = 100.0


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND_COLOR)
	if _scores.size() < 2:
		_draw_message("需至少两次考试才能绘制走势")
		return
	var plot := _plot_rect()
	_draw_axes(plot)
	_draw_grid(plot)
	_draw_data_line(plot)
	_draw_average_line(plot)
	_draw_date_labels(plot)


func set_data(dates: Array[String], scores: Array[float], max_score: float) -> void:
	_dates = dates
	_scores = scores
	_max_score = max_score
	queue_redraw()


func _average() -> float:
	var total := 0.0
	for value in _scores:
		total += value
	return total / _scores.size()


func _draw_average_line(plot: Rect2) -> void:
	var average := _average()
	var y := _point_y(average, plot)
	_draw_dashed_line(Vector2(plot.position.x, y), Vector2(plot.end.x, y), AVERAGE_COLOR, 2.0)
	var font := _font()
	var text := "均值 %.1f" % average
	var width := _text_width(font, text, AVERAGE_FONT_SIZE)
	draw_string(font, Vector2(plot.end.x - GRIDLINE_GAP - width, y - 6.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, AVERAGE_FONT_SIZE, AVERAGE_COLOR)


func _draw_axes(plot: Rect2) -> void:
	draw_rect(plot, AXIS_COLOR, false, 2.0)


func _draw_dashed_line(from: Vector2, to: Vector2, color: Color, width: float) -> void:
	var length := from.distance_to(to)
	var direction := (to - from).normalized()
	var dash := 8.0
	var gap := 6.0
	var traveled := 0.0
	while traveled < length:
		var segment_end := minf(traveled + dash, length)
		draw_line(from + direction * traveled, from + direction * segment_end, color, width)
		traveled += dash + gap


func _draw_data_line(plot: Rect2) -> void:
	var points: PackedVector2Array = []
	for i in _scores.size():
		points.append(Vector2(_point_x(i, plot), _point_y(_scores[i], plot)))
	draw_polyline(points, LINE_COLOR, LINE_WIDTH, true)
	for i in _scores.size():
		draw_circle(points[i], POINT_RADIUS, LINE_COLOR)


func _draw_date_label(font: Font, x: float, bottom_y: float, text: String) -> void:
	var width := _text_width(font, text, DATE_FONT_SIZE)
	draw_string(font, Vector2(x - width * 0.5, bottom_y + 22.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, DATE_FONT_SIZE, TEXT_COLOR)


func _draw_date_labels(plot: Rect2) -> void:
	var font := _font()
	var count := _dates.size()
	var step := maxi(1, int(ceil(float(count) / 8.0)))
	for i in count:
		if i % step != 0 and i != count - 1:
			continue
		var x := _point_x(i, plot)
		_draw_date_label(font, x, plot.end.y, _dates[i])


func _draw_grid(plot: Rect2) -> void:
	var font := _font()
	for step in range(0, 5):
		var fraction := float(step) / 4.0
		var y := plot.position.y + plot.size.y * (1.0 - fraction)
		var value := _max_score * fraction
		draw_line(Vector2(plot.position.x, y), Vector2(plot.end.x, y), GRID_COLOR, 1.0)
		_draw_score_label(font, y, str(round(value)))


func _draw_message(text: String) -> void:
	var font := _font()
	var width := _text_width(font, text, SCORE_FONT_SIZE)
	var x := (size.x - width) * 0.5
	draw_string(font, Vector2(x, size.y * 0.5 + 5.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, SCORE_FONT_SIZE, TEXT_COLOR)


func _draw_score_label(font: Font, gridline_y: float, text: String) -> void:
	var width := _text_width(font, text, SCORE_FONT_SIZE)
	var baseline := gridline_y + SCORE_FONT_SIZE * 0.35
	draw_string(font, Vector2(PADDING_LEFT - GRIDLINE_GAP - width, baseline), text, HORIZONTAL_ALIGNMENT_LEFT, -1, SCORE_FONT_SIZE, TEXT_COLOR)


func _font() -> Font:
	var font := get_theme_font("font", "Label")
	if font == null:
		font = ThemeDB.fallback_font
	return font


func _point_x(index: int, plot: Rect2) -> float:
	return plot.position.x + plot.size.x * float(index) / float(_scores.size() - 1)


func _point_y(value: float, plot: Rect2) -> float:
	if _max_score <= 0.0:
		return plot.end.y
	var clamped := clampf(value, 0.0, _max_score)
	return plot.position.y + plot.size.y * (1.0 - clamped / _max_score)


func _plot_rect() -> Rect2:
	var width := maxf(size.x - PADDING_LEFT - PADDING_RIGHT, 1.0)
	var height := maxf(size.y - PADDING_TOP - PADDING_BOTTOM, 1.0)
	return Rect2(PADDING_LEFT, PADDING_TOP, width, height)


func _text_width(font: Font, text: String, font_size: int) -> float:
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
