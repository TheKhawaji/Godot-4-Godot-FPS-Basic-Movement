extends CharacterBody3D

# the Player Nodes
@onready var Head = $Head
@onready var PlayerCollision = $PlayerCollision
@onready var PlayerShapeCast = $PlayerShapeCast


# Mouse Sensitivity
@export var _MouseSens : float = deg_to_rad(2.85)

@export_subgroup("Max and Minimum Angles")
# Max and Minimum Angles for the camera
@export var MaxUp := deg_to_rad(89)
@export var MinDown := deg_to_rad(-80)

@export_subgroup("Speeds")
# Speeds
var Speed : float
@export var DefaultMovementSpeed : float = 8
@export var CrouchMovementSpeed : float = 4
@export var AccelerationSpeed : float = 16
@export var DeAccelerationSpeed : float = 4
@export var Crouch_TransionSpeed : float = 12
@export var unCrouch_TransionSpeed : float = 12

@export_subgroup("Heights")
# Palyer Height
@export var CrouchHeight : float = 1.5
@export var NormalHeight : float

@export_subgroup("GravityStuff")
@export var JumpVelocity : float = 6
@export var Gravity : float = 12

# allows the player to move in 3D space
var Direction = Vector3()
var InputDirection = Vector3()

func _ready():
	NormalHeight = Head.position.y
	NormalHeight = PlayerCollision.shape.height
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Speed = DefaultMovementSpeed


func _process(delta):
	if Input.is_action_pressed("Exit"):
		get_tree().quit()


func _unhandled_input(event):
		if event is InputEventMouseMotion:
			rotate_y (deg_to_rad(-event.relative.x * _MouseSens))
			Head.rotate_x (deg_to_rad(-event.relative.y * _MouseSens))
			Head.rotation.x = clamp(Head.rotation.x,MinDown,MaxUp)

# Handles Inputs
func _GetInput(delta):
	
	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor() and is_on_floor():
		velocity.y = JumpVelocity


	if Input.is_action_pressed("Crouch") or PlayerShapeCast.is_colliding():
		_Crouch(delta)
		Speed = CrouchMovementSpeed
	else:
		_unCrouch(delta)
		Speed = DefaultMovementSpeed


	# Handles Movement
	InputDirection = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	Direction = transform.basis * Vector3(InputDirection.x, 0, InputDirection.y)
	if Direction:
		velocity.x = lerp(velocity.x,Direction.x * Speed, AccelerationSpeed * delta)
		velocity.z = lerp(velocity.z,Direction.z * Speed, AccelerationSpeed * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, DeAccelerationSpeed * delta)
		velocity.z = lerp(velocity.z, 0.0, DeAccelerationSpeed * delta)

func _Crouch(delta):
	PlayerCollision.shape.height = lerp(PlayerCollision.shape.height,CrouchHeight, Crouch_TransionSpeed * delta)
	Head.position.y = lerp(Head.position.y,1.5,Crouch_TransionSpeed * delta)
func _unCrouch(delta):
	PlayerCollision.shape.height = lerp(PlayerCollision.shape.height,NormalHeight,unCrouch_TransionSpeed * delta)
	Head.position.y = lerp(Head.position.y,NormalHeight,unCrouch_TransionSpeed * delta)



func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= Gravity * delta
	
	_GetInput(delta)

	move_and_slide()
