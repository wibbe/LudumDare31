
extends Node2D

const ENEMY_FIELD_MAX_DISTANCE = 4
const OFFSETS = [Vector2(-1, 0), Vector2(0, -1), Vector2(1, 0), Vector2(0, 1)]

var board = null
var time_to_tick = 0.0
var cell_state = {}

var enemy_field_dirty = true
var enemy_field = {}


var Constants = preload("res://scenes/constants.gd")



func _ready():
	set_process(true)
	board = get_parent().get_node("Cells")
	
	time_to_tick = calculate_next_tick_rate()

func _process(delta):
	time_to_tick -= delta
	if (time_to_tick < 0):
		tick()
		time_to_tick = calculate_next_tick_rate()


func tick():
	var field = {}
	var potential_positions = {}
	var hotspots = []
	
	collect_information(potential_positions, hotspots)
	
	print("Hotspots: ", hotspots.size())


func collect_information(positions, hotspots):
	for idx in board.get_cell_board():
		var cell = board.get_cell_board()[idx]
		if (cell.is_player()):
			hotspots.append({"value": -6, "decay": 2, "pos": idx})
		else:
			# This cell is beeing attacked add a strong hotspot here
			if (cell.is_attacked()):
				hotspots.append({"value": 20, "decay": -2, "pos": idx})
			
			# Add the positions around the ai cell as potential positions to evaluate
			for offset in OFFSETS:
				var pos = idx + offset
				if (board.is_valid(pos)):
					positions[pos] = 0.0


func manhattan_dist(p1, p2):
	return abs(p1.x - p2.x) + abs(p1.y - p2.y)
	

func calculate_potential_field(positions, hotspots):
	for position in positions:
		var value = 0
		
		for hotspot in hotspots:
			value += max(0, hotspot["value"] - (manhattan_dist(position, hotspot["pos"]) * hotspot["decay"]))
		
		positions[position] = value



func calculate_next_tick_rate():
	return Constants.AI_TICK_RATE * randf() * Constants.AT_TICK_RATE_VARIATION


func cell_added():
	enemy_field_dirty = true
