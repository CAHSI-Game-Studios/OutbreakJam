extends Node2D
#author Yadziel
@onready var force = 500

func _on_area_2d_body_entered(body: Player) -> void:
	print("me cago en luma")
	print(rotation_degrees)
	print("y " + str(sin(rotation)*force))
	print("x " + str(cos(rotation)*force))
	var new_v = Vector2(cos(rotation)*force,sin(rotation)*force)
	body.velocity += new_v
	
