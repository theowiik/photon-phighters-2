class_name Bulb
extends Area2D

signal bulb_hit(new_team: Team)

var team: Team = Team.white()
var _color_initialized := false

@onready var core: Capsule = $Core


func _ready() -> void:
	if _color_initialized:
		_apply_team(team)
		bulb_hit.emit(team)


func set_team(new_team: Team) -> void:
	team = new_team
	_color_initialized = true


func _apply_team(new_team: Team) -> void:
	team = new_team
	core.color = team.color


func claim(new_team: Team) -> void:
	if team == new_team:
		return

	_apply_team(new_team)
	bulb_hit.emit(new_team)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group(Constants.BULLETS_GROUP):
		claim(area.team)
		area.queue_free()
