class_name FollowCamera
extends Camera3D

@export var smoothing_speed: float = 5.0
var follow: Array[Player] = []
var offset: Vector3 = Vector3(0, 0, 100)


func _ready() -> void:
	follow = Groups.get_all_players()


func _physics_process(delta: float) -> void:
	if follow.is_empty():
		return

	var avg_position: Vector3 = Vector3.ZERO
	for node in follow:
		avg_position += node.global_position
	avg_position /= follow.size()

	var target_position: Vector3 = avg_position + offset
	global_position = global_position.lerp(target_position, 1.0 - exp(-smoothing_speed * delta))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dev_zoom_in"):
		offset.z += 10
	elif event.is_action_pressed("dev_zoom_out"):
		offset.z -= 10
