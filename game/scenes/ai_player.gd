
extends Node2D

const ENEMY_FIELD_MAX_DISTANCE = 4
const OFFSETS = [Vector2(-1, 0), Vector2(0, -1), Vector2(1, 0), Vector2(0, 1)]

var board = null
var time_to_tick = 0.0

var all_cells = []
var next_to_process = 0

var positions = {}
var hotspots = []

var enemies = {}

var debug_info_for = null


var Constants = preload("res://scenes/constants.gd")
var ubuntu_mono = preload("res://fonts/ubuntu_mono.fnt")



func _ready():
	set_process(true)
	board = get_parent().get_node("Cells")
	
	time_to_tick = calculate_next_tick_rate()

func _process(delta):
	time_to_tick -= delta
	if (time_to_tick < 0):
		collect_information()
		update()
		time_to_tick = calculate_next_tick_rate()
	
	if (all_cells.size() > 0):
		if (next_to_process >= all_cells.size()):
			next_to_process = 0
		process_cell(all_cells[next_to_process])
		next_to_process += 1


func _draw():
	for hotspot in hotspots:
		var pos = board.get_world_pos(hotspot["pos"])
		var color = Color(1, 0, 0)
		if (hotspot["value"] > 0):
			color = Color(0, 1, 0)
		
		draw_rect(Rect2(pos.x - 15, pos.y - 15, 4, 4), color)
		
	for idx in board.get_cell_board():
		var cell = board.get_cell_board()[idx]
		if (not cell.is_player() and cell.is_attacked()):
			var pos = cell.get_pos()
			draw_rect(Rect2(pos.x - 15, pos.y + 11, 4, 4), Color(0, 0, 1))
			
	if (debug_info_for != null):
		var cell = board.get_cell(debug_info_for)
		
		if (cell):
			for offset in OFFSETS:
				var pos = debug_info_for + offset
				var world_pos = board.get_world_pos(pos)
				var string = str(int(calculate_potential_field_value(cell, pos)))
				var size = ubuntu_mono.get_string_size(string)
				draw_string(ubuntu_mono, Vector2(world_pos.x - (size.x * 0.5), world_pos.y), string)




func process_cell(cell):
	var selected_pos = null
	var selected_score = 0
	
	for offset in OFFSETS:
		var pos = cell.pos + offset
		if (board.is_valid(pos)):
			var score = calculate_potential_field_value(cell, pos)
			if (score > selected_score):
				selected_score = score
				selected_pos = pos
			
	if (selected_pos != null):
		if (cell.current_energy > Constants.COLONIZE_ENERGY_COST * 3):
			cell.attack(selected_pos)
		else:
			cell.attack(null)
	else:
		cell.attack(null)


func manhattan_dist(p1, p2):
	return abs(p1.x - p2.x) + abs(p1.y - p2.y)
	

func calculate_potential_field_value(source, position):
	var value = 0
		
	for hotspot in hotspots:
		var dist = manhattan_dist(position, hotspot["pos"])
		value += max(0, abs(hotspot["value"]) - (dist * hotspot["decay"])) * sign(hotspot["value"])
	
	var cell = board.get_cell(position)
	if (cell):
		if (not cell.is_player()):
			if (not cell.is_attacked()):
				if (cell.current_energy < 20 and source.current_energy > 60):
					value += Constants.OWN_CELL_SCORE
				elif (cell.current_energy > 60):
					value -= Constants.OWN_CELL_SCORE
		else:
			pass
	
	return value


func collect_information():
	hotspots.clear()
	
	# Process all the food sources in the board
	for idx in board.get_energy_board():
		var amount = board.get_energy_board()[idx]
		if (amount > 100):
			#var value = (amount / 2000.0) * Constants.HOTSPOT_FOOD_VALUE
			hotspots.append({"value": Constants.HOTSPOT_FOOD_VALUE, "decay": Constants.HOTSPOT_FOOD_DECAY, "pos": idx})

	# Process all the cells in the board
	for idx in board.get_cell_board():
		var cell = board.get_cell(idx)
		if (cell.is_player()):
			hotspots.append({"value": Constants.HOTSPOT_ENEMY_CELL_VALUE, "decay": Constants.HOTSPOT_ENEMY_CELL_DECAY, "pos": idx})
		else:
			# This cell is beeing attacked add a strong hotspot here
			if (cell.is_attacked()):
				hotspots.append({"value": Constants.HOTSPOT_ATTACKED_CELL_VALUE, "decay": Constants.HOTSPOT_ATTACKED_CELL_DECAY, "pos": idx})




func calculate_next_tick_rate():
	return Constants.AI_TICK_RATE * randf() * Constants.AT_TICK_RATE_VARIATION


func cell_added(cell):
	all_cells.append(cell)

	
func cell_removed(cell):
	all_cells.erase(cell)
