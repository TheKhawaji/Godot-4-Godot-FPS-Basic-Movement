extends CharacterBody3D

# the Player Nodes
@onready var Head = $Head
@onready var CollisionShape = $CollisionShape3D



#the MAX amount for the player Head/Camera to look either Up or Down most games have this to not let the Head/Camera to loop around the character
@export var _LookUp := deg_to_rad(89)
@export var _LookDown := deg_to_rad(-89)

@export var _MouseSens : float = deg_to_rad(2.85)


# Speed 
var _Speed

# this is the Movement Speed for the player
@export var _DefaultMovementSpeed = 6.5

# the is the Lerp Speed you can remove this if you'd like
@export var _LerpSpeed = 8

const _JumpVelocity = 2.5
var _Gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# allows the player to move in 3D space
var _Direction = Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_Speed = _DefaultMovementSpeed


func _input(event):
	if event.is_action_pressed("Exit"):
		get_tree().quit()

func _unhandled_input(event):
		if event is InputEventMouseMotion:
			rotate_y (deg_to_rad(-event.relative.x * _MouseSens))
			Head.rotate_x (deg_to_rad(-event.relative.y * _MouseSens))
			Head.rotation.x = clamp(Head.rotation.x,_LookDown,_LookUp)

func _process(delta):
	pass


func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= _Gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = _JumpVelocity

	# Handles Movement
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	_Direction = lerp(_Direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * _LerpSpeed)
	if _Direction:
		velocity.x = _Direction.x * _Speed
		velocity.z = _Direction.z * _Speed
	else:
		velocity.x = move_toward(velocity.x, 0, _Speed)
		velocity.z = move_toward(velocity.z, 0, _Speed)

	move_and_slide()
