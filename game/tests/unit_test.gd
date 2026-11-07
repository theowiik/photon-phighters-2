class_name UnitTest
extends Node

const STEP: float = 1.0 / 60.0

var failed: bool = false


func _ready() -> void:
	_test_running()
	_test_ground_jump()
	_test_coyote_time()
	_test_jump_buffer()
	_test_wall_jump()
	_test_double_jump()
	_test_phast()
	_test_shooting()
	_test_crystal_registry()
	if not failed:
		print("PASS: running, jumps, wall jump, movement and shooting crystals, registry")
	get_tree().quit(1 if failed else 0)


func _test_running() -> void:
	var mover := BaseMover.new()
	var velocity := _run(mover, 30, 1.0, true)
	_expect(is_equal_approx(velocity.x, BaseMover.SPEED))
	velocity = _run(mover, 30, 0.0, true, velocity)
	_expect(velocity.x == 0.0)


func _test_ground_jump() -> void:
	var mover := BaseMover.new()
	_expect(_jump(mover, true).y == BaseMover.JUMP_VELOCITY)
	_run(mover, 10, 0.0, false)
	_expect(_jump(mover, false).y > BaseMover.JUMP_VELOCITY)


func _test_coyote_time() -> void:
	var mover := BaseMover.new()
	_run(mover, 1, 0.0, true)
	_run(mover, 3, 0.0, false)
	_expect(_jump(mover, false).y == BaseMover.JUMP_VELOCITY)

	mover = BaseMover.new()
	_run(mover, 1, 0.0, true)
	_run(mover, 10, 0.0, false)
	_expect(_jump(mover, false).y > BaseMover.JUMP_VELOCITY)


func _test_jump_buffer() -> void:
	var mover := BaseMover.new()
	_run(mover, 10, 0.0, false)
	_jump(mover, false)
	_expect(_run(mover, 1, 0.0, true).y == BaseMover.JUMP_VELOCITY)


func _test_wall_jump() -> void:
	var mover := BaseMover.new()
	_run(mover, 10, 0.0, false)
	var context := _context(Vector2.ZERO, false)
	context.is_on_wall = true
	context.wall_normal = Vector2.RIGHT
	context.jump_pressed = true
	var velocity := mover.process_movement(Vector2.ZERO, STEP, context)
	_expect(velocity.y == BaseMover.WALL_JUMP_VELOCITY)
	_expect(velocity.x == BaseMover.WALL_JUMP_PUSH)


func _test_double_jump() -> void:
	var mover := DoubleJumpDecorator.new(BaseMover.new())
	_jump(mover, true)
	_run(mover, 10, 0.0, false)
	_expect(_jump(mover, false).y == BaseMover.JUMP_VELOCITY)
	_run(mover, 10, 0.0, false)
	_expect(_jump(mover, false).y > BaseMover.JUMP_VELOCITY)

	mover = DoubleJumpDecorator.new(BaseMover.new())
	_run(mover, 1, 0.0, true)
	_run(mover, 10, 0.0, false)
	_expect(_jump(mover, false).y == BaseMover.JUMP_VELOCITY)


func _test_phast() -> void:
	var mover := PhastDecorator.new(BaseMover.new())
	var velocity := _run(mover, 60, 1.0, true)
	_expect(is_equal_approx(velocity.x, BaseMover.SPEED * PhastDecorator.SPEED_MULTIPLIER))


func _test_shooting() -> void:
	var base := BaseShooter.new()
	var bullets := _shoot(base)
	_expect(bullets.size() == 1)
	_expect(is_equal_approx(bullets[0].velocity.length(), BaseShooter.BULLET_SPEED))
	_expect(_shoot(TripleShotDecorator.new(base)).size() == 3)

	var fast_speed := _shoot(FastBulletsDecorator.new(base))[0].velocity.length()
	var expected_speed := BaseShooter.BULLET_SPEED * FastBulletsDecorator.SPEED_MULTIPLIER
	_expect(is_equal_approx(fast_speed, expected_speed))

	var wobbly := _shoot(WobblyBulletsDecorator.new(base))[0]
	_expect(wobbly.wobble_amount == WobblyBulletsDecorator.WOBBLE_AMOUNT)

	var expected_delay := BaseShooter.SHOOT_DELAY * RapidFireDecorator.DELAY_MULTIPLIER
	_expect(is_equal_approx(RapidFireDecorator.new(base).get_shoot_delay(), expected_delay))


func _test_crystal_registry() -> void:
	for crystal in CrystalRegistry.get_all_crystals():
		_expect(not CrystalRegistry.get_description(crystal).is_empty())
		_expect(not CrystalRegistry.get_effects(crystal).is_empty())
	for crystal: String in CrystalRegistry.movement_crystals:
		var mover := CrystalRegistry.create_movement_decorator(crystal, BaseMover.new())
		_expect(mover is MoverDecorator)
	for crystal: String in CrystalRegistry.shooting_crystals:
		var shooter := CrystalRegistry.create_shooting_decorator(crystal, BaseShooter.new())
		_expect(shooter is ShooterDecorator)


func _run(
	mover: MoverInterface, frames: int, input_x: float, on_floor: bool, start := Vector2.ZERO
) -> Vector2:
	var velocity := start
	for _frame in frames:
		velocity = mover.process_movement(Vector2(input_x, 0.0), STEP, _context(velocity, on_floor))
	return velocity


func _jump(mover: MoverInterface, on_floor: bool) -> Vector2:
	var context := _context(Vector2.ZERO, on_floor)
	context.jump_pressed = true
	return mover.process_movement(Vector2.ZERO, STEP, context)


func _context(velocity: Vector2, on_floor: bool) -> MovementContext:
	var context := MovementContext.new()
	context.velocity = velocity
	context.is_on_floor = on_floor
	return context


func _shoot(shooter: ShooterInterface) -> Array[Bullet]:
	var context := ShootingContext.new(Vector2.ZERO, Vector2.RIGHT, Team.red(), self, null)
	var bullets := shooter.shoot(context)
	for bullet in bullets:
		bullet.queue_free()
	return bullets


func _expect(condition: bool) -> void:
	if not condition:
		failed = true
		push_error("Unit check failed: %s" % get_stack()[1])
