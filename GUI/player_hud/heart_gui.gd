class_name HeartGUI extends Control

@onready var sprite_2d = $Sprite2D

var value: int = 2 :
	set(_value):
		value = _value
		update_sprite()

func update_sprite() -> void:
	sprite_2d.frame = value
