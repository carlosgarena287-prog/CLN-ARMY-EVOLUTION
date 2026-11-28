extends Node3D

const START_ARMY: int = 12
const MAX_VISIBLE: int = 80
const TRACK_LENGTH: float = 112.0
const GATE_ZS: Array[float] = [-22.0, -48.0, -74.0]
const ENEMY_Z: float = -126.0
const MAX_ARMY: int = 9999

const COLS: int = 10
const SPACING_X: float = 0.68
const SPACING_Z: float = 0.66
const BRIDGE_HALF: float = 5.2
const GATE_X: float = 2.6
const PLAYER_BULLETS: int = 48
const ENEMY_BULLETS: int = 32
const MAX_SPARKS: int = 24
const CAM_HEIGHT: float = 8.4
const CAM_BACK: float = 11.0

# ---------------------------------------------------------------
# MAPAS (um por fase, repetem em ciclo)
# ---------------------------------------------------------------
var THEMES: Array[Dictionary] = [
	{
		"name": "VULCÃO",
		"sky_top": Color(0.20, 0.10, 0.24), "sky_hor": Color(0.85, 0.38, 0.18),
		"fog": Color(0.80, 0.38, 0.20), "fog_d": 0.0025,
		"sun": Color(1.0, 0.93, 0.82), "sun_e": 0.85, "amb": Color(0.75, 0.70, 0.80), "amb_e": 0.45,
		"stone": Color(0.40, 0.41, 0.47), "seam": Color(0.26, 0.27, 0.32),
		"rail": Color(0.22, 0.24, 0.30), "rail_top": Color(0.55, 0.57, 0.64),
		"l_col": Color(0.35, 0.05, 0.0), "l_emi": Color(1.0, 0.28, 0.03), "l_en": 0.9,
		"r_col": Color(0.02, 0.18, 0.45), "r_emi": Color(0.05, 0.30, 0.80), "r_en": 0.35,
		"deco": Color(0.18, 0.12, 0.12),
		"ember_l": Color(1.0, 0.55, 0.1), "ember_r": Color(0.6, 0.9, 1.0), "ember_g": 0.5, "ember_y": -0.8,
		"enemy": Color(0.80, 0.12, 0.10), "enemy_l": Color(1.0, 0.45, 0.20),
		"boss_body": Color(0.55, 0.08, 0.06), "boss_skin": Color(0.95, 0.45, 0.18)
	},
	{
		"name": "GELO",
		"sky_top": Color(0.30, 0.50, 0.85), "sky_hor": Color(0.80, 0.92, 1.0),
		"fog": Color(0.70, 0.85, 1.0), "fog_d": 0.0035,
		"sun": Color(0.90, 0.95, 1.0), "sun_e": 0.8, "amb": Color(0.70, 0.80, 0.95), "amb_e": 0.55,
		"stone": Color(0.50, 0.62, 0.75), "seam": Color(0.36, 0.48, 0.62),
		"rail": Color(0.30, 0.45, 0.62), "rail_top": Color(0.85, 0.93, 1.0),
		"l_col": Color(0.03, 0.22, 0.45), "l_emi": Color(0.10, 0.45, 0.85), "l_en": 0.45,
		"r_col": Color(0.70, 0.80, 0.92), "r_emi": Color(0.55, 0.70, 0.90), "r_en": 0.25,
		"deco": Color(0.60, 0.80, 0.95),
		"ember_l": Color(1.0, 1.0, 1.0), "ember_r": Color(0.85, 0.95, 1.0), "ember_g": -1.2, "ember_y": 9.0,
		"enemy": Color(0.35, 0.18, 0.65), "enemy_l": Color(0.70, 0.55, 1.0),
		"boss_body": Color(0.25, 0.45, 0.80), "boss_skin": Color(0.70, 0.90, 1.0)
	},
	{
		"name": "DESERTO",
		"sky_top": Color(0.25, 0.45, 0.80), "sky_hor": Color(1.0, 0.78, 0.48),
		"fog": Color(0.95, 0.75, 0.50), "fog_d": 0.003,
		"sun": Color(1.0, 0.90, 0.72), "sun_e": 0.95, "amb": Color(0.90, 0.80, 0.70), "amb_e": 0.50,
		"stone": Color(0.60, 0.48, 0.33), "seam": Color(0.42, 0.32, 0.22),
		"rail": Color(0.45, 0.33, 0.22), "rail_top": Color(0.80, 0.66, 0.45),
		"l_col": Color(0.78, 0.58, 0.28), "l_emi": Color(0.60, 0.40, 0.15), "l_en": 0.15,
		"r_col": Color(0.05, 0.40, 0.45), "r_emi": Color(0.05, 0.45, 0.50), "r_en": 0.3,
		"deco": Color(0.70, 0.50, 0.25),
		"ember_l": Color(0.95, 0.80, 0.45), "ember_r": Color(0.95, 0.80, 0.45), "ember_g": 0.2, "ember_y": 0.5,
		"enemy": Color(0.45, 0.28, 0.12), "enemy_l": Color(0.90, 0.65, 0.25),
		"boss_body": Color(0.45, 0.30, 0.12), "boss_skin": Color(0.85, 0.65, 0.30)
	},
	{
		"name": "NEON",
		"sky_top": Color(0.03, 0.02, 0.10), "sky_hor": Color(0.50, 0.10, 0.60),
		"fog": Color(0.25, 0.05, 0.35), "fog_d": 0.004,
		"sun": Color(0.75, 0.70, 1.0), "sun_e": 0.7, "amb": Color(0.50, 0.40, 0.75), "amb_e": 0.55,
		"stone": Color(0.16, 0.16, 0.27), "seam": Color(0.30, 0.10, 0.45),
		"rail": Color(0.10, 0.10, 0.20), "rail_top": Color(0.20, 0.85, 0.95),
		"l_col": Color(0.30, 0.0, 0.40), "l_emi": Color(0.90, 0.10, 0.90), "l_en": 1.0,
		"r_col": Color(0.0, 0.25, 0.35), "r_emi": Color(0.0, 0.85, 0.95), "r_en": 0.9,
		"deco": Color(0.12, 0.08, 0.25),
		"ember_l": Color(1.0, 0.3, 0.9), "ember_r": Color(0.3, 1.0, 1.0), "ember_g": 0.6, "ember_y": -0.8,
		"enemy": Color(0.10, 0.55, 0.20), "enemy_l": Color(0.55, 1.0, 0.35),
		"boss_body": Color(0.10, 0.40, 0.18), "boss_skin": Color(0.60, 1.0, 0.30)
	}
]

# ---------------------------------------------------------------
# ARMAS
# ---------------------------------------------------------------
var WEAPONS: Array[Dictionary] = [
	{"name": "PISTOLA", "color": Color(1.0, 0.90, 0.20), "rate": 14.0, "mult": 1.0, "speed": 48.0, "w": 1.0, "l": 1.0},
	{"name": "RIFLE", "color": Color(1.0, 0.35, 0.80), "rate": 28.0, "mult": 1.15, "speed": 56.0, "w": 0.8, "l": 1.0},
	{"name": "LASER", "color": Color(0.30, 1.0, 1.0), "rate": 20.0, "mult": 1.35, "speed": 70.0, "w": 0.6, "l": 2.4},
	{"name": "MÍSSIL", "color": Color(1.0, 0.50, 0.10), "rate": 6.0, "mult": 1.7, "speed": 36.0, "w": 3.2, "l": 1.6}
]

var army_count: int = START_ARMY
var enemy_count: int = 34
var level: int = 1
var weapon_idx: int = 0

var progress: float = 0.0
var player_x: float = 0.0
var target_x: float = 0.0

var game_state: String = "running"
var gate_used: Array[bool] = [false, false, false]
var gate_defs: Array[Dictionary] = []

var run_clock: float = 0.0
var battle_timer: float = 0.0
var shoot_timer: float = 0.0
var enemy_shoot_timer: float = 0.0
var pop_timer: float = 0.0

var enemy_acc: float = 0.0
var army_acc: float = 0.0
var enemy_lost_pop: int = 0
var army_lost_pop: int = 0

var touch_down: bool = false
var last_pointer_x: float = 0.0

var env: Environment
var sky_material: ProceduralSkyMaterial
var sun: DirectionalLight3D

var army_root: Node3D
var enemy_root: Node3D
var boss_root: Node3D
var track_root: Node3D
var gate_root: Node3D
var camera: Camera3D

var army_label: Label3D
var enemy_label: Label3D

var soldiers: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var bullets: Array[Dictionary] = []
var sparks: Array[Dictionary] = []
var embers: Array[CPUParticles3D] = []

var weapon_mats: Array[StandardMaterial3D] = []
var enemy_bullet_mat: StandardMaterial3D

var left_mat: StandardMaterial3D
var right_mat: StandardMaterial3D
var l_energy_base: float = 0.9
var ember_y: float = -0.8

var mat_blue: StandardMaterial3D
var mat_blue_light: StandardMaterial3D
var mat_red: StandardMaterial3D
var mat_red_light: StandardMaterial3D
var mat_skin: StandardMaterial3D
var mat_dark: StandardMaterial3D

var hud_level: Label
var hud_count: Label
var hud_enemy: Label
var hud_hint: Label
var progress_bar: ProgressBar
var weapon_button: Button

var result_panel: PanelContainer
var result_label: Label
var continue_button: Button
var retry_button: Button


func _ready() -> void:
	_build_world()
	_build_armies()
	_build_bullets()
	_build_sparks()
	_build_embers()
	_build_labels()
	_build_hud()

	_start_level_visuals()

	_refresh_army()
	_refresh_enemy()
	_update_hud()


func _theme() -> Dictionary:
	return THEMES[(level - 1) % THEMES.size()]


func _boss_count() -> int:
	if level % 3 == 0:
		return 3
	if level % 2 == 0:
		return 2
	return 1


func _start_level_visuals() -> void:
	_apply_theme()
	_build_gates()
	_build_bosses()


func _apply_theme() -> void:
	var t: Dictionary = _theme()

	sky_material.sky_top_color = t["sky_top"]
	sky_material.sky_horizon_color = t["sky_hor"]
	sky_material.ground_bottom_color = t["sky_top"]
	sky_material.ground_horizon_color = t["sky_hor"]

	env.fog_light_color = t["fog"]
	env.fog_density = float(t["fog_d"])
	env.ambient_light_color = t["amb"]
	env.ambient_light_energy = float(t["amb_e"])

	sun.light_color = t["sun"]
	sun.light_energy = float(t["sun_e"])

	mat_red.albedo_color = t["enemy"]
	mat_red_light.albedo_color = t["enemy_l"]

	ember_y = float(t["ember_y"])

	for i in range(embers.size()):
		var p: CPUParticles3D = embers[i]
		var m := p.material_override as StandardMaterial3D
		m.albedo_color = t["ember_l"] if i == 0 else t["ember_r"]
		p.gravity = Vector3(0.0, float(t["ember_g"]), 0.0)

	_build_track()


func _process(delta: float) -> void:
	run_clock += delta

	left_mat.emission_energy_multiplier = l_energy_base * (1.0 + sin(run_clock * 2.0) * 0.2)
	boss_root.position.y = sin(run_clock * 3.0) * 0.12

	match game_state:
		"running":
			_update_running(delta)
		"battle":
			_update_battle(delta)

	if game_state == "running" or game_state == "battle":
		var w: Dictionary = WEAPONS[weapon_idx]
		var interval: float = 1.0 / float(w["rate"])

		shoot_timer -= delta

		while shoot_timer <= 0.0:
			shoot_timer += interval
			_shoot()

	_update_bullets(delta)
	_update_sparks(delta)

	for i in range(embers.size()):
		var side: float = -1.0 if i == 0 else 1.0
		embers[i].position = Vector3(
			side * (BRIDGE_HALF + 14.0),
			ember_y,
			army_root.position.z - 15.0
		)


func _update_running(delta: float) -> void:
	progress = minf(progress + 11.0 * delta, TRACK_LENGTH)

	player_x = move_toward(player_x, target_x, 13.0 * delta)

	army_root.position = Vector3(player_x, 0.0, -progress)

	_place_camera()

	_animate_squad(soldiers, run_clock, 1.0)

	_check_gates()

	progress_bar.value = progress / TRACK_LENGTH * 100.0

	if progress >= TRACK_LENGTH:
		_start_battle()


func _place_camera() -> void:
	camera.position = Vector3(
		player_x * 0.28,
		CAM_HEIGHT,
		-progress + CAM_BACK
	)

	camera.look_at(
		Vector3(player_x * 0.18, 0.8, -progress - 14.0),
		Vector3.UP
	)


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
		-4.2,
		4.2
	)


# ---------------------------------------------------------------
# MUNDO
# ---------------------------------------------------------------
func _build_world() -> void:
	var world := WorldEnvironment.new()
	env = Environment.new()

	env.background_mode = Environment.BG_SKY

	var sky := Sky.new()
	sky_material = ProceduralSkyMaterial.new()
	sky.sky_material = sky_material
	env.sky = sky

	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 0.85

	env.fog_enabled = true

	env.glow_enabled = true
	env.glow_intensity = 0.8
	env.glow_bloom = 0.15
	env.glow_hdr_threshold = 0.9

	get_viewport().msaa_3d = Viewport.MSAA_4X

	world.environment = env
	add_child(world)

	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50.0, -25.0, 0.0)
	sun.shadow_enabled = false
	add_child(sun)

	camera = Camera3D.new()
	camera.fov = 60.0
	camera.current = true
	add_child(camera)

	_place_camera()


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


func _mesh_sphere(
	parent: Node3D,
	radius: float,
	pos: Vector3,
	material: Material
) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := SphereMesh.new()

	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 16
	mesh.rings = 8

	node.mesh = mesh
	node.position = pos
	node.material_override = material

	parent.add_child(node)
	return node


func _mesh_capsule(
	parent: Node3D,
	radius: float,
	height: float,
	pos: Vector3,
	material: Material
) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()

	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 16

	node.mesh = mesh
	node.position = pos
	node.material_override = material

	parent.add_child(node)
	return node


func _mesh_cone(
	parent: Node3D,
	radius: float,
	height: float,
	pos: Vector3,
	material: Material
) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := CylinderMesh.new()

	mesh.top_radius = 0.0
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8

	node.mesh = mesh
	node.position = pos
	node.material_override = material

	parent.add_child(node)
	return node


func _build_track() -> void:
	if track_root != null:
		track_root.queue_free()

	track_root = Node3D.new()
	add_child(track_root)

	var t: Dictionary = _theme()

	var stone := _mat(t["stone"], 0.0, 0.9)
	var seam := _mat(t["seam"], 0.0, 0.9)
	var rail := _mat(t["rail"], 0.2, 0.6)
	var rail_top := _mat(t["rail_top"], 0.1, 0.5)
	var deco := _mat(t["deco"], 0.1, 0.7)

	left_mat = _mat(t["l_col"], 0.0, 0.6)
	left_mat.emission_enabled = true
	left_mat.emission = t["l_emi"]
	left_mat.emission_energy_multiplier = float(t["l_en"])
	l_energy_base = float(t["l_en"])

	right_mat = _mat(t["r_col"], 0.0, 0.2)
	right_mat.emission_enabled = true
	right_mat.emission = t["r_emi"]
	right_mat.emission_energy_multiplier = float(t["r_en"])

	var length: float = TRACK_LENGTH + 45.0
	var center_z: float = -TRACK_LENGTH * 0.48

	_mesh_box(
		track_root,
		Vector3(BRIDGE_HALF * 2.0, 0.6, length),
		Vector3(0.0, -0.3, center_z),
		stone
	)

	_mesh_box(
		track_root,
		Vector3(60.0, 0.3, length + 40.0),
		Vector3(-(BRIDGE_HALF + 30.0), -1.2, center_z),
		left_mat
	)

	_mesh_box(
		track_root,
		Vector3(60.0, 0.3, length + 40.0),
		Vector3(BRIDGE_HALF + 30.0, -1.2, center_z),
		right_mat
	)

	for i in range(30):
		_mesh_box(
			track_root,
			Vector3(BRIDGE_HALF * 2.0, 0.02, 0.1),
			Vector3(0.0, 0.012, 10.0 - float(i) * 5.5),
			seam
		)

	for side in [-1.0, 1.0]:
		var rail_x: float = side * (BRIDGE_HALF + 0.15)

		_mesh_box(
			track_root,
			Vector3(0.3, 0.5, length),
			Vector3(rail_x, 0.25, center_z),
			rail
		)

		_mesh_box(
			track_root,
			Vector3(0.42, 0.08, length),
			Vector3(rail_x, 0.54, center_z),
			rail_top
		)

		for i in range(36):
			_mesh_box(
				track_root,
				Vector3(0.36, 0.9, 0.36),
				Vector3(rail_x, 0.45, 8.0 - float(i) * 4.0),
				rail_top
			)

	# Pedras / blocos de decoração saindo do líquido
	for i in range(26):
		for side in [-1.0, 1.0]:
			var k: float = float(i) * 2.399 + (0.0 if side < 0.0 else 1.7)
			var dx: float = BRIDGE_HALF + 4.0 + absf(sin(k * 3.1)) * 14.0
			var sz: float = 1.2 + absf(cos(k * 1.7)) * 2.2
			var h: float = 2.0 + absf(sin(k * 2.3)) * 5.0

			var block := _mesh_box(
				track_root,
				Vector3(sz, h, sz),
				Vector3(side * dx, h * 0.5 - 1.2, 10.0 - float(i) * 6.2),
				deco
			)
			block.rotation.y = k


# ---------------------------------------------------------------
# PORTAIS (contas e armas)
# ---------------------------------------------------------------
func _build_gates() -> void:
	if gate_root != null:
		gate_root.queue_free()

	gate_root = Node3D.new()
	add_child(gate_root)

	var add1: int = 10 + 4 * (level - 1)
	var add2: int = 15 + 4 * (level - 1)
	var wa: int = level % WEAPONS.size()
	var wb: int = (level + 2) % WEAPONS.size()

	var blue := Color(0.05, 0.43, 1.0)
	var teal := Color(0.0, 0.78, 0.75)

	gate_defs = [
		{
			"l": {"kind": "add", "value": add1, "caption": "+%d" % add1, "color": blue},
			"r": {"kind": "mul", "value": 2, "caption": "×2", "color": teal}
		},
		{
			"l": {"kind": "weapon", "value": wa, "caption": str(WEAPONS[wa]["name"]), "color": WEAPONS[wa]["color"]},
			"r": {"kind": "weapon", "value": wb, "caption": str(WEAPONS[wb]["name"]), "color": WEAPONS[wb]["color"]}
		},
		{
			"l": {"kind": "add", "value": add2, "caption": "+%d" % add2, "color": blue},
			"r": {"kind": "mul", "value": 2, "caption": "×2", "color": teal}
		}
	]

	for i in range(GATE_ZS.size()):
		var l: Dictionary = gate_defs[i]["l"]
		var r: Dictionary = gate_defs[i]["r"]

		_make_gate(-GATE_X, GATE_ZS[i], str(l["caption"]), l["color"])
		_make_gate(GATE_X, GATE_ZS[i], str(r["caption"]), r["color"])


func _make_gate(
	x: float,
	z: float,
	caption: String,
	tint: Color
) -> void:
	var gate := Node3D.new()
	gate.position = Vector3(x, 1.45, z)
	gate_root.add_child(gate)

	var glow := _mat(Color(tint.r, tint.g, tint.b, 0.28), 0.1, 0.25)
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.emission_enabled = true
	glow.emission = tint
	glow.emission_energy_multiplier = 0.5

	_mesh_box(gate, Vector3(4.2, 2.8, 0.2), Vector3.ZERO, glow)

	var frame_material := _mat(tint, 0.2, 0.3)
	frame_material.emission_enabled = true
	frame_material.emission = tint
	frame_material.emission_energy_multiplier = 0.9

	_mesh_box(gate, Vector3(0.18, 3.0, 0.3), Vector3(-2.1, 0.0, 0.0), frame_material)
	_mesh_box(gate, Vector3(0.18, 3.0, 0.3), Vector3(2.1, 0.0, 0.0), frame_material)
	_mesh_box(gate, Vector3(4.35, 0.18, 0.3), Vector3(0.0, 1.48, 0.0), frame_material)

	var label := Label3D.new()
	label.text = caption
	label.font_size = 120 if caption.length() <= 4 else 80
	label.pixel_size = 0.009
	label.position = Vector3(0.0, 0.0, -0.19)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color.WHITE
	label.outline_size = 18
	label.outline_modulate = Color(0.0, 0.1, 0.25)

	gate.add_child(label)


func _check_gates() -> void:
	for i in range(GATE_ZS.size()):
		if gate_used[i]:
			continue

		if progress < absf(GATE_ZS[i]):
			continue

		gate_used[i] = true

		var side: String = "l" if player_x < 0.0 else "r"
		var g: Dictionary = gate_defs[i][side]
		var kind: String = g["kind"]
		var value: int = g["value"]
		var pop_color: Color = g["color"]

		if kind == "add":
			army_count = mini(army_count + value, MAX_ARMY)
			hud_hint.text = "PORTAL +%d: SOLDADOS ADICIONADOS!" % value
		elif kind == "mul":
			army_count = mini(army_count * value, MAX_ARMY)
			hud_hint.text = "PORTAL ×%d: EXÉRCITO MULTIPLICADO!" % value
		else:
			weapon_idx = value
			hud_hint.text = "NOVA ARMA: %s!" % str(WEAPONS[value]["name"])

		_spawn_pop(
			Vector3(player_x, 3.6, -progress - 7.0),
			str(g["caption"]),
			pop_color.lightened(0.35)
		)

		_refresh_army()
		_update_hud()


# ---------------------------------------------------------------
# EXÉRCITOS
# ---------------------------------------------------------------
func _build_armies() -> void:
	mat_blue = _mat(Color(0.10, 0.36, 0.95), 0.0, 0.45)
	mat_blue_light = _mat(Color(0.35, 0.75, 1.0), 0.0, 0.35)
	mat_red = _mat(Color(0.80, 0.12, 0.10), 0.0, 0.45)
	mat_red_light = _mat(Color(1.0, 0.45, 0.20), 0.0, 0.35)
	mat_skin = _mat(Color(1.0, 0.80, 0.65), 0.0, 0.6)
	mat_dark = _mat(Color(0.08, 0.09, 0.14), 0.0, 0.65)

	army_root = Node3D.new()
	add_child(army_root)

	enemy_root = Node3D.new()
	enemy_root.position = Vector3(0.0, 0.0, ENEMY_Z)
	add_child(enemy_root)

	boss_root = Node3D.new()
	boss_root.position = Vector3(0.0, 0.0, -6.5)
	enemy_root.add_child(boss_root)

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

	var uniform: Material = mat_red if enemy else mat_blue
	var armor: Material = mat_red_light if enemy else mat_blue_light

	# Estilo "chibi": cabeça grande, corpo pequeno, olhões
	_mesh_capsule(unit, 0.24, 0.62, Vector3(0.0, 0.62, 0.0), uniform)
	_mesh_sphere(unit, 0.34, Vector3(0.0, 1.18, 0.0), mat_skin)

	var helmet := _mesh_sphere(unit, 0.37, Vector3(0.0, 1.27, 0.0), armor)
	helmet.scale = Vector3(1.0, 0.62, 1.0)

	_mesh_sphere(unit, 0.065, Vector3(-0.13, 1.16, -0.30), mat_dark)
	_mesh_sphere(unit, 0.065, Vector3(0.13, 1.16, -0.30), mat_dark)

	if enemy:
		_mesh_cone(unit, 0.09, 0.30, Vector3(0.0, 1.60, 0.0), mat_dark)

	var left_arm := _make_limb(unit, Vector3(-0.30, 0.88, 0.0), uniform, 0.08, 0.42)
	var right_arm := _make_limb(unit, Vector3(0.30, 0.88, 0.0), uniform, 0.08, 0.42)

	# Arminha na mão direita
	_mesh_box(right_arm, Vector3(0.07, 0.07, 0.38), Vector3(0.0, -0.22, -0.2), mat_dark)

	var left_leg := _make_limb(unit, Vector3(-0.11, 0.38, 0.0), mat_dark, 0.10, 0.40)
	var right_leg := _make_limb(unit, Vector3(0.11, 0.38, 0.0), mat_dark, 0.10, 0.40)

	if enemy:
		unit.rotation.y = PI

	unit.position = _slot(index, enemy)
	unit.visible = false

	return {
		"node": unit,
		"la": left_arm,
		"ra": right_arm,
		"ll": left_leg,
		"rl": right_leg,
		"phase": float(index) * 0.55
	}


func _slot(i: int, enemy: bool) -> Vector3:
	var row: int = i / COLS
	var col: int = i % COLS

	var jitter_x: float = sin(float(i) * 12.9898) * 0.07
	var jitter_z: float = cos(float(i) * 7.233) * 0.07

	var z: float = float(row) * SPACING_Z

	if enemy:
		z = -z

	return Vector3(
		(float(col) - float(COLS - 1) * 0.5) * SPACING_X + jitter_x,
		0.0,
		z + jitter_z
	)


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


# ---------------------------------------------------------------
# BOSSES (1, 2 ou 3 conforme a fase)
# ---------------------------------------------------------------
func _build_bosses() -> void:
	for ch in boss_root.get_children():
		ch.queue_free()

	var t: Dictionary = _theme()
	var count: int = _boss_count()

	var s: float = minf(1.0 + float(level - 1) * 0.06, 1.6)

	if count == 2:
		s = 0.85
	elif count == 3:
		s = 0.65

	for k in range(count):
		var x: float = 0.0
		var z: float = 0.0

		if count == 2:
			x = (float(k) - 0.5) * 4.8
		elif count == 3:
			x = (float(k) - 1.0) * 3.8
			z = -1.5 if k == 1 else 0.0

		var boss := Node3D.new()
		boss.position = Vector3(x, 0.0, z)
		boss.scale = Vector3(s, s, s)
		boss_root.add_child(boss)

		_make_boss(boss, t["boss_body"], t["boss_skin"])

	enemy_label.position = Vector3(0.0, 6.4 * s + 1.2, -6.5)


func _make_boss(boss: Node3D, body_color: Color, skin_color: Color) -> void:
	var body_mat := _mat(body_color, 0.0, 0.5)
	var skin_mat := _mat(skin_color, 0.0, 0.5)
	var dark_mat := _mat(Color(0.12, 0.06, 0.06), 0.0, 0.7)
	var white_mat := _mat(Color(1.0, 1.0, 1.0), 0.0, 0.4)

	_mesh_capsule(boss, 1.3, 3.8, Vector3(0.0, 2.4, 0.0), body_mat)
	_mesh_box(boss, Vector3(2.7, 0.35, 1.9), Vector3(0.0, 1.5, 0.0), dark_mat)
	_mesh_sphere(boss, 0.95, Vector3(0.0, 4.9, 0.0), skin_mat)
	_mesh_box(boss, Vector3(1.3, 0.18, 0.2), Vector3(0.0, 5.2, 0.9), dark_mat)

	for side in [-1.0, 1.0]:
		_mesh_cone(boss, 0.28, 1.1, Vector3(side * 0.6, 5.8, 0.0), dark_mat)
		_mesh_sphere(boss, 0.8, Vector3(side * 1.5, 3.7, 0.0), body_mat)
		_mesh_cone(boss, 0.3, 0.9, Vector3(side * 1.6, 4.4, 0.0), dark_mat)
		_mesh_sphere(boss, 0.7, Vector3(side * 1.95, 2.2, 0.35), skin_mat)
		_mesh_sphere(boss, 0.2, Vector3(side * 0.38, 5.0, 0.85), white_mat)
		_mesh_sphere(boss, 0.09, Vector3(side * 0.38, 5.0, 1.03), dark_mat)


# ---------------------------------------------------------------
# TIROS / EFEITOS
# ---------------------------------------------------------------
func _build_bullets() -> void:
	for w in WEAPONS:
		var m := StandardMaterial3D.new()
		m.albedo_color = w["color"]
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		weapon_mats.append(m)

	enemy_bullet_mat = StandardMaterial3D.new()
	enemy_bullet_mat.albedo_color = Color(1.0, 0.20, 0.10)
	enemy_bullet_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.10, 0.10, 0.9)

	for i in range(PLAYER_BULLETS + ENEMY_BULLETS):
		var node := MeshInstance3D.new()
		node.mesh = mesh
		node.material_override = weapon_mats[0] if i < PLAYER_BULLETS else enemy_bullet_mat
		node.visible = false
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(node)

		bullets.append({
			"node": node,
			"life": 0.0,
			"dmg": 0.0,
			"spd": 40.0
		})


func _shoot() -> void:
	var shown: int = mini(army_count, MAX_VISIBLE)

	if shown <= 0:
		return

	var w: Dictionary = WEAPONS[weapon_idx]

	for i in range(PLAYER_BULLETS):
		var b: Dictionary = bullets[i]
		var life: float = b["life"]

		if life > 0.0:
			continue

		var src: Dictionary = soldiers[randi() % shown]
		var unit: Node3D = src["node"]
		var node: MeshInstance3D = b["node"]

		node.position = army_root.position + unit.position + Vector3(0.3, 0.7, -0.6)
		node.material_override = weapon_mats[weapon_idx]
		node.scale = Vector3(float(w["w"]), float(w["w"]), float(w["l"]))
		node.visible = true

		b["life"] = 1.0
		b["spd"] = float(w["speed"])
		b["dmg"] = float(army_count) * 0.55 * float(w["mult"]) / float(w["rate"])
		return


func _enemy_shoot() -> void:
	var shown: int = mini(enemy_count, MAX_VISIBLE)

	if shown <= 0:
		return

	for i in range(PLAYER_BULLETS, bullets.size()):
		var b: Dictionary = bullets[i]
		var life: float = b["life"]

		if life > 0.0:
			continue

		var src: Dictionary = enemies[randi() % shown]
		var unit: Node3D = src["node"]
		var node: MeshInstance3D = b["node"]

		node.position = enemy_root.position + unit.position + Vector3(-0.3, 0.7, 0.6)
		node.visible = true

		b["life"] = 1.6
		b["spd"] = 40.0
		b["dmg"] = float(enemy_count) * 0.0179
		return


func _update_bullets(delta: float) -> void:
	for i in range(bullets.size()):
		var b: Dictionary = bullets[i]
		var life: float = b["life"]

		if life <= 0.0:
			continue

		life -= delta

		var node: MeshInstance3D = b["node"]
		var spd: float = b["spd"]

		if i < PLAYER_BULLETS:
			node.position.z -= spd * delta

			if game_state == "battle" and enemy_count > 0 and node.position.z <= enemy_root.position.z + 0.3:
				_hit_enemy(float(b["dmg"]), node.position)
				life = 0.0
		else:
			node.position.z += spd * delta

			if game_state == "battle" and army_count > 0 and node.position.z >= army_root.position.z - 0.3:
				_hit_army(float(b["dmg"]), node.position)
				life = 0.0

		b["life"] = maxf(life, 0.0)

		if life <= 0.0:
			node.visible = false


func _hit_enemy(dmg: float, pos: Vector3) -> void:
	_spark(pos)

	enemy_acc += dmg
	var n: int = int(enemy_acc)

	if n > 0:
		enemy_acc -= float(n)
		enemy_count = maxi(0, enemy_count - n)
		enemy_lost_pop += n
		_refresh_enemy()
		_update_hud()


func _hit_army(dmg: float, pos: Vector3) -> void:
	_spark(pos)

	army_acc += dmg
	var n: int = int(army_acc)

	if n > 0:
		army_acc -= float(n)
		army_count = maxi(0, army_count - n)
		army_lost_pop += n
		_refresh_army()
		_update_hud()


func _build_sparks() -> void:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(1.0, 0.8, 0.3)
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	var mesh := SphereMesh.new()
	mesh.radius = 0.25
	mesh.height = 0.5
	mesh.radial_segments = 8
	mesh.rings = 4

	for i in range(MAX_SPARKS):
		var node := MeshInstance3D.new()
		node.mesh = mesh
		node.material_override = m
		node.visible = false
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(node)

		sparks.append({"node": node, "life": 0.0})


func _spark(pos: Vector3) -> void:
	for sp in sparks:
		var life: float = sp["life"]

		if life > 0.0:
			continue

		var node: MeshInstance3D = sp["node"]
		node.position = pos
		node.scale = Vector3(0.5, 0.5, 0.5)
		node.visible = true
		sp["life"] = 0.18
		return


func _update_sparks(delta: float) -> void:
	for sp in sparks:
		var life: float = sp["life"]

		if life <= 0.0:
			continue

		life -= delta
		sp["life"] = maxf(life, 0.0)

		var node: MeshInstance3D = sp["node"]
		var k: float = 1.0 - clampf(life / 0.18, 0.0, 1.0)
		var sc: float = 0.5 + k * 1.5
		node.scale = Vector3(sc, sc, sc)

		if life <= 0.0:
			node.visible = false


func _clear_fx() -> void:
	for b in bullets:
		b["life"] = 0.0
		var node: MeshInstance3D = b["node"]
		node.visible = false

	for sp in sparks:
		sp["life"] = 0.0
		var node2: MeshInstance3D = sp["node"]
		node2.visible = false

	enemy_acc = 0.0
	army_acc = 0.0
	enemy_lost_pop = 0
	army_lost_pop = 0


func _build_embers() -> void:
	var ember_mesh := SphereMesh.new()
	ember_mesh.radius = 0.07
	ember_mesh.height = 0.14
	ember_mesh.radial_segments = 6
	ember_mesh.rings = 3

	for i in range(2):
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.albedo_color = Color(1.0, 0.55, 0.1)

		var p := CPUParticles3D.new()
		p.amount = 120
		p.lifetime = 3.5
		p.mesh = ember_mesh
		p.material_override = m
		p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
		p.emission_box_extents = Vector3(12.0, 0.1, 45.0)
		p.direction = Vector3(0.0, 1.0, 0.0)
		p.spread = 20.0
		p.gravity = Vector3(0.0, 0.5, 0.0)
		p.initial_velocity_min = 0.6
		p.initial_velocity_max = 2.0
		p.scale_amount_min = 0.6
		p.scale_amount_max = 1.6
		add_child(p)
		embers.append(p)


func _build_labels() -> void:
	army_label = Label3D.new()
	army_label.font_size = 110
	army_label.pixel_size = 0.008
	army_label.position = Vector3(0.0, 2.6, 0.5)
	army_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	army_label.no_depth_test = true
	army_label.modulate = Color(0.55, 0.88, 1.0)
	army_label.outline_size = 30
	army_label.outline_modulate = Color(0.02, 0.08, 0.2)
	army_root.add_child(army_label)

	enemy_label = Label3D.new()
	enemy_label.font_size = 140
	enemy_label.pixel_size = 0.010
	enemy_label.position = Vector3(0.0, 7.2, -6.5)
	enemy_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	enemy_label.no_depth_test = true
	enemy_label.modulate = Color(1.0, 0.62, 0.12)
	enemy_label.outline_size = 32
	enemy_label.outline_modulate = Color(0.2, 0.03, 0.0)
	enemy_root.add_child(enemy_label)


func _spawn_pop(
	pos: Vector3,
	text: String,
	color: Color,
	size: int = 100
) -> void:
	var label := Label3D.new()
	label.text = text
	label.font_size = size
	label.pixel_size = 0.008
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.modulate = color
	label.outline_size = 28
	label.outline_modulate = Color(0.05, 0.05, 0.10)
	label.position = pos
	add_child(label)

	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", pos.y + 3.0, 0.9)
	tween.tween_property(label, "modulate:a", 0.0, 0.6).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)


func _refresh_army() -> void:
	_set_squad_visibility(soldiers, army_count, false)


func _refresh_enemy() -> void:
	_set_squad_visibility(enemies, enemy_count, true)
	boss_root.visible = enemy_count > 0


func _set_squad_visibility(
	squad: Array[Dictionary],
	amount: int,
	enemy: bool
) -> void:
	var shown: int = mini(amount, MAX_VISIBLE)

	for i in range(squad.size()):
		var node: Node3D = squad[i]["node"]

		node.visible = i < shown
		node.position = _slot(i, enemy)


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
		right_arm.rotation.x = 0.9 + swing * 0.15
		left_leg.rotation.x = -swing
		right_leg.rotation.x = swing


# ---------------------------------------------------------------
# HUD
# ---------------------------------------------------------------
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
	hud_count.add_theme_color_override("font_color", Color(0.28, 0.72, 1.0))
	root.add_child(hud_count)

	hud_enemy = Label.new()
	hud_enemy.position = Vector2(28.0, 112.0)
	hud_enemy.add_theme_font_size_override("font_size", 20)
	hud_enemy.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
	root.add_child(hud_enemy)

	progress_bar = ProgressBar.new()
	progress_bar.position = Vector2(28.0, 150.0)
	progress_bar.size = Vector2(664.0, 16.0)
	progress_bar.max_value = 100.0
	progress_bar.show_percentage = false
	root.add_child(progress_bar)

	hud_hint = Label.new()
	hud_hint.position = Vector2(28.0, 180.0)
	hud_hint.add_theme_font_size_override("font_size", 18)
	hud_hint.add_theme_color_override("font_color", Color(0.86, 0.92, 1.0))
	hud_hint.text = "DESLIZE PARA ESCOLHER SEU PORTAL"
	root.add_child(hud_hint)

	# Botão para trocar de arma manualmente
	weapon_button = Button.new()
	weapon_button.position = Vector2(180.0, 1150.0)
	weapon_button.custom_minimum_size = Vector2(360.0, 70.0)
	weapon_button.add_theme_font_size_override("font_size", 24)
	weapon_button.pressed.connect(_cycle_weapon)
	root.add_child(weapon_button)

	result_panel = PanelContainer.new()
	result_panel.set_anchors_preset(Control.PRESET_CENTER)
	result_panel.position = Vector2(-260.0, -145.0)
	result_panel.size = Vector2(520.0, 290.0)
	result_panel.visible = false
	root.add_child(result_panel)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.055, 0.10, 0.96)
	panel_style.border_color = Color(0.18, 0.55, 0.95)
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(18)
	result_panel.add_theme_stylebox_override("panel", panel_style)

	var panel_box := VBoxContainer.new()
	panel_box.alignment = BoxContainer.ALIGNMENT_CENTER
	panel_box.add_theme_constant_override("separation", 12)
	result_panel.add_child(panel_box)

	result_label = Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 28)
	result_label.add_theme_color_override("font_color", Color.WHITE)
	panel_box.add_child(result_label)

	continue_button = Button.new()
	continue_button.text = "PRÓXIMA FASE"
	continue_button.custom_minimum_size = Vector2(300.0, 55.0)
	continue_button.add_theme_font_size_override("font_size", 22)
	continue_button.pressed.connect(_next_level)
	panel_box.add_child(continue_button)

	retry_button = Button.new()
	retry_button.text = "TENTAR NOVAMENTE"
	retry_button.custom_minimum_size = Vector2(300.0, 55.0)
	retry_button.add_theme_font_size_override("font_size", 22)
	retry_button.pressed.connect(_retry_level)
	panel_box.add_child(retry_button)


func _cycle_weapon() -> void:
	weapon_idx = (weapon_idx + 1) % WEAPONS.size()
	_update_hud()


func _update_hud() -> void:
	var t: Dictionary = _theme()

	hud_level.text = "CLN ARMY  •  FASE %02d  •  %s" % [level, str(t["name"])]
	hud_count.text = "TROPAS: %d" % army_count
	hud_enemy.text = "INIMIGOS: %d" % enemy_count
	weapon_button.text = "ARMA: %s  ▶" % str(WEAPONS[weapon_idx]["name"])

	army_label.text = str(army_count)
	enemy_label.text = str(enemy_count)


# ---------------------------------------------------------------
# BATALHA
# ---------------------------------------------------------------
func _start_battle() -> void:
	game_state = "battle"

	battle_timer = 0.0
	enemy_shoot_timer = 0.0
	pop_timer = 0.0

	_clear_fx()

	hud_hint.text = "BATALHA! ATIRE NO EXÉRCITO INIMIGO"

	army_root.position.z = -progress
	enemy_root.position = Vector3(0.0, 0.0, ENEMY_Z)

	_refresh_army()
	_refresh_enemy()

	result_panel.visible = false


func _update_battle(delta: float) -> void:
	battle_timer += delta

	_animate_squad(soldiers, run_clock, 0.9)
	_animate_squad(enemies, run_clock + 0.7, 0.9)

	# Alinha e aproxima o exército, parando a 8 unidades do inimigo
	army_root.position.x = move_toward(army_root.position.x, 0.0, 6.0 * delta)

	var gap: float = army_root.position.z - enemy_root.position.z

	if gap > 8.0:
		army_root.position.z -= minf(9.0 * delta, gap - 8.0)

	# Inimigo também atira
	enemy_shoot_timer -= delta

	if enemy_shoot_timer <= 0.0:
		enemy_shoot_timer = 0.07
		_enemy_shoot()
		_enemy_shoot()

	# Números de dano agrupados
	pop_timer += delta

	if pop_timer >= 0.6:
		pop_timer = 0.0

		if enemy_lost_pop > 0:
			_spawn_pop(
				enemy_root.position + Vector3(0.0, enemy_label.position.y + 1.0, -6.5),
				"-%d" % enemy_lost_pop,
				Color(1.0, 0.9, 0.3),
				90
			)
			enemy_lost_pop = 0

		if army_lost_pop > 0:
			_spawn_pop(
				army_root.position + Vector3(0.0, 3.8, 0.0),
				"-%d" % army_lost_pop,
				Color(1.0, 0.35, 0.35),
				80
			)
			army_lost_pop = 0

	if army_count <= 0 or enemy_count <= 0 or battle_timer >= 30.0:
		_finish_battle()


func _finish_battle() -> void:
	game_state = "result"
	result_panel.visible = true

	if army_count > 0 and (enemy_count <= 0 or army_count > enemy_count):
		result_label.text = "VITÓRIA!\nSeu exército venceu!"
		continue_button.visible = true
		retry_button.visible = false
	else:
		result_label.text = "DERROTA!\nTente novamente e reforce suas tropas."
		continue_button.visible = false
		retry_button.visible = true

	hud_hint.text = "CONFRONTO FINALIZADO"


func _enemy_for_level() -> int:
	var base: int = 34 + (level - 1) * 9

	if _boss_count() == 3:
		base = int(float(base) * 1.25)

	return base


func _next_level() -> void:
	level += 1

	army_count = START_ARMY + (level - 1) * 4
	enemy_count = _enemy_for_level()
	weapon_idx = 0

	_reset_level()
	_start_level_visuals()
	_update_hud()


func _retry_level() -> void:
	army_count = START_ARMY + (level - 1) * 4
	enemy_count = _enemy_for_level()

	_reset_level()
	_build_gates()


func _reset_level() -> void:
	progress = 0.0
	player_x = 0.0
	target_x = 0.0

	gate_used = [false, false, false]

	game_state = "running"

	battle_timer = 0.0

	army_root.position = Vector3.ZERO
	enemy_root.position = Vector3(0.0, 0.0, ENEMY_Z)

	_clear_fx()
	_place_camera()

	result_panel.visible = false

	continue_button.visible = true
	retry_button.visible = true

	hud_hint.text = "DESLIZE PARA ESCOLHER SEU PORTAL"
	progress_bar.value = 0.0

	_refresh_army()
	_refresh_enemy()
	_update_hud()
