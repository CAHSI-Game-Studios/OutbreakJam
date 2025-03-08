extends Area2D
class_name Laser


func _on_body_entered(body: Player) -> void:
	body.die()
