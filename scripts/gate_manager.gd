extends Node3D
class_name GateManager

signal gate_crossed(gate_index: int, new_troop_count: int)

var gate_positions: Array[float] = [-22.0, -48.0, -74.0]
var used_gates: Array[bool] = [false, false, false]

var gate_width: float = 4.8
var gate_height: float = 3.0


func _ready() -> void:
	create_gates()


func create_gates() -> void:
	for i in range(gate_positions.size()):
		_create_gate(Vector3(-3.0, 1.5, gate_positions[i]), "+10", Color(0.05, 0.43, 1.0))
		_create_gate(Vector3(3.0, 1.5, gate_positions[i]), "×2", Color(0.0, 0.78, 0.48))


func _create_gate(pos: Vector3, caption: String, tint: Color) -> void:
	var gate := Node3D.new()
	gate.position = pos
	add_child(gate)

	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.emission_enabled = true
	material.emission = tint
	material.emission_energy_multiplier = 1.4

	_add_box(gate, Vector3(0.18, gate_height, 0.3), Vector3(-gate_width * 0.5, 0.0, 0.0), material)
	_add_box(gate, Vector3(0.18, gate_height, 0.3), Vector3(gate_width * 0.5, 0.0, 0.0), material)
	_add_box(gate, Vector3(gate_width, 0.18, 0.3), Vector3(0.0, gate_height * 0.5, 0.0), material)

	var label := Label3D.new()
	label.text = caption
	label.font_size = 100
	label.position = Vector3(0.0, 0.0, -0.22)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	gate.add_child(label)


func check_gate(progress: float, player_x: float, troops: int) -> int:
	for i in range(gate_positions.size()):
		if used_gates[i]:
			continue

		if absf(progress - absf(gate_positions[i])) <= 0.65:
			used_gates[i] = true

			var result: int = troops + 10 if player_x < 0.0 else troops * 2
			result = mini(result, 99999)

			gate_crossed.emit(i, result)
			return result

	return troops


func reset_gates() -> void:
	for i in range(used_gates.size()):
		used_gates[i] = false


func _add_box(parent: Node3D, size: Vector3, pos: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)
