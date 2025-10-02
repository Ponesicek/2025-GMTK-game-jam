## Wire segment that propagates electrical state to connected wires and doors.
## Part of the circuit/puzzle system for controlling doors.
extends Area2D

@onready var animation_player = $Sprite2D

@onready var level : Node2D = get_tree().get_root().get_node('level')

## Current electrical state of the wire (on/off)
var wireState : bool = false

## Initialize wire in off state and connect to level signals
func _ready() -> void:
	level.end_loop.connect(end_loop)
	level.reset_loop.connect(reset_loop)
	wireState = false

## Change wire state and propagate to overlapping connected objects
func state_change(state : bool):
	if wireState != state:
		wireState = state
		for i in get_overlapping_areas():
			if 'state_change' in i:
				i.state_change(state)

		if wireState:
			animation_player.set_frame(1)
		else:
			animation_player.set_frame(0)

## Reset wire to off state when loop ends
func end_loop():
	animation_player.set_frame(0)
	wireState = false

## Reset wire (same as end_loop)
func reset_loop():
	end_loop()
