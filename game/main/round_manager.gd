class_name RoundManager
extends Node

signal round_finished(winner: Player, loser: Player)
signal time_updated(time_remaining: float)
signal scores_updated(scores: Dictionary[Team, int])

var players: Array[Player] = []
var time_remaining: float = 0.0
var is_active: bool = false
var scores: Dictionary[Team, int] = {}


func _ready() -> void:
	_connect_bulb_signals()
	get_tree().node_added.connect(_on_node_added)


func _process(delta: float) -> void:
	if not is_active:
		return

	time_remaining = maxf(time_remaining - delta, 0.0)
	time_updated.emit(time_remaining)

	if time_remaining <= 0:
		is_active = false
		_finish_round()


func reset() -> void:
	is_active = false
	_clear_group(Constants.BULBS_GROUP)
	_clear_group(Constants.BULLETS_GROUP)
	time_remaining = Constants.ROUND_DURATION
	time_updated.emit(time_remaining)
	recalculate_scores()


func start() -> void:
	is_active = true


func get_score(team: Team) -> int:
	return scores.get(team, 0)


func _clear_group(group: String) -> void:
	for node in get_tree().get_nodes_in_group(group):
		node.remove_from_group(group)
		node.queue_free()


func _connect_bulb_signals() -> void:
	for bulb in get_tree().get_nodes_in_group(Constants.BULBS_GROUP):
		if not bulb.bulb_hit.is_connected(_on_bulb_hit):
			bulb.bulb_hit.connect(_on_bulb_hit)


func _on_node_added(node: Node) -> void:
	if node.is_in_group(Constants.BULBS_GROUP):
		if not node.bulb_hit.is_connected(_on_bulb_hit):
			node.bulb_hit.connect(_on_bulb_hit)


func _on_bulb_hit(_team: Team) -> void:
	recalculate_scores()


func recalculate_scores() -> void:
	scores.clear()

	for bulb in get_tree().get_nodes_in_group(Constants.BULBS_GROUP):
		scores[bulb.team] = scores.get(bulb.team, 0) + 1

	scores_updated.emit(scores)


func _finish_round() -> void:
	var ranked: Array[Player] = players.duplicate()
	ranked.sort_custom(
		func(a: Player, b: Player) -> bool: return get_score(a.team) > get_score(b.team)
	)

	if get_score(ranked[0].team) == get_score(ranked[1].team):
		round_finished.emit(null, null)
		return

	round_finished.emit(ranked[0], ranked[-1])
