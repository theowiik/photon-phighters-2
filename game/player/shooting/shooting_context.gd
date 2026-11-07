class_name ShootingContext
extends RefCounted

## Spread angle in degrees
var spread: float = 15.0
var from_position: Vector2
var direction: Vector2
var team: Team
var parent: Node
var player: Player
var speed_multiplier: float = 1.0
var extra_shots: int = 0


func _init(
	shot_from: Vector2,
	shot_direction: Vector2,
	shooter_team: Team,
	bullet_parent: Node,
	shooter: Player
) -> void:
	from_position = shot_from
	direction = shot_direction
	team = shooter_team
	parent = bullet_parent
	player = shooter
