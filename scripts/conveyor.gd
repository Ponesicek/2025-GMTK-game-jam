extends Area2D

@export var direction: Vector2 = Vector2.RIGHT

@onready var level : Node2D = get_tree().get_root().get_node("level")

func _ready() -> void:
	level.step.connect(step)

func step() -> void:
	# Check for overlapping bodies (Player) and areas (Box)
	# Note: Conveyor is Area2D. 
	# Player is CharacterBody2D (Collision layer 1?)
	# Box is Area2D (Collision layer 2?) (from conveyor.tscn mask=2)
	
	var push_limit = level.push_limit
	var move_vec = direction * 32 # grid_size assumed 32 from player.gd
	
	for body in get_overlapping_bodies():
		if body.has_method("move"):
			body.move(move_vec, push_limit)
			
	for area in get_overlapping_areas():
		if area.has_method("move"):
			area.move(move_vec, push_limit)

func _on_area_entered(area: Area2D) -> void:
	pass

func _on_area_exited(area: Area2D) -> void:
	pass
