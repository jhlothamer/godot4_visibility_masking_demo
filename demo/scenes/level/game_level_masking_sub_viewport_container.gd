extends Control

@onready var _game_viewport:SubViewport = $SubViewportContainer/SubViewport
@onready var _mask_viewport:SubViewport = $ViewMask
@onready var _background_viewport:SubViewport = $BackgroundSubViewportEx


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var ek:InputEventKey = event
		if ek.keycode == KEY_ESCAPE and ek.pressed:
			get_tree().quit()
			return
	if event.is_action_pressed("output_mask_screen_shot"):
		pass
		_save_viewport_image(_game_viewport, "game")
		_save_viewport_image(_mask_viewport, "mask")
		_save_viewport_image(_background_viewport, "background")
	

func _save_viewport_image(viewport:SubViewport, label:String) -> void:
	var image := viewport.get_texture().get_image()
	var file_path = "user://%s.png" % label
	image.save_png(file_path)
	print("Viewport image saved to %s" % file_path)

