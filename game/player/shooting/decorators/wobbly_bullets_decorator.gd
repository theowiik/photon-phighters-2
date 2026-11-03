class_name WobblyBulletsDecorator
extends ShooterDecorator

var wobble_amount: float = 0.4


func shoot(context: ShootingContext) -> Array[Bullet]:
	var bullets = wrapped_shooter.shoot(context)

	for bullet in bullets:
		bullet.wobble_amount += wobble_amount

	return bullets
