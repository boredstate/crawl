extends Node2D

const TILE := 32

@onready var player = $Player
@onready var slime = $Slime
@onready var hp_label: Label = $CanvasLayer/HPLabel
@onready var potion: ColorRect = $Potion
@onready var stairs: ColorRect = $Stairs
@onready var door: ColorRect = $Door
@onready var key: ColorRect = $Key
@onready var boss = $Boss

var player_hp := 5
var won := false
var dead := false
var has_key := false
var strength := 1

func _ready() -> void:
	slime.bumped.connect(_on_bumped)
	_place(player, Vector2i(4, 4))
	_place(slime, Vector2i(8, 4))
	_place(potion, Vector2i(4, 8))
	potion.visible = true
	potion.color = Color(1, 0, 0)
	_place(stairs, Vector2i(10, 4))
	stairs.color = Color.WHITE
	_place(door, Vector2i(6, 4))
	_place(key, Vector2i(4, 6))
	door.color = Color(0.45, 0.28, 0.08)
	key.color = Color(1, 0.9, 0.1)
	_place(boss, Vector2i(12, 6))
	boss.hp = 4
	boss.color = Color(0.55, 0, 0.7)
	boss.bumped.connect(_on_bumped)
	_refresh()
	
func try_step(step: Vector2) -> void:
	if won or dead:
		return
	var dest := _tile(player) + Vector2i(roundi(step.x / TILE), roundi(step.y / TILE))
	if step != Vector2.ZERO and door.visible and dest == _tile(door) and not has_key:
		_enemies_turn()
		if not dead:
			_refresh()
		return
	if step != Vector2.ZERO and stairs.visible and dest == _tile(stairs):
		won = true
		hp_label.text = "WIN"
		return
	var enemy = _enemy_at(dest)
	if step != Vector2.ZERO and enemy != null:
		enemy.hp -= 1 + strength
		enemy.bumped.emit()
		_flash(enemy)
		if enemy.hp <= 0:
			enemy.visible = false
	elif step != Vector2.ZERO:
		if potion.visible and dest == _tile(potion):
			player_hp += 1
			potion.visible = false
		if key.visible and dest == _tile(key):
			has_key = true
			key.visible = false
		if door.visible and dest == _tile(door):
			door.visible = false
		_place(player, dest)
	_enemies_turn()
	if not won and not dead:
		_refresh()

func _enemies_turn() -> void:
	_enemy_turn(slime)
	if dead:
		return
	_enemy_turn(boss)

func _enemy_turn(enemy) -> void:
	if not enemy.visible:
		return
	var delta := _tile(player) - _tile(enemy)
	if abs(delta.x) + abs(delta.y) == 1:
		player_hp -= 1
		enemy.bumped.emit()
		_flash(player)
		if player_hp <= 0:
			dead = true
			hp_label.text = "DEAD"
		return
	var step := Vector2i.ZERO
	if abs(delta.x) > abs(delta.y):
		step.x = 1 if delta.x > 0 else -1
	elif delta.y != 0:
		step.y = 1 if delta.y > 0 else -1
	var next := _tile(enemy) + step
	if _enemy_at(next) != null:
		return
	_place(enemy, next)

func _enemy_at(tile: Vector2i):
	if slime.visible and _tile(slime) == tile:
		return slime
	if boss.visible and _tile(boss) == tile:
		return boss
	return null

func _tile(node: CanvasItem) -> Vector2i:
	return Vector2i(roundi(node.position.x / TILE), roundi(node.position.y / TILE))

func _place(node: CanvasItem, tile: Vector2i) -> void:
	node.position = Vector2(tile) * TILE

func _on_bumped() -> void:
	_refresh()

func _refresh() -> void:
		hp_label.text = "You %d  Slime %d  Boss %d  Key %d" % [player_hp, slime.hp, boss.hp, int(has_key)]

func _flash(rect) -> void:
	var old = rect.modulate
	rect.modulate = Color(4, 4, 4)
	await get_tree().create_timer(0.12).timeout
	if is_instance_valid(rect):
		rect.modulate = old
