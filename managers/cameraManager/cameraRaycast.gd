extends Camera


signal camera_raycast_result(current_tile_index,last_tile_index)

#source: https://www.youtube.com/watch?v=42q6vZSvtxc
var mouse_position : Vector2 = Vector2()

var _last_tile_index : int = -1
var _current_tile_index : int

func get_object():
	# raycast
	var worldspace = get_world().direct_space_state
	var start = project_ray_origin(mouse_position) 
	var end = project_position(mouse_position,1000)
	var result = worldspace.intersect_ray(start,end)
	
	# if the raycast collides with an object
	if result.has("collider"):
		var collider_ref = result["collider"]
		var parent_tile = collider_ref.get_parent()
		return parent_tile.tile_index
	else:
		return -1

func _input(event):
	if event is InputEventMouse:
		mouse_position = event.position
		
		
func _process(delta):
	_current_tile_index = get_object()
	if _last_tile_index != _current_tile_index:
		emit_signal("camera_raycast_result",_current_tile_index, _last_tile_index)
		_last_tile_index = _current_tile_index
