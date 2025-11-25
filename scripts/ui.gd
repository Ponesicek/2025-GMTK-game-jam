extends Control

@onready var stepLabel : Label = $BoxContainer/GameInfo/Steps
@onready var loopLabel : Label = $BoxContainer/GameInfo/Loops

@onready var level = get_parent()

func _ready() -> void:
	loopLabel.visible = level.can_loop

func update_steps(value):
	stepLabel.text = 'Steps left: ' + str(value)

func update_loops(value):
	loopLabel.text = 'Clones left: ' + str(value)
