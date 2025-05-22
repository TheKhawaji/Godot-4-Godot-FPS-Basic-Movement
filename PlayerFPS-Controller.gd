extends CharacterBody3D

# VarNodes
@onready var head: Node3D = %Head
@onready var p_camera: Camera3D = $"Head/P-Camera"

@export var JumpVelo := 4
@export var AutoBjmp := false
@export var MouseSense := 0.005

var DesDir = Vector3.ZERO

# GMS (Ground Movement Settings)
@export var DefMovSpeed := 10
@export var GroundAccel := 18
@export var GroundDeccel := 14
@export var GroundFriction := 8


# AMS (Air Movement Settings)
@export var AirCap := 0.90
@export var AirAccel := 950
@export var AirMovementSpeed := 600


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in %PlayerEnvMesh.find_children("*", "VisualInstace3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ################################################## #
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MouseSense)
		p_camera.rotate_x(-event.relative.y * MouseSense)
		p_camera.rotation.x = clamp(p_camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Handles Grounds Phyx
func _hgp(delta: float) -> void:
	var CurrentSpeed_in_DesDir = self.velocity.dot(DesDir)
	var AddedSpeed_Untill_Maxxed = DefMovSpeed - CurrentSpeed_in_DesDir
	# basically the same as _hap
	if AddedSpeed_Untill_Maxxed > 0:
		var AccelSpeed = GroundAccel * delta * DefMovSpeed
		AccelSpeed = min(AccelSpeed, AddedSpeed_Untill_Maxxed)
		self.velocity += AccelSpeed * DesDir
	# Apply's the Ground Friction
	var control = max(self.velocity.length(), GroundDeccel)
	var dip = control * GroundFriction * delta
	var NwSpeed = max(self.velocity.length() - dip, 0.0)
	if self.velocity.length() > 0:
		NwSpeed /= self.velocity.length()
	self.velocity *= NwSpeed

# Handles Air Phyx
func _hap(delta: float) -> void:
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	 # Source-Like Movement Code
	var CurrentSpeed_in_DesDir = self.velocity.dot(DesDir)
	var MaxxedSpeed = min((AirMovementSpeed * DesDir).length(), AirCap)
	var AddedSpeed_Untill_Maxxed = MaxxedSpeed - CurrentSpeed_in_DesDir
	# the 'CurrentSpeed_in_DesDir' is a Dot function that does math stuff that I watched from a Quake History Video
	# the 'MaxxedSpeed' is in it's name the max speed the player can have in the air which is AMS * DD
	# the 'AddedSpeed_Untill_Maxxed' it adds speed until it reaches the max limit
	# (I am too stupid to explain how this works, it's Black Magic from the 1990's)
	if AddedSpeed_Untill_Maxxed > 0:
		var AccelSpeed = AirAccel * AirMovementSpeed * delta
		AccelSpeed = min(AccelSpeed, AddedSpeed_Untill_Maxxed)
		self.velocity += AccelSpeed * DesDir
	

func _physics_process(delta: float) -> void:
	var InputDir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	# Moves to the Direction you are Facing
	
	DesDir = self.global_transform.basis * Vector3(InputDir.x, 0, InputDir.y)
	
	if is_on_floor():
		if Input.is_action_just_pressed("Jump-Up") or (AutoBjmp and Input.is_action_pressed("Jump-Up")):
			self.velocity.y = JumpVelo
		_hgp(delta)
	else:
		_hap(delta)
	
	move_and_slide()
