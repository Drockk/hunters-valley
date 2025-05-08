@tool
class_name DialogPortrait extends Sprite2D

var blink: bool = false: set = _set_blink
var open_mouth: bool = false: set = _set_open_mouth
var mouth_open_frames: int = 0

@onready var audio: AudioStreamPlayer = $'../AudioStreamPlayer'

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	DialogSystem.letter_added.connect(check_mouth_open)
	blinker()
	pass


func update_portrait() -> void:
	if open_mouth:
		frame = 2
	else:
		frame = 0
	
	if blink:
		frame += 1
	pass


func _set_blink(_value: bool) -> void:
	if blink != _value:
		blink = _value
		update_portrait()
	pass


func blinker() -> void:
	if blink == false:
		await get_tree().create_timer(randf_range(0.1, 2)).timeout
	else:
		await get_tree().create_timer(0.15).timeout

	blink = not blink
	blinker()
	pass


func _set_open_mouth(_value: bool) -> void:
	if open_mouth != _value:
		open_mouth = _value
		update_portrait()
	pass


func check_mouth_open(letter: String) -> void:
	if 'aeiouy1234567890'.contains(letter.to_lower()):
		open_mouth = true
		mouth_open_frames += 3
		audio.pitch_scale = randf_range(0.96, 1.04)
		audio.play()
	elif '.,!?'.contains(letter):
		mouth_open_frames = 0

	if mouth_open_frames > 0:
		mouth_open_frames -= 1

	if mouth_open_frames == 0:
		open_mouth = false

	pass
