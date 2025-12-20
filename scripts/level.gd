extends Node2D

@export_group("Player settings")
## Set how many clones can player make
@export var loop_limit : int = 3
## Set how many steps can player make
@export var step_limit : int = 10
## Set how many boxes can player push at once, -1 means that player can push unlimited boxes
@export var push_limit : int = -1
## Set if player can loop
@export var can_loop : bool = false

var ui_steps_node

var last_steps = []
var last_step = null
var step_counter = 0

signal step
signal undo
signal reset
signal reset_loop
signal end_loop

func _ready():
	ui_steps_node = get_node("UI/UIControl")

func _unhandled_input(event):
	if not event.is_action_type():
		return
		
	if event.is_action_pressed("reset_level"):
		reset.emit()
		print('level was reset')
		get_tree().reload_current_scene()
		
	elif event.is_action_pressed("reset_loop"):
		step_counter = 0
		reset_loop.emit()
		
	elif event.is_action_pressed("undo"):
		if step_counter != 0:
			step_counter -= 1
			undo.emit()
		
	elif false and event.is_action_pressed("end_loop") and can_loop:
		step_counter = 0
		end_loop.emit()

func force_step():
	step_counter += 1
	step.emit()

func force_end_loop():
	step_counter = 0
	end_loop.emit()




func on_loop_ended():
	loop_limit -= 1
	if loop_limit == 0 :
		on_loops_depleted()

func on_loops_depleted():
	get_tree().reload_current_scene()
