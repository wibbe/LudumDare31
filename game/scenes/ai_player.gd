
extends Node2D



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
	var possible_location = []
	var cells = collect_cells()
	
	var new_state = {}
	
	for cell in cells:
		var pos = cell.pos
		var state = null
		
		if (cell_state.has(pos)):
			state = cell_state[pos]
		else:
			state = CellState.new(pos)
			
		state.evaluate()
		new_state[pos] = new_state
	
	cell_state = new_state


func calculate_enemy_field():
	enemy_field = {}
	var hotspots = []
	
	for idx in board.get_cells():
		var cell = board.get_cells()[idx]
		if (cell.is_player()):
			hotspots.pust_back(idx)
			
	calculate_potential_field(enemy_field, hotspots)


func calculate_potential_field(field, hotspots):
	for y in range(board.minIdx.y, board.maxIdx.y):
		for x in range(board.minIdx.x, board.maxIdx.x):
			var value = 0.0

func collect_cells():
	var cells = []
	
	for idx in board.get_cells():
		var cell = board.get_cells()[idx]
		if (not cell.is_player()):
			cells.push_back(cell)
	
	return cells

func calculate_next_tick_rate():
	return Constants.AI_TICK_RATE * randf() * Constants.AT_TICK_RATE_VARIATION


func cells_added():
	enemy_field_dirty = true