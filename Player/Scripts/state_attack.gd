class_name State_Attack extends State

var attacking: bool = false

@export var attack_sound: AudioStream
@export_range(1, 20, 0.5) var decelarate_speed: float = 5.0

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var attack_anim: AnimationPlayer = $"../../Sprite2D/AttackEffectSprite/AnimationPlayer"
@onready var walk: State = $"../Walk"
@onready var idle: State = $"../Idle"
@onready var audio: AudioStreamPlayer2D =$"../../Audio/AudioStreamPlayer2D"
@onready var hurt_box: HurtBox = %AttackHurtBox

func Enter() -> void:
	player.UpdateAnimation("attack")
	attack_anim.play("attack_" + player.AnimDirection())
	
	animation_player.animation_finished.connect(EndAttack)
	
	audio.stream = attack_sound
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()
	
	attacking = true
	
	await get_tree().create_timer(0.075).timeout
	hurt_box.monitoring = true

func Exit() -> void:
	animation_player.animation_finished.disconnect(EndAttack)
	attacking = false
	
	hurt_box.monitoring = false
	pass

func Process(_delta: float) -> State:
	player.velocity -= player.velocity * decelarate_speed * _delta
	
	if attacking == false:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk
	
	return null

func Physics(_delat: float) -> State:
	return null

func HandleInput(_event: InputEvent) -> State:
	return null

func EndAttack(_newAnimation: String) -> void:
	attacking = false
