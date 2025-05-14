@tool
@icon("res://GUI/dialog_system/icons/chat_bubbles.svg")
class_name DialogMaster extends Area2D

signal player_interacted
signal finished

@export_file("*.yaml")
var dialog_file: String
@export
var hero_resource: NPCResource

var dialog_data: Dictionary

var dialog_items: Array[DialogItem]

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _get_configuration_warnings() -> PackedStringArray:
	if dialog_file.is_empty():
		return ["Requires dialog file"]
	return []


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if dialog_file.is_empty():
		printerr("Requires dialog file")
		return
	
	dialog_data = _load_file()
	if dialog_data.is_empty():
		printerr("Data is empty")
		return
	
	area_entered.connect(_on_area_enter)
	area_exited.connect(_on_area_exit)
	pass


func _on_area_enter(_a: Area2D) -> void:
	animation_player.play("show")
	PlayerManager.interact_pressed.connect(_player_interact)
	pass


func _on_area_exit(_a: Area2D) -> void:
	animation_player.play("hide")
	PlayerManager.interact_pressed.disconnect(_player_interact)
	pass

func _player_interact() -> void:
	_parse_data(dialog_data)
	_update_dialog_items_children()

	player_interacted.emit()

	await get_tree().process_frame
	await get_tree().process_frame

	DialogSystem.show_dialog(dialog_items)

	DialogSystem.finished.connect(_on_dialog_finished)
	pass

func _on_dialog_finished() -> void:
	DialogSystem.finished.disconnect(_on_dialog_finished)
	finished.emit()
	pass


func _load_file() -> Dictionary:
	var file = FileAccess.open(dialog_file, FileAccess.READ)

	if not file:
		printerr("Failed to open YAML file: ", dialog_file)
		return {}
	
	var yaml_text = file.get_as_text()

	file.close()

	var parse_result := YAML.parse(yaml_text)

	if parse_result.has_error():
		printerr("Failed to parse YAML: ", parse_result.get_error_message())
		printerr("At line: ", parse_result.get_error_line(), ", column: ", parse_result.get_error_column())
		return {}
	
	var data = parse_result.get_data()
	match typeof(data):
		TYPE_NIL:
			printerr("Failed to get data from YAML")
			return {}

	return parse_result.get_data()


func _parse_data(data: Dictionary) -> void:
	var dialogs = data.dialogs

	for dialog in dialogs:
		# Handle unique

		if dialog.talk:
			_handle_talk(dialog.talk)
		# elif dialog.choice:
		# 	_handle_choice(dialog.choice)
			pass
	pass

func _handle_talk(talk) -> void:
	for line in talk:
		var dialog_text: DialogText = DialogText.new()

		if line.who != "NPC":
			dialog_text.npc_info = hero_resource

		dialog_text.text = line.text as String
		
		add_child(dialog_text)
	pass


func _handle_choice(choice) -> void:
	var dialog_choice: DialogChoice = DialogChoice.new()

	for line in choice:
		var dialog_branch: DialogBranch = DialogBranch.new()

		dialog_branch.text = choice.text

		dialog_choice.add_child(dialog_branch)

	add_child(dialog_choice)
	pass


func _update_dialog_items_children() -> void:
	for c in get_children():
		if c is DialogItem:
			dialog_items.append(c)
	pass
