class_name PlayerStateMachine extends Node

var states: Array[State]
var previous_state: State
var current_state: State

func _read():
	process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta):
	ChangeState(current_state.Process(delta))

func _physics_process(delta):
	ChangeState(current_state.Physics(delta))

func _unhandled_input(event):
	ChangeState(current_state.HandleInput(event))

func Initialize(_player: Player) -> void:
	states = []
	
	for c in get_children():
		if c is State:
			states.append(c)
	
	if states.size() == 0:
		return
	
	states[0].player = _player
	states[0].state_machine = self
	
	for state in states:
		state.init()

	ChangeState(states[0])
	process_mode = Node.PROCESS_MODE_INHERIT

func ChangeState(new_state: State) -> void:
	if new_state == null || new_state == current_state:
		return
	
	if current_state:
		current_state.Exit()
	
	previous_state = current_state
	current_state = new_state
	
	current_state.Enter()
