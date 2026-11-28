extends Node
class_name ArmySaveManager

const SAVE_PATH: String = "user://cln_army_save.json"

var save_data: Dictionary = {
	"level": 1,
	"best_level": 1,
	"coins": 0,
	"total_wins": 0,
	"upgrade_damage": 0,
	"upgrade_income": 0
}


func _ready() -> void:
	load_game()


func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		push_warning("Não foi possível salvar o progresso.")
		return

	file.store_string(JSON.stringify(save_data))
	file.close()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		save_game()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()

	if parsed is Dictionary:
		for key in save_data.keys():
			if parsed.has(key):
				save_data[key] = parsed[key]


func set_value(key: String, value: Variant) -> void:
	save_data[key] = value
	save_game()


func get_value(key: String, fallback: Variant = 0) -> Variant:
	return save_data.get(key, fallback)


func add_coins(amount: int) -> void:
	save_data["coins"] = int(save_data["coins"]) + maxi(amount, 0)
	save_game()


func register_win() -> void:
	save_data["total_wins"] = int(save_data["total_wins"]) + 1
	save_game()


func register_level(level: int) -> void:
	save_data["level"] = level
	save_data["best_level"] = maxi(int(save_data["best_level"]), level)
	save_game()
