extends CanvasLayer

var overlay: ColorRect
var tween: Tween

func _ready():
	overlay = ColorRect.new()
	overlay.color = Color(0,0,0,0)
	overlay.size = get_viewport().get_visible_rect().size
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

func _process(delta):
	# Keep size updated if window resizes
	overlay.size = get_viewport().get_visible_rect().size

func change_scene(path: String) -> void:
	await _fade_in()
	get_tree().change_scene_to_file(path)
	await _fade_out()

func _fade_in():
	tween = create_tween()
	tween.tween_property(overlay, "color", Color(0,0,0,1), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween.finished

func _fade_out():
	tween = create_tween()
	tween.tween_property(overlay, "color", Color(0,0,0,0), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween.finished
