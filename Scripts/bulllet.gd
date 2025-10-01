extends Node3D
#signals
#consttants
const SPEED := 200.0

#exports
#var


#onready
@onready var mesh := $MeshInstance3D
@onready var ray := $RayCast3D
@onready var spark := $Sparks
@onready var blood_splatter: GPUParticles3D = $Blood_Splatter
@onready var terrain_splatter: GPUParticles3D = $Terrain_Splatter


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	position =position + transform.basis * Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding():
		mesh.visible = false
		spark.emitting = true
		ray.enabled = false
		if ray.get_collider().is_in_group("Enemy"):
			ray.get_collider().hit()
		await get_tree().create_timer(2.0).timeout
		queue_free()

func trigger_particle(pos, gun_pos, on_enemy):
	if on_enemy:
		spark.emitting = false
		blood_splatter.position = pos
		blood_splatter.look_at(gun_pos)
		blood_splatter.emitting = true
	else :
		spark.emitting = false
		terrain_splatter.position = pos
		terrain_splatter.look_at(gun_pos)
		terrain_splatter.emitting = true


func _on_timer_timeout() -> void:
	queue_free()
