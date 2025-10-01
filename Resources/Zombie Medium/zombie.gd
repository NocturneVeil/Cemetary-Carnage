extends CharacterBody3D

#signal
signal zombie_died
signal player_hit
signal zombie_hit

#constants
const SPEED := 4.0
const ATTACK_RANGE = 2.5

#Exports
@export var player_path := "/root/Cemetary Map/Map/NavigationRegion3D/Player"


#Variables
var player = null
var state_machine
var HEALTH = 6
var sound_effects = []

#OnReady Variables
@onready var nav_agent := $NavigationAgent3D
@onready var anim_tree := $AnimationTree
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var attack_sound: AudioStreamPlayer3D = $AttackSound


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#load sound effect.
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-1.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-2.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-3.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-4.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-5.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-6.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-7.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-8.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-9.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-11.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-12.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-13.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-14.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-15.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-16.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-17.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-18.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-19.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-20.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-21.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-22.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-23.wav"))
	sound_effects.append(preload("res://Resources/Audio/SFX/ZombieSFX/zombie-24.wav"))
	_emit_random_sound()

	
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#set velocity
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"Run":
			var next_nav_point = nav_agent.get_next_path_position()
			nav_agent.set_target_position(player.global_transform.origin)
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta*10)
		"Punch":
			look_at(Vector3(player.global_position.x, global_position.y, 
			player.global_position.z), Vector3.UP)
			attack_sound.play()
	
	##Navigation
	#nav_agent.set_target_position(player.global_transform.origin)
	#var next_nav_point = nav_agent.get_next_path_position()
	#velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
	#
	##Look AT Player
	#look_at(Vector3(player.global_position.x, global_position.y, 
			#player.global_position.z), Vector3.UP)
	
	#Conditions
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	
	#anim_tree.get("parameters/playback")
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE
	
	
func hit_finished(player_hit):
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)


func _on_area_3d_body_part_hit(dmg: Variant) -> void:
	HEALTH -= dmg
	emit_signal("zombie_hit")
	if HEALTH <= 0:
		audio_stream_player_3d.stop()
		anim_tree.set("parameters/conditions/Die", true)
		await get_tree().create_timer(4.0).timeout
		emit_signal("zombie_died") #emits signal of enemy dead
		queue_free()

func _emit_random_sound():
	#Choose Random Sounds
	var random_sound = sound_effects[randi() % sound_effects.size()]
	audio_stream_player_3d.stream = random_sound
	audio_stream_player_3d.play()
	
	#cal this funct again after random interval
	var random_interval = randi_range(1.0, 4.0) #interval of 1 to 4 seconds
	await get_tree().create_timer(random_interval).timeout
	_emit_random_sound()
