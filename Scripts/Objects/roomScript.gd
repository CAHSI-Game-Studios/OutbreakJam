extends Node2D
class_name Room

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $Player/AudioStreamPlayer2D


@onready var stim_select_ui: Control = $StimSelectUI
@onready var player: Player = $Player
@onready var walls: TileMapLayer = $walls
@onready var decorations: TileMapLayer = $decorations


var stimScene = preload("res://Objects/Stims/Stim.tscn")
const DASH_STIM = preload("res://Objects/Stims/dashStim.tres")
const DOUBLE_JUMP_STIM = preload("res://Objects/Stims/doubleJumpStim.tres")
const FLOAT_STIM = preload("res://Objects/Stims/floatStim.tres")
const HEAL_STIM = preload("res://Objects/Stims/healStim.tres")
const MAGNETIC_STIM = preload("res://Objects/Stims/magneticStim.tres")



# Author: Puma
func _ready():
	Global.playerReference = player.duplicate()
	player.allowInput = false
	for textButton : TextureButton in stim_select_ui.get_children():
		var currentStim : Stim = textButton.get_child(0)
		if currentStim.StimType != null:
			continue # 
		var randonInteger : int = randi_range(0,100)
		if randonInteger < 30:
			currentStim.StimType = HEAL_STIM
		elif randonInteger < 60:
			currentStim.StimType =DASH_STIM
		elif randonInteger < 80:
			currentStim.StimType = DOUBLE_JUMP_STIM
		elif randonInteger < 90:
			currentStim.StimType = FLOAT_STIM
		elif randonInteger <= 100:
			currentStim.StimType = MAGNETIC_STIM
		currentStim.frame = currentStim.getType()# Type is an enumerator, see StimResource.gd
		textButton.texture_normal = currentStim.sprite_frames.get_frame_texture("default",currentStim.frame)
		audio_stream_player_2d.play()
func _process(delta: float) -> void:
	if !audio_stream_player_2d.playing:
		audio_stream_player_2d
func beginRoom():
	player.allowInput = true
	stim_select_ui.visible = false
func _on_stim_1_pressed() -> void:
	player.giveStim(stim_select_ui.get_child(0).get_child(0))
	beginRoom()
func _on_stim_2_pressed() -> void:
	player.giveStim(stim_select_ui.get_child(1).get_child(0))
	beginRoom()
func _on_stim_3_pressed() -> void:
	player.giveStim(stim_select_ui.get_child(2).get_child(0))
	beginRoom()
	get_tree()
