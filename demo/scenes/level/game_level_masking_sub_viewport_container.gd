extends Control

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var ek:InputEventKey = event
		if ek.keycode == KEY_ESCAPE and ek.pressed:
			get_tree().quit()
	
