
extends Node2D


var FungusCell = preload("res://scenes/fungus_cell.scn")
var Constants = preload("res://scenes/constants.gd")

var tile_map = null
var cells = null
var spread = null

var is_playing = false

var time_to_next_tick = 0.0

var selection = null
var pressed_pos = null
var musicCooldown = 0.0

func _ready():
	set_process_input(true)
	set_process(true)
	
	cells = get_node("Cells")
	tile_map = get_node("ValidTiles")
	spread = get_node("Cells/Spread")
	
	tile_map.hide()
	spread.hide()
	
	get_node("SplashScreen").show()


func _process(delta):
	if is_playing:
		time_to_next_tick += delta
		while (time_to_next_tick > Constants.GAME_SPEED):
			time_to_next_tick -= Constants.GAME_SPEED
			cells.tick()
		if musicCooldown>0.0:
			musicCooldown -= delta
			if musicCooldown<=0.0:
				print(get_node("SamplePlayer2D").get_sample_library().get_sample("musicloop"))
				get_node("SamplePlayer2D").play("musicloop", 5)

	
func _input(event):
	if is_playing:

		if (event.type == InputEvent.MOUSE_BUTTON):
			if (event.pressed and event.button_index == 1):
				var pos = get_tile_pos(event.pos)
				var cell = cells.get_cell(pos)
			
				if (cell and cell.is_player()):
					pressed_pos = pos
				else:
					pressed_pos = null
			elif (pressed_pos != null and event.button_index == 1):
				# Left-dragging will extend the arm towards the cell
				var pos = get_tile_pos(event.pos)
				var cell = cells.get_cell(pos)
			
				if ((pos.x == pressed_pos.x) or (pos.y == pressed_pos.y)):
					var selected = cells.get_cell(pressed_pos)
					
					if (pressed_pos != pos):
						pressed_pos.x += sign(pos.x - pressed_pos.x) * 1
						pressed_pos.y += sign(pos.y - pressed_pos.y) * 1
					
					selected.attack(pressed_pos)
					spread.hide()
					
				pressed_pos = null
				
			elif (event.pressed and event.button_index == 2):
				# Right-clicking on a cell will retrackt the arm
				var pos = get_tile_pos(event.pos)
				var cell = cells.get_cell(pos)
			
				if (cell and cell.is_player()):
					cell.attack(pos)
			elif (event.pressed and event.button_index == 3):
				var pos = get_tile_pos(event.pos)
				var cell = cells.get_cell(pos)
			
				if (cell and not cell.is_player()):
					get_node("AIPlayer").debug_info_for = pos
				else:
					get_node("AIPlayer").debug_info_for = null
			
				pressed_pos = null
		elif (event.type == InputEvent.MOUSE_MOTION):
			if (pressed_pos != null):
				spread.hide()
	
				var pos = get_tile_pos(event.pos)
				var cell = cells.get_cell(pos)
			
				if (((pos.x == pressed_pos.x) or (pos.y == pressed_pos.y)) and pos != pressed_pos):
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
	else:
		# Not playing input goes here
		pass


func start_game():
	get_node("SamplePlayer2D").play("start", 0)
	musicCooldown = 0.75
	is_playing = true
	init_board()
	get_node("SplashScreen").hide()
	

func get_tile_pos(pos):
	pos -= tile_map.get_pos()
	return tile_map.world_to_map(Vector2(pos.x / tile_map.get_scale().x, pos.y / tile_map.get_scale().y))


func init_board():
	for y in range(0, tile_map.get_cell_size().y):
		for x in range(0, tile_map.get_cell_size().x):
			var tile = tile_map.get_cell(x, y)
			
			if (tile == Constants.PLAYER_START_TILE):
				cells.add_cell(Vector2(x, y), FungusCell, Constants.HUMAN_PLAYER)
				cells.add_energy(Vector2(x, y), Constants.START_ENERGY)
				cells.update_min_max(x, y)
			elif (tile == Constants.AI_START_TILE):
				cells.add_cell(Vector2(x, y), FungusCell, Constants.AI_PLAYER)
				cells.add_energy(Vector2(x, y), Constants.START_ENERGY)
				cells.update_min_max(x, y)
			elif (tile == Constants.PLAY_FIELD_TILE):
				var rnd = randf()
				if (rnd < 0.05):  #5% chance that the cell has 1000-2000 energy
					cells.add_energy(Vector2(x, y), round(1000 + randf() * 1000))
				elif (rnd < 0.35):  #30% chance that the cell has 500-1000 energy
					cells.add_energy(Vector2(x, y), round(500 + randf() * 500))
				else:  #65% chance that the cell has 0-500 energy
					cells.add_energy(Vector2(x, y), round(randf() * 60))
				cells.update_min_max(x, y)
				
	print("Game world: (", cells.minIdx.x, ",", cells.minIdx.y, ") -> (", cells.maxIdx.x, ", ", cells.maxIdx.y, ")")


func get_world_pos(pos):
	var world_pos = tile_map.map_to_world(Vector2(pos.x, pos.y))
	world_pos.x += 32
	world_pos.y += 32
	world_pos.x *= tile_map.get_scale().x
	world_pos.y *= tile_map.get_scale().y
	
	return world_pos


func onStartButtonMouseEnter():
	get_node("SamplePlayer2D").play("over")

func onStartButtonMouseExit():
	get_node("SamplePlayer2D").play("out")
