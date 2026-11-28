extends Node3D
class_name ArmyManager

const SOLDIER_LIMIT: int = 180
const SOLDIER_SCENE_SCRIPT = preload("res://scripts/soldier.gd")

@export var columns: int = 12
@export var spacing_x: float = 0.72
@export var spacing_z: float = 0.82

var soldiers: Array[ArmySoldier] = []
var troop_count: int = 0
var enemy_team: bool = false


func create_army(amount: int, enemy: bool = false) -> void:
	clear_army()
	enemy_team = enemy
	troop_count = maxi(amount, 0)

	var visible_count: int = mini(troop_count, SOLDIER_LIMIT)

	for i in range(visible_count):
		var soldier := ArmySoldier.new()
		soldier.setup(enemy_team, i)
		add_child(soldier)
		soldiers.append(soldier)

	_position_soldiers()


func set_troop_count(amount: int) -> void:
	troop_count = maxi(amount, 0)
	var visible_count: int = mini(troop_count, SOLDIER_LIMIT)

	while soldiers.size() < visible_count:
		var soldier := ArmySoldier.new()
		soldier.setup(enemy_team, soldiers.size())
		add_child(soldier)
		soldiers.append(soldier)

	for i in range(soldiers.size()):
		soldiers[i].visible = i < visible_count

	_position_soldiers()


func _position_soldiers() -> void:
	for i in range(soldiers.size()):
		var row: int = i / columns
		var col: int = i % columns

		soldiers[i].position = Vector3(
			(float(col) - float(columns - 1) * 0.5) * spacing_x,
			0.0,
			float(row) * spacing_z
		)


func animate_army(clock: float, strength: float = 1.0) -> void:
	for soldier in soldiers:
		if soldier.visible:
			soldier.animate_running(clock, strength)


func clear_army() -> void:
	for soldier in soldiers:
		if is_instance_valid(soldier):
			soldier.queue_free()

	soldiers.clear()
	troop_count = 0
