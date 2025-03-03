extends CharacterBody2D

@onready var animation_tree: AnimationTree = $AnimationTree

const SPEED : int = 300.0
const JUMP_VELOCITY : int = -400.0
var jumped : bool = false
var onGround : bool = true
var running : float = 1
var notRunning : bool = true
var fastFall : float = 1

func _ready():
	animation_tree.active = true

func _process(delta: float) -> void:
	update_animation_parameters()

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("down"):
		fastFall = 1.5
	else:
		fastFall = 1
	if not is_on_floor():
		velocity += get_gravity() * delta * fastFall
		onGround = false
	else:
		onGround = true
		if jumped:
			jumped = false
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		jumped = true
	
	var direction = Input.get_axis("left","right")
	
	if Input.is_action_pressed("run") && direction:
		running = 1.25
	else:
		running = 1
	velocity.x = SPEED*direction*running
	move_and_slide()


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
	
		
	
