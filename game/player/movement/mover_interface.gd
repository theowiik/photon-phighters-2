class_name MoverInterface
extends RefCounted


func process_movement(_input_vector: Vector2, _delta: float, _context: MovementContext) -> Vector3:
	push_error("MoverInterface.process_movement() not implemented")
	return Vector3.ZERO
