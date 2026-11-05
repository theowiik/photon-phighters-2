class_name GamepadInput
extends InputInterface

const STICK_DEADZONE: float = 0.2

var device_id: int

var _shoot_pressed: bool = false
var _jump_pressed: bool = false
var _jump_just_pressed: bool = false
var _movement: Vector2 = Vector2.ZERO
var _aim_direction: Vector2 = Vector2.ZERO


func _init(p_device_id: int) -> void:
	device_id = p_device_id


func update() -> void:
	_shoot_pressed = (
		_get_axis(JOY_AXIS_TRIGGER_RIGHT) > 0.5 or _is_button_pressed(JOY_BUTTON_RIGHT_SHOULDER)
	)

	var was_jump_pressed := _jump_pressed
	_jump_pressed = _get_axis(JOY_AXIS_TRIGGER_LEFT) > 0.5 or _is_button_pressed(JOY_BUTTON_A)
	_jump_just_pressed = _jump_pressed and not was_jump_pressed

	_movement = _compute_movement()
	_aim_direction = _compute_aim_direction()


func _compute_movement() -> Vector2:
	var input_vector := Vector2(_get_axis(JOY_AXIS_LEFT_X), _get_axis(JOY_AXIS_LEFT_Y))
	if absf(input_vector.x) < STICK_DEADZONE:
		input_vector.x = 0.0
	if absf(input_vector.y) < STICK_DEADZONE:
		input_vector.y = 0.0
	return input_vector


func _compute_aim_direction() -> Vector2:
	var aim_vector := Vector2(_get_axis(JOY_AXIS_RIGHT_X), _get_axis(JOY_AXIS_RIGHT_Y))
	if aim_vector.length() < STICK_DEADZONE:
		return Vector2.ZERO

	return aim_vector.normalized()


func get_movement() -> Vector2:
	return _movement


func get_aim_direction() -> Vector2:
	return _aim_direction


func is_shoot_pressed() -> bool:
	return _shoot_pressed


func is_jump_just_pressed() -> bool:
	return _jump_just_pressed


func _is_button_pressed(button: JoyButton) -> bool:
	return Input.is_joy_button_pressed(device_id, button)


func _get_axis(axis: JoyAxis) -> float:
	return Input.get_joy_axis(device_id, axis)


func is_jump_held() -> bool:
	return _jump_pressed
