class_name Plant extends Node2D

const PICKUP = preload("res://Items/item_pickup/item_pickup.tscn")

@onready var is_destroyed: PersistentDataHandler = $PersistentDataIsDestroyed

@export_category("Item Drops")
@export var drops: Array[DropData]

func _ready():
	$HitBox.damaged.connect(TakeDamage)
	is_destroyed.data_loaded.connect(_set_state)
	_set_state()


func _set_state() -> void:
	if is_destroyed.value == true:
		queue_free()
	pass


func TakeDamage(_damage: HurtBox) -> void:
	is_destroyed.set_value()

	drop_items()

	queue_free()

func drop_items() -> void:
	if drops.size() == 0:
		return
	
	for i in drops.size():
		if drops[i] == null or drops[i].item == null:
			continue
		
		var drop_count: int = drops[i].get_drop_count()

		for j in drop_count:
			var drop: ItemPickup = PICKUP.instantiate() as ItemPickup
			drop.item_data = drops[i].item
			self.get_parent().call_deferred("add_child", drop)
			drop.global_position = self.global_position
			# drop.velocity = self.velocity.rotated(randf_range(-1.5, 1.5)) * randf_range(0.9, 1.5)

	pass
