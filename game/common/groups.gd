extends Node


func get_all_players() -> Array[Player]:
	var result: Array[Player] = []
	_collect_group(Constants.PLAYERS_GROUP, Player, result)
	return result


func get_all_bullets() -> Array[Node3D]:
	var result: Array[Node3D] = []
	_collect_group(Constants.BULLETS_GROUP, Node3D, result)
	return result


func get_all_bulbs() -> Array[Area3D]:
	var result: Array[Area3D] = []
	_collect_group(Constants.BULBS_GROUP, Area3D, result)
	return result


func _collect_group(group: String, expected_type: Variant, out: Array) -> void:
	for node in get_tree().get_nodes_in_group(group):
		if is_instance_of(node, expected_type):
			out.append(node)
		else:
			push_warning("Node '%s' in group '%s' is not of expected type" % [node.name, group])
