class_name Team
extends RefCounted

var name: String
var color: Color


func _init(team_name: String, team_color: Color) -> void:
	name = team_name
	color = team_color


func get_hex() -> String:
	return color.to_html(false)


static func red() -> Team:
	return Team.new("Red", Color(1.0, 0.3, 0.2))


static func blue() -> Team:
	return Team.new("Blue", Color(0.2, 0.4, 1.0))


static func green() -> Team:
	return Team.new("Green", Color(0.2, 1.0, 0.4))


static func orange() -> Team:
	return Team.new("Orange", Color(1.0, 0.5, 0.1))


static func purple() -> Team:
	return Team.new("Purple", Color(0.7, 0.2, 1.0))


static func cyan() -> Team:
	return Team.new("Cyan", Color(0.2, 0.9, 1.0))


static func yellow() -> Team:
	return Team.new("Yellow", Color(1.0, 0.9, 0.2))


static func pink() -> Team:
	return Team.new("Pink", Color(1.0, 0.4, 0.7))


static func white() -> Team:
	return Team.new("White", Color.WHITE)
