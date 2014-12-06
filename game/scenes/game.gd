
extends Node2D

export(int) var resolution_x = 10
export(int) var resolution_y = 10

const START_TILE = 2
const START_ENERGY = 1000
const CELL_SCALE = 0.5
const GAME_SPEED = 0.05

var FungusCell = preload("res://scenes/fungus_cell.scn")

var tile_map = null
var cells = null

var time_to_next_tick = 0.0
var selection = null

func _ready():
	set_process_input(true)
	set_process(true)
	
	cells = get_node("Cells")
	tile_map = get_node("ValidTiles")
	tile_map.hide()
	init_board()

func _process(delta):
	time_to_next_tick += delta
	while (time_to_next_tick > GAME_SPEED):
		time_to_next_tick -= GAME_SPEED
		
		cells.tick()

	
func _input(event):
	if (event.type == InputEvent.MOUSE_BUTTON): # && event.pressed):
	
		if (event.pressed):
			var pos = get_tile_pos(event.pos)
			var cell = cells.get_cell(pos)
			
			if (cell and cell.is_player()):
				if (selection):
					selection.deselect()
					
					if (selection.pos == pos):
						selection = null
					else:
						selection = cell
				else:
					selection = cell
					
				if (selection):
					selection.select()
			else:
				if (selection):
					selection.deselect()
					selection = null
			
			
		

		
func get_tile_pos(pos):
	return tile_map.world_to_map(Vector2(pos.x / tile_map.get_scale().x, pos.y / tile_map.get_scale().y))


func init_board():
	for y in range(0, resolution_y):
		for x in range(0, resolution_x):
			var tile = tile_map.get_cell(x, y)
			
			if (tile == START_TILE):
				cells.add_cell(Vector2(x, y), FungusCell)
				cells.add_energy(Vector2(x, y), START_ENERGY)
		

