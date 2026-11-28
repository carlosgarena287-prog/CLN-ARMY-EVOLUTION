
extends Node3D

const START_ARMY: int = 12
const MAX_VISIBLE: int = 64
const TRACK_LENGTH: float = 112.0
const GATE_ZS: Array[float] = [-22.0, -48.0, -74.0]
const ENEMY_Z: float = -126.0

var army_count: int = START_ARMY
var enemy_count: int = 34
var level: int = 1
var progress: float = 0.0
var player_x: float = 0.0
var target_x: float = 0.0
var game_state: String = "running"
var gate_used: Array[bool] = [false, false, false]

var touch_down: bool = false
var last_pointer_x: float = 0.0
var run_clock: float = 0.0
var battle_timer: float = 0.0
var battle_start_player_z: float = 0.0
var battle_start_enemy_z: float = 0.0

var army_root: Node3D
var enemy_root: Node3D
var camera: Camera3D

var soldiers: Array[Dictionary] = []
var enemies: Array[Dictionary] = []

var hud_level: Label
var hud_count: Label
var hud_hint: Label
var progress_bar: ProgressBar
var result_panel: PanelContainer
var result_label: Label
var continue_button: Button


func _ready() -> void:
	_build_world()
	_build_track()
	_build_gates()
	_build_armies()
	_build_hud()
	_refresh_army()
	_refresh_enemy()
	_update_hud()


func _process(delta: float) -> void:
	run_clock += delta

	if game_state == "running":
		_update_running(delta)
	elif game_state == "battle":
		_update_battle(delta)


func _update_running(delta: float) -> void:
	progress = minf(progress + 11.0 * delta, TRACK_LENGTH)
	player_x = move_toward(player_x, target_x, 13.0 * delta)

	army_root.position = Vector3(player_x, 0.0, -progress)

	camera.position = Vector3(
		player_x * 0.28,
		10.5,
		-progress + 13.5
	)

	camera.look_at(
		Vector3(player_x * 0.18, 0.0, -progress - 13.0),
		Vector3.UP
	)

	_animate_squad(soldiers, run_clock, 1.0)
	_check_gates()

	progress_bar.value = progress / TRACK_LENGTH * 100.0

	if progress >= TRACK_LENGTH:
		_start_battle()


func _input(event: InputEvent) -> void:
	if game_state != "running":
		return

	if event is InputEventScreenTouch:
		touch_down = event.pressed
		last_pointer_x = event.position.x

	elif event is InputEventScreenDrag and touch_down:
		_move_player(event.position.x - last_pointer_x)
		last_pointer_x = event.position.x

	elif event is InputEventMouseButton:
		touch_down = event.pressed
		last_pointer_x = event.position.x

	elif event is InputEventMouseMotion and touch_down:
		_move_player(event.position.x - last_pointer_x)
		last_pointer_x = event.position.x


func _move_player(delta_x: float) -> void:
	target_x = clampf(
		target_x + delta_x / 720.0 * 13.0,
		-4.7,
		4.7
	)


func _build_world() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()

	env.background_mode = Environment.BG_SKY

	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()

	sky_material.sky_top_color = Color(0.055, 0.12, 0.24)
	sky_material.sky_horizon_color = Color(0.32, 0.48, 0.62)
	sky_material.ground_bottom_color = Color(0.055, 0.075, 0.09)
	sky_material.ground_horizon_color = Color(0.22, 0.29, 0.32)

	sky.sky_material = sky_material
	env.sky = sky

	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.62, 0.72, 0.9)
	env.ambient_light_energy = 0.75
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC

	world.environment = env
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -25.0, 0.0)
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	add_child(sun)

	camera = Camera3D.new()
	camera.position = Vector3(0.0, 10.5, 13.5)
	camera.fov = 62.0
	camera.current = true
	add_child(camera)

	camera.look_at(Vector3(0.0, 0.0, -13.0), Vector3.UP)


func _mat(
	color: Color,
	metallic: float = 0.0,
	roughness: float = 0.72
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	return material


func _mesh_box(
	parent: Node3D,
	size: Vector3,
	pos: Vector3,
	material: Material
) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()

	mesh.size = size
	node.mesh = mesh
	node.position = pos
	node.material_override = material

	parent.add_child(node)
	return node


func _mesh_cylinder(
	parent: Node3D,
	radius: float,
	height: float,
	pos: Vector3,
	material: Material
) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := CylinderMesh.new()

	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12

	node.mesh = mesh
	node.position = pos
	node.material_override = material

	parent.add_child(node)
	return node


func _build_track() -> void:
	var asphalt := _mat(Color(0.105, 0.145, 0.19), 0.12, 0.88)
	var edge := _mat(Color(0.95, 0.72, 0.22), 0.25, 0.45)
	var stripe := _mat(Color(0.78, 0.86, 0.92))
	var grass := _mat(Color(0.12, 0.25, 0.19))

	_mesh_box(
		self,
		Vector3(13.0, 0.42, TRACK_LENGTH + 45.0),
		Vector3(0.0, -0.38, -TRACK_LENGTH * 0.48),
		asphalt
	)

	for side in [-1.0, 1.0]:
		_mesh_box(
			self,
			Vector3(0.16, 0.045, TRACK_LENGTH + 40.0),
			Vector3(side * 6.2, -0.15, -TRACK_LENGTH * 0.48),
			edge
		)

		_mesh_box(
			self,
			Vector3(7.0, 0.25, TRACK_LENGTH + 45.0),
			Vector3(side * 10.0, -0.52, -TRACK_LENGTH * 0.48),
			grass
		)

	for i in range(26):
		_mesh_box(
			self,
			Vector3(0.12, 0.035, 2.2),
			Vector3(0.0, -0.145, -float(i) * 4.3 - 2.0),
			stripe
		)

	for side in [-1.0, 1.0]:
		for i in range(15):
			var tree := Node3D.new()
			tree.position = Vector3(
				side * (7.8 + float(i % 3) * 0.45),
				0.0,
				-float(i) * 7.2 - 5.0
			)

			add_child(tree)

			_mesh_cylinder(
				tree,
				0.12,
				1.2,
				Vector3(0.0, 0.6, 0.0),
				_mat(Color(0.24, 0.16, 0.11))
			)

			var crown := MeshInstance3D.new()
			var sphere := SphereMesh.new()

			sphere.radius = 0.62
			sphere.height = 1.35

			crown.mesh = sphere
			crown.position = Vector3(0.0, 1.55, 0.0)
			crown.material_override = _mat(Color(0.12, 0.34, 0.24))

			tree.add_child(crown)


func _build_gates() -> void:
	for i in range(GATE_ZS.size()):
		_make_gate(
			-3.0,
			GATE_ZS[i],
			"+10",
			Color(0.05, 0.43, 1.0)
		)

		_make_gate(
			3.0,
			GATE_ZS[i],
			"×2",
			Color(0.0, 0.78, 0.48)
		)


func _make_gate(
	x: float,
	z: float,
	caption: String,
	tint: Color
) -> void:
	var gate := Node3D.new()
	gate.position = Vector3(x, 1.45, z)
	add_child(gate)

	var glow := _mat(Color(tint.r, tint.g, tint.b, 0.22), 0.15, 0.25)
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	_mesh_box(
		gate,
		Vector3(4.8, 2.8, 0.22),
		Vector3.ZERO,
		glow
	)

	var frame_material := _mat(tint, 0.35, 0.28)

	_mesh_box(
		gate,
		Vector3(0.18, 3.0, 0.3),
		Vector3(-2.42, 0.0, 0.0),
		frame_material
	)

	_mesh_box(
		gate,
		Vector3(0.18, 3.0, 0.3),
		Vector3(2.42, 0.0, 0.0),
		frame_material
	)

	_mesh_box(
		gate,
		Vector3(4.95, 0.18, 0.3),
		Vector3(0.0, 1.48, 0.0),
		frame_material
	)

	var label := Label3D.new()
	label.text = caption
	label.font_size = 104
	label.pixel_size = 0.009
	label.position = Vector3(0.0, 0.0, -0.19)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color.WHITE

	gate.add_child(label)


func _build_armies() -> void:
	army_root = Node3D.new()
	add_child(army_root)

	enemy_root = Node3D.new()
	enemy_root.position = Vector3(0.0, 0.0, ENEMY_Z)
	add_child(enemy_root)

	for i in range(MAX_VISIBLE):
		soldiers.append(_create_soldier(army_root, false, i))
		enemies.append(_create_soldier(enemy_root, true, i))


func _create_soldier(
	parent: Node3D,
	enemy: bool,
	index: int
) -> Dictionary:
	var unit := Node3D.new()
	parent.add_child(unit)

	var blue := _mat(Color(0.035, 0.24, 0.78), 0.18, 0.48)
	var blue_light := _mat(Color(0.08, 0.48, 1.0), 0.25, 0.38)

	var red := _mat(Color(0.62, 0.055, 0.075), 0.15, 0.5)
	var red_light := _mat(Color(0.95, 0.16, 0.12), 0.18, 0.42)

	var uniform: Material = red if enemy else blue
	var armor: Material = red_light if enemy else blue_light

	var skin := _mat(Color(0.72, 0.49, 0.34))
	var dark := _mat(Color(0.055, 0.07, 0.09), 0.1, 0.65)

	var torso := MeshInstance3D.new()
	var torso_mesh := CapsuleMesh.new()

	torso_mesh.radius = 0.22
	torso_mesh.height = 0.72
	torso_mesh.radial_segments = 12

	torso.mesh = torso_mesh
	torso.position.y = 0.98
	torso.material_override = uniform
	unit.add_child(torso)

	var vest := MeshInstance3D.new()
	var vest_mesh := BoxMesh.new()

	vest_mesh.size = Vector3(0.39, 0.42, 0.27)
	vest.mesh = vest_mesh
	vest.position = Vector3(0.0, 1.0, -0.035)
	vest.material_override = armor

	unit.add_child(vest)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()

	head_mesh.radius = 0.17
	head_mesh.height = 0.34

	head.mesh = head_mesh
	head.position.y = 1.48
	head.material_override = skin

	unit.add_child(head)

	var helmet := MeshInstance3D.new()
	var helmet_mesh := SphereMesh.new()

	helmet_mesh.radius = 0.19
	helmet_mesh.height = 0.22

	helmet.mesh = helmet_mesh
	helmet.position = Vector3(0.0, 1.62, 0.0)
	helmet.material_override = armor

	unit.add_child(helmet)

	var left_arm := _make_limb(
		unit,
		Vector3(-0.27, 1.22, 0.0),
		uniform,
		0.075,
		0.48
	)

	var right_arm := _make_limb(
		unit,
		Vector3(0.27, 1.22, 0.0),
		uniform,
		0.075,
		0.48
	)

	var left_leg := _make_limb(
		unit,
		Vector3(-0.12, 0.62, 0.0),
		dark,
		0.09,
		0.58
	)

	var right_leg := _make_limb(
		unit,
		Vector3(0.12, 0.62, 0.0),
		dark,
		0.09,
		0.58
	)

	_mesh_box(
		unit,
		Vector3(0.38, 0.09, 0.29),
		Vector3(0.0, 0.72, 0.0),
		dark
	)

	_mesh_box(
		unit,
		Vector3(0.10, 0.12, 0.025),
		Vector3(0.0, 1.12, -0.17),
		skin
	)

	var row: int = index / 8
	var col: int = index % 8

	unit.position = Vector3(
		(float(col) - 3.5) * 0.72,
		0.0,
		float(row) * 0.78
	)

	unit.visible = false

	return {
		"node": unit,
		"la": left_arm,
		"ra": right_arm,
		"ll": left_leg,
		"rl": right_leg,
		"phase": float(index) * 0.55
	}


func _make_limb(
	parent: Node3D,
	pivot_position: Vector3,
	material: Material,
	radius: float,
	height: float
) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = pivot_position
	parent.add_child(pivot)

	var limb := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()

	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 8

	limb.mesh = mesh
	limb.position.y = -height * 0.36
	limb.material_override = material

	pivot.add_child(limb)

	return pivot


func _refresh_army() -> void:
	_set_squad_visibility(soldiers, army_count)


func _refresh_enemy() -> void:
	_set_squad_visibility(enemies, enemy_count)


func _set_squad_visibility(
	squad: Array[Dictionary],
	amount: int
) -> void:
	var shown: int = mini(amount, MAX_VISIBLE)

	for i in range(squad.size()):
		var row: int = i / 8
		var col: int = i % 8

		var node: Node3D = squad[i]["node"]

		node.visible = i < shown

		node.position = Vector3(
			(float(col) - 3.5) * 0.72,
			0.0,
			float(row) * 0.78
		)


func _animate_squad(
	squad: Array[Dictionary],
	clock: float,
	strength: float
) -> void:
	for unit in squad:
		var phase: float = unit["phase"]
		var swing: float = sin(clock * 10.0 + phase) * 0.62 * strength

		var left_arm: Node3D = unit["la"]
		var right_arm: Node3D = unit["ra"]
		var left_leg: Node3D = unit["ll"]
		var right_leg: Node3D = unit["rl"]

		left_arm.rotation.x = swing
		right_arm.rotation.x = -swing
		left_leg.rotation.x = -swing
		right_leg.rotation.x = swing


func _check_gates() -> void:
	for i in range(GATE_ZS.size()):
		if gate_used[i]:
			continue

		if absf(progress - absf(GATE_ZS[i])) < 0.65:
			if player_x < 0.0:
				army_count = mini(army_count + 10, 9999)
			else:
				army_count = mini(army_count * 2, 9999)

			gate_used[i] = true

			_refresh_army()
			_update_hud()

			hud_hint.text = "EXÉRCITO REFORÇADO!"


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)

	hud_level = Label.new()
	hud_level.position = Vector2(28.0, 26.0)
	hud_level.add_theme_font_size_override("font_size", 30)
	hud_level.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(hud_level)

	hud_count = Label.new()
	hud_count.position = Vector2(28.0, 72.0)
	hud_count.add_theme_font_size_override("font_size", 40)
	hud_count.add_theme_color_override(
		"font_color",
		Color(0.28, 0.72, 1.0)
	)
	root.add_child(hud_count)

	progress_bar = ProgressBar.new()
	progress_bar.position = Vector2(28.0, 128.0)
	progress_bar.size = Vector2(664.0, 16.0)
	progress_bar.max_value = 100.0
	progress_bar.show_percentage = false
	root.add_child(progress_bar)

	hud_hint = Label.new()
	hud_hint.position = Vector2(28.0, 158.0)
	hud_hint.add_theme_font_size_override("font_size", 18)
	hud_hint.add_theme_color_override(
		"font_color",
		Color(0.86, 0.92, 1.0)
	)
	hud_hint.text = "DESLIZE PARA ESCOLHER SEU PORTAL"
	root.add_child(hud_hint)

	result_panel = PanelContainer.new()
	result_panel.set_anchors_preset(Control.PRESET_CENTER)
	result_panel.position = Vector2(-260.0, -110.0)
	result_panel.size = Vector2(520.0, 220.0)
	result_panel.visible = false
	root.add_child(result_panel)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.055, 0.10, 0.94)
	panel_style.border_color = Color(0.18, 0.55, 0.95)
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(18)

	result_panel.add_theme_stylebox_override("panel", panel_style)

	var panel_box := VBoxContainer.new()
	panel_box.alignment = BoxContainer.ALIGNMENT_CENTER
	panel_box.add_theme_constant_override("separation", 14)
	result_panel.add_child(panel_box)

	result_label = Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 30)
	result_label.add_theme_color_override("font_color", Color.WHITE)
	panel_box.add_child(result_label)

	continue_button = Button.new()
	continue_button.text = "PRÓXIMA FASE"
	continue_button.custom_minimum_size = Vector2(300.0, 58.0)
	continue_button.add_theme_font_size_override("font_size", 22)
	continue_button.pressed.connect(_next_level)
	panel_box.add_child(continue_button)


func _update_hud() -> void:
	hud_level.text = "CLN ARMY  •  FASE %02d" % level
	hud_count.text = "TROPAS: %d" % army_count


func _start_battle() -> void:
	game_state = "battle"

	hud_hint.text = "BATALHA! SEU EXÉRCITO ESTÁ EM COMBATE"

	army_root.position.z = -progress
	enemy_root.position = Vector3(0.0, 0.0, ENEMY_Z)

	_refresh_army()
	_refresh_enemy()

	battle_timer = 0.0
	battle_start_player_z = army_root.position.z
	battle_start_enemy_z = enemy_root.position.z

	var won: bool = army_count >= enemy_count

	if won:
		result_label.text = "VITÓRIA!\nSeu exército dominou o campo."
	else:
		result_label.text = "DERROTA!\nReforce suas tropas e tente novamente."

	result_panel.visible = false


func _update_battle(delta: float) -> void:
	battle_timer += delta

	_animate_squad(soldiers, run_clock, 0.7)
	_animate_squad(enemies, run_clock + 0.7, 0.7)

	var t: float = minf(battle_timer / 2.8, 1.0)

	army_root.position.z = lerpf(
		battle_start_player_z,
		battle_start_player_z - 5.5,
		t
	)

	enemy_root.position.z = lerpf(
		battle_start_enemy_z,
		battle_start_enemy_z + 5.5,
		t
	)

	if battle_timer >= 3.2:
		result_panel.visible = true
		hud_hint.text = "CONFRONTO FINALIZADO"


func _next_level() -> void:
	level += 1

	army_count = START_ARMY + (level - 1) * 4
	enemy_count = 34 + (level - 1) * 9

	progress = 0.0
	player_x = 0.0
	target_x = 0.0

	gate_used = [false, false, false]
	game_state = "running"
	battle_timer = 0.0

	army_root.position = Vector3.ZERO
	enemy_root.position = Vector3(0.0, 0.0, ENEMY_Z)

	camera.position = Vector3(0.0, 10.5, 13.5)

	result_panel.visible = false
	hud_hint.text = "DESLIZE PARA ESCOLHER SEU PORTAL"

	progress_bar.value = 0.0

	_refresh_army()
	_refresh_enemy()
	_update_hud()
