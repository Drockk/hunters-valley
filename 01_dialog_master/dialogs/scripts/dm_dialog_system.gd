class_name DialogMasterDialogSystem extends Node

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var wait_screen: CanvasLayer = $CanvasLayer

var remote_llm_url = "http://127.0.0.1:11434/api/chat"
var headers = ["Content-Type: application/json"]

signal dialog_ready(dialog: String)


func show_wait_screen() -> void:
	wait_screen.visible = true


func hide_wait_screen() -> void:
	wait_screen.visible = false


func send_dialog(_dialog: Dictionary) -> void:
	var parsed_dialog = _parse_dialog(_dialog)
	if parsed_dialog.is_empty():
		printerr("A problem occurs when parsing the dialog")
		return
	
	var user_message: Dictionary = {
		role = "user",
		content = parsed_dialog
	}

	var chat_message: Dictionary = {
		model = "dm",
		messages = [user_message],
		stream = false
	}

	var chat_message_json: String = JSON.stringify(chat_message)

	http_request.request_completed.connect(_on_request_completed)
	http_request.request(
		remote_llm_url,
		headers,
		HTTPClient.METHOD_POST,
		chat_message_json
	)

	pass

func _parse_dialog(dialog: Dictionary) -> String:
	var result = YAML.stringify(dialog)
	if result.has_error():
		printerr("Error:", result.get_error_message())
		return ""
	return result.get_data()

func _on_request_completed(result, _response_code, _headers, body) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("A problem occurs when sending a notification, response code: ", result)
		return
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	var dialog: String = response["message"]["content"] as String
	print(dialog)
	dialog = dialog.trim_prefix("```yaml")
	dialog = dialog.trim_suffix("```")
	print(dialog)

	http_request.request_completed.disconnect(_on_request_completed)

	dialog_ready.emit(dialog)
	pass
