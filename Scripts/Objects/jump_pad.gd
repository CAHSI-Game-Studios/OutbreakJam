extends Node2D
#author Yadziel
@onready var force = 500
@onready var JP_Animation: AnimatedSprite2D = $AnimatedSprite2D

func _on_area_2d_body_entered(body: Player) -> void:
	JP_Animation.play("default")
	var new_v = Vector2(cos(rotation)*force,sin(rotation)*force)
	body.velocity += new_v

func _on_animated_sprite_2d_frame_changed() -> void:
	if JP_Animation.frame == 0:
		JP_Animation.pause()
