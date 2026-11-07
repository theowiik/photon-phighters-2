class_name AnimationManager
extends RefCounted

const PLATFORMS_MASK: int = 1
const RUN_SPEED: float = 288.0
const JUMP_SPEED: float = 432.0
const MAX_KICK: float = 320.0
const GROUND_Y: float = 28.0
const TELEPORT_DISTANCE: float = 96.0
const GROUND_PROBE_UP: float = 32.0
const GROUND_PROBE_DOWN: float = 48.0

const STANCE_SPREAD: float = 4.8
const STEP_THRESHOLD: float = 3.2
const STEP_THRESHOLD_PER_SPEED: float = 0.07
const STEP_LEAD_SECONDS: float = 0.08
const SLOW_STEP_DURATION: float = 0.22
const FAST_STEP_DURATION: float = 0.13
const SLOW_STEP_HEIGHT: float = 4.8
const FAST_STEP_HEIGHT: float = 12.8
const STEP_PITCH: float = 0.6
const WALL_FOOT_REACH: float = 12.8
const RUN_STRIDE: float = 89.6
const RUN_REACH: float = RUN_STRIDE / 4.0
const RUN_LIFT: float = 14.4
const RUN_FOOT_PITCH: float = 0.6
const RUN_BOB: float = 2.56
const RUN_BLEND_START: float = 0.25
const RUN_BLEND_END: float = 0.6
const AIR_CYCLE_SPEED: float = 10.0
const AIR_FALL_CYCLE_BOOST: float = 6.0
const LEG_CIRCLE: float = 8.0
const ARM_CIRCLE: float = 11.2
const ARM_CIRCLE_ROLL: float = 0.6

const BODY_FOLLOW: float = 0.7
const MAX_BODY_DROP: float = 12.8
const STEP_BOB: float = 3.2
const RUN_CROUCH: float = 2.56
const BREATH_HEIGHT: float = 1.28
const HOVER_SPEED: float = 2.2
const HOVER_SIZE: float = 1.92
const HAND_REACH: float = 9.6
const HAND_DROP: float = 1.6
const ARM_SWING: float = 1.0
const ARM_LIFT: float = 0.3
const RUN_HAND_DROP: float = 6.4
const ARM_ROLL: float = 0.025
const GRIP_REACH: float = 17.6
const GRIP_DROP: float = 3.84
const IDLE_HAND_ROLL: float = -0.3
const AIR_HAND_BACK: float = 9.6
const AIR_HAND_LIFT: float = 14.4
const AIR_HAND_ROLL: float = -2.6
const WALL_HAND_ROLL: float = -2.2
const WALL_HAND_REACH: float = 14.4
const WALL_HAND_LIFT: float = 19.2
const AIR_TRAIL: float = 0.035
const MAX_AIR_TRAIL: float = 19.2
const LOOK_AMOUNT: float = 0.6
const MAX_LOOK: float = 0.6
const TORSO_LOOK: float = 0.2
const WOBBLE_PER_SPEED: float = 0.0025
const MAX_WOBBLE: float = 0.6

const TORSO_STIFFNESS: float = 180.0
const TORSO_DAMPING: float = 16.0
const TORSO_INERTIA: float = 0.08
const HEAD_STIFFNESS: float = 90.0
const HEAD_DAMPING: float = 8.0
const HEAD_INERTIA: float = 0.18
const HAND_STIFFNESS: float = 45.0
const HAND_DAMPING: float = 6.0
const HAND_INERTIA: float = 0.3
const FOOT_STIFFNESS: float = 110.0
const FOOT_DAMPING: float = 10.0
const FOOT_INERTIA: float = 0.2
const ROLL_STIFFNESS: float = 120.0
const ROLL_DAMPING: float = 9.0
const HEAD_ROLL_STIFFNESS: float = 60.0
const HEAD_ROLL_DAMPING: float = 4.5
const WEIGHT_SHARPNESS: float = 8.0

const LEAN_PER_SPEED: float = 0.000625
const LEAN_KICK: float = 0.009375
const MAX_LEAN: float = 0.3
const LEAN_STIFFNESS: float = 90.0
const LEAN_DAMPING: float = 9.0

const STRETCH_PER_SPEED: float = 0.0001875
const MAX_STRETCH: float = 0.12
const STRETCH_STIFFNESS: float = 250.0
const STRETCH_DAMPING: float = 12.0
const LANDING_SQUASH: float = 0.009375
const TAKEOFF_STRETCH: float = 0.00125
const TURN_SQUASH: float = 1.5

var body: Node2D
var player: Node2D
var torso: BodyPart
var head: BodyPart
var left_hand: BodyPart
var right_hand: BodyPart
var left_foot: BodyFoot
var right_foot: BodyFoot
var rest_body_y: float
var time: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var kick: Vector2 = Vector2.ZERO
var speed: float = 0.0
var is_grounded: bool = true
var gait: float = 0.0
var run_blend: float = 0.0
var run_phase: float = 0.0
var air_phase: float = 0.0
var air: float = 0.0
var wall: float = 0.0
var rise: float = 0.0
var look: float = 0.0
var aim_direction: Vector2 = Vector2.RIGHT
var aim_origin: Vector2
var facing: float = 1.0
var lean: float = 0.0
var lean_velocity: float = 0.0
var stretch: float = 1.0
var stretch_velocity: float = 0.0


func _init(body_node: Node2D) -> void:
	body = body_node
	player = body.get_parent() as Node2D
	rest_body_y = body.position.y
	aim_origin = player.get_node("AimPivot").position
	torso = BodyPart.new(body.get_node("Torso"))
	head = BodyPart.new(body.get_node("Head"))
	left_hand = BodyPart.new(body.get_node("LeftHand"))
	right_hand = BodyPart.new(body.get_node("RightHand"))
	left_foot = BodyFoot.new(body.get_node("LeftFoot"), -1.0)
	right_foot = BodyFoot.new(body.get_node("RightFoot"), 1.0)


func update(
	delta: float,
	new_velocity: Vector2,
	is_on_floor: bool,
	is_on_wall: bool,
	wall_normal: Vector2,
	aim_angle: float
) -> void:
	time += delta
	kick = (new_velocity - velocity).limit_length(MAX_KICK)
	velocity = new_velocity
	speed = clampf(absf(velocity.x) / RUN_SPEED, 0.0, 1.0)
	var was_grounded := is_grounded
	is_grounded = is_on_floor
	var on_wall := is_on_wall and not is_on_floor

	gait = _smooth(gait, speed if is_grounded else 0.0, delta)
	air = _smooth(air, 0.0 if is_grounded or on_wall else 1.0, delta)
	wall = _smooth(wall, 1.0 if on_wall else 0.0, delta)
	rise = _smooth(rise, clampf(-velocity.y / JUMP_SPEED, -1.0, 1.0), delta)
	var run_target := smoothstep(RUN_BLEND_START, RUN_BLEND_END, speed) if is_grounded else 0.0
	run_blend = _smooth(run_blend, run_target, delta)
	if is_grounded:
		run_phase = fmod(run_phase + absf(velocity.x) * delta / RUN_STRIDE * TAU, TAU)
	var fall := maxf(-rise, 0.0) * air
	air_phase = fmod(air_phase + (AIR_CYCLE_SPEED + AIR_FALL_CYCLE_BOOST * fall) * delta, TAU)

	_update_facing(on_wall, wall_normal)
	_update_look(aim_angle, delta)
	_update_stretch(delta, was_grounded)
	_update_lean(delta, on_wall)
	_update_body()
	_update_foot(left_foot, right_foot, delta)
	_update_foot(right_foot, left_foot, delta)
	_update_torso_and_head(delta)
	_update_hand(left_hand, right_foot, HAND_REACH, 0.0, true, delta)
	_update_hand(right_hand, left_foot, -HAND_REACH, PI, false, delta)


func _update_facing(on_wall: bool, wall_normal: Vector2) -> void:
	var new_facing := facing
	if on_wall:
		new_facing = -1.0 if wall_normal.x > 0.0 else 1.0
	elif absf(velocity.x) > 3.2:
		new_facing = signf(velocity.x)
	if new_facing != facing:
		stretch_velocity -= TURN_SQUASH
	facing = new_facing


func _update_look(aim_angle: float, delta: float) -> void:
	aim_direction = Vector2.from_angle(aim_angle)
	var aim_height := atan2(aim_direction.y, absf(aim_direction.x))
	look = _smooth(look, clampf(aim_height * LOOK_AMOUNT, -MAX_LOOK, MAX_LOOK), delta)


func _update_stretch(delta: float, was_grounded: bool) -> void:
	if is_grounded and not was_grounded:
		stretch_velocity -= maxf(-kick.y, 0.0) * LANDING_SQUASH
	elif was_grounded and not is_grounded and velocity.y < 0.0:
		stretch_velocity -= velocity.y * TAKEOFF_STRETCH

	var target := 1.0
	if not is_grounded:
		target += clampf(absf(velocity.y) * STRETCH_PER_SPEED, 0.0, MAX_STRETCH)
	stretch_velocity += (
		(STRETCH_STIFFNESS * (target - stretch) - STRETCH_DAMPING * stretch_velocity) * delta
	)
	stretch = clampf(
		stretch + stretch_velocity * delta, 1.0 - MAX_STRETCH * 2.0, 1.0 + MAX_STRETCH * 2.0
	)


func _update_lean(delta: float, on_wall: bool) -> void:
	var target := 0.0 if on_wall else clampf(velocity.x * LEAN_PER_SPEED, -MAX_LEAN, MAX_LEAN)
	lean_velocity += kick.x * LEAN_KICK
	lean_velocity += (LEAN_STIFFNESS * (target - lean) - LEAN_DAMPING * lean_velocity) * delta
	lean = clampf(lean + lean_velocity * delta, -MAX_LEAN * 2.0, MAX_LEAN * 2.0)


func _update_body() -> void:
	var width := 1.0 / sqrt(stretch)
	body.rotation = lean
	body.scale = Vector2(facing * width, stretch)
	body.position.y = rest_body_y + GROUND_Y * (1.0 - stretch)


func _update_foot(foot: BodyFoot, other_foot: BodyFoot, delta: float) -> void:
	var home := player.to_global(_foot_home(foot, 0.0))
	if foot.world_center.distance_to(home) > TELEPORT_DISTANCE:
		foot.world_center = home
		foot.is_planted = false
		foot.step_progress = -1.0
		foot.spring.position = player.to_local(home)

	if not is_grounded:
		_float_foot(foot, delta)
	elif foot.is_stepping():
		_advance_step(foot, delta)
	elif not foot.is_planted or _wants_step(foot, other_foot):
		foot.start_step()
		_advance_step(foot, delta)

	foot.shown_center = foot.world_center
	if run_blend > 0.0:
		foot.shown_center = foot.world_center.lerp(_run_cycle_point(foot), run_blend)

	if is_grounded:
		foot.spring.position = player.to_local(foot.shown_center)
		foot.spring.velocity = Vector2.ZERO

	var roll := lerpf(_foot_roll(foot), _run_cycle_roll(foot), run_blend)
	foot.spin(roll, ROLL_STIFFNESS, ROLL_DAMPING, delta)
	foot.place(_to_body(player.to_local(foot.shown_center)))


func _run_cycle(foot: BodyFoot) -> float:
	return run_phase + (PI if foot == right_foot else 0.0)


func _run_cycle_point(foot: BodyFoot) -> Vector2:
	var cycle := _run_cycle(foot)
	var ground := _plant_point(foot, -cos(cycle) * RUN_REACH * facing)
	return ground + Vector2.UP * maxf(sin(cycle), 0.0) * RUN_LIFT


func _run_cycle_roll(foot: BodyFoot) -> float:
	return cos(_run_cycle(foot)) * RUN_FOOT_PITCH


func _air_cycle(foot: BodyFoot) -> float:
	return air_phase + (PI if foot == right_foot else 0.0)


func _wants_step(foot: BodyFoot, other_foot: BodyFoot) -> bool:
	var threshold := STEP_THRESHOLD + absf(velocity.x) * STEP_THRESHOLD_PER_SPEED
	var distance := foot.world_center.distance_to(_plant_point(foot, 0.0))
	if distance > threshold * 2.0:
		return true
	return distance > threshold and not other_foot.is_stepping()


func _advance_step(foot: BodyFoot, delta: float) -> void:
	var duration := lerpf(SLOW_STEP_DURATION, FAST_STEP_DURATION, speed)
	foot.step_progress = minf(foot.step_progress + delta / duration, 1.0)
	var target := _plant_point(foot, velocity.x * STEP_LEAD_SECONDS)
	var eased := smoothstep(0.0, 1.0, foot.step_progress)
	var height := lerpf(SLOW_STEP_HEIGHT, FAST_STEP_HEIGHT, speed)
	var arc := Vector2.UP * sin(foot.step_progress * PI) * height
	foot.world_center = foot.step_from.lerp(target, eased) + arc
	if foot.step_progress >= 1.0:
		foot.world_center = target
		foot.ground_normal = foot.target_normal
		foot.is_planted = true
		foot.step_progress = -1.0


func _float_foot(foot: BodyFoot, delta: float) -> void:
	foot.is_planted = false
	foot.step_progress = -1.0
	var cycle := _air_cycle(foot)
	var pedal := Vector2(cos(cycle), sin(cycle)) * LEG_CIRCLE
	var dangle := (Vector2(foot.side * 6.4, -4.8 - 3.2 * rise) + pedal) * air
	var brace := Vector2(WALL_FOOT_REACH, -8.0 - foot.side * 4.8) * wall
	var target := body.transform * (foot.rest_center + dangle + brace) + _air_trail()
	foot.spring.velocity -= kick * FOOT_INERTIA
	foot.world_center = player.to_global(
		foot.spring.step(target, FOOT_STIFFNESS, FOOT_DAMPING, delta)
	)


func _foot_roll(foot: BodyFoot) -> float:
	if not is_grounded:
		return _wobble(foot) + cos(_air_cycle(foot)) * RUN_FOOT_PITCH * air
	var normal := foot.target_normal if foot.is_stepping() else foot.ground_normal
	var slope := atan2(normal.x, -normal.y) * facing
	if foot.is_stepping():
		slope += sin(foot.step_progress * TAU) * STEP_PITCH
	return slope


func _foot_home(foot: BodyFoot, lead: float) -> Vector2:
	var x := facing * (foot.rest_center.x + foot.side * STANCE_SPREAD) + lead
	return Vector2(x, rest_body_y + foot.rest_center.y)


func _plant_point(foot: BodyFoot, lead: float) -> Vector2:
	var center := player.to_global(_foot_home(foot, lead))
	var query := PhysicsRayQueryParameters2D.create(
		center + Vector2.UP * GROUND_PROBE_UP,
		center + Vector2.DOWN * (foot.sole_height + GROUND_PROBE_DOWN),
		PLATFORMS_MASK
	)
	var hit := body.get_world_2d().direct_space_state.intersect_ray(query)
	if not hit:
		foot.target_normal = Vector2.UP
		return center
	foot.target_normal = hit.normal
	return hit.position + Vector2.UP * foot.sole_height


func _update_torso_and_head(delta: float) -> void:
	var idle := (1.0 - gait) * (1.0 - air) * (1.0 - wall)
	var breath := sin(time * HOVER_SPEED) * BREATH_HEIGHT * idle
	var height := breath + RUN_CROUCH * gait + _ground_height() + _step_bob()

	var torso_offset := Vector2(3.2 * wall, height)
	_follow(torso, torso_offset, Vector2.ZERO, TORSO_STIFFNESS, TORSO_DAMPING, TORSO_INERTIA, delta)
	torso.spin(look * TORSO_LOOK, ROLL_STIFFNESS, ROLL_DAMPING, delta)

	var head_offset := Vector2(1.6 * gait - 4.8 * wall, height + breath - 3.2 * rise * air)
	_follow(head, head_offset, Vector2.ZERO, HEAD_STIFFNESS, HEAD_DAMPING, HEAD_INERTIA, delta)
	head.spin(look + _wobble(head), HEAD_ROLL_STIFFNESS, HEAD_ROLL_DAMPING, delta)


func _update_hand(
	hand: BodyPart, opposite_foot: BodyFoot, reach: float, phase: float, grips: bool, delta: float
) -> void:
	var hover := time * HOVER_SPEED + phase
	var windmill := air_phase + phase
	var swing := _foot_reach(opposite_foot) * ARM_SWING
	var bob := _ground_height() + _step_bob()
	var ground := (1.0 - air) * (1.0 - wall)
	var idle_weight := (1.0 - gait) * ground
	var run_weight := gait * ground

	var idle_spot := Vector2(reach, HAND_DROP + sin(hover) * HOVER_SIZE + bob)
	var idle_roll := IDLE_HAND_ROLL
	if grips:
		idle_spot = _grip_spot() - hand.rest_center
		idle_roll = atan2(aim_direction.y, aim_direction.x * facing)
	var run_spot := Vector2(swing, RUN_HAND_DROP - absf(swing) * ARM_LIFT + bob)
	var air_spot := (
		Vector2(-AIR_HAND_BACK, -AIR_HAND_LIFT)
		+ Vector2(cos(windmill), -sin(windmill)) * ARM_CIRCLE
	)
	var wall_spot := Vector2(WALL_HAND_REACH, -WALL_HAND_LIFT)

	var total := idle_weight + run_weight + air + wall
	var offset := (
		(idle_spot * idle_weight + run_spot * run_weight + air_spot * air + wall_spot * wall)
		/ total
	)
	var roll := (
		(
			idle_roll * idle_weight
			+ swing * ARM_ROLL * run_weight
			+ (AIR_HAND_ROLL - sin(windmill) * ARM_CIRCLE_ROLL) * air
			+ WALL_HAND_ROLL * wall
		)
		/ total
	)

	var trail := _air_trail() * 1.5
	_follow(hand, offset, trail, HAND_STIFFNESS, HAND_DAMPING, HAND_INERTIA, delta)
	hand.spin(roll + _wobble(hand), ROLL_STIFFNESS, ROLL_DAMPING, delta)


func _grip_spot() -> Vector2:
	return _to_body(aim_origin + aim_direction * GRIP_REACH + Vector2.DOWN * GRIP_DROP)


func _ground_height() -> float:
	if not is_grounded:
		return 0.0
	var lowest := -INF
	for foot: BodyFoot in [left_foot, right_foot]:
		var rest_y := player.to_global(_foot_home(foot, 0.0)).y
		lowest = maxf(lowest, foot.shown_center.y - rest_y)
	return clampf(lowest * BODY_FOLLOW, -MAX_BODY_DROP, MAX_BODY_DROP)


func _step_bob() -> float:
	var bob := 0.0
	for foot: BodyFoot in [left_foot, right_foot]:
		if foot.is_stepping():
			bob = maxf(bob, sin(foot.step_progress * PI) * STEP_BOB)
	var run_bob := (1.0 - absf(sin(run_phase))) * RUN_BOB
	return -lerpf(bob, run_bob, run_blend)


func _foot_reach(foot: BodyFoot) -> float:
	return (player.to_local(foot.shown_center).x - _foot_home(foot, 0.0).x) * facing


func _air_trail() -> Vector2:
	return (-velocity * AIR_TRAIL * air).limit_length(MAX_AIR_TRAIL)


func _wobble(part: BodyPart) -> float:
	var sway := (part.spring.velocity.x + part.spring.velocity.y) * facing * WOBBLE_PER_SPEED
	return clampf(sway, -MAX_WOBBLE, MAX_WOBBLE)


func _follow(
	part: BodyPart,
	offset: Vector2,
	drift: Vector2,
	stiffness: float,
	damping: float,
	inertia: float,
	delta: float
) -> void:
	part.spring.velocity -= kick * inertia
	var target := body.transform * (part.rest_center + offset) + drift
	part.place(_to_body(part.spring.step(target, stiffness, damping, delta)))


func _to_body(player_point: Vector2) -> Vector2:
	return body.transform.affine_inverse() * player_point


func _smooth(current: float, target: float, delta: float) -> float:
	return lerpf(current, target, 1.0 - exp(-WEIGHT_SHARPNESS * delta))
