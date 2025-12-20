extends Area2D

@onready var level: Node2D = get_tree().get_root().get_node("level")
@onready var ui: Node = level.get_node("UI/UIControl")

func win(_body):
	var level_name := level.scene_file_path
	var next_level_path := ""
	var has_next := false

	var regex := RegEx.new()
	if regex.compile(r"level_(\d+)\.tscn") == OK:
		var result := regex.search(level_name)
		if result:
			var levelnumber := result.get_string(1)
			next_level_path = "res://scenes/levels/level_%d.tscn" % (int(levelnumber) + 1)
			has_next = ResourceLoader.exists(next_level_path)

	if ui and ui.has_method("show_win_menu"):
		ui.show_win_menu(next_level_path, has_next)
