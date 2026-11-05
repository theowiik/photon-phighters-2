class_name MoverDecorator
extends MoverInterface

var wrapped_mover: MoverInterface


func _init(mover: MoverInterface):
	wrapped_mover = mover


func process_movement(input_vector: Vector2, delta: float, context: MovementContext) -> Vector3:
	return wrapped_mover.process_movement(input_vector, delta, context)
