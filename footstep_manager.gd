extends Node3D

@export var footstep_sounds: Array[AudioStreamMP3] = [
	preload("res://Resources/Audio/SFX/FootSteps/gravel.mp3"),
	preload("res://Resources/Audio/SFX/FootSteps/gravel_reverse.mp3")
]
@export var ground_pos: Marker3D
@export var player: CharacterBody3D


@onready var audio_listener: AudioListener3D = $AudioListener3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_parent()  # Correctly reference the player node if it's the parent
	if player:
		print("Player found")
		if player.has_method("step"):  # Ensure the step signal exists
			player.connect("step", Callable(self, "play_sound"))
		else:
			print("Error: 'step' method not found on player")
	else:
		print("Error: Player not found")
	
	# Check if ground_pos is correctly initialized
	if ground_pos:
		print("Ground position marker found")
	else:
		print("Error: ground_pos is null")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_sound() :
	# Ensure ground_pos is not null before adding a child
	if ground_pos:
		var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		var random_index: int = randi_range(0, footstep_sounds.size() - 1)
		audio_player.stream = footstep_sounds[random_index]
		audio_player.pitch_scale = randf_range(0.5, 1.25)
		audio_player.volume_db = 0
		audio_player.attenuation_filter_cutoff_hz = 5000
		audio_player.attenuation_filter_db = 0
		audio_player.max_distance = 50
		ground_pos.add_child(audio_player)
		audio_player.play()
		audio_player.connect("finished", Callable(audio_player, "queue_free"))
	else:
		print("Error: ground_pos is null")
