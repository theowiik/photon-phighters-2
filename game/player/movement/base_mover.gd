class_name BaseMover
extends MoverInterface

const GROUND_ACCELERATION = 70.0
const GROUND_DECELERATION = 90.0
const AIR_ACCELERATION = 40.0
const JUMP_VELOCITY = 12.0
const GRAVITY = 28.0
const FALL_GRAVITY_MULTIPLIER = 1.5
const RELEASED_JUMP_GRAVITY_MULTIPLIER = 2.5
const MAX_FALL_SPEED = 24.0
const WALL_SLIDE_SPEED = 3.5
const WALL_JUMP_VELOCITY = 11.0
const WALL_JUMP_PUSH = 9.0
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.12

var speed: float = 7.5
var _coyote_remaining: float = 0.0
var _jump_buffer_remaining: float = 0.0


func _init(movement_speed: float = 7.5):
	speed = movement_speed


func process_movement(input_vector: Vector2, delta: float, context: MovementContext) -> Vector3:
	_update_jump_timers(delta, context)

	var target_speed := input_vector.x * speed * context.speed_multiplier
	var velocity := Vector3(
		_accelerate(context.velocity_x, target_speed, delta, context.is_on_floor),
		_fall(input_vector.x, delta, context),
		0
	)

	var wants_ground_jump := _jump_buffer_remaining > 0.0 and _coyote_remaining > 0.0
	var wants_wall_jump := (
		context.jump_pressed
		and context.is_on_wall
		and not context.is_on_floor
		and not wants_ground_jump
	)

	if wants_wall_jump:
		velocity.y = WALL_JUMP_VELOCITY
		velocity.x = context.wall_normal.x * WALL_JUMP_PUSH
		context.jump_count = 1
		_consume_jump(context)
	elif wants_ground_jump or context.jump_requested:
		velocity.y = JUMP_VELOCITY
		context.jump_count += 1
		_consume_jump(context)

	return velocity


func _update_jump_timers(delta: float, context: MovementContext) -> void:
	if context.is_on_floor:
		_coyote_remaining = COYOTE_TIME
		context.jump_count = 0
	else:
		_coyote_remaining -= delta
		if _coyote_remaining <= 0.0 and context.jump_count == 0:
			context.jump_count = 1

	_jump_buffer_remaining -= delta
	if context.jump_pressed:
		_jump_buffer_remaining = JUMP_BUFFER_TIME


func _consume_jump(context: MovementContext) -> void:
	context.jump_requested = false
	_jump_buffer_remaining = 0.0
	_coyote_remaining = 0.0


func _accelerate(current: float, target: float, delta: float, on_floor: bool) -> float:
	var rate := AIR_ACCELERATION
	if on_floor:
		rate = GROUND_ACCELERATION if target != 0.0 else GROUND_DECELERATION
	return move_toward(current, target, rate * delta)


func _fall(input_x: float, delta: float, context: MovementContext) -> float:
	if context.is_on_floor:
		return context.velocity_y

	var gravity := GRAVITY
	if context.velocity_y < 0.0:
		gravity *= FALL_GRAVITY_MULTIPLIER
	elif not context.jump_held:
		gravity *= RELEASED_JUMP_GRAVITY_MULTIPLIER

	var velocity_y := maxf(context.velocity_y - gravity * delta, -MAX_FALL_SPEED)
	var pushing_into_wall := context.is_on_wall and input_x * context.wall_normal.x < 0.0
	if pushing_into_wall:
		velocity_y = maxf(velocity_y, -WALL_SLIDE_SPEED)
	return velocity_y
