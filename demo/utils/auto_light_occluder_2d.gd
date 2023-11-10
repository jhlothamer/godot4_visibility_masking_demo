@tool
class_name AutoLightOccluder2D
extends LightOccluder2D


func _ready() -> void:
	if !occluder:
		occluder = OccluderPolygon2D.new()
	_process_parent_shape()
	if Engine.is_editor_hint():
		get_parent().connect("draw",Callable(self,"_on_draw"))

func _process_parent_shape() -> void:
	if !is_inside_tree():
		return
	var parent = get_parent()
	if parent is CollisionShape2D:
		if parent.shape is ConvexPolygonShape2D:
			_create_polygon_2d(parent.shape.points)
		elif parent.shape is ConcavePolygonShape2D:
			_create_polygon_2d(parent.shape.segments)
		elif parent.shape is CapsuleShape2D or parent.shape is RectangleShape2D:
			var shape_polygon = Shape2DUtil.make_polygon_from_shape(parent.shape)
			_create_polygon_2d(shape_polygon)
		elif parent.shape is CircleShape2D:
			var shape_polygon = Shape2DUtil.make_polygon_from_shape(parent.shape, 500)
			_create_polygon_2d(shape_polygon)
	elif parent is CollisionPolygon2D:
		_create_polygon_2d(parent.polygon)
	else:
		push_error("Parent must be a CollisionSHape2D or CollisionPolygon2D")


func _create_polygon_2d(p: PackedVector2Array) -> void:
	occluder.polygon = p


func _on_draw() -> void:
	_process_parent_shape()
	#queue_redraw()
