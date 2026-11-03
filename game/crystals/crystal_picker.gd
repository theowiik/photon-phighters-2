class_name CrystalPicker
extends Control

signal crystal_picked(crystal_name: String)

var crystal_button_scene: PackedScene = preload("res://crystals/crystal_button.tscn")
var picking_player: Player
var has_picked: bool = false
var selected_index: int = 0
var stick_direction: int = 0

@onready var result_label: RichTextLabel = $Center/Panel/Content/ResultLabel
@onready var buttons: VBoxContainer = $Center/Panel/Content/Buttons
@onready var hint: Label = $Center/Panel/Content/Hint


func show_choices(winner: Player, loser: Player, choices: Array[String]) -> void:
	picking_player = loser
	result_label.text = (
		"[color=#%s]%s[/color] won the round.\n[color=#%s]%s · %s[/color] picks an upgrade."
		% [
			winner.team.get_hex(),
			winner.team.name,
			loser.team.get_hex(),
			loser.display_name,
			loser.team.name
		]
	)
	for crystal_name in choices:
		var button: Button = crystal_button_scene.instantiate()
		button.text = (
			"%s\n%s" % [crystal_name.capitalize(), CrystalRegistry.get_description(crystal_name)]
		)
		button.custom_minimum_size.y = 72
		button.disabled = loser.is_bot()
		buttons.add_child(button)
		button.pressed.connect(_on_crystal_button_pressed.bind(crystal_name))

	for index in buttons.get_child_count():
		var button: Button = buttons.get_child(index)
		var previous: Button = buttons.get_child(wrapi(index - 1, 0, buttons.get_child_count()))
		var next: Button = buttons.get_child(wrapi(index + 1, 0, buttons.get_child_count()))
		button.focus_neighbor_top = button.get_path_to(previous)
		button.focus_neighbor_bottom = button.get_path_to(next)
		button.focus_previous = button.get_path_to(previous)
		button.focus_next = button.get_path_to(next)

	if loser.is_bot():
		hint.text = "The bot is choosing…"
		await get_tree().create_timer(2.5).timeout
		_on_crystal_button_pressed(choices.pick_random())
	else:
		buttons.get_child(0).grab_focus()
		if loser.input is GamepadInput:
			hint.text = "Use your left stick or D-pad · A to choose"
		else:
			hint.text = "Click a crystal or use ↑ / ↓ · Enter to choose"


func _input(event: InputEvent) -> void:
	if picking_player == null:
		return
	if has_picked or picking_player.is_bot():
		get_viewport().set_input_as_handled()
		return

	if picking_player.input is GamepadInput:
		if event.device == picking_player.input.device_id:
			_handle_gamepad_input(event)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouse:
		return
	if event is InputEventKey:
		for action in ["ui_up", "ui_down", "ui_accept", "ui_focus_next", "ui_focus_prev"]:
			if event.is_action(action):
				return
	get_viewport().set_input_as_handled()


func _handle_gamepad_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.pressed:
		match event.button_index:
			JOY_BUTTON_A:
				buttons.get_child(selected_index).pressed.emit()
			JOY_BUTTON_DPAD_UP:
				_move_selection(-1)
			JOY_BUTTON_DPAD_DOWN:
				_move_selection(1)
	if event is InputEventJoypadMotion and event.axis == JOY_AXIS_LEFT_Y:
		var direction: int = 0
		if absf(event.axis_value) > 0.5:
			direction = int(signf(event.axis_value))
		if direction != 0 and direction != stick_direction:
			_move_selection(direction)
		stick_direction = direction


func _move_selection(direction: int) -> void:
	selected_index = wrapi(selected_index + direction, 0, buttons.get_child_count())
	buttons.get_child(selected_index).grab_focus()


func _on_crystal_button_pressed(crystal_name: String) -> void:
	if has_picked:
		return
	has_picked = true
	hide()
	crystal_picked.emit(crystal_name)
