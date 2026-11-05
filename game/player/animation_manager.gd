class_name AnimationManager
extends RefCounted

enum State {GROUNDED, INITIATE_JUMP, JUMP_UP, JUMP_DOWN, LANDING, IDLE, WALL_GLIDE, WALL_GLIDE_JUMP}

const DEFAULT_BLEND: float = 0.1
const LANDING_BLEND: float = 0.05

var animation_player: AnimationPlayer
var body: Node3D
var current_state: State = State.GROUNDED
var was_on_floor: bool = true
var facing_right: bool = true


func _init(anim_player: AnimationPlayer, body_node: Node3D):
	animation_player = anim_player
	body = body_node


func update(
	velocity: Vector3,
	is_on_floor: bool,
	is_on_wall: bool = false,
	wall_normal: Vector3 = Vector3.ZERO
) -> void:
	var new_state = _determine_state(velocity.y, is_on_floor, is_on_wall)

	if new_state == State.WALL_GLIDE:
		var wall_on_left = wall_normal.x > 0
		body.scale.x = -1.0 if wall_on_left else 1.0
		facing_right = not wall_on_left
	elif new_state != State.WALL_GLIDE_JUMP:
		_update_facing(velocity.x)

	if abs(velocity.x) < 0.1 and is_on_floor:
		new_state = State.IDLE

	if new_state != current_state:
		_transition_to(new_state)

	was_on_floor = is_on_floor


func _update_facing(velocity_x: float) -> void:
	if velocity_x > 0.1 and not facing_right:
		facing_right = true
		body.scale.x = 1.0
	elif velocity_x < -0.1 and facing_right:
		facing_right = false
		body.scale.x = -1.0


func _determine_state(velocity_y: float, is_on_floor: bool, is_on_wall: bool) -> State:
	var result: State

	if is_on_floor:
		if current_state in [State.JUMP_DOWN, State.WALL_GLIDE, State.WALL_GLIDE_JUMP]:
			result = State.LANDING
		elif current_state == State.LANDING and animation_player.is_playing():
			result = State.LANDING
		else:
			result = State.GROUNDED
	elif is_on_wall:
		result = State.WALL_GLIDE
	elif current_state == State.WALL_GLIDE:
		result = State.WALL_GLIDE_JUMP
	elif current_state == State.WALL_GLIDE_JUMP:
		if animation_player.is_playing():
			result = State.WALL_GLIDE_JUMP
		else:
			result = State.JUMP_UP if velocity_y > 0 else State.JUMP_DOWN
	elif current_state == State.GROUNDED and velocity_y > 0:
		result = State.INITIATE_JUMP
	elif current_state == State.INITIATE_JUMP:
		result = State.JUMP_UP if not animation_player.is_playing() else State.INITIATE_JUMP
	else:
		result = State.JUMP_UP if velocity_y > 0 else State.JUMP_DOWN

	return result


func _transition_to(new_state: State) -> void:
	current_state = new_state
	animation_player.speed_scale = 1.0

	match new_state:
		State.GROUNDED:
			animation_player.play("walk", DEFAULT_BLEND)
		State.INITIATE_JUMP:
			animation_player.play("initiate_jump", DEFAULT_BLEND)
		State.JUMP_UP:
			animation_player.play("jump_up", DEFAULT_BLEND)
		State.JUMP_DOWN:
			animation_player.play("jump_down", DEFAULT_BLEND)
		State.LANDING:
			animation_player.play("jump_land", LANDING_BLEND)
		State.IDLE:
			animation_player.play("idle_animation", DEFAULT_BLEND)
		State.WALL_GLIDE:
			animation_player.play("wall_glide", DEFAULT_BLEND)
		State.WALL_GLIDE_JUMP:
			animation_player.play("wall_glide_jump", DEFAULT_BLEND)
