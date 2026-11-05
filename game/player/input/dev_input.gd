class_name DevInput
extends InputInterface

var _keyboard_input: KeyboardMouseInput
var _gamepad_input: GamepadInput

var _active_input: InputInterface


func _init(p_player_node: Node3D, p_gamepad_device_id: int = 0):
	_keyboard_input = KeyboardMouseInput.new(p_player_node)
	_gamepad_input = GamepadInput.new(p_gamepad_device_id)
	_active_input = _keyboard_input


func update() -> void:
	_keyboard_input.update()
	_gamepad_input.update()

	_update_active_input()


func _update_active_input() -> void:
	var gamepad_has_input = (
		_gamepad_input.get_movement().length() > 0.1
		or _gamepad_input.is_aiming()
		or _gamepad_input.is_shoot_pressed()
		or _gamepad_input.is_jump_just_pressed()
	)

	var keyboard_has_input = (
		_keyboard_input.get_movement().length() > 0.1
		or _keyboard_input.is_shoot_pressed()
		or _keyboard_input.is_jump_just_pressed()
	)

	if gamepad_has_input and not keyboard_has_input:
		_active_input = _gamepad_input
	elif keyboard_has_input and not gamepad_has_input:
		_active_input = _keyboard_input


func get_movement() -> Vector2:
	return _active_input.get_movement()


func get_aim_direction() -> Vector2:
	return _active_input.get_aim_direction()


func is_aiming() -> bool:
	return _active_input.is_aiming()


func is_shoot_just_pressed() -> bool:
	return _keyboard_input.is_shoot_just_pressed() or _gamepad_input.is_shoot_just_pressed()


func is_shoot_pressed() -> bool:
	return _active_input.is_shoot_pressed()


func is_jump_just_pressed() -> bool:
	return _keyboard_input.is_jump_just_pressed() or _gamepad_input.is_jump_just_pressed()
