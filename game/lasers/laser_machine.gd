class_name LaserMachine
extends Node3D

const LASER_COUNT: int = 10
const SPREAD: float = 60.0
const WAVE_SPEED: float = 2.0
const WAVE_AMOUNT: float = 30.0
const HUE: float = 0.62
const HUE_SHIFT: float = 0.12
const HUE_SPEED: float = 0.3
const SATURATION: float = 0.6
const ALPHA: float = 0.25

var laser_scene: PackedScene = load("res://lasers/laser.tscn")
var lasers: Array[Laser] = []


func _ready() -> void:
	for i in LASER_COUNT:
		var laser: Laser = laser_scene.instantiate()
		add_child(laser)

		laser.rotation_degrees.y = -SPREAD / 2.0 + (SPREAD / (LASER_COUNT - 1)) * i
		lasers.append(laser)


func _process(_delta: float) -> void:
	var time := Time.get_ticks_msec() / 1000.0

	for i in lasers.size():
		var phase := float(i) / lasers.size() * TAU
		lasers[i].rotation_degrees.x = sin(time * WAVE_SPEED + phase) * WAVE_AMOUNT

		var hue := HUE + HUE_SHIFT * sin(time * HUE_SPEED + phase)
		lasers[i].set_color(Color.from_hsv(hue, SATURATION, 1.0, ALPHA))
