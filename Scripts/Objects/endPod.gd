extends Area2D
class_name EndPod


func _on_body_entered(player: Player) -> void:
	player.over = true
	player.inmovable = true
	player.decay_bar.visible = false
	player.item_ui.visible = false
	get_parent().get_parent().endRoom()
