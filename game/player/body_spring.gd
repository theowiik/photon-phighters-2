class_name BodySpring
extends RefCounted

var position: Vector2
var velocity: Vector2 = Vector2.ZERO


func _init(start: Vector2) -> void:
	position = start


func step(target: Vector2, stiffness: float, damping: float, delta: float) -> Vector2:
	velocity += (stiffness * (target - position) - damping * velocity) * delta
	position += velocity * delta
	return position
