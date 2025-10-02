## Pressure plate that activates when the player stands on it.
## Triggers state changes in connected wires and doors.
extends Area2D

## Deactivate connected objects when player exits the plate
func _on_body_exited(_body):
	for i in get_overlapping_areas():
		if 'state_change' in i:
			i.state_change(false)

## Activate connected objects when player enters the plate
func _on_body_entered(_body):
	for i in get_overlapping_areas():
		if 'state_change' in i:
			i.state_change(true)
