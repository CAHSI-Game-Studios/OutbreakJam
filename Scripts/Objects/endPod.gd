extends Area2D
class_name EndPod


func _on_body_entered(player: Player) -> void:
	get_parent().endRoom()
