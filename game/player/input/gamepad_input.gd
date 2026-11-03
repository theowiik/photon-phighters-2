class_name GamepadInput
extends InputInterface

const STICK_DEADZONE: float = 0.2

var device_id: int

var _shoot_pressed: bool = false
var _shoot_just_pressed: bool = false
var _jump_pressed: bool = false
var _jump_just_pressed: bool = false
var _movement: Vector2 = Vector2.ZERO
var _aim_direction: Vector2 = Vector2.ZERO


func _init(p_device_id: int = 0):
	device_id = p_device_id


func update() -> void:
	var prev_shoot = _shoot_pressed
	_shoot_pressed = _get_axis(JOY_AXIS_TRIGGER_RIGHT) > 0.5
	_shoot_just_pressed = _shoot_pressed and not prev_shoot

	var prev_jump = _jump_pressed
	_jump_pressed = _get_axis(JOY_AXIS_TRIGGER_LEFT) > 0.5
	_jump_just_pressed = _jump_pressed and not prev_jump

	_movement = _compute_movement()
	_aim_direction = _compute_aim_direction()


func _compute_movement() -> Vector2:
	var input_vector = Vector2.ZERO

	var stick_x = _get_axis(JOY_AXIS_LEFT_X)
	var stick_y = _get_axis(JOY_AXIS_LEFT_Y)

	if abs(stick_x) > STICK_DEADZONE:
		input_vector.x = stick_x
	if abs(stick_y) > STICK_DEADZONE:
		input_vector.y = stick_y

	return input_vector


func _compute_aim_direction() -> Vector2:
	var aim_x = _get_axis(JOY_AXIS_RIGHT_X)
	var aim_y = _get_axis(JOY_AXIS_RIGHT_Y)

	var aim_vector = Vector2(aim_x, aim_y)

	if aim_vector.length() < STICK_DEADZONE:
		return Vector2.ZERO

	return aim_vector.normalized()


func get_movement() -> Vector2:
	return _movement


func get_aim_direction() -> Vector2:
	return _aim_direction


func is_aiming() -> bool:
	return _aim_direction != Vector2.ZERO


func is_shoot_just_pressed() -> bool:
	return _shoot_just_pressed


func is_shoot_pressed() -> bool:
	return _shoot_pressed


func is_jump_just_pressed() -> bool:
	return _jump_just_pressed


func _is_button_pressed(button: JoyButton) -> bool:
	return Input.is_joy_button_pressed(device_id, button)


func _get_axis(axis: JoyAxis) -> float:
	return Input.get_joy_axis(device_id, axis)
