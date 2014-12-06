
extends Node2D

export(NodePath) var tile_map_path = null

var tile_map = null

func _ready():
	set_process_input(true)
	
	tile_map = get_node(tile_map_path)

	
func _input(event):
	if (event.type == InputEvent.MOUSE_BUTTON):
		print("Click at: ", event.pos)
		
		var pos = get_tile_pos(event.pos)
		
		print("Map: ", pos)
		
		#var tile = get_cell(pos)
		#print("Cell: ", tile)
		
func get_tile_pos(pos):
	return tile_map.world_to_map(Vector2(pos.x / tile_map.get_scale().x, pos.y / tile_map.get_scale().y))

func is_valid(pos):
	return tile_map.get_cell(pos.x, pos.y)

