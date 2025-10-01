extends Node3D
#Signals

#Enumns variables

#Constants variables

#Exports variables

#Variables variables
var zombie := load("res://Resources/Zombie Medium/zombie.tscn")
var instance
var score = 0

#OnReady variables
@onready var hit_rect: ColorRect = $UI/HitRect
@onready var SPAWNS = $Map/Spawner
@onready var NAVIGATION_REGION = $Map/NavigationRegion3D
@onready var cross_hair: TextureRect = $"UI/Crosshair"
@onready var crosshair_hit: TextureRect = $UI/Crosshair_hit
@onready var Player: CharacterBody3D = $Map/NavigationRegion3D/Player
@onready var score_label: Label = $UI/ScoreLabel
@onready var background: AudioStreamPlayer3D = $Background


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensure HitRect does not capture mouse input or focus 
	#hit_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	#hit_rect.focus_mode = Control.FOCUS_NONE
	randomize()
	cross_hair.position.x = get_viewport().size.x / 2 -32
	cross_hair.position.y = get_viewport().size.y / 2 -32
	crosshair_hit.position.x = get_viewport().size.x / 2 -32
	crosshair_hit.position.y = get_viewport().size.y / 2 -32
	background.play()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	score_label.text = "Score: " + str(score)
	

# Connect to the zombie_died signal and update the score
func _on_zombie_died():
	score += 6  # Add points when a zombie dies
	score_label.text = "Score: " + str(score)  # Update the score label

func _on_player_player_hit():
	instance.hit_finished.connect(_on_player_player_hit)
	print("Player hit! Showing HitRect...")
	# Ensure the correct instance calls hit_finished
	if instance:
		instance.hit_finished(Player)
		hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	print("Player Not hit! Hiding HitRect...")
	hit_rect.visible = false
	
func _get_random_child(parent_node):
	var random_id = randi() %parent_node.get_child_count()
	return parent_node.get_child(random_id)
	
func _on_zombie_spawn_timer_timeout() -> void:
	var spawn_points = _get_random_child(SPAWNS).global_position
	instance = zombie.instantiate()
	instance.position = spawn_points
	 # Connect the zombie_died signal to the _on_zombie_died function
	instance.connect("zombie_died", Callable(self, "_on_zombie_died"))
	# Connect zombie_hit signal to the on_zombie_hit function
	instance.zombie_hit.connect(_on_zombie_hit)
	NAVIGATION_REGION.add_child(instance)
	
func _on_zombie_hit():
	crosshair_hit.visible = true
	await get_tree().create_timer(0.05).timeout
	crosshair_hit.visible = false
