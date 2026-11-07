class_name Bulb
extends Area2D

signal bulb_hit(new_team: Team)

const POP_SECONDS: float = 0.25
const CLAIM_SCALE: float = 1.8
const GLOW: float = 3.5
const LIGHT_ENERGY: float = 0.35
const CLAIM_LIGHT_ENERGY: float = 1.0

var team: Team = Team.white()
var _color_initialized := false

@onready var light: Sprite2D = $Light
@onready var core: Capsule = $Core


func _ready() -> void:
	core.scale = Vector2.ZERO
	_pop()

	if _color_initialized:
		_apply_team(team)
		bulb_hit.emit(team)


func set_team(new_team: Team) -> void:
	team = new_team
	_color_initialized = true


func _apply_team(new_team: Team) -> void:
	team = new_team
	light.modulate = Color(team.color, light.modulate.a)
	core.color = team.color * Color(GLOW, GLOW, GLOW)


func claim(new_team: Team) -> void:
	if team == new_team:
		return

	_apply_team(new_team)
	bulb_hit.emit(new_team)
	core.scale = Vector2.ONE * CLAIM_SCALE
	light.modulate.a = CLAIM_LIGHT_ENERGY
	_pop()


func _pop() -> void:
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(core, "scale", Vector2.ONE, POP_SECONDS)
	tween.tween_property(light, "modulate:a", LIGHT_ENERGY, POP_SECONDS)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group(Constants.BULLETS_GROUP):
		claim(area.team)
		area.queue_free()
