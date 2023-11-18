extends SubViewport


# reference to the SubViewport that contains the actual game level
@export var game_sub_viewport: SubViewport
# reference to the "player" - or whatever the view mask should follow in the game
@export var player:Player


# the mask light that actually creates the mask
@onready var _mask_light:PointLight2D = $ViewMaskNodes/FollowPlayer/MaskLight
# all nodes in the view mask are under one node for convenience
@onready var _follow_Player:Node2D = $ViewMaskNodes/FollowPlayer


func _ready() -> void:
	if !game_sub_viewport:
		printerr("ViewMask: Game Sub Viewport is required in order for the view mask to work")
		return
	if !player:
		printerr("ViewMask: Player is required in order for the view mask to work")
		return
	
	# give the view mask SubViewport the game SubViewport's World2D
	# this allows us to put everything in the game level scene - no node copying!
	world_2d = game_sub_viewport.world_2d
	# we want the mask size to match the game window's size
	size = game_sub_viewport.size
	
	# light 2d's need to be re-added to the tree so they will interact with occluders, etc.
	# from the game SubViewport.  (Hopefully in the future we won't need to re-add the light.)
	var mask_light_parent = _mask_light.get_parent()
	mask_light_parent.remove_child(_mask_light)
	mask_light_parent.add_child(_mask_light)
	
	_setup_player_remote_transform()
	call_deferred("_add_camera")


# This function adds a remote transform as a chile to the player and sets it to
# part of the view mask - mainly so the light follows the player
func _setup_player_remote_transform() -> void:
	var rt := RemoteTransform2D.new()
	player.add_child(rt)
	rt.remote_path = _follow_Player.get_path()


# this function adds a camera to the mask view - a duplicate of the game view's camera
func _add_camera() -> void:
	var other_view_camera := game_sub_viewport.get_camera_2d()
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
	var game_cam := game_sub_viewport.get_camera_2d()
	var mask_cam := get_camera_2d()
	if !game_cam or !mask_cam:
		return
	if mask_cam.limit_bottom != game_cam.limit_bottom:
		mask_cam.limit_bottom = game_cam.limit_bottom
	if mask_cam.limit_top != game_cam.limit_top:
		mask_cam.limit_top = game_cam.limit_top
	if mask_cam.limit_left != game_cam.limit_left:
		mask_cam.limit_left = game_cam.limit_left
	if mask_cam.limit_right != game_cam.limit_right:
		mask_cam.limit_right = game_cam.limit_right


