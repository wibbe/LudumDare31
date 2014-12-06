
extends Node2D

const START_TILE = 2
const START_ENERGY = 1000
const CELL_SCALE = 0.5
const GAME_SPEED = 0.2

var FungusCell = preload("res://scenes/fungus_cell.scn")

var tile_map = null
var cells = null
var spread = null

var time_to_next_tick = 0.0
var selection = null

func _ready():
	set_process_input(true)
	set_process(true)
	
	cells = get_node("Cells")
	tile_map = get_node("ValidTiles")
	spread = get_node("Cells/Spread")
	
	tile_map.hide()
	init_board()

func _process(delta):
	time_to_next_tick += delta
	while (time_to_next_tick > GAME_SPEED):
		time_to_next_tick -= GAME_SPEED
		
		cells.tick()

	
func _input(event):
	if (event.type == InputEvent.MOUSE_BUTTON && event.pressed):
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
				if ((pos.x == selection.pos.x and abs(pos.y - selection.pos.y) == 1) or (pos.y == selection.pos.y and abs(pos.x - selection.pos.x) == 1)):
					selection.attack(pos)
					spread.hide()
				else:
					selection.deselect()
					selection = null
	elif (event.type == InputEvent.MOUSE_MOTION):
		spread.hide()
		
		if (selection):
			var pos = get_tile_pos(event.pos)
			var cell = cells.get_cell(pos)
			
			if (not cell or not cell.is_player()):
				if (pos.x == selection.pos.x or pos.y == selection.pos.y):
					spread.show();
					spread.set_pos(get_world_pos(selection.pos))
					spread.set_rot(spread.get_pos().angle_to_point(get_world_pos(pos)))


func get_tile_pos(pos):
	pos -= tile_map.get_pos()
	return tile_map.world_to_map(Vector2(pos.x / tile_map.get_scale().x, pos.y / tile_map.get_scale().y))


func init_board():
	for y in range(0, tile_map.get_cell_size().y):
		for x in range(0, tile_map.get_cell_size().x):
			var tile = tile_map.get_cell(x, y)
			
			if (tile == START_TILE):
				cells.add_cell(Vector2(x, y), FungusCell, null)
				cells.add_energy(Vector2(x, y), START_ENERGY)


func get_world_pos(pos):
	var world_pos = tile_map.map_to_world(Vector2(pos.x, pos.y))
	world_pos.x += 32
	world_pos.y += 32
	world_pos.x *= tile_map.get_scale().x
	world_pos.y *= tile_map.get_scale().y
	
	return world_pos
