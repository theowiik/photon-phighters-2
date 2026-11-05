class_name HUD
extends Control

var console: Console

@onready var score_label: RichTextLabel = $ScoreLabel
@onready var console_input: LineEdit = $ConsoleLineEdit
@onready var console_output: RichTextLabel = $ConsoleLabel
@onready var time_label: Label = $TimeLabel


func _ready() -> void:
	console = Console.new(console_output, get_tree())


func update_scores(scores: Dictionary) -> void:
	const BAR_LENGTH: int = 20
	const BAR_CHAR: String = "█"

	var total: int = 0
	for count in scores.values():
		total += count

	if total == 0:
		score_label.text = ""
		return

	# Build proportional bar with colored segments
	var bbcode: String = ""
	var colors_sorted = scores.keys()

	for hex in colors_sorted:
		var count: int = scores[hex]
		var segment_length: int = roundi(float(count) / total * BAR_LENGTH)
		if segment_length > 0:
			bbcode += "[color=#%s]%s[/color]" % [hex, BAR_CHAR.repeat(segment_length)]

	score_label.bbcode_enabled = true
	score_label.text = bbcode


func _on_console_line_edit_text_submitted(new_text: String) -> void:
	console_input.clear()
	console.execute(new_text)


func update_time(time_remaining: float) -> void:
	time_label.text = str(int(time_remaining)) + "s"


func add_log(text: String) -> void:
	console_output.text += text + "\n"
