extends Node3D
class_name ArmyEffectsManager

var active_effects: Array[Node3D] = []


func spawn_gate_burst(world_position: Vector3, tint: Color) -> void:
	var effect := Node3D.new()
	effect.position = world_position
	add_child(effect)
	active_effects.append(effect)

	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.emission_enabled = true
	material.emission = tint
	material.emission_energy_multiplier = 2.0

	for i in range(12):
		var particle := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = 0.12
		mesh.height = 0.24
		particle.mesh = mesh
		particle.material_override = material
		effect.add_child(particle)

		var angle := TAU * float(i) / 12.0
		particle.position = Vector3(cos(angle), 0.8, sin(angle)) * 0.7

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(effect, "scale", Vector3(2.2, 2.2, 2.2), 0.45)
	tween.tween_property(effect, "modulate:a", 0.0, 0.45)
	tween.chain().tween_callback(effect.queue_free)


func spawn_battle_flash(world_position: Vector3) -> void:
	var flash := OmniLight3D.new()
	flash.position = world_position
	flash.light_color = Color(0.35, 0.65, 1.0)
	flash.light_energy = 2.5
	flash.omni_range = 5.0
	add_child(flash)

	var tween := create_tween()
	tween.tween_property(flash, "light_energy", 0.0, 0.3)
	tween.tween_callback(flash.queue_free)


func clear_effects() -> void:
	for effect in active_effects:
		if is_instance_valid(effect):
			effect.queue_free()

	active_effects.clear()
