class_name DoubleJumpDecorator
extends MoverDecorator

const EXTRA_JUMPS: int = 1


func process_movement(input_vector: Vector2, delta: float, context: MovementContext) -> Vector2:
	context.max_jumps += EXTRA_JUMPS
	return wrapped_mover.process_movement(input_vector, delta, context)
