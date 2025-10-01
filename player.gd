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
	#bullets
var bullet  = preload("res://Resources/Guns/bulllet.tscn")
var instance
	#weapons
var FOOTSTEPS = [ 
	$FootSteps/Run,
	$FootSteps/Walk
]
#initial weapons
var GUN = WEAPONS.Submachine
var can_shoot = true

#OnReady variables
@onready var Head := $Head
@onready var Camera := $Head/Camera3D
	#Gun variables
@onready var gun_anim := $Head/Camera3D/Pistol/AnimationPlayer
@onready var gun_barrel := $Head/Camera3D/Pistol/PistolArmature/Skeleton3D/Muzzle/RayCast3D
@onready var crosshair: TextureRect = $"../../../UI/Crosshair"
@onready var P90:= $Head/Camera3D/P90/AnimationPlayer
@onready var aim_ray:= $Head/Camera3D/P90/P90Armature/Skeleton3D/P90/AimRay
@onready var weapon_switch: AnimationPlayer = $Head/Camera3D/WeaponSwitch
@onready var gunshot_pistol: AudioStreamPlayer3D = $SFX/GUNSHOT_pistol
@onready var gunshot_p_90: AudioStreamPlayer3D = $SFX/GUNSHOT_P90
@onready var weapon_switchSFX: AudioStreamPlayer3D = $SFX/WeaponSwitch
@onready var Flash = $Head/Camera3D/SpotLight3D



#Enum
enum WEAPONS{
	Submachine,
	PISTOLS
}
 

func _ready() :
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#for child in $WorldModel.find_children("*", "VisualInstance3d"): 
		#child.set_layer_mask_value(1, false) 
		#child.set_layer_mask_value(2, true)
		
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		Head.rotate_y(-event.relative.x * SENSITIVITY)
		Camera.rotate_x(-event.relative.y * SENSITIVITY) 
		Camera.rotation.x = clamp(Camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	
	
	if event.is_action_pressed("Pause"):
		$PauseMenu._pause()
		crosshair.visible = false
	else:
		crosshair.visible = true
	
func _physics_process(delta: float) -> void:
	#flash ligh management
	if Input.is_action_just_pressed("Flashlight"):
		Flash.visible = not Flash.visible
	
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
	
	#Shooting
	# Shooting
	if Input.is_action_pressed("Shoot")and can_shoot:
		match GUN:
			WEAPONS.Submachine:
				_shoot_Submachine()
			WEAPONS.PISTOLS:
				_shoot_pistol()
				
	#WEAPONS SWITCHING
	if Input.is_action_just_pressed("HANDGUNS") and GUN != WEAPONS.PISTOLS : 
		_raise_weapon("WEAPONS.PISTOLS")
		weapon_switch.play()
	if Input.is_action_just_pressed("SUBMACHINES") and GUN != WEAPONS.Submachine :
		_raise_weapon("WEAPONS.Submachine")
		weapon_switch.play()

		
		
		 
	move_and_slide()

func _HeadBOB(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	return pos

# Method to handle hit finishing
func hit(dir):
	emit_signal("player_hit")
	velocity += dir * HIT_STAGGER
	

func _shoot_pistol():
	if !gun_anim.is_playing():
			gun_anim.play("PistolArmature|Fire")
			gunshot_pistol.play()
			instance = bullet.instantiate()  # Use instantiate() for Godot 4.x
			get_tree().root.add_child(instance)  # Add instance as a child to the parent node
			instance.global_transform = gun_barrel.global_transform
			instance.global_transform.basis = gun_barrel.global_transform.basis
			if gun_barrel.is_colliding():
				if gun_barrel.get_collider().is_in_group("Enemy"):         
					gun_barrel.get_collider().hit()
					instance.trigger_particle(gun_barrel.get_collision_point(),
					gun_barrel.global_position, true)
				else : 
					instance.trigger_particle(gun_barrel.get_collision_point(),
					aim_ray.global_position, false)
			
func _shoot_Submachine():
	if !P90.is_playing():
		P90.play("P90Armature|Fire")
		gunshot_p_90.play()
		instance = bullet.instantiate()  # Use instantiate() for Godot 4.x
		get_tree().root.add_child(instance)  # Add instance as a child to the parent node
		instance.global_transform = aim_ray.global_transform
		instance.global_transform.basis = aim_ray.global_transform.basis
		if aim_ray.is_colliding():
			if aim_ray.get_collider().is_in_group("Enemy"):             
				aim_ray.get_collider().hit()
				instance.trigger_particle(aim_ray.get_collision_point(),
				aim_ray.global_position, true)
			else : 
				instance.trigger_particle(aim_ray.get_collision_point(),
				aim_ray.global_position, false)

func footsteps():
	var FOOTSTEPS_PLAYING = false
	for audio in FOOTSTEPS:
		if audio.is_playing():
			FOOTSTEPS_PLAYING = true
			break
			
		else :
			FOOTSTEPS_PLAYING = false
	if SPEED == WALK_SPEED and !FOOTSTEPS_PLAYING:
		FOOTSTEPS[0].play()

func _lower_weapon():
	match GUN:
		WEAPONS.Submachine:
			weapon_switch.play("LowSub")
			$Head/Camera3D/P90.visible = false
		WEAPONS.PISTOLS:
			weapon_switch.play("LowPistol")
			$Head/Camera3D/Pistol.visible = false

func _raise_weapon(new_weapon):
	can_shoot = false
	_lower_weapon()
	await get_tree().create_timer(0.1).timeout
	match new_weapon:
		WEAPONS.Submachine:
			$Head/Camera3D/P90.visible = true
			weapon_switch.play_backwards("LowSub")
		WEAPONS.PISTOLS:
			$Head/Camera3D/Pistol.visible = true
			weapon_switch.play_backwards("LowPistol")
	GUN = new_weapon
	can_shoot = true
