## Finish line that triggers level completion and loads the next level.
## Uses regex to parse level number from filename and load sequential levels.
extends Area2D

@onready var level : Node2D = get_tree().get_root().get_node('level')

## Handle player reaching the finish line and transition to next level
func win(_trash):
	var level_name = level.scene_file_path
	var regex = RegEx.new()
	regex.compile(r"level_(\d+)\.tscn")
	var result = regex.search(level_name)
	var levelnumber = result.get_string(1)
	var next_level_path = "res://scenes/levels/level_%d.tscn" % (int(levelnumber) + 1)
	# Try to load next level, or return to level select if no more levels
	if ResourceLoader.exists(next_level_path):
		get_tree().call_deferred('change_scene_to_file', next_level_path)
		return
	get_tree().call_deferred('change_scene_to_file', "res://scenes/ui/levels_menu.tscn")
