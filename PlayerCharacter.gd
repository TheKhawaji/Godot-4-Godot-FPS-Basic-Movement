extends CharacterBody3D

# the Player Nodes
@onready var Head = $Head
@onready var PlayerCollision = $PlayerCollision
@onready var PlayerShapeCast = $PlayerShapeCast

# Mouse Sensitivity
@export var _MouseSens : float = deg_to_rad(2.85)

@export_subgroup("Max and Minimum Angles")
# Max and Minimum Angles for the camera
@export var _LookUp := deg_to_rad(89)
@export var _LookDown := deg_to_rad(-80)

@export_subgroup("Speeds")
# Speeds
var _Speed : float
@export var _DefaultMovementSpeed : float = 8
@export var _CrouchMovementSpeed : float = 4
@export var _AccelerationSpeed : float = 16
@export var _TransiyionSpeed : float = 12

@export_subgroup("Heights")
# Palyer Height
@export var _CrouchHeight : float = 1.25
@export var _NormalHeight : float

@export_subgroup("GravityStuff")
@export var _JumpVelocity : float = 6
@export var _Gravity : float = 12

# allows the player to move in 3D space
var _Direction = Vector3.ZERO
var _InputDirection = Vector3.UP

func _ready():
	_NormalHeight = PlayerCollision.shape.height
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_Speed = _DefaultMovementSpeed


func _process(delta):
	if Input.is_action_pressed("Exit"):
		get_tree().quit()


func _unhandled_input(event):
		if event is InputEventMouseMotion:
			rotate_y (deg_to_rad(-event.relative.x * _MouseSens))
			Head.rotate_x (deg_to_rad(-event.relative.y * _MouseSens))
			Head.rotation.x = clamp(Head.rotation.x,_LookDown,_LookUp)

# Handles Inputs
func _GetInput(delta):
	
	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor() and is_on_floor():
		velocity.y = _JumpVelocity
	if Input.is_action_pressed("Crouch") or PlayerShapeCast.is_colliding():
		_Crouch(delta)
		_Speed = _CrouchMovementSpeed
	else:
		_unCrouch(delta)
		_Speed = _DefaultMovementSpeed

	# Handles Movement
	_InputDirection = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	_Direction = lerp(_Direction,(transform.basis * Vector3(_InputDirection.x, 0, _InputDirection.y)).normalized(), delta * _AccelerationSpeed)
	if _Direction:
		velocity.x = _Direction.x * _Speed
		velocity.z = _Direction.z * _Speed
	else:
		velocity.x = 0
		velocity.z = 0

# this is the Crouch Code
func _Crouch(delta):
	PlayerCollision.shape.height = lerp(PlayerCollision.shape.height,_CrouchHeight, _TransiyionSpeed * delta)
	Head.position.y = lerp(Head.position.y,1.2,_TransiyionSpeed * delta)
func _unCrouch(delta):
	PlayerCollision.shape.height = lerp(PlayerCollision.shape.height,_NormalHeight,_TransiyionSpeed * delta)
	Head.position.y = lerp(Head.position.y,1.8,_TransiyionSpeed * delta)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= _Gravity * delta
	
	_GetInput(delta)

	move_and_slide()
