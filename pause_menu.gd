extends Control

# OnReady Variables
#@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var click: AudioStreamPlayer = $Click
@onready var hover_on: AudioStreamPlayer = $HoverOn
@onready var hover_out: AudioStreamPlayer = $HoverOut
@onready var pause_menu_bgm: AudioStreamPlayer = $PauseMenuBGM



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible= false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_testPause()

func _resume() -> void:
	get_tree().paused = false
	pause_menu_bgm.stop()
	$AnimationPlayer.play("resume_game")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.visible= false #hides the pause menu
	

func _pause() -> void:
	get_tree().paused = true
	$AnimationPlayer.play("pause_game")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	self.visible= true #shows the pause menu
	pause_menu_bgm.play()

# Getting input and testing if the scene is paused or not
func _testPause() -> void:
	if Input.is_action_just_pressed("Pause"):
		if Input.is_action_just_pressed("Pause") and !get_tree().paused:
			_pause()
	elif Input.is_action_just_pressed("Pause") and get_tree().paused:
		_resume()

# When 'resume' button is pressed
func _on_resume_button_pressed() -> void:
	click.play()
	await click.finished
	_resume()

## When 'restart' button is pressed
func _on_restart_button_pressed() -> void:
	_resume()
	click.play()
	await click.finished
	get_tree().reload_current_scene()
#
## When 'main_menu' button is pressed
#func _on_main_menu_pressed() -> void:
	#_resume()
	#get_tree().change_scene_to_file("res://Main_Menu.tscn")
#
## When 'quit' button is pressed
func _on_quit_button_pressed() -> void:
	click.play()
	await click.finished
	get_tree().quit()



	


func _on_resume_button_mouse_entered() -> void:
	await hover_out.finished
	hover_on.play()


func _on_restart_button_mouse_entered() -> void:
	await hover_out.finished
	hover_on.play()


func _on_quit_button_mouse_entered() -> void:
	await hover_out.finished
	hover_on.play()


func _on_resume_button_mouse_exited() -> void:
	await hover_on.finished
	hover_out.play()


func _on_restart_button_mouse_exited() -> void:
	await hover_on.finished
	hover_out.play()


func _on_quit_button_mouse_exited() -> void:
	await hover_on.finished
	hover_out.play()
