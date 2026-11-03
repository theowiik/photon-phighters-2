class_name NaiveBotInput
extends InputInterface

const WANDER_CHANCE: float = 0.02
const WANDER_DURATION: float = 0.5
const RETARGET_INTERVAL: float = 0.25
const TARGET_RANGE: float = 10.0
const JUMP_INTERVAL: float = 0.8

var player_node: Player
var current_target: Node3D = null
var retarget_timer: float = 0.25
var camera: Camera3D = null

var wander_timer: float = 0.0
var wander_direction: Vector2 = Vector2.LEFT
var jump_timer: float = 0.0

var _movement: Vector2 = Vector2.ZERO
var _aim_direction: Vector2 = Vector2.ZERO
var _shoot_pressed: bool = false
var _jump_just_pressed: bool = false


func _init(p_player_node: Player) -> void:
	player_node = p_player_node


func update() -> void:
	_update_camera()
	_update_target()

	_movement = _compute_movement()
	_aim_direction = _compute_aim_direction()
	_shoot_pressed = true
	_update_jump()


func _compute_movement() -> Vector2:
	var delta: float = player_node.get_physics_process_delta_time()
	wander_timer -= delta

	# Randomly start wandering
	if wander_timer <= 0 and randf() < WANDER_CHANCE:
		wander_timer = WANDER_DURATION
		wander_direction = Vector2.LEFT if randf() < 0.5 else Vector2.RIGHT

	# If wandering, go that direction
	if wander_timer > 0:
		return wander_direction

	if not is_instance_valid(current_target):
		return wander_direction

	# Otherwise chase target
	var distance_x: float = current_target.global_position.x - player_node.global_position.x
	if absf(distance_x) > 2.0:
		return Vector2(signf(distance_x), 0.0)

	return wander_direction


func _update_jump() -> void:
	jump_timer -= player_node.get_physics_process_delta_time()
	_jump_just_pressed = false
	if jump_timer > 0.0:
		return

	var target_above: bool = (
		is_instance_valid(current_target)
		and current_target.global_position.y > player_node.global_position.y + 1.0
	)
	if player_node.is_on_wall() or (player_node.is_on_floor() and target_above):
		_jump_just_pressed = true
		jump_timer = JUMP_INTERVAL


func _update_camera() -> void:
	if camera == null or not is_instance_valid(camera):
		var viewport = player_node.get_viewport()
		if viewport:
			camera = viewport.get_camera_3d()


func _compute_aim_direction() -> Vector2:
	if camera == null or not is_instance_valid(current_target):
		return Vector2(_movement.x, 0.8).normalized()
	if player_node.global_position.distance_to(current_target.global_position) > TARGET_RANGE:
		return Vector2(_movement.x, 0.8).normalized()

	var player_screen_pos: Vector2 = camera.unproject_position(
		player_node.aim_pivot.global_position
	)
	var target_screen_pos: Vector2 = camera.unproject_position(current_target.global_position)
	var direction: Vector2 = (target_screen_pos - player_screen_pos).normalized()

	return direction


func _update_target() -> void:
	retarget_timer -= player_node.get_physics_process_delta_time()
	if retarget_timer > 0 and current_target != null and is_instance_valid(current_target):
		return

	retarget_timer = RETARGET_INTERVAL
	current_target = _find_enemy_bulb()
	if current_target == null:
		current_target = _find_closest_enemy()


func _find_enemy_bulb() -> Bulb:
	var closest: Bulb = null
	var closest_distance: float = TARGET_RANGE
	for bulb in Groups.get_all_bulbs():
		if bulb.team.color == player_node.team.color:
			continue
		var distance: float = player_node.global_position.distance_to(bulb.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = bulb
	return closest


func _find_closest_enemy() -> Player:
	var players: Array[Player] = Groups.get_all_players()
	var closest: Player = null
	var closest_distance: float = INF
	var my_team: Team = player_node.team

	for player in players:
		if player == player_node or player.is_knocked_out:
			continue
		if player.team.color == my_team.color:
			continue

		var distance: float = player_node.global_position.distance_to(player.global_position)
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
	return _jump_just_pressed
