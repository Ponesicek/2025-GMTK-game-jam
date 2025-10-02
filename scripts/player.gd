## Player character controller with time-loop mechanics.
## Handles movement, clone creation, and replay of recorded actions.
extends CharacterBody2D

# Mapping of input actions to direction vectors (grid based)
const inputs : Dictionary[String, Vector2] = {
	"move_right": Vector2.RIGHT,
	"move_left": Vector2.LEFT,
	"move_down": Vector2.DOWN,
	"move_up": Vector2.UP,
	"wait": Vector2.ZERO
}

# Size of one grid cell (tiles are 32x32)
const grid_size : int = 32

## True if this is a clone playing back recorded moves
var clone : bool = false

## Absolute positions per committed move (first is spawn position)
var step_history : Array[Vector2] = []
## Index for clone playback during replay
var replay_step : int = 0

## How many boxes this player can push at once (-1 = unlimited)
var push_limit : int = -1
## How many loops/clones can still be created
var remaining_loops : int
## How many steps the player can still take
var remaining_steps : int
## When true, player slides continuously on fast tiles
var onFastLine : bool = false

## Whether this player instance can create clones
var can_create_clones : bool = false

## Color palette for clone visual differentiation
var clone_colors : Array[Color] = [
	Color('0000ff'), Color('00ff00'), Color('ff0000'),
	Color('7c00b5'), Color('94d121'), Color('e77239'),
	Color('ff28ea'), Color('00fff7'), Color('b06200'),
	Color('ff1b99'), Color('4bf983'), Color('ffea28'),
]

@onready var ray_cast_2d : RayCast2D = $PlayerRaycast
@onready var ray_cast_fast : RayCast2D = $RayCastFast
@onready var player_sprite : Sprite2D = $PlayerSprite
@onready var level_ui = get_tree().get_root().get_node("level/UI")
@onready var level : Node2D = get_tree().get_root().get_node("level")

## Initialize step history with the starting position
func _init_history():
	step_history.clear()
	step_history.append(position)

## Check if the player can push a movable object in the given direction
## Returns true if the push was successful
func _can_push(cast: RayCast2D, delta: Vector2) -> bool:
	var collider = cast.get_collider()
	if collider and "move" in collider:
		return collider.move(delta, push_limit)
	return false

## Move the player in the specified direction (grid-based).
## Handles both normal movement and sliding on fast tiles.
## Returns true if the move was successful
func move(destination: Vector2) -> bool:
	if destination == Vector2.ZERO:
		return true
	if not onFastLine:
		ray_cast_2d.target_position = destination
		ray_cast_2d.force_raycast_update()
		if not ray_cast_2d.is_colliding():
			position += destination
			return true
		if _can_push(ray_cast_2d, destination):
			position += destination
			return true
		return false
	# Fast line movement - slide until hitting an obstacle
	var dir := destination
	var slid := false
	var safety := 50
	while safety > 0:
		safety -= 1
		ray_cast_2d.target_position = dir
		ray_cast_2d.force_raycast_update()
		if not ray_cast_2d.is_colliding():
			position += dir
			slid = true
			continue
		if _can_push(ray_cast_2d, dir):
			position += dir
			slid = true
		break
	if safety == 0:
		push_warning("Fast line movement reached safety limit")
	return slid

## Undo the last action (for clones: go back in replay, for player: restore last position)
func undo() -> void:
	if clone:
		replay_step -= 1
		position = step_history[replay_step % step_history.size()]
	else:
		if step_history.size() > 1:
			var last_position = step_history[-2]
			step_history.pop_back()
			position = last_position
			remaining_steps += 1
			level_ui.update_steps(remaining_steps)

## End the current loop and convert to a clone (or reset clone to start)
func end_loop() -> void:
	if not clone:
		clone = true
		player_sprite.modulate = Color(clone_colors[randi() % clone_colors.size()], 0.5)
	position = step_history[0]
	replay_step = 0

## Advance one step (for clones: replay next move, original does nothing here)
func step() -> void:
	if clone:
		if (replay_step % step_history.size()) == (step_history.size() - 1):
			position = step_history[0]
		else:
			var delta = step_history[(replay_step + 1) % step_history.size()] - step_history[replay_step % step_history.size()]
			move(delta)
		replay_step += 1

## Reset to the beginning of the loop
func reset_loop() -> void:
	position = step_history[0]
	replay_step = 0
	if not clone:
		remaining_steps += step_history.size() - 1
		level_ui.update_steps(remaining_steps)
		_init_history()

## Initialize player with level settings and connect signals
func _ready():

	remaining_steps = level.step_limit

	push_limit = level.push_limit

	can_create_clones = level.can_loop

	remaining_loops = level.loop_limit

	level.undo.connect(Callable(self, "undo"))

	level.end_loop.connect(Callable(self, "end_loop"))

	level.step.connect(Callable(self, "step"))

	level.reset_loop.connect(Callable(self, "reset_loop"))

	level_ui.update_steps(remaining_steps)

	level_ui.update_loops(remaining_loops)

	_init_history()

## Handle player input for movement and loop creation
func _unhandled_input(event: InputEvent) -> void:
	# Ignore input for clones
	if clone:
		return
	# If no steps remain, allow only loop-end (handled below) and ignore movement
	if remaining_steps == 0:
		return

	# Handle creating a clone / ending current loop
	if event.is_action_pressed("end_loop") and remaining_loops > 0:
		remaining_loops -= 1
		level_ui.update_loops(remaining_loops)
		level.loop_limit = remaining_loops
		level.step_limit = remaining_steps
		level.force_end_loop()
		return

	# Process movement / wait actions
	for action in inputs.keys():
		if event.is_action_pressed(action):
			var destination: Vector2 = inputs[action] * float(grid_size)
			if move(destination):
				step_history.append(position)
				remaining_steps -= 1
				level_ui.update_steps(remaining_steps)
				level.force_step()
			return  # Consume this input event
