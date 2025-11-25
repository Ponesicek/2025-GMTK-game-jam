extends CharacterBody2D
#
# Player logic with:
#  - Canon mode (on_canon): continuous sliding along direction until blocked (each input = 1 step)
#  - Fast forward mode (on_fast_line): attempts to move exactly two tiles (or one if second blocked) per input using only 1 step
#  - Normal mode: single-tile (grid_size) movement
#  - Clone replay logic (time loop ghosts)
#  - Support for pushing chains of movable objects implementing move(delta, push_limit)
#

# Mapping of input actions to direction vectors (grid based)
const inputs : Dictionary[String, Vector2] = {
	"move_right": Vector2.RIGHT,
	"move_left": Vector2.LEFT,
	"move_down": Vector2.DOWN,
	"move_up": Vector2.UP,
	"wait": Vector2.ZERO
}

# Size of one grid cell
const grid_size : int = 32

var clone : bool = false

var step_history : Array[Vector2] = []				# Absolute positions in chronological order
var step_delta_history : Array[Vector2] = []	 # Deltas for each committed move (optional / analytics)
var replay_step : int = 0											 # Index into step_history for clone playback

var push_limit : int = -1
var remaining_loops : int
var remaining_steps : int

var on_canon : bool = false				 # Slide infinitely in the chosen direction
var on_fast_line : bool = false		 # Move 2 tiles (or as far as possible up to 2) per input

var can_create_clones : bool = false

var clone_colors : Array[Color] = [
	Color('0000ff'), Color('00ff00'), Color('ff0000'),
	Color('7c00b5'), Color('94d121'), Color('e77239'),
	Color('ff28ea'), Color('00fff7'), Color('b06200'),
	Color('ff1b99'), Color('4bf983'), Color('ffea28'),
]

@onready var ray_cast_2d : RayCast2D = $PlayerRaycast
@onready var ray_cast_fast : RayCast2D = $RayCastFast # Reserved (not strictly required after refactor)
@onready var player_sprite : Sprite2D = $PlayerSprite
@onready var level_ui = get_tree().get_root().get_node("level/UI/UIControl")
@onready var level : Node2D = get_tree().get_root().get_node("level")

# -------- Initialization --------
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

func _init_history():
	step_history.clear()
	step_history.append(position)

# -------- Movement Helpers --------
func _can_push(cast: RayCast2D, delta: Vector2) -> bool:
	var collider = cast.get_collider()
	if collider and "move" in collider:
		return collider.move(delta, push_limit)
	return false

func _setup_raycast(delta: Vector2):
	ray_cast_2d.target_position = delta
	ray_cast_2d.force_raycast_update()

# Attempt a single-tile step (delta must be exactly one grid cell vector or Vector2.ZERO).
# Returns true if movement (or push + movement) succeeded.
func _attempt_single_step(delta: Vector2) -> bool:
	if delta == Vector2.ZERO:
		return true
	_setup_raycast(delta)
	if not ray_cast_2d.is_colliding():
		position += delta
		return true
	if _can_push(ray_cast_2d, delta):
		position += delta
		return true
	return false

# Handle multi-tile (clone playback) displacement by breaking into grid increments to respect collisions/pushing.
# Returns true if any movement occurred.
func _attempt_multi_tile(delta: Vector2) -> bool:
	if delta == Vector2.ZERO:
		return true
	var moved_any := false
	var steps := 0
	var axis_vec := Vector2.ZERO
	if delta.x != 0 and delta.y == 0:
		steps = int(abs(delta.x) / grid_size)
		axis_vec = Vector2(sign(delta.x) * grid_size, 0)
	elif delta.y != 0 and delta.x == 0:
		steps = int(abs(delta.y) / grid_size)
		axis_vec = Vector2(0, sign(delta.y) * grid_size)
	else:
		# Diagonal or non-grid-aligned isn't expected; try direct (fallback)
		return _attempt_single_step(delta)
	for i in range(steps):
		if _attempt_single_step(axis_vec):
			moved_any = true
		else:
			break
	return moved_any

# Public move entry point.
# destination is expected to be (dir * grid_size) for a normal input OR possibly larger (clone replay).
func move(destination: Vector2) -> bool:
	# Wait action
	if destination == Vector2.ZERO:
		return true

	# Canon sliding: continuous until blocked/push fails
	if on_canon:
		var dir := destination
		var slid := false
		# Normalize dir to exactly one-tile increments
		if dir.length() > grid_size:
			if abs(dir.x) > 0 and abs(dir.y) == 0:
				dir = Vector2(sign(dir.x) * grid_size, 0)
			elif abs(dir.y) > 0 and abs(dir.x) == 0:
				dir = Vector2(0, sign(dir.y) * grid_size)
		var safety := 256
		while safety > 0:
			safety -= 1
			if not _attempt_single_step(dir):
				break
			slid = true
		return slid

	# Fast forward (two-tile movement). Treat as up to two discrete steps.
	if on_fast_line:
		var moved := false
		var one_step := destination
		# Ensure one_step is exactly one tile; if bigger, break it down at replay
		if one_step.length() > grid_size:
			# Split large destination into multi steps for consistency
			return _attempt_multi_tile(one_step)

		# First step
		if _attempt_single_step(one_step):
			moved = true
			# Second step only if first succeeded
			if _attempt_single_step(one_step):
				moved = true
		return moved

	# Normal single-tile move; if delta bigger (clone replay) break into increments
	if destination.length() > grid_size:
		return _attempt_multi_tile(destination)

	return _attempt_single_step(destination)

# -------- Input Handling --------
func _unhandled_input(event: InputEvent) -> void:
	if clone:
		return
	if remaining_steps == 0:
		return

	if event.is_action_pressed("end_loop") and remaining_loops > 0:
		remaining_loops -= 1
		level_ui.update_loops(remaining_loops)
		level.loop_limit = remaining_loops
		level.step_limit = remaining_steps
		level.force_end_loop()
		return

	for action in inputs.keys():
		if event.is_action_pressed(action):
			var destination: Vector2 = inputs[action] * float(grid_size)
			if move(destination):
				step_history.append(position)
				step_delta_history.append(destination)
				remaining_steps -= 1
				level_ui.update_steps(remaining_steps)
				level.force_step()
			return

# -------- Temporal / Loop Control --------
func undo():
	if clone:
		replay_step -= 1
		# modulo indexing safe even if negative by adding size
		var size := step_history.size()
		replay_step = (replay_step % size + size) % size
		position = step_history[replay_step]
	else:
		if step_history.size() > 1:
			var last_position = step_history[-2]
			step_history.pop_back()
			step_delta_history.pop_back()
			position = last_position
			remaining_steps += 1
			level_ui.update_steps(remaining_steps)

func end_loop():
	if not clone:
		clone = true
		player_sprite.modulate = Color(clone_colors[randi() % clone_colors.size()], 0.5)
	position = step_history[0]
	replay_step = 0

func step():
	if clone and step_history.size() > 0:
		if (replay_step % step_history.size()) == (step_history.size() - 1):
			position = step_history[0]
		else:
			var delta = step_history[(replay_step + 1) % step_history.size()] - step_history[replay_step % step_history.size()]
			move(delta) # Replays multi-tile paths using same logic (handles two-tile or slides)
		replay_step += 1

func reset_loop():
	position = step_history[0]
	replay_step = 0
	if not clone:
		remaining_steps += step_history.size() - 1
		level_ui.update_steps(remaining_steps)
		_init_history()
