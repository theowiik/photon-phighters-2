class_name KeyboardMouseInput
extends InputInterface

var aim_origin: Node3D
var camera: Camera3D

var _shoot_pressed: bool = false
var _jump_pressed: bool = false
var _jump_just_pressed: bool = false
var _movement: Vector2 = Vector2.ZERO
var _aim_direction: Vector2 = Vector2.ZERO


func _init(origin: Node3D) -> void:
	aim_origin = origin


func update() -> void:
	_update_camera()
	if aim_origin.get_viewport().gui_get_focus_owner() is LineEdit:
		_shoot_pressed = false
		_jump_pressed = false
		_jump_just_pressed = false
		_movement = Vector2.ZERO
		return

	_shoot_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	var was_jump_pressed := _jump_pressed
	_jump_pressed = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W)
	_jump_just_pressed = _jump_pressed and not was_jump_pressed

	_movement = _compute_movement()
	_aim_direction = _compute_aim_direction()


func _update_camera() -> void:
	if not is_instance_valid(camera):
		camera = aim_origin.get_viewport().get_camera_3d()


func _compute_movement() -> Vector2:
	var input_vector := Vector2.ZERO

	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1.0
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_vector.y += 1.0
	if Input.is_key_pressed(KEY_W):
		input_vector.y -= 1.0

	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	return input_vector


func _compute_aim_direction() -> Vector2:
	if camera == null:
		return Vector2.ZERO

	var origin_screen_pos := camera.unproject_position(aim_origin.global_position)
	var mouse_pos := aim_origin.get_viewport().get_mouse_position()
	return (mouse_pos - origin_screen_pos).normalized()


func get_movement() -> Vector2:
	return _movement


func get_aim_direction() -> Vector2:
	return _aim_direction


func is_shoot_pressed() -> bool:
	return _shoot_pressed


func is_jump_just_pressed() -> bool:
	return _jump_just_pressed


func is_jump_held() -> bool:
	return _jump_pressed
