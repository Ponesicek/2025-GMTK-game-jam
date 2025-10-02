## Level selection button component.
## Loads the specified level when the play button is pressed.
extends VBoxContainer

## Path to the level scene file
@export var path: String

## Load and start the specified level
func _on_play_button_pressed():
	get_tree().change_scene_to_file(path)
