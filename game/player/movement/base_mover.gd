class_name BaseMover
extends MoverInterface

const SPEED: float = 288.0
const GROUND_ACCELERATION: float = 2240.0
const GROUND_DECELERATION: float = 2880.0
const AIR_ACCELERATION: float = 1280.0
const JUMP_VELOCITY: float = -432.0
const GRAVITY: float = 896.0
const FALL_GRAVITY_MULTIPLIER: float = 1.5
const RELEASED_JUMP_GRAVITY_MULTIPLIER: float = 2.5
const MAX_FALL_SPEED: float = 768.0
const WALL_SLIDE_SPEED: float = 112.0
const WALL_JUMP_VELOCITY: float = -512.0
const WALL_JUMP_PUSH: float = 192.0
const COYOTE_TIME: float = 0.1
const JUMP_BUFFER_TIME: float = 0.12

var _jump_count: int = 0
var _coyote_remaining: float = 0.0
var _jump_buffer_remaining: float = 0.0


func process_movement(input_vector: Vector2, delta: float, context: MovementContext) -> Vector2:
	_update_jump_timers(delta, context)

	var target_speed := input_vector.x * SPEED * context.speed_multiplier
	var velocity := Vector2(
		_accelerate(context.velocity.x, target_speed, delta, context.is_on_floor),
		_fall(input_vector.x, delta, context)
	)

	var in_air_jump := context.jump_pressed and not context.is_on_floor
	if _jump_buffer_remaining > 0.0 and _coyote_remaining > 0.0:
		velocity.y = JUMP_VELOCITY
		_consume_jump(1)
	elif in_air_jump and context.is_on_wall:
		velocity.y = WALL_JUMP_VELOCITY
		velocity.x = context.wall_normal.x * WALL_JUMP_PUSH
		_consume_jump(1)
	elif in_air_jump and _jump_count < context.max_jumps:
		velocity.y = JUMP_VELOCITY
		_consume_jump(_jump_count + 1)

	return velocity


func _update_jump_timers(delta: float, context: MovementContext) -> void:
	if context.is_on_floor:
		_coyote_remaining = COYOTE_TIME
		_jump_count = 0
	else:
		_coyote_remaining -= delta
		if _coyote_remaining <= 0.0:
			_jump_count = maxi(_jump_count, 1)

	_jump_buffer_remaining -= delta
	if context.jump_pressed:
		_jump_buffer_remaining = JUMP_BUFFER_TIME


func _consume_jump(jump_count: int) -> void:
	_jump_count = jump_count
	_jump_buffer_remaining = 0.0
	_coyote_remaining = 0.0


func _accelerate(current: float, target: float, delta: float, on_floor: bool) -> float:
	var rate := AIR_ACCELERATION
	if on_floor:
		rate = GROUND_ACCELERATION if target != 0.0 else GROUND_DECELERATION
	return move_toward(current, target, rate * delta)


func _fall(input_x: float, delta: float, context: MovementContext) -> float:
	if context.is_on_floor:
		return context.velocity.y

	var gravity := GRAVITY
	if context.velocity.y > 0.0:
		gravity *= FALL_GRAVITY_MULTIPLIER
	elif not context.jump_held:
		gravity *= RELEASED_JUMP_GRAVITY_MULTIPLIER

	var velocity_y := minf(context.velocity.y + gravity * delta, MAX_FALL_SPEED)
	var pushing_into_wall := context.is_on_wall and input_x * context.wall_normal.x < 0.0
	if pushing_into_wall:
		velocity_y = minf(velocity_y, WALL_SLIDE_SPEED)
	return velocity_y
