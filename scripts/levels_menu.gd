## Level selection menu UI.
## Displays available levels and provides navigation back to main menu.
extends Control

## Return to main menu
func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
