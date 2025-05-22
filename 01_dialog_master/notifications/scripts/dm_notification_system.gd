class_name DialogMasterNotification extends Node

var queue: Array[String] = []
var mutex: Mutex = Mutex.new()
var is_waiting_for_response: bool = false

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var wait_screen: CanvasLayer = $CanvasLayer

var remote_llm_url = "http://127.0.0.1:11434/api/chat"
var headers = ["Content-Type: application/json"]

signal sent_all_notifications

func send_notification(text: String) -> void:
	mutex.lock()
	queue.append(text)
	mutex.unlock()
	pass


func notification_queue_is_empty() -> bool:
	return queue.is_empty()


func show_wait_screen() -> void:
	wait_screen.visible = true


func hide_wait_screen() -> void:
	wait_screen.visible = false


func _process(_delta: float) -> void:
	if queue.is_empty() or is_waiting_for_response:
		sent_all_notifications.emit()
		return

	mutex.lock()
	var notification_text = queue.front()
	mutex.unlock()

	var message: Dictionary = {
		notification = notification_text
	}

	_send(message)
	queue.pop_front()
	pass


func _send(message: Dictionary) -> void:
	var parsed_message = _parse_message(message)
	if parsed_message.is_empty():
		printerr("A problem occurs when parsing the message")
		return

	var user_message: Dictionary = {
		role = "user",
		content = parsed_message
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

	is_waiting_for_response = true
	pass


func _parse_message(text: Dictionary) -> String:
	var result = YAML.stringify(text)
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
	var status: String = response["message"]["content"] as String
	status = status.trim_suffix("\n")

	if status != "OK":
		printerr("The model will not return an 'OK' response, the model's response: ", status)

	http_request.request_completed.disconnect(_on_request_completed)

	is_waiting_for_response = false
	pass
