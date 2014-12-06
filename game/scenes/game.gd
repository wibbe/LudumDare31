
extends Node2D

const START_TILE = 2
const SCALE = 0.3125

var Cell = preload("res://scenes/fungus_cell.scn")

var tile_map = null
var cells = null
var board = {}

func _ready():
	set_process_input(true)
	
	cells = get_node("Cells")
	tile_map = get_node("ValidTiles")
	tile_map.hide()
	init_board()

	
func _input(event):
	if (event.type == InputEvent.MOUSE_BUTTON):
		print("Click at: ", event.pos)
		
		var pos = get_tile_pos(event.pos)
		
		print("Map: ", pos)
		
		#var tile = get_cell(pos)
		#print("Cell: ", tile)
		
func get_tile_pos(pos):
	return tile_map.world_to_map(Vector2(pos.x / tile_map.get_scale().x, pos.y / tile_map.get_scale().y))

func get_cell_pos(pos):
	var world_pos = tile_map.map_to_world(Vector2(pos.x, pos.y))
	world_pos.x *= tile_map.get_scale().x
	world_pos.y *= tile_map.get_scale().y
	
	return world_pos

func is_valid(pos):
	return tile_map.get_cell(pos.x, pos.y)

func init_board():
	for y in range(0, tile_map.get_cell_size().y):
		for x in range(0, tile_map.get_cell_size().x):
			var tile = tile_map.get_cell(x, y)
			
			if (tile == START_TILE):
				print("Creating start at: ", x, y)
				var pos = get_cell_pos(Vector2(x, y))
				var cell = Cell.instance()
				cell.set_pos(pos)
				
				cells.add_child(cell)
		

