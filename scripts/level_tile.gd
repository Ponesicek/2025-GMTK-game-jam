extends Button

signal level_selected(scene_path: String)

@export var level_number: int = 0
@export var scene_path: String = ""
@export var icon_tex: Texture2D

@onready var icon_rect: TextureRect = $VBox/Icon
@onready var label: Label = $VBox/Label

func setup(num: int, scene: String, icon_texture: Texture2D):
	level_number = num
	scene_path = scene
	icon_tex = icon_texture
	label.text = "Level %d" % num
	if icon_texture:
		icon_rect.texture = icon_texture
	custom_minimum_size = Vector2(180,180)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

func _pressed():
	emit_signal("level_selected", scene_path)
