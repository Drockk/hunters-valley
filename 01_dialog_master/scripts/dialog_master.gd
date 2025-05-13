@tool
class_name DialogMaster extends Node

@export_file("*.yaml")
var dialog_file: String

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
	
	var data = _load_file()
	if data.is_empty():
		printerr("Data is empty")
		return

	_parse_data(data)
	pass


func _load_file() -> Dictionary:
	var file = FileAccess.open(dialog_file, FileAccess.READ)

	if not file:
		printerr("Failed to open YAML file: ", dialog_file)
		return {}
	
	var yaml_text = file.get_as_text()

	file.close()

	# var yaml = YAML.new()
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
	var dialog = data.dialogue
	
	for id in dialog:
		print(id)
	pass
