## Animated door that can be opened/closed via buttons or wires.
## Blocks player/box movement when closed, allows passage when open.
extends Area2D

@onready var animation_player = $AnimatedSprite2D
@onready var level : Node2D = get_tree().get_root().get_node('level')

## Initialize door in closed state and connect to level signals
func _ready() -> void:
	level.end_loop.connect(end_loop)
	level.reset_loop.connect(reset_loop)
	animation_player.set_frame(0)
	set_collision_layer_value(4, true)

## Open the door and disable collision
func open_door() -> void:
	set_collision_layer_value(4, false)
	animation_player.play("open")

## Close the door and enable collision
func close_door() -> void:
	set_collision_layer_value(4, true)
	animation_player.play("close")

## Change door state based on button/wire activation
func state_change(state: bool) -> void:
	if state:
		open_door()
	else:
		close_door()

## Reset door to closed state when loop ends
func end_loop() -> void:
	animation_player.set_frame(0)
	set_collision_layer_value(4, true)

## Reset door (same as end_loop)
func reset_loop() -> void:
	end_loop()
