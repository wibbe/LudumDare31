
extends Node2D

var body = null
var board
var pos

func _ready():
	body = get_node("Body")
	body.set_rot(randf() * PI)
	body.set_opacity(1.0)


func update_scale(scale):
	if (scale > body.get_scale().x):
		body.set_scale(Vector2(scale, scale))


func initialize(pos_, board_):
	pos = pos_
	board = board_
	
	board.add_background(pos, self)
