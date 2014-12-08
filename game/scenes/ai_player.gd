
extends Node2D

var board = null

func _ready():
	set_process(true)
	board = get_parent().get_node("Cells")

func _process(delta):
	pass
