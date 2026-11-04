class_name PhastDecorator
extends MoverDecorator

const SPEED_MULTIPLIER: float = 1.6


func process_movement(input_vector: Vector2, delta: float, context: MovementContext) -> Vector3:
	context.speed_multiplier *= SPEED_MULTIPLIER
	return wrapped_mover.process_movement(input_vector, delta, context)
