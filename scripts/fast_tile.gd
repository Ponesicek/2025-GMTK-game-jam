## Fast lane tile that makes the player slide continuously in one direction.
## Activates the player's onFastLine flag when entered.
extends Area2D

## Enable fast line mode when player enters the tile
func _on_body_entered(body: Node2D) -> void:
	if "onFastLine" in body:
		body.onFastLine = true

## Disable fast line mode when player exits the tile
func _on_body_exited(body: Node2D) -> void:
	if "onFastLine" in body:
		body.onFastLine = false
