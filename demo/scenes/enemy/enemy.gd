extends CharacterBody2D


@export var _player:Node2D


func _ready() -> void:
	if !_player:
		set_physics_process(false)


func _physics_process(_delta: float) -> void:
	var look_angle = global_position.angle_to_point(_player.global_position)
	global_rotation = lerp_angle(global_rotation, look_angle, .1)
