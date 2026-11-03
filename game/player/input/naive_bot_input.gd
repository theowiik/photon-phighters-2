class_name NaiveBotInput
extends InputInterface

const WANDER_CHANCE: float = 0.02
const WANDER_DURATION: float = 0.5
const RETARGET_INTERVAL: float = 0.25

var player_node: Node3D
var current_target: Node3D = null
var retarget_timer: float = 0.25
var camera: Camera3D = null

var wander_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO

var _movement: Vector2 = Vector2.ZERO
var _aim_direction: Vector2 = Vector2.ZERO
var _shoot_pressed: bool = false


func _init(p_player_node: Node3D):
	player_node = p_player_node


func update() -> void:
	_update_camera()
	_update_target()

	if current_target == null or not is_instance_valid(current_target):
		_movement = Vector2.ZERO
		_aim_direction = Vector2.ZERO
		_shoot_pressed = false
		return

	_movement = _compute_movement()
	_aim_direction = _compute_aim_direction()
	_shoot_pressed = true


func _compute_movement() -> Vector2:
	var delta = player_node.get_physics_process_delta_time()
	wander_timer -= delta

	# Randomly start wandering
	if wander_timer <= 0 and randf() < WANDER_CHANCE:
		wander_timer = WANDER_DURATION
		wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

	# If wandering, go that direction
	if wander_timer > 0:
		return wander_direction

	# Otherwise chase target
	var direction_3d = current_target.global_position - player_node.global_position
	var direction_2d = Vector2(direction_3d.x, direction_3d.z)

	if direction_2d.length() > 0.1:
		return direction_2d.normalized()

	return Vector2.ZERO


func _update_camera() -> void:
	if camera == null or not is_instance_valid(camera):
		var viewport = player_node.get_viewport()
		if viewport:
			camera = viewport.get_camera_3d()


func _compute_aim_direction() -> Vector2:
	if camera == null or current_target == null:
		return Vector2.RIGHT

	var player_screen_pos = camera.unproject_position(player_node.global_position)
	var target_screen_pos = camera.unproject_position(current_target.global_position)
	var direction = (target_screen_pos - player_screen_pos).normalized()

	return direction


func _update_target() -> void:
	retarget_timer -= player_node.get_physics_process_delta_time()
	if retarget_timer > 0 and current_target != null and is_instance_valid(current_target):
		return

	retarget_timer = RETARGET_INTERVAL
	current_target = _find_closest_enemy()


func _find_closest_enemy() -> Node3D:
	var players = player_node.get_tree().get_nodes_in_group(Constants.PLAYERS_GROUP)
	var closest: Node3D = null
	var closest_distance: float = INF
	var my_team: Team = player_node.team

	for player in players:
		if player == player_node:
			continue
		if player.team.color == my_team.color:
			continue

		var distance = player_node.global_position.distance_to(player.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = player

	return closest


func get_movement() -> Vector2:
	return _movement


func get_aim_direction() -> Vector2:
	return _aim_direction


func is_aiming() -> bool:
	return _aim_direction != Vector2.ZERO


func is_shoot_just_pressed() -> bool:
	return false


func is_shoot_pressed() -> bool:
	return _shoot_pressed


func is_jump_just_pressed() -> bool:
	return false
