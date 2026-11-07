@tool
class_name Capsule
extends Node2D
## A filled capsule drawn in code, lying along its longer side. A square size draws a
## circle. Colors above 1.0 glow.

@export var size: Vector2 = Vector2(16.0, 16.0):
	set(value):
		size = value
		queue_redraw()

@export var color: Color = Color.WHITE:
	set(value):
		color = value
		queue_redraw()

@export var outline_width: float = 0.0:
	set(value):
		outline_width = value
		queue_redraw()

@export var outline_color: Color = Color.BLACK:
	set(value):
		outline_color = value
		queue_redraw()


func _draw() -> void:
	if outline_width > 0.0:
		_draw_capsule(size + Vector2.ONE * outline_width * 2.0, outline_color)
	_draw_capsule(size, color)


func _draw_capsule(capsule_size: Vector2, fill: Color) -> void:
	var radius := minf(capsule_size.x, capsule_size.y) / 2.0
	var reach := capsule_size / 2.0 - Vector2.ONE * radius
	draw_line(-reach, reach, fill, radius * 2.0)
	draw_circle(-reach, radius, fill)
	draw_circle(reach, radius, fill)
