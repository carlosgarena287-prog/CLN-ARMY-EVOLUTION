extends Node3D
class_name ArmySoldier

var is_enemy: bool = false
var soldier_index: int = 0
var move_phase: float = 0.0
var animation_speed: float = 10.0

var body_pivot: Node3D
var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D

var uniform_material: StandardMaterial3D
var armor_material: StandardMaterial3D
var skin_material: StandardMaterial3D
var dark_material: StandardMaterial3D


func setup(enemy: bool, index: int) -> void:
	is_enemy = enemy
	soldier_index = index
	move_phase = float(index) * 0.47
	_build_materials()
	_build_model()


func _build_materials() -> void:
	uniform_material = StandardMaterial3D.new()
	armor_material = StandardMaterial3D.new()
	skin_material = StandardMaterial3D.new()
	dark_material = StandardMaterial3D.new()

	if is_enemy:
		uniform_material.albedo_color = Color(0.42, 0.045, 0.065)
		armor_material.albedo_color = Color(0.88, 0.12, 0.10)
	else:
		uniform_material.albedo_color = Color(0.025, 0.16, 0.58)
		armor_material.albedo_color = Color(0.08, 0.42, 0.95)

	skin_material.albedo_color = Color(0.72, 0.49, 0.34)
	dark_material.albedo_color = Color(0.045, 0.055, 0.075)

	uniform_material.roughness = 0.65
	armor_material.metallic = 0.25
	armor_material.roughness = 0.38


func _build_model() -> void:
	body_pivot = Node3D.new()
	add_child(body_pivot)

	_add_capsule(
		body_pivot,
		0.23,
		0.76,
		Vector3(0.0, 1.0, 0.0),
		uniform_material
	)

	_add_box(
		body_pivot,
		Vector3(0.42, 0.43, 0.29),
		Vector3(0.0, 1.02, -0.035),
		armor_material
	)

	_add_sphere(
		body_pivot,
		0.17,
		Vector3(0.0, 1.51, 0.0),
		skin_material
	)

	_add_sphere(
		body_pivot,
		0.19,
		Vector3(0.0, 1.65, 0.0),
		armor_material
	)

	left_arm = _make_limb(
		Vector3(-0.28, 1.23, 0.0),
		uniform_material,
		0.075,
		0.48
	)

	right_arm = _make_limb(
		Vector3(0.28, 1.23, 0.0),
		uniform_material,
		0.075,
		0.48
	)

	left_leg = _make_limb(
		Vector3(-0.13, 0.65, 0.0),
		dark_material,
		0.095,
		0.62
	)

	right_leg = _make_limb(
		Vector3(0.13, 0.65, 0.0),
		dark_material,
		0.095,
		0.62
	)

	_add_box(
		body_pivot,
		Vector3(0.40, 0.10, 0.30),
		Vector3(0.0, 0.73, 0.0),
		dark_material
	)


func _make_limb(
	pivot_position: Vector3,
	material: Material,
	radius: float,
	height: float
) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = pivot_position
	body_pivot.add_child(pivot)

	_add_capsule(
		pivot,
		radius,
		height,
		Vector3(0.0, -height * 0.36, 0.0),
		material
	)

	return pivot


func _add_capsule(
	parent: Node3D,
	radius: float,
	height: float,
	pos: Vector3,
	material: Material
) -> void:
	var mesh_instance := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)


func _add_sphere(
	parent: Node3D,
	radius: float,
	pos: Vector3,
	material: Material
) -> void:
	var mesh_instance := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)


func _add_box(
	parent: Node3D,
	size: Vector3,
	pos: Vector3,
	material: Material
) -> void:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)


func animate_running(clock: float, strength: float = 1.0) -> void:
	var swing := sin(clock * animation_speed + move_phase) * 0.62 * strength

	left_arm.rotation.x = swing
	right_arm.rotation.x = -swing
	left_leg.rotation.x = -swing
	right_leg.rotation.x = swing

	body_pivot.position.y = absf(sin(clock * 20.0 + move_phase)) * 0.045 * strength


func set_running(active: bool) -> void:
	if not active:
		left_arm.rotation.x = 0.0
		right_arm.rotation.x = 0.0
		left_leg.rotation.x = 0.0
		right_leg.rotation.x = 0.0
