## Step counter label (appears to be unused or legacy code).
## Note: The current implementation has a bug - it should use `str(value)` not `(steps_left - value)`.
extends Label

## Initial number of steps (hardcoded value, should come from level)
var steps_left = 7

## Update the steps remaining display
## Warning: This implementation appears incorrect and may not be used
func update_steps(value: int) -> void:
	text = "Steps left: " + str(value)
