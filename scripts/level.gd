## Level controller that manages game state, player limits, and input handling.
## Emits signals to coordinate actions between player, clones, and game objects.
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

## Reference to the UI node for updating display
var ui_steps_node

## Counter tracking the current step in the level
var step_counter = 0

## Emitted when a step is taken
signal step
## Emitted when undo action is requested
signal undo
## Emitted when level reset is requested
signal reset
## Emitted when current loop should be reset
signal reset_loop
## Emitted when a loop ends and a clone is created
signal end_loop

## Initialize the level by getting reference to UI node
func _ready():
	ui_steps_node = get_node("UI")

## Handle keyboard input for level controls (reset, undo, reset loop)
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

## Force a step to occur (called by player when they move)
func force_step() -> void:
	step_counter += 1
	step.emit()

## Force the current loop to end (called when player creates a clone)
func force_end_loop() -> void:
	step_counter = 0
	end_loop.emit()

## Called when a loop ends, decrements loop counter
func on_loop_ended() -> void:
	loop_limit -= 1
	if loop_limit == 0 :
		on_loops_depleted()

## Called when all loops are used up, reloads the level
func on_loops_depleted() -> void:
	get_tree().reload_current_scene()
