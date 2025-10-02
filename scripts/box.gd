## Movable box that can be pushed by the player and records its movement history.
## Supports undo/redo and loop reset functionality.
extends Area2D

@onready var ray_cast_2d : RayCast2D = $BoxRaycast
@onready var level : Node2D = get_tree().get_root().get_node('level')

## History of box positions for each step
var step_history : Array[Vector2] = []

## Initialize box and connect to level signals
func _ready():
	level.undo.connect(undo)
	level.step.connect(step)
	level.end_loop.connect(end_loop)
	level.reset_loop.connect(reset_loop)
	init_history()

## Initialize position history with current position
func init_history() -> void:
	step_history = []
	step_history.append(position)

## Attempt to move the box in the given direction.
## Returns true if move was successful, false if blocked.
## Supports pushing other boxes (respecting push limit).
func move(destination: Vector2, limit: int) -> bool:
	if limit > -1:
		limit -= 1
		if limit < 0:
			return false
	
	ray_cast_2d.target_position = destination
	ray_cast_2d.force_raycast_update()
	if not ray_cast_2d.is_colliding():
		position += destination
	elif ray_cast_2d.get_collision_mask_value(3) : 
		var movable = ray_cast_2d.get_collider()
		if 'move' in movable:
			if movable.move(destination, limit):
				position += destination
			else:
				return false
		else:
			return false
	else:
		return false
	return true

## Record current position in history when a step occurs
func step() -> void:
	step_history.append(position)

## Undo last move by restoring previous position
func undo() -> void:
	if step_history.size() > 1:
		var last_position = step_history[-2]
		step_history.pop_back()
		position = last_position

## Reset box to starting position when loop ends
func end_loop() -> void:
	position = step_history[0]
	init_history()

## Reset loop (same as end_loop for boxes)
func reset_loop() -> void:
	end_loop()
