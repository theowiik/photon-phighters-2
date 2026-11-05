class_name ShootingContext
extends RefCounted

## Spread angle in degrees
var spread: float = 15.0
var from_position: Vector3
var direction: Vector3
var team: Team
var parent: Node
var player: CharacterBody3D
var bullet_speed: float = 0.0
var bullet_scene: PackedScene = null
var speed_multiplier: float = 1.0
var delay_multiplier: float = 1.0
var extra_shots: int = 0


func _init(pos: Vector3, dir: Vector3, t: Team, p: Node, player_ref: CharacterBody3D = null):
	from_position = pos
	direction = dir
	team = t
	parent = p
	player = player_ref
