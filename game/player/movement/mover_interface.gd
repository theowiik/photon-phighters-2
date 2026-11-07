class_name MoverInterface
extends RefCounted


func process_movement(_input_vector: Vector2, _delta: float, _context: MovementContext) -> Vector2:
	push_error("MoverInterface.process_movement() not implemented")
	return Vector2.ZERO
