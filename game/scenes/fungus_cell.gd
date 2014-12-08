
extends Node2D


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

var animations = {
	Constants.HUMAN_PLAYER: preload("res://images/line_spread_animation_A.res"),
	Constants.AI_PLAYER: preload("res://images/line_spread_animation_b.res")
}

var pos = Vector2(0, 0)
var current_energy = 0
var attack_count = 0
var board = null
var sprite = null
var energy_bar = null
var background = null
var arm_animation = null
var owner = Constants.HUMAN_PLAYER

var current_attack_pos = null
var next_attack_pos = null
var arm_animation_time = 0.0

func _ready():
	set_process(true)
	current_energy = Constants.INITIAL_ENERGY
	sprite = get_node("Body")
	energy_bar = get_node("Selection/Energy")
	arm_animation = get_node("ArmAnimation")
	
	sprite.set_rot(randf() * PI)
	
	get_node("Selection").hide()
	hide()


func initialize(pos_, owner_, board_):
	pos = pos_
	board = board_
	owner = owner_
	
	print("Cell: ", owner)
	
	sprite.set_texture(textures[owner][randi() % 3])
	get_node("Arm/Connection").set_sprite_frames(animations[owner])

	sprite.set_opacity(1.0)
	get_node("Arm").set_opacity(0.0)
	show()

		
	if (not board.has_background(pos)):
		background = FungusCellBackground.instance()
		background.initialize(pos, board)


func _process(delta):
	var target_scale = 0.4 + (current_energy / Constants.MAX_ENERGY) * 0.6
	var scale = sprite.get_scale().x
	
	if (abs(target_scale - scale) < delta):
		scale = target_scale
	else:
		scale += sign(target_scale - scale) * delta
	
	sprite.set_scale(Vector2(scale, scale))
	energy_bar.set_scale(Vector2(current_energy / Constants.MAX_ENERGY, 1))
	
	if (background):
		background.update_scale(scale)
		
	# Update arm animation
	arm_animation_time += delta
	while (arm_animation_time >= Constants.FUNGUS_ARM_ANIMATION_FRAME_TIME):
		arm_animation_time -= Constants.FUNGUS_ARM_ANIMATION_FRAME_TIME
		var connection = get_node("Arm/Connection")
		var frame_count = connection.get_sprite_frames().get_frame_count()
		var next_frame = connection.get_frame() + 1
		if (next_frame >= frame_count):
			next_frame = 0
		connection.set_frame(next_frame)
		
	# Control the attack animation
	if (not arm_animation.is_playing() and (current_attack_pos != null or next_attack_pos != null)):
		if (current_attack_pos != null and next_attack_pos != null):
			# Retract the arm
			playSpreadSound()
			arm_animation.play("Attack", -1, -1, true)
			current_attack_pos = null
		elif (current_attack_pos == null and next_attack_pos != null):
			# Extend the arm by only if we are attacking another cell besides our own
			playSpreadSound()
			if (next_attack_pos != pos):
				var arm = get_node("Arm")
				arm.set_rot(get_pos().angle_to_point(board.get_world_pos(next_attack_pos)))
				
				arm_animation.play("Attack", -1, 1, false)
				current_attack_pos = next_attack_pos
			
			next_attack_pos = null

func playSpreadSound():
	if is_player():
		get_parent().get_parent().get_node("SamplePlayer2D").play("spread"+str(1+floor(randf()*3)))

func tick():
	if (attack_count > 0):
		attack_count -= 1

	if (current_energy < Constants.MAX_ENERGY):
		var energy = board.draw_energy(pos)
		current_energy += energy
		
	current_energy -= Constants.ENERGY_DRAIN
	
	# Transfere energy if 
	if (current_attack_pos != null and not arm_animation.is_playing()):
		var target_cell = board.get_cell(current_attack_pos)
		if (not target_cell and current_energy > Constants.COLONIZE_ENERGY_COST):
			board.add_cell(current_attack_pos, FungusCell, owner)
			current_energy -= Constants.COLONIZE_ENERGY_COST
		elif (target_cell and current_energy > Constants.SEND_ENERGY_THRESHOLD):
			if (target_cell.owner == owner):
				current_energy -= target_cell.transfer_energy(Constants.ENERGY_TRANSFER)
			else:
				target_cell.drain_energy(Constants.ATTACK_ENERGY)
				current_energy -= Constants.ATTACK_ENERGY * 0.25
	
	# The cell is killed if we run out of energy
	if (current_energy <= 0):
		board.clear_cell(self)


func transfer_energy(energy):
	if (current_energy < Constants.MAX_ENERGY):
		var needed = min(Constants.MAX_ENERGY - current_energy, energy)
		current_energy += needed
		return needed
	else:
		return 0.0


func drain_energy(energy):
	current_energy -= energy
	attack_count = 30


func attack(pos):
	if (pos != current_attack_pos):
		next_attack_pos = pos


func is_attacked():
	return attack_count > 0

func select():
	get_node("Selection").show()
	
func deselect():
	get_node("Selection").hide()


func is_player():
	return owner == Constants.HUMAN_PLAYER
