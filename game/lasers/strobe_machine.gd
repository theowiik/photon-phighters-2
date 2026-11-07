class_name StrobeMachine
extends Node2D

var on: bool = false
var strobe_speed: float = 10.0

@onready var light: Sprite2D = $Light


func _process(_delta: float) -> void:
	if not on:
		return

	var time := Time.get_ticks_msec() / 1000.0
	light.visible = sin(time * strobe_speed * TAU) > 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_J:
		on = not on
		visible = on
