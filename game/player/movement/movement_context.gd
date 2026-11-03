class_name MovementContext
extends RefCounted

var velocity_y: float = 0.0
var is_on_floor: bool = false
var is_on_wall: bool = false
var wall_normal: Vector3 = Vector3.ZERO
var jump_pressed: bool = false
var jump_count: int = 0
var jump_requested: bool = false
var wall_jump_requested: bool = false
var speed_multiplier: float = 1.0


func _init(
	vel_y: float = 0.0,
	on_floor: bool = false,
	jump: bool = false,
	jumps: int = 0,
	on_wall: bool = false,
	w_normal: Vector3 = Vector3.ZERO
):
	velocity_y = vel_y
	is_on_floor = on_floor
	jump_pressed = jump
	jump_count = jumps
	is_on_wall = on_wall
	wall_normal = w_normal
