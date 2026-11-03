class_name HUD
extends Control

signal start_requested

var console: Console
var players: Array[Player] = []
var accepting_start: bool = false

@onready var score_labels: Array[RichTextLabel] = [$Top/Left/Score, $Top/Right/Score]
@onready var status_labels: Array[Label] = [$Bottom/Left, $Bottom/Right]
@onready var win_labels: Array[Label] = [$Top/Left/Wins, $Top/Right/Wins]
@onready var console_input: LineEdit = $Console/Content/ConsoleLineEdit
@onready var console_output: RichTextLabel = $Console/Content/ConsoleLabel
@onready var time_label: Label = $Top/Clock/Time
@onready var round_label: Label = $Top/Clock/Round
@onready var message: Control = $Message
@onready var message_title: Label = $Message/Panel/Content/Title
@onready var message_detail: Label = $Message/Panel/Content/Detail
@onready var start_button: Button = $Message/Panel/Content/Start
@onready var flash_label: Label = $Flash
@onready var flash_timer: Timer = $FlashTimer


func _ready() -> void:
	console = Console.new(console_output, get_tree())


func setup(match_players: Array[Player], round_wins: Dictionary) -> void:
	players = match_players
	for i in players.size():
		win_labels[i].modulate = players[i].team.color
	update_scores({})
	update_round_wins(round_wins)


func _process(_delta: float) -> void:
	for i in players.size():
		var player: Player = players[i]
		var health_text := "HP %d" % ceili(player.health)
		if player.is_knocked_out:
			health_text = "Respawning..."
		var crystals: Array[String] = []
		for crystal in player.mover_decorator_names + player.shooter_decorator_names:
			crystals.append(crystal.capitalize())
		var crystal_text := "No crystals yet"
		if not crystals.is_empty():
			crystal_text = " · ".join(crystals)
		status_labels[i].text = "%s  |  %s\n%s" % [player.display_name, health_text, crystal_text]


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F1:
		$Console.visible = not $Console.visible
		if $Console.visible:
			console_input.grab_focus()
		else:
			console_input.release_focus()
		get_viewport().set_input_as_handled()
		return
	if not accepting_start or console_input.has_focus():
		return
	var keyboard_start: bool = (
		event is InputEventKey
		and event.pressed
		and not event.echo
		and event.keycode in [KEY_ENTER, KEY_KP_ENTER]
	)
	var gamepad_start: bool = (
		event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_A
	)
	if keyboard_start or gamepad_start:
		get_viewport().set_input_as_handled()
		_on_start_pressed()


func update_scores(scores: Dictionary) -> void:
	for i in players.size():
		var player: Player = players[i]
		score_labels[i].text = (
			"[color=#%s]%s · %s[/color]\n[b]%d bulbs[/b]"
			% [
				player.team.get_hex(),
				player.display_name,
				player.team.name,
				scores.get(player.team.get_hex(), 0),
			]
		)


func update_round(number: int) -> void:
	round_label.text = "ROUND %d" % number


func update_round_wins(round_wins: Dictionary) -> void:
	for i in players.size():
		win_labels[i].text = "%d / %d rounds" % [round_wins[players[i]], Constants.ROUNDS_TO_WIN]


func update_time(time_remaining: float) -> void:
	time_label.text = "%02d" % ceili(maxf(time_remaining, 0.0))
	time_label.modulate = Color("ffb879") if time_remaining <= 10.0 else Color.WHITE


func show_message(
	title: String, detail: String = "", color: Color = Color.WHITE, can_start: bool = false
) -> void:
	flash_timer.stop()
	flash_label.hide()
	message_title.text = title
	message_title.modulate = color
	message_detail.text = detail
	message_detail.visible = not detail.is_empty()
	accepting_start = can_start
	start_button.visible = can_start
	start_button.text = "PLAY AGAIN" if title.contains("wins the match") else "START MATCH"
	message.show()
	if can_start:
		start_button.grab_focus()


func hide_message() -> void:
	accepting_start = false
	start_button.release_focus()
	message.hide()


func flash_message(title: String) -> void:
	hide_message()
	flash_label.text = title
	flash_label.show()
	flash_timer.start()


func _on_start_pressed() -> void:
	if not accepting_start:
		return
	accepting_start = false
	start_button.release_focus()
	start_requested.emit()


func _on_console_line_edit_text_submitted(new_text: String) -> void:
	console_input.clear()
	console.execute(new_text)


func add_log(text: String) -> void:
	console_output.text += text + "\n"
