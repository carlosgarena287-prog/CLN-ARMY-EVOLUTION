extends Camera3D
class_name ArmyCameraController

@export var follow_height: float = 10.5
@export var follow_distance: float = 13.5
@export var horizontal_smoothing: float = 5.0
@export var vertical_smoothing: float = 5.0

var follow_target: Node3D
var look_distance: float = 13.0


func set_target(target: Node3D) -> void:
	follow_target = target


func follow_position(delta: float) -> void:
	if not is_instance_valid(follow_target):
		return

	var desired := Vector3(
		follow_target.position.x * 0.28,
		follow_height,
		follow_target.position.z + follow_distance
	)

	position.x = lerpf(position.x, desired.x, horizontal_smoothing * delta)
	position.y = lerpf(position.y, desired.y, vertical_smoothing * delta)
	position.z = lerpf(position.z, desired.z, vertical_smoothing * delta)

	var look_target := Vector3(
		follow_target.position.x * 0.18,
		0.0,
		follow_target.position.z - look_distance
	)

	look_at(look_target, Vector3.UP)


func reset_camera(target_position: Vector3 = Vector3.ZERO) -> void:
	position = Vector3(
		target_position.x * 0.28,
		follow_height,
		target_position.z + follow_distance
	)

	look_at(
		Vector3(target_position.x * 0.18, 0.0, target_position.z - look_distance),
		Vector3.UP
	)
