class_name DMHttpRequest extends AwaitableHTTPRequest

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
