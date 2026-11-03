extends Area3D

signal bulb_hit(new_team: Team)

var team: Team = Team.white()
var _color_initialized := false
var _material: StandardMaterial3D

@onready var light: OmniLight3D = $OmniLight3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	_material.emission_energy_multiplier = 2.0
	mesh_instance.material_override = _material

	if _color_initialized:
		_apply_team(team)
		bulb_hit.emit(team)


func set_team(new_team: Team) -> void:
	team = new_team
	_color_initialized = true


func get_team() -> Team:
	return team


func _apply_team(new_team: Team) -> void:
	team = new_team
	light.light_color = team.color

	if _material:
		_material.albedo_color = team.color
		_material.emission = team.color


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group(Constants.BULLETS_GROUP):
		var new_team: Team = area.team

		if team.color != new_team.color:
			_apply_team(new_team)
			bulb_hit.emit(new_team)

		area.queue_free()
