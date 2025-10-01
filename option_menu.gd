extends Control
@onready var click: AudioStreamPlayer = $Click
@onready var hover: AudioStreamPlayer = $HoverOn
@onready var options_menu_bgm: AudioStreamPlayer = $OptionsMenuBGM



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	options_menu_bgm.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#On Back pressed
func _on_back_pressed() -> void:
	click.play()         
	options_menu_bgm.stop()
	get_tree().change_scene_to_file("res://Main_Menu.tscn")

#On Back hovered
func _on_back_mouse_entered() -> void:
	hover.play()

#On quit pressed 
func _on_quit_pressed() -> void:
	click.play()
	await click.finished       # wait till click audio finishes              
	get_tree().quit()          # Quits scene

 
