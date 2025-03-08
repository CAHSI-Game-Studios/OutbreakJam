extends Sprite2D
class_name TitleScreen


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Rooms/roomTutorial1.tscn")
