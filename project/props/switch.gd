
extends Area2D


func _ready():
	set_enable_monitoring(true)

func body_enter(body):
	print("Enter")
	
func body_exit(body):
	print("Exit")

