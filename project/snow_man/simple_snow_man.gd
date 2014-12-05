
extends KinematicBody2D

const GRAVITY = 3000.0
const WALK_SPEED = 400.0
const JUMP = 1000.0

var velocity = Vector2()
var grounded = false
var connected
var legs = null
var body = null
var head = null
var animations = null

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	
	legs = get_parent().get_node("Legs")
	body = get_parent().get_node("Body")
	head = get_parent().get_node("Head")
	animations = get_node("Animations")
	
	# Start the idle animation
	animations.play("Idle")
	
func _input(event):
	if (event.is_action("player_disconnect")):
		disconnect_parts()
	
func _fixed_process(delta):
	velocity.y += GRAVITY * delta
	
	if (Input.is_action_pressed("ui_left")):
		velocity.x = -WALK_SPEED
	elif (Input.is_action_pressed("ui_right")):
		velocity.x = WALK_SPEED
	else:
		velocity.x = 0.0
		
	if (Input.is_action_pressed("player_jump") and grounded):
		grounded = false
		velocity.y -= JUMP
	
	var motion = velocity * delta
	motion = move(motion)
	
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
		
		if (n.dot(Vector2(0, 1)) < -0.3):
			grounded = true
		else:
			grounded = false	
	else:
		grounded = false

func disconnect_parts():
	print("Disconncting parts")
	body.set_mode(RigidBody2D.MODE_RIGID)
	head.set_mode(RigidBody2D.MODE_RIGID)
	legs.set_mode(RigidBody2D.MODE_RIGID)
	get_node("RemoteHead").set_remote_node(NodePath(""))
	get_node("RemoteBody").set_remote_node(NodePath(""))
	get_node("RemoteLegs").set_remote_node(NodePath(""))
	
	body.apply_impulse(Vector2(0, 0), Vector2(200, 100))
	head.apply_impulse(Vector2(0, 0), Vector2(-200, 100))
