
extends Node2D

const START_TILE = 2
const START_ENERGY = 200
const CELL_SCALE = 0.3125
const GAME_SPEED = 0.1

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
	if (event.type == InputEvent.MOUSE_BUTTON):
		var pos = get_tile_pos(event.pos)
		var cell = cells.get_cell(pos)
		
		if (cell and cell.is_player()):
			if (selection):
				selection.deselect()
			selection = cell
			selection.select()
		else:
			if (selection):
				if (pos.x >= (selection.pos.x - 1) and pos.x <= (selection.pos.x + 1) and pos.y >= (selection.pos.y - 1) and pos.y <= (selection.pos.y + 1)):
					selection.attack(pos)
				else:
					selection.deselect()
					selection = null
			
			
		

		
func get_tile_pos(pos):
	return tile_map.world_to_map(Vector2(pos.x / tile_map.get_scale().x, pos.y / tile_map.get_scale().y))


func init_board():
	for y in range(0, tile_map.get_cell_size().y):
		for x in range(0, tile_map.get_cell_size().x):
			var tile = tile_map.get_cell(x, y)
			
			if (tile == START_TILE):
				cells.add_cell(Vector2(x, y), FungusCell)
				cells.add_energy(Vector2(x, y), START_ENERGY)
		

