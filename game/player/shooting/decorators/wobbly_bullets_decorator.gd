class_name WobblyBulletsDecorator
extends ShooterDecorator

const WOBBLE_AMOUNT: float = 0.4


func shoot(context: ShootingContext) -> Array[Bullet]:
	var bullets := wrapped_shooter.shoot(context)
	for bullet in bullets:
		bullet.wobble_amount += WOBBLE_AMOUNT
	return bullets
