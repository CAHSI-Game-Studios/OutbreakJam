extends CharacterBody2D
class_name Player
@onready var animation_tree: AnimationTree = $AnimationTree
@export var maxDecay : float = 100
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dashing_timer: Timer = $dashingTimer


const SPEED : int = 300.0
const JUMP_VELOCITY : int = -400.0

@export var dashSpeed: int = 1500
var currentMaxSpeed : int
@export var maxSpeedWalk : int  = 300
@export var maxSpeedRun : int  = 500
@export var maxSpeedDash: int  = 3000
var Falling_position: float = 0

var allowInput : bool = true


# IMPLEMENT LOGIC TO CHANGE selectedStim maybe a keypressed -1/+1 the value
@export var heldStims : Array[Stim]
var selectedStim : int
var decay : float

# Stim variables
var canDash : bool = true
var canDoubleJump : bool = true
var isMagnetic : bool = false
var isFloaty : bool = false

# Animation handler and logic variables
var jumped : bool = false
var onGround : bool = true
var running : float = 1
var notRunning : bool = true
var fastFall : float = 1
var direction : float
var isDashing: bool = false 

# Use stim variables
var canUseDoubleJump : bool = true

# Runs everytime the player is instantiated
func _ready():
	for stim in $tempStims.get_children():
		if stim is Stim:
			heldStims.push_back(stim)                                                                                                             
	decay = maxDecay
	animation_tree.active = true
	

# Runs every frame
func _physics_process(delta: float) -> void:
	decay -= delta*5
	update_ui()
	update_animation_parameters()
	input()

	if isDashing:
		currentMaxSpeed = maxSpeedDash
	elif running > 1:
		currentMaxSpeed = maxSpeedRun
	else:
		currentMaxSpeed = maxSpeedWalk
	if not is_on_floor():
		if !isDashing:
			velocity.y += get_gravity().y * delta * fastFall
		onGround = false
	else:
		onGround = true
		
	
	velocity.x = min(SPEED*direction*running, currentMaxSpeed)
	if isDashing:
		velocity.x = min(dashSpeed*direction*running, currentMaxSpeed)
	move_and_slide()
	if is_on_floor():
		jumped = false
# Updates UI elements
func update_ui():
	# update stim UI here
	$tempDecayIndicator.text = str(int(decay))
# Handles the input 
func input():
	if allowInput:
		if Input.is_action_pressed("down"):
			fastFall = 1.5
		else:
			fastFall = 1
		if Input.is_action_just_pressed("jump"):
			if  is_on_floor():
				velocity.y = JUMP_VELOCITY
				jumped = true
				canUseDoubleJump = true
				Falling_position = velocity.y
			elif canDoubleJump && canUseDoubleJump:
				velocity.y = JUMP_VELOCITY
				jumped = true
				canUseDoubleJump = false
				canDoubleJump = false
				Falling_position = velocity.y 
		direction = Input.get_axis("left","right")
		if Input.is_action_just_pressed("dash") :
			dash()  
			
		if Input.is_action_pressed("run") && direction:
			running = 1.25
		else:
			running = 1
			
func die():
	Global.add_player_deathCount()
  
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
		
	
func useStim() -> void:
	if heldStims.is_empty():
		return
	
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
	# remove stim from the ui
	decay -= stimToUse.getDecayCost()
	heldStims.erase(stimToUse)

func applyDashStim() -> void:
	canDash = true

func applyDoubleJumpStim() -> void:
	canDoubleJump = true
	

func applyFloatyStim() -> void:
	isFloaty = true

func applyMagneticStim() -> void:
	isMagnetic = true
	
func dash() -> void:
	velocity.x += dashSpeed * direction
	dashing_timer.start()
	isDashing = true
	canDash = false


func giveStim(newStim : Stim):
	self.heldStims.push_back(newStim)
func getDecay() -> float:
	return self.decay
func getMaxDecay() -> float:
	return self.maxDecay
func _on_dashing_timer_timeout() -> void:
	isDashing = false
