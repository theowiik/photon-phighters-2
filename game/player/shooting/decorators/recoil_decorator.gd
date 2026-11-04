class_name RecoilDecorator
extends ShooterDecorator

const KNOCKBACK: float = 7.0


func shoot(context: ShootingContext) -> Array[Bullet]:
	var bullets := wrapped_shooter.shoot(context)
	context.player.apply_impulse(-context.direction.normalized() * KNOCKBACK)
	return bullets
