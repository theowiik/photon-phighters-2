class_name DoubleJumpDecorator
extends MoverDecorator

var max_jumps: int = 2


func _init(mover: MoverInterface, max_jump_count: int = 2):
	super(mover)
	max_jumps = max_jump_count


func process_movement(input_vector: Vector2, delta: float, context: MovementContext) -> Vector3:
	if (
		context.jump_pressed
		and not context.is_on_floor
		and context.jump_count > 0
		and context.jump_count < max_jumps
	):
		context.jump_requested = true

	return wrapped_mover.process_movement(input_vector, delta, context)
