extends Control
#@onready var crosshair: TextureRect = $UI/Crosshair
@onready var click: AudioStreamPlayer = $Click
@onready var hover_on: AudioStreamPlayer = $HoverOn
@onready var hover_out: AudioStreamPlayer = $HoverOut
@onready var main_menu_bgm: AudioStreamPlayer = $MainMenuBGM


 #Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu_bgm.play()
	


 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_game_pressed() -> void:
	click.play()
	await click.finished
	main_menu_bgm.stop()
	get_tree().change_scene_to_file("res://Cemetary Map.tscn")
	


func _on_options_pressed() -> void:
	click.play()
	await click.finished
	print("Options Pressed")
	get_tree().change_scene_to_file("res://Option_Menu.tscn")


func _on_quit_game_pressed() -> void:
	click.play()
	await click.finished
	get_tree().quit()

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("Pause"):
		#$PauseMenu._pause()
		#crosshair.visible = false
	#else:
		#crosshair.visible = true


func _on_start_game_mouse_entered() -> void:
	hover_on.play()


func _on_options_mouse_entered() -> void:
	hover_on.play()


func _on_quit_game_mouse_entered() -> void:
	hover_on.play()


#func _on_start_game_mouse_exited() -> void:
	#hover_out.play()


#func _on_options_mouse_exited() -> void:
	#hover_out.play()


#func _on_quit_game_mouse_exited() -> void:
	#hover_out.play()
