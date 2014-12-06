
extends Node2D

const MAX_ENERGY = 100.0
const INITIAL_ENERGY = 5.0
const COLONIZE_ENERGY_COST = 10.0

var FungusCell = preload("res://scenes/fungus_cell.scn")

var pos = Vector2(0, 0)
var current_energy = 0
var board = null
var sprite = null
var colonize = {}

func _ready():
	set_process(true)
	current_energy = INITIAL_ENERGY
	sprite = get_node("Background")
	sprite.set_rot(randf() * PI)
	
	
	get_node("Selection").hide()
	
func _process(delta):
	#var scale = 0.1 + (current_energy / MAX_ENERGY) * 0.9
	#sprite.set_scale(Vector2(scale, scale))
	pass

func initialize(pos_, board_):
	pos = pos_
	board = board_

func tick():
	if (current_energy < MAX_ENERGY):
		var energy = board.draw_energy(pos)
		current_energy += energy
		
	for colony in colonize:
		var target = board.get_cell(colony)
		if (not target and current_energy > COLONIZE_ENERGY_COST):
			board.add_cell(colony, FungusCell)
			current_energy -= COLONIZE_ENERGY_COST
		elif (target and target.is_player() and current_energy > 0):
			if (target.transfere_energy()):
				current_energy -= 1.0
			

func transfere_energy():
	if (current_energy < MAX_ENERGY):
		current_energy += 1
		return true
	else:
		return false

func attack(pos):
	if (not colonize.has(pos) && board.is_valid(pos)):
		colonize[pos] = true

func select():
	get_node("Selection").show()
	
func deselect():
	get_node("Selection").hide()


func is_player():
	return true
