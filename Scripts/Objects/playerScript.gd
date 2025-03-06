extends CharacterBody2D
class_name Player
@onready var animation_tree: AnimationTree = $AnimationTree
@export var maxDecay : int = 100


const SPEED : int = 300.0
const JUMP_VELOCITY : int = -400.0


# IMPLEMENT LOGIC TO CHANGE selectedStim maybe a keypressed -1/+1 the value
var heldStims : Array[Stim]
var selectedStim : int
var decay : int

# Stim variables
var canDash : bool = false
var canDoubleJump : bool = false
var isMagnetic : bool = false
var isFloaty : bool = false

# Animation handler and logic variables
var jumped : bool = false
var onGround : bool = true
var running : float = 1
var notRunning : bool = true
var fastFall : float = 1
var direction : float


# Runs everytime the player is instantiated
func _ready():
	animation_tree.active = true

# Runs every frame
func _physics_process(delta: float) -> void:
	update_animation_parameters()
	input()
	if not is_on_floor():
		velocity.y += get_gravity().y * delta * fastFall
	velocity.x = SPEED*direction*running
	move_and_slide()

# Handles the input 
func input():
	if Input.is_action_pressed("down"):
		fastFall = 1.5
	else:
		fastFall = 1
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumped = true
	direction = Input.get_axis("left","right")
	if Input.is_action_pressed("run") && direction:
		running = 1.25
	else:
		running = 1

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
	var stimToUse : Stim = heldStims[selectedStim]
	match stimToUse.getType():
		1: 
			canDash = true
		2:
			canDoubleJump = true
		3:
			isFloaty = true
		4: 
			isMagnetic = true
	# remove stim from the ui
	decay -= stimToUse.getDecayCost()
	heldStims.erase(stimToUse)
