@tool
class_name ItemDropper extends Node2D

const PICKUP = preload("res://Items/item_pickup/item_pickup.tscn")

@export var item_data: ItemData: set = _set_item_data


var has_dropped: bool = false


@onready var sprite : Sprite2D = $Sprite2D
@onready var has_dropped_data: Node = $PersistentDataHandler
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
    if Engine.is_editor_hint():
        _update_texture()
        return
    
    sprite.visible = false
    has_dropped_data.data_loaded.connect(_on_data_loaded)
    _on_data_loaded()
    pass

func drop_item() -> void:
    if has_dropped:
        return

    has_dropped = true
    
    var drop = PICKUP.instantiate() as ItemPickup
    drop.item_data = item_data
    add_child(drop)
    drop.picked_up.connect(_on_drop_picked_up)
    audio.play()

    pass

func _set_item_data(value: ItemData) -> void:
    item_data = value
    _update_texture()
    pass


func _update_texture() -> void:
    if Engine.is_editor_hint():
        if item_data and sprite:
            sprite.texture = item_data.texture
    pass


func _on_data_loaded() -> void:
    has_dropped = has_dropped_data.value
    pass


func _on_drop_picked_up() -> void:
    has_dropped_data.set_value()
    pass