extends CharacterBody3D

@onready var animated_sprite_2d = $CanvasLayer/GunBase/AnimatedSprite2D
@onready var ray_cast_3d = $RayCast3D
@onready var head = $Head
@onready var camera_3d = $Head/Camera3D



@export_range(1,6) var _MouseSensitivity : float = 1
@export var _MouseSensY : float = 0.5
@export var _MouseSensX : float = 0.5

var _CameraControll 

var _Direction = Vector3.ZERO

var _Speed
var _SprintMovementSpeed = 5.0
var _DefaultMovementSpeed = 3.0
var _LerpSpeed = 6


const _JumpVelocity = 3.0
var _Gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_Speed = _DefaultMovementSpeed
	
	_MouseSensX = _MouseSensitivity 
	_MouseSensY = _MouseSensitivity 

func _input(event):
	if event.is_action_pressed("Exit"):
		get_tree().quit()
	if Input.is_action_pressed("Sprint"):
		_Speed = _SprintMovementSpeed
	else:
		_Speed = _DefaultMovementSpeed

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y (deg_to_rad(-event.relative.x * _MouseSensX))
		head.rotate_x (deg_to_rad(-event.relative.y * _MouseSensY))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-70),deg_to_rad(70))
		
		
		


func _process(delta):
	pass

func _physics_process(delta):
	
	
	
	if not is_on_floor():
		velocity.y -= _Gravity * delta

	# Handle jump.
	if Input.is_action_pressed("Jump") and is_on_floor():
		velocity.y = _JumpVelocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	_Direction = lerp(_Direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * _LerpSpeed)
	if _Direction:
		velocity.x = _Direction.x * _Speed
		velocity.z = _Direction.z * _Speed
	else:
		velocity.x = move_toward(velocity.x, 0, _Speed)
		velocity.z = move_toward(velocity.z, 0, _Speed)

	move_and_slide()
