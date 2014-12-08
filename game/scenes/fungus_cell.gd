
extends Node2D

const MAX_ENERGY = 100.0
const INITIAL_ENERGY = 5.0
const COLONIZE_ENERGY_COST = 10.0
const ENERGY_DRAIN = 0.1
const ENERGY_TRANSFER = 0.5
const SEND_ENERGY_THRESHOLD = 10.0


var FungusCell = preload("res://scenes/fungus_cell.scn")
var FungusCellBackground = preload("res://scenes/fungus_cell_background.scn")
var Constants = preload("res://scenes/constants.gd")

var textures  = {
	Constants.HUMAN_PLAYER: [
		preload("res://images/Fungus1a.tex"),
		preload("res://images/Fungus2a.tex"),
		preload("res://images/Fungus3a.tex")],
	Constants.AI_PLAYER: [
		preload("res://images/FungusBad1.tex"),
		preload("res://images/FungusBad2.tex"),
		preload("res://images/FungusBad3.tex")]
}

var pos = Vector2(0, 0)
var current_energy = 0
var board = null
var sprite = null
var energy_bar = null
var background = null
var owner = Constants.HUMAN_PLAYER

var current_attack_pos = null
var next_attack_pos = null

func _ready():
	set_process(true)
	current_energy = INITIAL_ENERGY
	sprite = get_node("Body")
	energy_bar = get_node("Selection/Energy")
	
	sprite.set_rot(randf() * PI)
	
	get_node("Selection").hide()
	hide()


func initialize(pos_, owner_, board_):
	pos = pos_
	board = board_
	owner = owner_
	
	print("Cell: ", owner)
	
	sprite.set_texture(textures[owner][randi() % 3])

	sprite.set_opacity(1.0)
	get_node("Arm").set_opacity(0.0)
	show()

		
	if (not board.has_background(pos)):
		background = FungusCellBackground.instance()
		background.initialize(pos, board)


func _process(delta):
	var target_scale = 0.4 + (current_energy / MAX_ENERGY) * 0.6
	var scale = sprite.get_scale().x
	
	if (abs(target_scale - scale) < delta):
		scale = target_scale
	else:
		scale += sign(target_scale - scale) * delta
	
	sprite.set_scale(Vector2(scale, scale))
	energy_bar.set_scale(Vector2(current_energy / MAX_ENERGY, 1))
	
	if (background):
		background.update_scale(scale)
		
	# Control the attack animation
	var animation = get_node("ArmAnimation")
	if (not animation.is_playing() and (current_attack_pos != null or next_attack_pos != null)):
	
		if (current_attack_pos != null and next_attack_pos != null):
			# Retract the arm
			animation.play("Attack", -1, -1, true)
			current_attack_pos = null
		elif (current_attack_pos == null and next_attack_pos != null):
			# Extend the arm by only if we are attacking another cell besides our own
			if (next_attack_pos != pos):
				var arm = get_node("Arm")
				arm.set_rot(get_pos().angle_to_point(board.get_world_pos(next_attack_pos)))
				
				animation.play("Attack", -1, 1, false)
				current_attack_pos = next_attack_pos
			
			next_attack_pos = null


func tick():
	if (current_energy < MAX_ENERGY):
		var energy = board.draw_energy(pos)
		current_energy += energy
		
	current_energy -= ENERGY_DRAIN
	
	# Transfere energy if 
	if (current_attack_pos != null):
		var target_cell = board.get_cell(current_attack_pos)
		if (not target_cell and current_energy > COLONIZE_ENERGY_COST):
			board.add_cell(current_attack_pos, FungusCell, owner)
			current_energy -= COLONIZE_ENERGY_COST
		elif (target_cell and current_energy > SEND_ENERGY_THRESHOLD):
			if (target_cell.is_player() and target_cell.transfer_energy(ENERGY_TRANSFER)):
				current_energy -= ENERGY_TRANSFER
			# Need to attack enemy cells here!!!
	
	# The cell is killed if we run out of energy
	if (current_energy <= 0):
		board.clear_cell(self)


func transfer_energy(energy):
	if (current_energy < MAX_ENERGY):
		current_energy += energy
		return true
	else:
		return false


func attack(pos):
	next_attack_pos = pos


func select():
	get_node("Selection").show()
	
func deselect():
	get_node("Selection").hide()


func is_player():
	return owner == Constants.HUMAN_PLAYER
