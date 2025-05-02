extends Node

var music_audio_player_count: int = 2
var current_music_player: int = 0
var music_player: Array[AudioStreamPlayer] = []
var music_bus: String = "Music"
var music_fade_duration: float = 0.75

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	 
	for i in music_audio_player_count:
		var player = AudioStreamPlayer.new()
		player.bus = music_bus
		player.volume_db = -40
		add_child(player)
		music_player.append(player)
	pass


func play_music(music: AudioStream) -> void:
	if music == music_player[current_music_player].stream:
		return
	
	var previous_player: AudioStreamPlayer = music_player[current_music_player]
	
	current_music_player += 1
	current_music_player = current_music_player % music_audio_player_count
	var current_player: AudioStreamPlayer = music_player[current_music_player]

	current_player.stream = music
	
	play_and_fade_in(current_player)
	fade_out_and_stop(previous_player)
	pass


func play_and_fade_in(player: AudioStreamPlayer) -> void:
	player.play()
	
	var tween: Tween = create_tween()
	tween.tween_property(player, "volume_db", 0, music_fade_duration)
	pass


func fade_out_and_stop(player: AudioStreamPlayer) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(player, "volume_db", -40, music_fade_duration)
	
	await tween.finished
	
	player.stop()
	pass
