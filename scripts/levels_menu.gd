extends Control

@onready var grid: GridContainer = $Margin/VBox/Scroll/Grid
@onready var back_button: Button = $Margin/VBox/Buttons/Back
var level_tile_scene: PackedScene = preload("res://scenes/ui/LevelTile.tscn")

func _ready():
	_populate_levels()
	back_button.pressed.connect(_on_back_button_pressed)

func _populate_levels():
	print("Populating levels menu")
	for i in range(1, 15):
		var scene_path = "res://scenes/levels/level_%d.tscn" % i
		var icon_path = "res://assets/level_%d_icon.jpg" % i
		var icon_tex: Texture2D = null
		if ResourceLoader.exists(icon_path):
			icon_tex = load(icon_path)
		var tile = level_tile_scene.instantiate()
		tile.name = "LevelTile_%d" % i
		tile.level_selected.connect(_on_level_selected)
		grid.add_child(tile)
		tile.custom_minimum_size = Vector2(180,180)
		if tile.has_method("setup"):
			tile.setup(i, scene_path, icon_tex)

func _on_level_selected(scene_path: String):
	if Engine.has_singleton("SceneTransition"):
		SceneTransition.change_scene(scene_path)
	else:
		get_tree().change_scene_to_file(scene_path)

func _on_back_button_pressed():
	if Engine.has_singleton("SceneTransition"):
		SceneTransition.change_scene("res://scenes/ui/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
