
extends Node2D

const CELL_SCALE = 0.5

var cell_board = {}
var energy_board = {}
var background_board = {}
var food_board = {}
var cells_to_clear = []

var minIdx
var maxIdx

var tile_map = null

var food1 = preload("res://scenes/food1.scn")
var food2 = preload("res://scenes/food2.scn")
var food3 = preload("res://scenes/food3.scn")

func _ready():
	tile_map = get_node("../ValidTiles")
	minIdx = Vector2(100, 100)
	maxIdx = Vector2(-100, -100)


func tick():
	for idx in cell_board:
		var cell = cell_board[idx]
		cell.tick()
		
	for cell in cells_to_clear:
		remove_child(cell)
		cell_board.erase(cell.pos)
		cell.queue_free()
		
	cells_to_clear.clear()


func draw_energy(pos):
	if energy_board.has(pos) and energy_board[pos] > 0:
		energy_board[pos] = energy_board[pos] - 1
		reflectEnergy(pos);
		return 1
	else:
		return 0
	


func is_empty(pos):
	return is_valid(pos) and not cell_board.has(pos)


func is_valid(pos):
	return tile_map.get_cell(pos.x, pos.y) != -1


func has_background(pos):
	return background_board.has(pos)


func get_cell(pos):
	if (cell_board.has(pos)):
		return cell_board[pos]
	else:
		return null


func get_cell_board():
	return cell_board


func get_food_board():
	return food_board

func add_cell(pos, type, owner):
	if (not is_empty(pos)):
		return false
	
	var cell = type.instance()

	add_child(cell)	
	cell_board[pos] = cell
	
	cell.set_pos(get_world_pos(pos))
	cell.initialize(pos, owner, self)
	
	get_parent().get_node("AIPlayer").cell_added()
	return true


func clear_cell(cell):
	cells_to_clear.push_back(cell)


func add_energy(pos, energy):
	if (not is_valid(pos)):
		return
		
	energy_board[pos] = energy
	reflectEnergy(pos)


func add_background(pos, background):
	background_board[pos] = background
	background.set_pos(get_world_pos(pos))
	
	get_parent().get_node("Webb").add_child(background)


func get_world_pos(pos):
	var world_pos = tile_map.map_to_world(Vector2(pos.x, pos.y))
	#world_pos += tile_map.get_pos()
	world_pos.x += 32
	world_pos.y += 32
	world_pos.x *= tile_map.get_scale().x
	world_pos.y *= tile_map.get_scale().y
	
	return world_pos


func update_min_max(x, y):
	minIdx.x = min(x, minIdx.x)
	minIdx.y = min(y, minIdx.y)
	maxIdx.x = max(x, maxIdx.x)
	maxIdx.y = max(y, maxIdx.y)


func reflectEnergy(pos):
	var foodSceneObj = null
	if energy_board[pos]>1500:
		foodSceneObj = food3.instance()
	elif energy_board[pos]>1000:
		foodSceneObj = food2.instance()
	elif energy_board[pos]>500:
		foodSceneObj = food1.instance()
	if foodSceneObj!=null:
		foodSceneObj.set_pos(get_world_pos(pos))
		get_parent().get_node("Food").add_child(foodSceneObj)
	if food_board.has(pos) and food_board[pos]!=null:
		get_parent().get_node("Food").remove_child(food_board[pos])
	food_board[pos] = foodSceneObj
	
	
