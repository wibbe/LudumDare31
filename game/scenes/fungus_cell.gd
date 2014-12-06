
extends Node2D

const MAX_ENERGY = 100
const INITIAL_ENERGY = 10

var position = Vector2(0, 0)
var energy = 0
var game = null
var sprite = null

func set_game(g):
	game = g

func _ready():
	set_process(true)
	energy = INITIAL_ENERGY
	sprite = get_node("Sprite")
	
func _process(delta):
	var scale = 0.4 + (energy / MAX_ENERGY) * 0.6
	sprite.set_scale(Vector2(scale, scale))


