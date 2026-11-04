class_name PhastDecorator
extends MoverDecorator

var speed_multiplier: float = 1.6


func _init(mover: MoverInterface, multiplier: float = 1.6):
	super(mover)
	speed_multiplier = multiplier


func process_movement(input_vector: Vector2, delta: float, context: MovementContext) -> Vector3:
	context.speed_multiplier *= speed_multiplier
	return wrapped_mover.process_movement(input_vector, delta, context)
