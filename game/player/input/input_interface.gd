class_name InputInterface
extends RefCounted


func update() -> void:
	push_error("InputInterface.update() not implemented")


func get_movement() -> Vector2:
	push_error("InputInterface.get_movement() not implemented")
	return Vector2.ZERO


func get_aim_direction() -> Vector2:
	push_error("InputInterface.get_aim_direction() not implemented")
	return Vector2.ZERO


func is_aiming() -> bool:
	push_error("InputInterface.is_aiming() not implemented")
	return false


func is_shoot_just_pressed() -> bool:
	push_error("InputInterface.is_shoot_just_pressed() not implemented")
	return false


func is_shoot_pressed() -> bool:
	push_error("InputInterface.is_shoot_pressed() not implemented")
	return false


func is_jump_just_pressed() -> bool:
	push_error("InputInterface.is_jump_just_pressed() not implemented")
	return false
