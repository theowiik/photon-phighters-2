class_name LaserMachine
extends Node2D

const LASER_COUNT: int = 10
const LENGTH: float = 3200.0
const WIDTH: float = 2.0
const SPREAD: float = 60.0
const WAVE_SPEED: float = 2.0
const WAVE_AMOUNT: float = 30.0
const HUE: float = 0.62
const HUE_SHIFT: float = 0.12
const HUE_SPEED: float = 0.3
const SATURATION: float = 0.6
const ALPHA: float = 0.25

var lasers: Array[Line2D] = []


func _ready() -> void:
	for i in LASER_COUNT:
		var laser := Line2D.new()
		laser.points = [Vector2.ZERO, Vector2.UP * LENGTH]
		laser.width = WIDTH
		laser.use_parent_material = true
		add_child(laser)
		lasers.append(laser)


func _process(_delta: float) -> void:
	var time := Time.get_ticks_msec() / 1000.0

	for i in lasers.size():
		var phase := float(i) / lasers.size() * TAU
		var fan := -SPREAD / 2.0 + (SPREAD / (LASER_COUNT - 1)) * i
		lasers[i].rotation_degrees = fan + sin(time * WAVE_SPEED + phase) * WAVE_AMOUNT

		var hue := HUE + HUE_SHIFT * sin(time * HUE_SPEED + phase)
		lasers[i].default_color = Color.from_hsv(hue, SATURATION, 1.0, ALPHA)
