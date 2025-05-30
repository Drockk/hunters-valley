class_name Level extends Node2D

@export var music: AudioStream

func _ready() -> void:
	self.y_sort_enabled = true
	PlayerManager.set_as_parent(self)
	LevelManager.level_load_started.connect(_free_level)
	AudioManager.play_music(music)

	for c in get_children():
		if c is NPC:
			DmNotificationSystem.send_notification(c.npc_resource.npc_description)
	pass


func _free_level() -> void:
	PlayerManager.unparent_player(self)
	queue_free()
	pass
