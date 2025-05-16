class_name DMHttpRequest extends AwaitableHTTPRequest

# func _ready() -> void:
# 	set_use_threads(true)
# 	set_timeout(360)
# 	pass

func send_notification(_text: Dictionary) -> void:
	var yaml_text = _parse_text(_text)

	var user_message = {
		role = "user",
		content = yaml_text
	}

	var message: Dictionary = {
		model = "dm",
		messages = [user_message],
		stream = false
	}

	var message_json = JSON.stringify(message)

	var response := await async_request(
		"http://127.0.0.1:11434/api/chat",
		[],
		HTTPClient.METHOD_POST,
		message_json
	)

	if not response.success() and not response.status_ok():
		print("Error with Ollama response")


func _parse_text(text: Dictionary) -> String:
	var result = YAML.stringify(text)
	if result.has_error():
		printerr("Error:", result.get_error_message())
		return ""

	return result.get_data()

func send_dialog(text: String) -> String:
	print(text)

	var user_message = {
		role = "user",
		content = text
	}

	var message: Dictionary = {
		model = "dm",
		messages = [user_message],
		stream = false
	}

	var message_json = JSON.stringify(message)

	var response := await async_request(
		"http://127.0.0.1:11434/api/chat",
		[],
		HTTPClient.METHOD_POST,
		message_json
	)

	if not response.success() and not response.status_ok():
		print("Error with Ollama response")
		return ""

	var json = response.body_as_json()
	print(json["message"]["content"])

	return ""


# func send_dialog() -> void:
# 	var response := await async_request(
# 		"https://api.github.com/users/swarkin"
# 	)

# 	if response.success() and response.status_ok():
# 		print(response.status)                   # 200
# 		print(response.headers["content-type"])  # application/json

# 		var json = response.body_as_json()
# 		print(json["login"])                 # Swarkin
# 	pass
