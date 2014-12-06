
extends Node2D

const START_TILE = 2
const START_ENERGY = 1000
const CELL_SCALE = 0.5
const GAME_SPEED = 0.1

var FungusCell = preload("res://scenes/fungus_cell.scn")

var tile_map = null
var cells = null
var spread = null

var time_to_next_tick = 0.0

var selection = null
var pressed_pos = null


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
	if (event.type == InputEvent.MOUSE_BUTTON):
		if (event.pressed):
			var pos = get_tile_pos(event.pos)
			var cell = cells.get_cell(pos)
		
			if (cell and cell.is_player()):
				pressed_pos = pos
			else:
				pressed_pos = null
		elif (pressed_pos != null):
			var pos = get_tile_pos(event.pos)
			var cell = cells.get_cell(pos)
		
			if (not cell or not cell.is_player()):
				if ((pos.x == pressed_pos.x and abs(pos.y - pressed_pos.y) == 1) or (pos.y == pressed_pos.y and abs(pos.x - pressed_pos.x) == 1)):
					var selected = cells.get_cell(pressed_pos)
					selected.attack(pos)
					spread.hide()
		
			pressed_pos = null
	elif (event.type == InputEvent.MOUSE_MOTION):
		if (pressed_pos != null):
			spread.hide()

			var pos = get_tile_pos(event.pos)
			var cell = cells.get_cell(pos)
		
			if (not cell or not cell.is_player()):
				if ((pos.x == pressed_pos.x and abs(pos.y - pressed_pos.y) == 1) or (pos.y == pressed_pos.y and abs(pos.x - pressed_pos.x) == 1)):
					spread.show();
					spread.set_pos(get_world_pos(pressed_pos))
					spread.set_rot(spread.get_pos().angle_to_point(get_world_pos(pos)))
		else:
			spread.hide()
			
			if (selection):
				selection.deselect()
				selection = null
			
			var pos = get_tile_pos(event.pos)
			var cell = cells.get_cell(pos)
			
			if (cell and cell.is_player()):
				selection = cell
				selection.select()


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
			else:
				var rnd = randf()
				if (rnd<0.05):  #5% chance that the cell has 1000-2000 energy
					cells.add_energy(Vector2(x, y), round(1000 + randf() * 1000))
				elif (rnd<0.35):  #30% chance that the cell has 500-1000 energy
					cells.add_energy(Vector2(x, y), round(500 + randf() * 500))
				else:  #65% chance that the cell has 0-500 energy
					cells.add_energy(Vector2(x, y), round(randf() * 60))


func get_world_pos(pos):
	var world_pos = tile_map.map_to_world(Vector2(pos.x, pos.y))
	world_pos.x += 32
	world_pos.y += 32
	world_pos.x *= tile_map.get_scale().x
	world_pos.y *= tile_map.get_scale().y
	
	return world_pos
