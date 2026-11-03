class_name RecoilDecorator
extends ShooterDecorator

var knockback_strength: float = 3.0


func shoot(context: ShootingContext) -> Array[Bullet]:
	var bullets = wrapped_shooter.shoot(context)

	if context.player:
		var knockback_direction = -context.direction
		context.player.apply_impulse(knockback_direction.normalized() * knockback_strength)

	return bullets
