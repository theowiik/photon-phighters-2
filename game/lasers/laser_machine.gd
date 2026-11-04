extends Node3D

const LASER_COUNT: int = 10
const SPREAD: float = 60.0
const WAVE_SPEED: float = 2.0
const WAVE_AMOUNT: float = 30.0

var laser_scene: PackedScene = load("res://lasers/laser.tscn")
var lasers: Array[Node3D] = []


func _ready() -> void:
	for i in LASER_COUNT:
		var laser = laser_scene.instantiate()
		add_child(laser)

		laser.rotation_degrees.y = -SPREAD / 2.0 + (SPREAD / (LASER_COUNT - 1)) * i
		lasers.append(laser)


func _process(_delta: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0

	for i in lasers.size():
		var phase = float(i) / lasers.size() * TAU
		var angle = sin(time * WAVE_SPEED + phase) * WAVE_AMOUNT
		lasers[i].rotation_degrees.x = angle

		var hue = 0.62 + 0.12 * sin(time * 0.3 + phase)
		lasers[i].set_color(Color.from_hsv(hue, 0.6, 1.0, 0.25))
