extends CanvasLayer

signal shown
signal hidden

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var button_save = $Control/HBoxContainer/Button_Save
@onready var button_load = $Control/HBoxContainer/Button_Load
@onready var item_description: Label = $Control/ItemDescription

var is_paused: bool = false

func _ready() -> void:
	_hide_pause_menu()
	
	button_save.pressed.connect(_on_save_pressed)
	button_load.pressed.connect(_on_load_pressed)
	
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused == false:
			if DialogSystem.is_active:
				return
			_show_pause_menu()
		else:
			_hide_pause_menu()
	get_viewport().set_input_as_handled()
	pass


func _show_pause_menu() -> void:
	get_tree().paused = true
	visible = true
	is_paused = true
	shown.emit()
	pass


func _hide_pause_menu() -> void:
	get_tree().paused = false
	visible = false
	is_paused = false
	hidden.emit()
	pass


func _on_save_pressed() -> void:
	if is_paused == false:
		return
	
	GlobalSaveManager.save_game()
	_hide_pause_menu()
	pass


func _on_load_pressed() -> void:
	if is_paused == false:
		return
	
	GlobalSaveManager.load_game()
	
	await LevelManager.level_load_started
	
	_hide_pause_menu()
	pass


func update_item_description(new_text: String) -> void:
	item_description.text = new_text


func play_audio(audio: AudioStream) -> void:
	audio_stream_player.stream = audio
	audio_stream_player.play()
	pass
