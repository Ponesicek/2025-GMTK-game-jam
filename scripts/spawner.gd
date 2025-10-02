## Player spawner that can be pushed like a box and spawns new player clones.
## When a loop ends, creates a new player instance at its position.
extends Area2D

## Size of one grid cell (tiles are 32x32)
const GRID_SIZE : int = 32

@onready var ray_cast_2d : RayCast2D = $BoxRaycast
@onready var level : Node2D = get_tree().get_root().get_node('level')
@onready var tile_set : TileMapLayer = level.get_node('BGTileMapLayer')
@onready var animation_player : AnimatedSprite2D = $AnimatedSprite2D

## Scene to instantiate when spawning a new player
var player_scene : PackedScene = preload('res://scenes/tiles/Player.tscn')

## History of spawner positions for each step
var step_history : Array[Vector2] = []

## Initialize spawner and connect to level signals
func _ready():
	animation_player.play("default_1")
	level.undo.connect(undo)
	level.step.connect(step)
	level.end_loop.connect(end_loop)
	level.reset_loop.connect(reset_loop)
	init_history()

## Initialize position history with current position
func init_history() -> void:
	step_history.clear()
	step_history.append(position)

## Attempt to move the spawner in the given direction.
## Returns true if move was successful, false if blocked.
## Supports pushing other movable objects (respecting push limit).
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

## Spawn a new player clone when loop ends, then reset to starting position
func end_loop() -> void:
	var new_player = player_scene.instantiate()
	new_player.position = position + Vector2(GRID_SIZE, 0)
	tile_set.add_child(new_player)
	position = step_history[0]
	init_history()

## Reset spawner to starting position
func reset_loop() -> void:
	position = step_history[0]
	init_history()
