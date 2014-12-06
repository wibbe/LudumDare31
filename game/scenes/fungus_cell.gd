
extends Node2D

const MAX_ENERGY = 100.0
const INITIAL_ENERGY = 10.0

var pos = Vector2(0, 0)
var current_energy = 0
var board = null
var sprite = null
var connections = []

func _ready():
	set_process(true)
	current_energy = INITIAL_ENERGY
	sprite = get_node("Sprite")
	
	get_node("Selection").hide()
	
func _process(delta):
	var scale = 0.4 + (current_energy / MAX_ENERGY) * 0.6
	sprite.set_scale(Vector2(scale, scale))

func initialize(pos_, board_):
	pos = pos_
	board = board_

func tick():
	if (current_energy < MAX_ENERGY):
		var energy = board.draw_energy(pos)
		current_energy += energy
		print(current_energy)

func select():
	get_node("Selection").show()
	
func deselect():
	get_node("Selection").hide()


func is_player():
	return true
