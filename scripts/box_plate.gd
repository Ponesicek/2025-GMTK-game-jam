## Pressure plate that activates when a box (or movable object) is placed on it.
## Triggers state changes in connected wires and doors.
extends Area2D

## Deactivate connected objects when box exits the plate
func _on_area_exited(body):
	if body.get_collision_layer_value(3):
		for i in get_overlapping_areas():
			if 'state_change' in i:
				i.state_change(false)

## Activate connected objects when box enters the plate
func _on_area_entered(body):
	if body.get_collision_layer_value(3):
		for i in get_overlapping_areas():
			if 'state_change' in i:
				i.state_change(true)
