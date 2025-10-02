## In-game UI that displays steps and clones remaining.
## Updates labels based on player actions.
extends Control

@onready var stepLabel : Label = $BoxContainer/GameInfo/Steps
@onready var loopLabel : Label = $BoxContainer/GameInfo/Loops

@onready var level = get_tree().get_root().get_node('level')

## Initialize UI, hide loop counter if looping is disabled
func _ready() -> void:
	loopLabel.visible = level.can_loop

## Update the steps remaining display
func update_steps(value: int) -> void:
	stepLabel.text = 'Steps left: ' + str(value)

## Update the clones remaining display
func update_loops(value: int) -> void:
	loopLabel.text = 'Clones left: ' + str(value)
