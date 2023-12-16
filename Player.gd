extends CharacterBody3D

@onready var animated_sprite_2d = $CanvasLayer/GunBase/AnimatedSprite2D
@onready var ray_cast_3d = $RayCast3D
@onready var head = $Head


@export var _LookUp := deg_to_rad(70)
@export var _LookDown := deg_to_rad(-70)


@export var _MouseSensitivity : float = deg_to_rad(5)

@export var _SprintMovementSpeed = 3.5
@export var _DefaultMovementSpeed = 2.5
@export var _LerpSpeed = 6

var _Speed

var _Direction = Vector3.ZERO

const _JumpVelocity = 2.5
var _Gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_Speed = _DefaultMovementSpeed
	

func _input(event):
	if event.is_action_pressed("Exit"):
		get_tree().quit()
	if Input.is_action_pressed("Sprint"):
		_Speed = _SprintMovementSpeed
	else:
		_Speed = _DefaultMovementSpeed

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y (deg_to_rad(-event.relative.x * _MouseSensitivity))
		head.rotate_x (deg_to_rad(-event.relative.y * _MouseSensitivity))
		head.rotation.x = clamp(head.rotation.x,_LookDown,_LookUp)
		
		
		


func _physics_process(delta):
	
	
	
	if not is_on_floor():
		velocity.y -= _Gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = _JumpVelocity


	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	_Direction = lerp(_Direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * _LerpSpeed)
	if _Direction:
		velocity.x = _Direction.x * _Speed
		velocity.z = _Direction.z * _Speed
	else:
		velocity.x = move_toward(velocity.x, 0, _Speed)
		velocity.z = move_toward(velocity.z, 0, _Speed)

	move_and_slide()
