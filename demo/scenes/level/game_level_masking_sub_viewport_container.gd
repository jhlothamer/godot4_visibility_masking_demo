extends Control

@onready var _desat_background:Sprite2D = $DesaturatedBackgroundSprite2D

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var ek:InputEventKey = event
		if ek.keycode == KEY_ESCAPE and ek.pressed:
			get_tree().quit()
	
