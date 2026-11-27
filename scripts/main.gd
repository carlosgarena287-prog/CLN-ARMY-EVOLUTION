
extends Node3D

const MAX_VISIBLE_SOLDIERS := 160
const START_SOLDIERS := 12
const TRACK_LENGTH := 100.0
const GATE_ZS := [-20.0, -40.0, -60.0]
const ENEMY_Z := -86.0

var army_count: int = START_SOLDIERS
var enemy_count: int = 28
var player_x: float = 0.0
var target_x: float = 0.0
var progress: float = 0.0
var level: int = 1
var game_state: String = "running"
var gate_done: Array[bool] = [false, false, false]
var touch_active := false
var last_touch_x := 0.0

var army_multimesh: MultiMesh
var enemy_multimesh: MultiMesh
var army_instance: MultiMeshInstance3D
var enemy_instance: MultiMeshInstance3D

var hud_count: Label
var hud_level: Label
var message_label: Label
var progress_bar: ProgressBar
var restart_button: Button

func _ready() -> void:
	_setup_environment()
	_build_track()
	_build_gates()
	_build_armies()
	_build_hud()
	_update_army_visuals()
	_update_hud()

func _process(delta: float) -> void:
	if game_state != "running":
		return

	progress = minf(progress + 8.5 * delta, TRACK_LENGTH)
	player_x = move_toward(player_x, target_x, 10.0 * delta)

	army_instance.position.x = player_x
	army_instance.position.z = -progress

	_check_gates()
	progress_bar.value = progress / TRACK_LENGTH * 100.0

	if progress >= TRACK_LENGTH:
		_finish_battle()

func _input(event: InputEvent) -> void:
	if game_state != "running":
		return

	if event is InputEventScreenTouch:
		touch_active = event.pressed
		last_touch_x = event.position.x

	elif event is InputEventScreenDrag and touch_active:
		var dx: float = (event.position.x - last_touch_x) / 720.0 * 12.0
		target_x = clampf(target_x + dx, -5.0, 5.0)
		last_touch_x = event.position.x

	elif event is InputEventMouseButton:
		touch_active = event.pressed
		last_touch_x = event.position.x

	elif event is InputEventMouseMotion and touch_active:
		var dx_mouse: float = (event.position.x - last_touch_x) / 720.0 * 12.0
		target_x = clampf(target_x + dx_mouse, -5.0, 5.0)
		last_touch_x = event.position.x

func _setup_environment() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()

	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.48, 0.66, 0.82)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.75, 0.82, 0.95)
	env.ambient_light_energy = 0.8

	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	sun.light_energy = 1.15
	add_child(sun)

	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 8.5, 11.5)
	camera.rotation_degrees = Vector3(-25.0, 0.0, 0.0)
	camera.current = true
	add_child(camera)

func _material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.85
	return mat

func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()

	mesh.size = size
	node.mesh = mesh
	node.position = pos
	node.material_override = _material(color)

	parent.add_child(node)
	return node

func _build_track() -> void:
	_box(
		self,
		Vector3(13.0, 0.35, TRACK_LENGTH + 30.0),
		Vector3(0.0, -0.35, -TRACK_LENGTH * 0.48),
		Color(0.19, 0.25, 0.31)
	)

	for side in [-1.0, 1.0]:
		_box(
			self,
			Vector3(0.12, 0.025, TRACK_LENGTH + 25.0),
			Vector3(side * 6.15, -0.16, -TRACK_LENGTH * 0.48),
			Color(0.95, 0.83, 0.38)
		)

	for i in range(20):
		_box(
			self,
			Vector3(0.09, 0.025, 2.0),
			Vector3(0.0, -0.155, -float(i) * 5.0 - 3.0),
			Color(0.68, 0.73, 0.79)
		)

	for side in [-1.0, 1.0]:
		for i in range(12):
			_box(
				self,
				Vector3(0.55, 0.7, 0.55),
				Vector3(side * 7.2, 0.0, -float(i) * 9.0 - 4.0),
				Color(0.27, 0.43, 0.34)
			)

func _build_gates() -> void:
	for z in GATE_ZS:
		_make_gate(-3.0, z, "+5", Color(0.08, 0.55, 0.95))
		_make_gate(3.0, z, "×2", Color(0.12, 0.72, 0.42))

func _make_gate(x: float, z: float, text_value: String, color: Color) -> void:
	var gate := Node3D.new()
	gate.position = Vector3(x, 1.25, z)
	add_child(gate)

	_box(gate, Vector3(4.8, 2.5, 0.28), Vector3.ZERO, color)

	var label_3d := Label3D.new()
	label_3d.text = text_value
	label_3d.font_size = 96
	label_3d.pixel_size = 0.012
	label_3d.position = Vector3(0.0, 0.0, -0.18)
	label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED

	gate.add_child(label_3d)

func _build_armies() -> void:
	var blue_mesh := CapsuleMesh.new()
	blue_mesh.radius = 0.23
	blue_mesh.height = 0.95
	blue_mesh.radial_segments = 6
	blue_mesh.rings = 3

	army_multimesh = MultiMesh.new()
	army_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	army_multimesh.mesh = blue_mesh
	army_multimesh.instance_count = MAX_VISIBLE_SOLDIERS

	army_instance = MultiMeshInstance3D.new()
	army_instance.multimesh = army_multimesh
	army_instance.material_override = _material(Color(0.05, 0.38, 0.98))
	army_instance.position.y = 0.65

	add_child(army_instance)

	var red_mesh := CapsuleMesh.new()
	red_mesh.radius = 0.25
	red_mesh.height = 1.0
	red_mesh.radial_segments = 6
	red_mesh.rings = 3

	enemy_multimesh = MultiMesh.new()
	enemy_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	enemy_multimesh.mesh = red_mesh
	enemy_multimesh.instance_count = MAX_VISIBLE_SOLDIERS

	enemy_instance = MultiMeshInstance3D.new()
	enemy_instance.multimesh = enemy_multimesh
	enemy_instance.material_override = _material(Color(0.9, 0.12, 0.16))
	enemy_instance.position = Vector3(0.0, 0.65, ENEMY_Z)

	add_child(enemy_instance)
	_update_enemy_visuals()

func _update_army_visuals() -> void:
	var visible_count: int = mini(army_count, MAX_VISIBLE_SOLDIERS)

	for i in range(MAX_VISIBLE_SOLDIERS):
		var t := Transform3D.IDENTITY

		if i < visible_count:
			var row: int = i / 8
			var col: int = i % 8

			t.origin = Vector3(
				(float(col) - 3.5) * 0.62,
				0.0,
				float(row) * 0.72
			)
		else:
			t.origin = Vector3(0.0, -100.0, 0.0)

		army_multimesh.set_instance_transform(i, t)

func _update_enemy_visuals() -> void:
	for i in range(MAX_VISIBLE_SOLDIERS):
		var t := Transform3D.IDENTITY

		if i < mini(enemy_count, MAX_VISIBLE_SOLDIERS):
			var row: int = i / 8
			var col: int = i % 8

			t.origin = Vector3(
				(float(col) - 3.5) * 0.68,
				0.0,
				-float(row) * 0.8
			)
		else:
			t.origin = Vector3(0.0, -100.0, 0.0)

		enemy_multimesh.set_instance_transform(i, t)

func _check_gates() -> void:
	for i in range(GATE_ZS.size()):
		if gate_done[i]:
			continue

		if absf(progress - absf(GATE_ZS[i])) < 0.55:
			if player_x < 0.0:
				army_count += 5
			else:
				army_count = mini(army_count * 2, 9999)

			gate_done[i] = true
			_update_army_visuals()
			_update_hud()

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)

	hud_level = Label.new()
	hud_level.position = Vector2(24.0, 28.0)
	hud_level.add_theme_font_size_override("font_size", 30)
	hud_level.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(hud_level)

	hud_count = Label.new()
	hud_count.position = Vector2(24.0, 76.0)
	hud_count.add_theme_font_size_override("font_size", 38)
	hud_count.add_theme_color_override("font_color", Color(0.35, 0.75, 1.0))
	root.add_child(hud_count)

	progress_bar = ProgressBar.new()
	progress_bar.position = Vector2(24.0, 132.0)
	progress_bar.size = Vector2(672.0, 18.0)
	progress_bar.max_value = 100.0
	progress_bar.show_percentage = false
	root.add_child(progress_bar)

	message_label = Label.new()
	message_label.anchor_left = 0.5
	message_label.anchor_top = 0.5
	message_label.anchor_right = 0.5
	message_label.anchor_bottom = 0.5
	message_label.offset_left = -310.0
	message_label.offset_top = -70.0
	message_label.offset_right = 310.0
	message_label.offset_bottom = 10.0
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 34)
	message_label.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(message_label)

	restart_button = Button.new()
	restart_button.text = "JOGAR NOVAMENTE"
	restart_button.position = Vector2(180.0, 790.0)
	restart_button.size = Vector2(360.0, 76.0)
	restart_button.add_theme_font_size_override("font_size", 26)
	restart_button.visible = false
	restart_button.pressed.connect(_restart_level)
	root.add_child(restart_button)

func _update_hud() -> void:
	hud_level.text = "FASE %d" % level
	hud_count.text = "EXÉRCITO: %d" % army_count

func _finish_battle() -> void:
	game_state = "battle"

	if army_count > enemy_count:
		message_label.text = "VITÓRIA!\nSeu exército venceu!"
		message_label.add_theme_color_override(
			"font_color",
			Color(0.45, 1.0, 0.55)
		)
	else:
		message_label.text = "QUASE LÁ!\nFortaleça seu exército!"
		message_label.add_theme_color_override(
			"font_color",
			Color(1.0, 0.75, 0.35)
		)

	restart_button.visible = true

func _restart_level() -> void:
	level += 1
	army_count = START_SOLDIERS + (level - 1) * 3
	enemy_count = 28 + (level - 1) * 7

	progress = 0.0
	player_x = 0.0
	target_x = 0.0
	gate_done = [false, false, false]
	game_state = "running"

	army_instance.position = Vector3(0.0, 0.65, 0.0)
	message_label.text = ""
	restart_button.visible = false

	_update_enemy_visuals()
	_update_army_visuals()
	_update_hud()
