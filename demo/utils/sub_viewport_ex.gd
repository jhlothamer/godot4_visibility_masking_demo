class_name SubViewportEx
extends SubViewport


@export var main_sub_viewport: SubViewport


func _ready() -> void:
	pass # Replace with function body.
	if !main_sub_viewport:
		printerr("SubViewportEx: Main Sub Viewport is required")
		return
	world_2d = main_sub_viewport.world_2d
	size = main_sub_viewport.size
	call_deferred("_add_camera")
	

func _add_camera() -> void:
	# wait 2 frames - so the CameraLimitArea2D gets chance to set the main view cam's limits
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# NOTE: since camera limits will change during the game
	#       we'll have to somehow monitor for that change
	#       And for that matter, active cameras change in some
	#       games!!
	
	var other_view_camera := main_sub_viewport.get_camera_2d()
	if !other_view_camera:
		return
	
	var this_view_camera:Camera2D = other_view_camera.duplicate()
	add_child(this_view_camera)

	var remote_transform := RemoteTransform2D.new()
	other_view_camera.add_child(remote_transform)
	remote_transform.remote_path = this_view_camera.get_path()
	
	this_view_camera.reset_smoothing()


# We need to keep the camera limits synced between views
# If this is not done then the position of the cameras will not match
# and the mask will be wrong.
# If you do not use camera limits, then you can skip this part
func _process(_delta: float) -> void:
	var main_cam := main_sub_viewport.get_camera_2d()
	var cam := get_camera_2d()
	if !main_cam or !cam:
		return
	if cam.limit_bottom != main_cam.limit_bottom:
		cam.limit_bottom = main_cam.limit_bottom
	if cam.limit_top != main_cam.limit_top:
		cam.limit_top = main_cam.limit_top
	if cam.limit_left != main_cam.limit_left:
		cam.limit_left = main_cam.limit_left
	if cam.limit_right != main_cam.limit_right:
		cam.limit_right = main_cam.limit_right


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var ek:InputEventKey = event
		if ek.keycode == KEY_P:
			var main_cam := main_sub_viewport.get_camera_2d()
			var cam := get_camera_2d()
			print("main cam pos: %s" % main_cam.global_position)
			print("this cam pos: %s" % cam.global_position)

func print_cam_data() -> void:
	var main_cam := main_sub_viewport.get_camera_2d()
	var cam := get_camera_2d()
	print("main cam pos: %s" % main_cam.global_position)
	print("this cam pos: %s" % cam.global_position)





