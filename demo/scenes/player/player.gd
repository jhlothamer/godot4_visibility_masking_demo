class_name Player
extends CharacterBody2D

const JOY_AXIS_DEAD_ZONE = .2


@export var speed := 400.0


func _get_move_vector() -> Vector2:
	return Vector2(Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down"))


func _get_look_angle() -> float:
	return global_position.angle_to_point(get_global_mouse_position())


func _physics_process(_delta: float) -> void:
	global_rotation = lerp_angle(global_rotation, _get_look_angle(), .2)
	
	var v := _get_move_vector()
	if v == Vector2.ZERO:
		return

	velocity = v.normalized() * speed
	var _discard = move_and_slide()
