class_name HUD
extends Control

signal start_requested

const POP_SECONDS: float = 0.2
const LOW_TIME: float = 5.0
const LOW_TIME_COLOR: Color = Color("ffb35c")

var console: Console
var players: Array[Player] = []
var accepting_start: bool = false
var _banner_tween: Tween
var _prompt_tween: Tween

@onready var dim: ColorRect = $Dim
@onready var scoreboard: Control = $Scoreboard
@onready var score_labels: Array[Label] = [$Scoreboard/Left/Score, $Scoreboard/Right/Score]
@onready var win_labels: Array[Label] = [$Scoreboard/Left/Wins, $Scoreboard/Right/Wins]
@onready var time_label: Label = $Scoreboard/Time
@onready var loadout_labels: Array[Label] = [$Loadouts/Left, $Loadouts/Right]
@onready var banner: Control = $Banner
@onready var banner_title: Label = $Banner/Title
@onready var banner_detail: Label = $Banner/Detail
@onready var banner_prompt: Label = $Banner/Prompt
@onready var controls_label: Label = $Controls
@onready var console_panel: Control = $Console
@onready var console_input: LineEdit = $Console/Content/ConsoleLineEdit
@onready var console_output: RichTextLabel = $Console/Content/ConsoleLabel


func _ready() -> void:
	console = Console.new(console_output)


func setup(match_players: Array[Player], round_wins: Dictionary) -> void:
	players = match_players
	for i in players.size():
		for label: Label in [score_labels[i], win_labels[i], loadout_labels[i]]:
			label.add_theme_color_override("font_color", players[i].team.color)
	update_scores({})
	update_round_wins(round_wins)
	update_loadouts()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F1:
		console_panel.visible = not console_panel.visible
		if console_panel.visible:
			console_input.grab_focus()
		else:
			console_input.release_focus()
		get_viewport().set_input_as_handled()
		return

	if accepting_start and not console_input.has_focus() and _is_start_event(event):
		get_viewport().set_input_as_handled()
		accepting_start = false
		start_requested.emit()


func _is_start_event(event: InputEvent) -> bool:
	if not event.is_pressed() or event.is_echo():
		return false
	if event is InputEventKey:
		return event.keycode in [KEY_ENTER, KEY_KP_ENTER]
	if event is InputEventJoypadButton:
		return event.button_index == JOY_BUTTON_A
	if event is InputEventMouseButton:
		return event.button_index == MOUSE_BUTTON_LEFT
	return false


func update_scores(scores: Dictionary[Team, int]) -> void:
	for i in players.size():
		score_labels[i].text = str(scores.get(players[i].team, 0))


func update_round_wins(round_wins: Dictionary) -> void:
	for i in players.size():
		var wins: int = round_wins[players[i]]
		var pips: Array[String] = []
		for round_index in Constants.ROUNDS_TO_WIN:
			pips.append("●" if round_index < wins else "○")
		win_labels[i].text = " ".join(pips)


func update_loadouts() -> void:
	for i in players.size():
		var names: Array[String] = []
		for crystal in players[i].mover_decorator_names + players[i].shooter_decorator_names:
			names.append(crystal.capitalize())
		loadout_labels[i].text = " · ".join(names)


func update_time(time_remaining: float) -> void:
	time_label.text = str(ceili(time_remaining))
	if time_remaining <= LOW_TIME:
		time_label.add_theme_color_override("font_color", LOW_TIME_COLOR)
	else:
		time_label.remove_theme_color_override("font_color")


func show_title(controls: String) -> void:
	scoreboard.hide()
	controls_label.text = controls
	controls_label.show()
	show_banner("PHOTON PHIGHTERS", "Paint the arena with light", Color.WHITE, true)
	wait_for_start("Press Enter or A to start")


func show_scoreboard() -> void:
	controls_label.hide()
	scoreboard.show()


func show_banner(
	title: String, detail: String = "", color: Color = Color.WHITE, dimmed: bool = false
) -> void:
	accepting_start = false
	banner_title.text = title
	banner_title.add_theme_color_override("font_color", color)
	banner_detail.text = detail
	banner_detail.visible = not detail.is_empty()
	banner_prompt.hide()
	dim.visible = dimmed
	banner.show()

	banner.pivot_offset = banner.size / 2.0
	banner.scale = Vector2.ONE * 1.12
	banner.modulate.a = 0.0
	if _banner_tween:
		_banner_tween.kill()
	_banner_tween = create_tween().set_parallel().set_trans(Tween.TRANS_BACK)
	_banner_tween.tween_property(banner, "scale", Vector2.ONE, POP_SECONDS)
	_banner_tween.tween_property(banner, "modulate:a", 1.0, POP_SECONDS)


func flash_banner(title: String, seconds: float) -> void:
	show_banner(title)
	_banner_tween.chain().tween_interval(seconds)
	_banner_tween.chain().tween_property(banner, "modulate:a", 0.0, POP_SECONDS)
	_banner_tween.chain().tween_callback(banner.hide)


func wait_for_start(prompt: String) -> void:
	banner_prompt.text = prompt
	banner_prompt.show()
	accepting_start = true
	if _prompt_tween:
		_prompt_tween.kill()
	_prompt_tween = create_tween().set_loops()
	_prompt_tween.tween_property(banner_prompt, "modulate:a", 0.35, 0.7)
	_prompt_tween.tween_property(banner_prompt, "modulate:a", 1.0, 0.7)


func hide_banner() -> void:
	accepting_start = false
	dim.hide()
	banner.hide()


func _on_console_line_edit_text_submitted(new_text: String) -> void:
	console_input.clear()
	console.execute(new_text)


func add_log(text: String) -> void:
	console_output.text += text + "\n"
