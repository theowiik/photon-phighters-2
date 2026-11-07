class_name PlayerBody
extends Node2D


func set_color(color: Color) -> void:
	for part in get_children():
		if part is Capsule:
			part.color = color
