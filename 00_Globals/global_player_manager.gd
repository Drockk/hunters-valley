extends Node

const PLAYER = preload("res://Player/player.tscn")
const INVENTORY_DATA: InventoryData = preload("res://GUI/pause_menu/inventory/player_inventory.tres")

signal interact_pressed

var player: Player
var player_spawned: bool = false
var hero_resource = preload("res://Player/hero.tres")

func _ready() -> void:
	add_player_instance()
	await get_tree().create_timer(0.2).timeout
	player_spawned = true

	DmNotificationSystem.send_notification("Player character is Yuv")
	DmNotificationSystem.send_notification(hero_resource.npc_description)
	pass


func add_player_instance() -> void:
	player = PLAYER.instantiate()
	add_child(player)
	pass


func set_health(hp: int, max_hp: int) -> void:
	player.max_hp = max_hp
	player.hp = hp
	player.update_hp(0)
	pass


func set_player_position(_new_pos) -> void:
	player.global_position = _new_pos
	pass


func set_as_parent(_p: Node2D) -> void:
	if player.get_parent():
		player.get_parent().remove_child(player)
	_p.add_child(player)
	pass


func unparent_player(_p: Node2D) -> void:
	_p.remove_child(player)

func play_audio(_audio:AudioStream) -> void:
	player.audio.stream = _audio
	player.audio.play()
	pass
