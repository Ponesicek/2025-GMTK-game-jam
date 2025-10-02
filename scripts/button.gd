## Pressure plate button that activates when stepped on.
## Triggers state changes in connected wires and doors.
extends Area2D

@onready var animation_player = $ButtonSprite
@onready var collider : CollisionShape2D = $ButtonCollider

@onready var level : Node2D = get_tree().get_root().get_node('level')

## Whether the button is currently pressed
var activated : bool = false

## Step number when button was activated (for undo support)
var activation_step : int
## Current simulation step counter
var sim_step : int = 0

## Initialize button and connect to level signals
func _ready() -> void:
	level.end_loop.connect(end_loop)
	level.reset_loop.connect(reset_loop)
	level.undo.connect(undo)
	level.step.connect(step)
	animation_player.set_frame(0)

## Activate button when something enters (player or box)
func _on_body_entered(_body):
	if not activated:
		activated = true
		activation_step = sim_step
		for i in get_overlapping_areas():
			if 'state_change' in i:
				i.state_change(true)

		animation_player.set_frame(1)

## Reset button to unpressed state when loop ends
func end_loop() -> void:
	activated = false
	animation_player.set_frame(0)
	sim_step = 0

## Reset button (same as end_loop)
func reset_loop() -> void:
	end_loop()

## Increment step counter when a game step occurs
func step() -> void:
	sim_step += 1

## Undo button press if undoing past the activation step
func undo() -> void:
	sim_step -= 1
	if sim_step == activation_step-1:
		activated = false
		animation_player.set_frame(0)
		for i in get_overlapping_areas():
			if 'state_change' in i:
				i.state_change(false)
