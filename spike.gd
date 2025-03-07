extends Node2D

@onready var S_Animation: AnimatedSprite2D = $AnimatedSprite2D

func _on_area_2d_body_entered(body: Player) -> void:
	S_Animation.play("default")
	#die()

func _on_animated_sprite_2d_frame_changed() -> void:
	if S_Animation.frame == 0:
		S_Animation.pause()
