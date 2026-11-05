class_name KeyboardMouseInput
extends InputInterface

var player_node: Node3D
var camera: Camera3D

var _shoot_pressed: bool = false
var _shoot_just_pressed: bool = false
var _jump_pressed: bool = false
var _jump_just_pressed: bool = false
var _movement: Vector2 = Vector2.ZERO
var _aim_direction: Vector2 = Vector2.ZERO


func _init(p_player_node: Node3D):
	player_node = p_player_node


func update() -> void:
	_update_camera()

	var prev_shoot = _shoot_pressed
	_shoot_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	_shoot_just_pressed = _shoot_pressed and not prev_shoot

	var prev_jump = _jump_pressed
	_jump_pressed = Input.is_key_pressed(KEY_SPACE)
	_jump_just_pressed = _jump_pressed and not prev_jump

	_movement = _compute_movement()
	_aim_direction = _compute_aim_direction()


func _update_camera() -> void:
	if camera == null or not is_instance_valid(camera):
		var viewport = player_node.get_viewport()
		if viewport:
			camera = viewport.get_camera_3d()


func _compute_movement() -> Vector2:
	var input_vector = Vector2.ZERO

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
	if camera == null or player_node == null:
		return Vector2.ZERO

	var player_screen_pos = camera.unproject_position(player_node.aim_pivot.global_position)
	var mouse_pos = player_node.get_viewport().get_mouse_position()
	var direction = (mouse_pos - player_screen_pos).normalized()

	return direction


func get_movement() -> Vector2:
	return _movement


func get_aim_direction() -> Vector2:
	return _aim_direction


func is_aiming() -> bool:
	return true


func is_shoot_just_pressed() -> bool:
	return _shoot_just_pressed


func is_shoot_pressed() -> bool:
	return _shoot_pressed


func is_jump_just_pressed() -> bool:
	return _jump_just_pressed
