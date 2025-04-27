class_name Plant extends Node2D

@onready var is_destroyed: PersistentDataHandler = $PersistentDataIsDestroyed

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
	queue_free()
