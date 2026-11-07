class_name MovementContext
extends RefCounted

var velocity: Vector2 = Vector2.ZERO
var is_on_floor: bool = false
var is_on_wall: bool = false
var wall_normal: Vector2 = Vector2.ZERO
var jump_pressed: bool = false
var jump_held: bool = false
var speed_multiplier: float = 1.0
var max_jumps: int = 1
