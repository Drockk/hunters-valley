class_name HurtBox extends Area2D

@export var damage: int = 1

func _ready():
	area_entered.connect(AreaEntered)

func AreaEntered(_area: Area2D) -> void:
	if _area is HitBox:
		_area.take_damage(self)
