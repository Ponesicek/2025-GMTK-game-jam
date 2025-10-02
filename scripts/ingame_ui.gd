## In-game menu UI for pausing and exiting.
## Provides options to return to main menu or exit to desktop.
extends Control

## Return to main menu
func _on_exit_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

## Exit the game
func _on_exit_desktop_pressed():
	get_tree().quit()
