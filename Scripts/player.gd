extends CharacterBody3D

#Signal
signal player_hit

#Constants
	#FOV variables
const BASE_FOV := 70.0
const CHANGE_FOV := 1.5
	#Movement Variables
const WALK_SPEED := 5.0
const SPRINT_SPEED := 8.0
const JUMP_VELOCITY := 4.5
const GRAVITY := 9.8
const SENSITIVITY := 0.01
	#head Bob variables
const BOB_FREQ := 0.05
const BOB_AMP := 0.05
	#hit stagger
const HIT_STAGGER := 8.0 


#Exports
@export var Player := get_parent()

#Variables
var SPEED
	#head Bob variables
var t_bob := 0.0
var direction: Vector3  

#OnReady variables
@onready var Head := $Head
@onready var Camera := $Head/Camera3D
 
 

func _ready() :
	Head = $Head # Ensure the "Head" node exists and is correctly named
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#for child in $WorldModel.find_children("*", "VisualInstance3d"): 
		#child.set_layer_mask_value(1, false) 
		#child.set_layer_mask_value(2, true)
		
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		Head.rotate_y(-event.relative.x * SENSITIVITY)
		Camera.rotate_x(-event.relative.y * SENSITIVITY) 
		Camera.rotation.x = clamp(Camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
			
			
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle Sprint
	if Input.is_action_pressed("Sprint"):
		SPEED = SPRINT_SPEED
	else :
		SPEED = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var input_dir := Input.get_vector("StrafeLeft", "StrafeRight", "Forward", "Backward")
	var direction:Vector3 = (Head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			#velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.x = lerp(velocity.x, velocity.x * SPEED, delta * -3.50)
			#velocity.z = move_toward(velocity.z, 0, SPEED)
			velocity.z = lerp(velocity.z, velocity.z * SPEED, delta * -3.50)
	else:
		velocity.x = lerp(velocity.x, velocity.x * SPEED, delta * 0.01)
		velocity.z = lerp(velocity.z, velocity.z * SPEED, delta * 0.01)
			
	#Head_BOB Phy
	t_bob += velocity.length() * float(is_on_floor())
	Camera.transform.origin = _HeadBOB(t_bob)

	#FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + CHANGE_FOV * velocity_clamped
	Camera.fov = lerp(Camera.fov, target_fov, delta * 4 )
	
	move_and_slide()

func _HeadBOB(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	return pos
