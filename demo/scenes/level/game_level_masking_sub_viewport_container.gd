extends Control

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var ek:InputEventKey = event
		if ek.keycode == KEY_P:
			$BackgroundSubViewportEx.print_cam_data()
