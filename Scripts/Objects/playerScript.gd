extends CharacterBody2D
class_name Player

signal promptEndScreen
@onready var animation_tree: AnimationTree = $AnimationTree
@export var maxDecay : float = 100
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dashing_timer: Timer = $Timers/dashingTimer
@onready var floaty_timer: Timer = $Timers/floatyTimer
@onready var magnetic_timer: Timer = $Timers/magneticTimer
@onready var delay: Timer = $Timers/delay
@onready var decay_bar: ProgressBar = $CanvasLayer/DecayBar
@onready var item_ui: Control = $ItemUI
@onready var button: Button = $ItemUI/rerollButton
@onready var hover: Sprite2D = $ItemUI/hover
@onready var begin_room: Button = $ItemUI/beginRoom


const SPEED : int = 300.0
const JUMP_VELOCITY : int = -400.0

@export var dashSpeed: int = 1500
var currentMaxSpeed : int
@export var maxSpeedWalk : int  = 300
@export var maxSpeedRun : int  = 500
@export var maxSpeedDash: int  = 3000


var allowInput : bool = true

var heldStims : Array[Stim]
var selectedStim : int = 0
var decay : float 
var inmovable : bool = false
var over : bool = false

# Stim variables
var canDash : bool = false
var canDoubleJump : bool = false
var isFloaty : bool = false

# Animation handler and logic variables
var jumped : bool = false
var onGround : bool = true
var running : float = 1
var notRunning : bool = true
var fastFall : float = 1
var direction : float
var isDashing: bool = false 
var died : bool = false

# Use stim variables
var canUseDoubleJump : bool = true

# Runs everytime the player is instantiated
func _ready():                                                                                                        
	decay = 0
	decay_bar.max_value = maxDecay
	decay_bar.position = Vector2(50, 50)
	decay_bar.value = decay
	reroll()
	animation_tree.active = true


# Runs every frame
func _physics_process(delta: float) -> void:
	if decay >= maxDecay && !over:
		die()
	decay += delta* 1.5
	if running > 1:
		decay += delta * 2
	if jumped:
		decay += delta * 3
	decay = min(decay,maxDecay)
	update_ui()
	update_animation_parameters()
	input()
	decay_bar.position = Vector2(position.x - 50, position.y - 40)  # 50 es el desplazamiento hacia arriba

	if isDashing:
		currentMaxSpeed = maxSpeedDash
	elif running > 1:
		currentMaxSpeed = maxSpeedRun
	else:
		currentMaxSpeed = maxSpeedWalk
	if not is_on_floor():
		if !isDashing:
			if fastFall > 1:
				velocity.y += get_gravity().y * delta * fastFall
			elif isFloaty:
				velocity.y += get_gravity().y * delta * 0.5
			else:
				velocity.y += get_gravity().y * delta
		onGround = false
	else:
		onGround = true
		
	
	velocity.x = min(SPEED*direction*running, currentMaxSpeed)
	if isDashing:
		velocity.x = min(dashSpeed*direction*running, currentMaxSpeed)
	if inmovable:
		velocity.x = 0
	move_and_slide()
	if is_on_floor():
		jumped = false
# Updates UI elements
func update_ui():
	for i in range(0,3):
		var stimNode : Stim = item_ui.get_child(i)
		stimNode.frame_coords = Vector2(heldStims[i].getType(),heldStims[i].isUsed())
	decay_bar.value = decay
	hover.position.x = selectedStim*32
# Handles the input 
func input():
	if allowInput:
		if Input.is_action_just_pressed("item_left"):
			selectedStim = max(0,selectedStim-1)
		if Input.is_action_just_pressed("item_right"):
			selectedStim = min(2,selectedStim+1)
		if Input.is_action_just_pressed("use_item") && !heldStims[selectedStim].isUsed():
			useStim()
		if Input.is_action_pressed("down"):
			fastFall = 1.5
		else:
			fastFall = 1
		if Input.is_action_just_pressed("jump"):
			if  is_on_floor():
				velocity.y = JUMP_VELOCITY
				jumped = true
			elif canDoubleJump:
				velocity.y = JUMP_VELOCITY
				jumped = true
				canDoubleJump = false
		direction = Input.get_axis("left","right")
		if Input.is_action_just_pressed("dash") && canDash:
			dash()  
			
		if Input.is_action_pressed("run") && direction:
			running = 1.25
		else:
			running = 1
			
func die():
	decay = -100000
	decay_bar.visible = false
	item_ui.visible = false
	died = true
	allowInput = false
	inmovable = true
	delay.start()
	Global.addDeathCount()
  
# See Player->AnimationTree. https://www.youtube.com/watch?v=iElHZhOxGYA&ab_channel=Bitlytic
func update_animation_parameters():
	if velocity.x < 0:
		$Sprite2D.flip_h = true
	elif velocity.x > 0:
		$Sprite2D.flip_h = false

	if velocity == Vector2.ZERO:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/walk"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/walk"] = true
	if (Input.is_action_just_pressed("use_item")):
		animation_tree["parameters/conditions/use_item"] = true
	else:
		animation_tree["parameters/conditions/use_item"] = false
	if jumped:
		animation_tree["parameters/conditions/jumped"] = true
	else: 
		animation_tree["parameters/conditions/jumped"] = false
	if isDashing:
		animation_tree["parameters/conditions/dashing"] = true
	else: 
		animation_tree["parameters/conditions/dashing"] = false
	if onGround:
		animation_tree["parameters/conditions/onGround"] = true
		animation_tree["parameters/conditions/inAir"] = false
	else:
		animation_tree["parameters/conditions/onGround"] = false
		animation_tree["parameters/conditions/inAir"] = true
	if running > 1:
		animation_tree["parameters/conditions/running"] = true
		animation_tree["parameters/conditions/notRunning"] = false
	else:
		animation_tree["parameters/conditions/running"] = false
		animation_tree["parameters/conditions/notRunning"] = true
	if died:
		animation_tree["parameters/conditions/died"] = true
	else: 
		animation_tree["parameters/conditions/died"] = false
	
func useStim() -> void:
	var stimToUse : Stim = heldStims[selectedStim]
	match stimToUse.getType():
		1: 
			applyDashStim()
		2:
			applyDoubleJumpStim()
		3:
			applyFloatyStim()
		4: 
			applyMagneticStim()
	heldStims[selectedStim].used = true
	decay += stimToUse.getDecayCost()
	decay = min(decay,maxDecay)

func applyDashStim() -> void:
	canDash = true
func applyDoubleJumpStim() -> void:
	canDoubleJump = true
	
func applyFloatyStim() -> void:
	isFloaty = true
	floaty_timer.start()
func applyMagneticStim() -> void:
	set_collision_layer_value(2,true)
	set_collision_mask_value(2,true)
	magnetic_timer.start()
	
func dash() -> void:
	velocity.x += dashSpeed * direction
	dashing_timer.start()
	isDashing = true
	canDash = false
func reset_decay():
	decay = 0
func giveStim(newStim : Stim):
	self.heldStims.push_back(newStim)
func getDecay() -> float:
	return self.decay
func getMaxDecay() -> float:
	return self.maxDecay
func _on_dashing_timer_timeout() -> void:
	isDashing = false
	
var stimScene = preload("res://Objects/Stims/Stim.tscn")
const DASH_STIM = preload("res://Objects/Stims/dashStim.tres")
const DOUBLE_JUMP_STIM = preload("res://Objects/Stims/doubleJumpStim.tres")
const FLOAT_STIM = preload("res://Objects/Stims/floatStim.tres")
const HEAL_STIM = preload("res://Objects/Stims/healStim.tres")
const MAGNETIC_STIM = preload("res://Objects/Stims/magneticStim.tres")

func reroll() -> void:
	heldStims.clear()
	for stim in item_ui.get_children():
		if stim is not Stim:
			continue
		var randonInteger : int = randi_range(0,100)
		if randonInteger < 30:
			stim.setType(HEAL_STIM)
		elif randonInteger < 60:
			stim.setType(DASH_STIM)
		elif randonInteger < 80:
			stim.setType(DOUBLE_JUMP_STIM)
		elif randonInteger < 90:
			stim.setType(FLOAT_STIM)
		elif randonInteger <= 100:
			stim.setType(MAGNETIC_STIM)
		stim.used = false
		heldStims.push_back(stim)
func _on_reroll_button_pressed() -> void:
	reroll()
func _on_begin_room_pressed() -> void:
	get_parent().beginRoom()
	button.visible = false
	begin_room.visible = false
func _on_floaty_timer_timeout() -> void:
	isFloaty = false
func _on_magnetic_timer_timeout() -> void:
	set_collision_layer_value(2,false)
	set_collision_mask_value(2,false)
func _on_delay_timeout() -> void:
	promptEndScreen.emit()
