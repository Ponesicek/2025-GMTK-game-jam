## Main menu UI providing navigation to play, credits, and exit.
extends Control

## Navigate to level selection menu
func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/levels_menu.tscn")

## Navigate to credits screen
func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/credits_menu.tscn")

## Exit the game
func _on_exit_pressed():
	get_tree().quit()
