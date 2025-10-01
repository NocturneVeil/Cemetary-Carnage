extends Area3D
#Signal
signal body_part_hit(dmg)
#Constant
#Export
@export var DAMAGE := 1
#Variable
#OnReady


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func hit():
	emit_signal("body_part_hit", DAMAGE)
