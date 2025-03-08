extends Node2D
class_name Room

@export var nextRoomPath : String

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $Player/AudioStreamPlayer2D
@onready var player: Player = $Player
@onready var next_room_ui: Control = $Player/NextRoomUI
@onready var retry_ui: Control = $Player/RetryUI
@onready var starter_pod: StarterPod = $"RoomObjects/Start-End-Points/StarterPod"
@onready var win_sfx: AudioStreamPlayer2D = $winSFX


# Author: Puma
func _ready():
	player.allowInput = false
	player.position = starter_pod.position
	audio_stream_player_2d.play()
func _process(delta: float) -> void:
	if !audio_stream_player_2d.playing:
		audio_stream_player_2d.play()
func beginRoom():
	player.allowInput = true
func endRoom():
	player.velocity = Vector2.ZERO
	next_room_ui.visible = true
	player.allowInput = false
	win_sfx.play()
func _on_next_room_pressed() -> void:
	get_tree().change_scene_to_file(nextRoomPath)
func _on_retry_room_pressed() -> void:
	get_tree().reload_current_scene()
func _on_player_prompt_end_screen() -> void:
	retry_ui.visible = true
