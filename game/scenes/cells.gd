
extends Node2D

const CELL_SCALE = 0.5

var cell_board = {}
var energy_board = {}

var tile_map = null

func _ready():
	tile_map = get_node("../ValidTiles")
	
	
func tick():
	for idx in cell_board:
		var cell = cell_board[idx]
		cell.tick()


func draw_energy(pos):
	if energy_board.has(pos) and energy_board[pos] > 0:
		energy_board[pos] = energy_board[pos] - 1
		return 1
	else:
		return 0

func is_empty(pos):
	return is_valid(pos) and not cell_board.has(pos)


func is_valid(pos):
	return tile_map.get_cell(pos.x, pos.y) != -1


func get_cell(pos):
	if (cell_board.has(pos)):
		return cell_board[pos]
	else:
		return null


func add_cell(pos, type):
	if (not is_empty(pos)):
		return false
	
	var cell = type.instance()

	add_child(cell)	
	cell_board[pos] = cell
	
	cell.set_pos(get_world_pos(pos))
	cell.initialize(pos, self)
	
	print("Fugus Cell @ ", cell.get_pos())
		
	return true
	

func add_energy(pos, energy):
	if (not is_valid(pos)):
		return
		
	energy_board[pos] = energy
	
	
func get_world_pos(pos):
	var world_pos = tile_map.map_to_world(Vector2(pos.x, pos.y))
	#world_pos += tile_map.get_pos()
	#orld_pos.x += 32
	#world_pos.y += 32
	world_pos.x *= tile_map.get_scale().x
	world_pos.y *= tile_map.get_scale().y
	
	return world_pos