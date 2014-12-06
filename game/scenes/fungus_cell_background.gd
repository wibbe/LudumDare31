
extends Node2D

var body = null
var board
var pos

func _ready():
	body = get_node("Body")
	body.set_rot(randf() * PI)
	
func update_scale(scale):
	#if (scale > body.get_scale().x):
	#body.set_scale(Vector2(scale, scale))
	pass


func initialize(from_pos, pos_, board_):
	pos = pos_
	board = board_
	
	board.add_background(pos)
	
	if (from_pos != null):
		var animation = get_node("Animation")
		var arm = get_node("Arm")
		arm.set_rot(get_pos().angle_to_point(from_pos) + deg2rad(90))
		animation.play("Attack")
		show()
	else:
		get_node("Body").set_opacity(1.0)
		get_node("Arm").set_opacity(0.0)
		show()