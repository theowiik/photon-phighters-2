class_name RoundManager
extends Node3D

signal round_finished(winner: Player, loser: Player)
signal time_updated(time_remaining: float)
signal scores_updated(scores: Dictionary)

var time_remaining: float = 0.0
var is_active: bool = false
var scores: Dictionary = {}


func _ready() -> void:
	_connect_bulb_signals()
	get_tree().node_added.connect(_on_node_added)


func _process(delta: float) -> void:
	if not is_active:
		return

	time_remaining -= delta
	time_updated.emit(time_remaining)

	if time_remaining <= 0:
		time_remaining = 0
		is_active = false
		_finish_round()


func start() -> void:
	time_remaining = Constants.ROUND_DURATION
	is_active = true
	recalculate_scores()


func _connect_bulb_signals() -> void:
	for bulb in get_tree().get_nodes_in_group(Constants.BULBS_GROUP):
		if not bulb.bulb_hit.is_connected(_on_bulb_hit):
			bulb.bulb_hit.connect(_on_bulb_hit)


func _on_node_added(node: Node) -> void:
	if node.is_in_group(Constants.BULBS_GROUP):
		if not node.bulb_hit.is_connected(_on_bulb_hit):
			node.bulb_hit.connect(_on_bulb_hit)
		recalculate_scores()


func _on_bulb_hit(_team: Team) -> void:
	recalculate_scores()


func recalculate_scores() -> void:
	scores.clear()

	for bulb in get_tree().get_nodes_in_group(Constants.BULBS_GROUP):
		var team_hex: String = bulb.get_team().get_hex()
		scores[team_hex] = scores.get(team_hex, 0) + 1

	scores_updated.emit(scores)


func _finish_round() -> void:
	var players = get_tree().get_nodes_in_group(Constants.PLAYERS_GROUP)
	if players.size() < 2:
		return

	var player_scores: Array = []
	for player in players:
		var player_score: int = scores.get(player.team.get_hex(), 0)
		player_scores.append({"player": player, "score": player_score})

	player_scores.sort_custom(func(a, b): return a.score > b.score)

	var winner: Player = player_scores[0].player
	var loser: Player = player_scores[1].player

	# If tied, pick random winner/loser
	if player_scores[0].score == player_scores[1].score:
		players.shuffle()
		winner = players[0]
		loser = players[1]

	round_finished.emit(winner, loser)
