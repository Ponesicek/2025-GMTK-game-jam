extends Area2D

@onready var ray_cast_2d : RayCast2D = $BoxRaycast
@onready var box_sprite : Sprite2D = $BoxSprite
@onready var level : Node2D = get_tree().get_root().get_node('level')

var step_history : Array[Vector2] = []

# Tween animation
const TWEEN_DURATION : float = 0.06
var current_tween : Tween = null

func _ready():
	level.undo.connect(undo)
	level.step.connect(step)
	level.end_loop.connect(end_loop)
	level.reset_loop.connect(reset_loop)
	init_history()
	
func init_history():
	step_history = []
	step_history.append(position)

# Animate movement using sprite offset
func _animate_movement(movement_delta: Vector2) -> void:
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	# Set sprite offset to where we were (negative of movement), then animate to original position
	var sprite_original_pos := Vector2(-16, -16)  # BoxSprite's default position
	box_sprite.position = sprite_original_pos - movement_delta
	current_tween = create_tween()
	current_tween.tween_property(box_sprite, "position", sprite_original_pos, TWEEN_DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func move(destination, limit):
	if limit > -1:
		limit -= 1
		if limit < 0:
			return false
	
	ray_cast_2d.target_position = destination
	ray_cast_2d.force_raycast_update()
	if not ray_cast_2d.is_colliding():
		position += destination
		_animate_movement(destination)
	elif ray_cast_2d.get_collision_mask_value(3) : 
		var movable = ray_cast_2d.get_collider()
		if 'move' in movable:
			if movable.move(destination, limit):
				position += destination
				_animate_movement(destination)
			else:
				return false
		else:
			return false
	else:
		return false
	return true

func step():
	step_history.append(position)

func undo():
	if not len(step_history) == 1:
		var start_pos := position
		var last_position = step_history[-2]
		step_history.pop_back()
		position = last_position
		var total_movement := position - start_pos
		if total_movement != Vector2.ZERO:
			_animate_movement(total_movement)

func end_loop():
	var start_pos := position
	position = step_history[0]
	init_history()
	var total_movement := position - start_pos
	if total_movement != Vector2.ZERO:
		_animate_movement(total_movement)

func reset_loop():
	end_loop()		#well the code is the same so why not?
