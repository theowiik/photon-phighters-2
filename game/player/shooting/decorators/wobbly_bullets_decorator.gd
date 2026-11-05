class_name WobblyBulletsDecorator
extends ShooterDecorator

var wobble_amount: float = 0.3


func shoot(context: ShootingContext) -> Array[Bullet]:
	var bullets = wrapped_shooter.shoot(context)

	for bullet in bullets:
		var timer = Timer.new()
		timer.wait_time = 0.2
		timer.one_shot = true
		timer.autostart = true
		timer.timeout.connect(_on_timer_timeout.bind(bullet))
		bullet.add_child(timer)
		timer.start()

	return bullets


func _on_timer_timeout(bullet: Bullet) -> void:
	print("timeout")
	bullet.velocity = Vector3.ZERO
