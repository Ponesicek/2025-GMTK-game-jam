extends Control

@onready var stepLabel: Label = $BoxContainer/GameInfo/Steps
@onready var loopLabel: Label = $BoxContainer/GameInfo/Loops

@onready var level = get_parent().get_parent()

@onready var win_menu: Control = $WinMenu
@onready var next_button: Button = $WinMenu/Center/Background/VBox/NextLevel
@onready var menu_button: Button = $WinMenu/Center/Background/VBox/Menu

var _next_level_path: String = ""
var _has_next: bool = false

func _ready() -> void:
	loopLabel.visible = level.can_loop
	if win_menu:
		win_menu.visible = false
		next_button.pressed.connect(_on_next_level_pressed)
		menu_button.pressed.connect(_on_menu_pressed)

func update_steps(value):
	stepLabel.text = "Steps left: " + str(value)

func update_loops(value):
	loopLabel.text = "Clones left: " + str(value)

func show_win_menu(next_level_path: String, has_next: bool) -> void:
	_next_level_path = next_level_path
	_has_next = has_next

	# Snap all player animations to completion before pausing
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player.has_method("snap_animation"):
			player.snap_animation()

	if win_menu:
		win_menu.visible = true
		next_button.disabled = not has_next
		get_tree().paused = true

func _on_next_level_pressed() -> void:
	if not _has_next or _next_level_path == "":
		return

	get_tree().paused = false
	if Engine.has_singleton("SceneTransition"):
		SceneTransition.change_scene(_next_level_path)
	else:
		get_tree().change_scene_to_file(_next_level_path)

func _on_menu_pressed() -> void:
	var menu_path := "res://scenes/ui/levels_menu.tscn"
	get_tree().paused = false
	if Engine.has_singleton("SceneTransition"):
		SceneTransition.change_scene(menu_path)
	else:
		get_tree().change_scene_to_file(menu_path)
