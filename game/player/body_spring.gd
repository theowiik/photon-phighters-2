class_name BodySpring
extends RefCounted

var position: Vector3
var velocity: Vector3 = Vector3.ZERO


func _init(start: Vector3) -> void:
	position = start


func step(target: Vector3, stiffness: float, damping: float, delta: float) -> Vector3:
	velocity += (stiffness * (target - position) - damping * velocity) * delta
	position += velocity * delta
	return position
