class_name PlayerBody
extends Node2D

const FLASH_GLOW: float = 3.0
const FLASH_SECONDS: float = 0.12


func set_color(color: Color) -> void:
	for part in get_children():
		if part is Capsule:
			part.color = color


func flash() -> void:
	modulate = Color(FLASH_GLOW, FLASH_GLOW, FLASH_GLOW)
	create_tween().tween_property(self, "modulate", Color.WHITE, FLASH_SECONDS)
