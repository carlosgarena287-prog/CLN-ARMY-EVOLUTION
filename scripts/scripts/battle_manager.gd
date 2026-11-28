extends Node
class_name ArmyBattleManager

signal battle_updated(player_troops: int, enemy_troops: int)
signal battle_finished(player_won: bool)

var player_troops: int = 0
var enemy_troops: int = 0
var battle_active: bool = false
var elapsed: float = 0.0
var tick_timer: float = 0.0

var round_interval: float = 0.75
var maximum_duration: float = 18.0


func start_battle(player_amount: int, enemy_amount: int) -> void:
	player_troops = maxi(player_amount, 0)
	enemy_troops = maxi(enemy_amount, 0)
	elapsed = 0.0
	tick_timer = 0.0
	battle_active = true
	battle_updated.emit(player_troops, enemy_troops)


func update_battle(delta: float) -> void:
	if not battle_active:
		return

	elapsed += delta
	tick_timer += delta

	if tick_timer >= round_interval:
		tick_timer = 0.0
		_resolve_round()

	if player_troops <= 0 or enemy_troops <= 0 or elapsed >= maximum_duration:
		_finish()


func _resolve_round() -> void:
	var player_loss: int = maxi(1, int(round(float(enemy_troops) * 0.055)))
	var enemy_loss: int = maxi(1, int(round(float(player_troops) * 0.075)))

	player_troops = maxi(0, player_troops - player_loss)
	enemy_troops = maxi(0, enemy_troops - enemy_loss)

	battle_updated.emit(player_troops, enemy_troops)


func _finish() -> void:
	if not battle_active:
		return

	battle_active = false
	battle_finished.emit(player_troops > enemy_troops)


func cancel_battle() -> void:
	battle_active = false
	elapsed = 0.0
	tick_timer = 0.0
