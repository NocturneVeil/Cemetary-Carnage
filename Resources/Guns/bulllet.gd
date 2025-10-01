extends Node3D
#signals
#consttants
const SPEED := 50.0

#exports
#var
#onready
@onready var mesh := $MeshInstance3D
@onready var ray := $RayCast3D
@onready var spark := $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	position =position + transform.basis * Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding():
		mesh.visible = false
		spark.emitting = true
		await get_tree().create_timer(0.5).timeout
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
