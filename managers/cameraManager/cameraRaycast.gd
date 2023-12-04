extends Camera

# This code is inspired by https://www.youtube.com/watch?v=42q6vZSvtxc

signal camera_raycast_result(current_collision_information) #camera_raycast_result(current_tile_index,last_tile_index)

# public member variables
# property to ensure that ray casting can be switched off when it might cause
# undesired behavior, e.g. when a menu pop-up is on screen
var raycasting_permitted : bool = false 

# private member variables
var _mouse_position : Vector2 = Vector2(0,0)
var _last_collision : Array = [false, self]
var _current_collision : Array = [false, self]


func get_object():
	# raycast
	var worldspace = get_world().direct_space_state
	var start = project_ray_origin(_mouse_position) 
	var end = project_position(_mouse_position,1000)
	var result = worldspace.intersect_ray(start,end)

	# if the raycast collides with an object
	if result.has("collider"):
		var collider_ref = result["collider"]
		return [true, collider_ref]
	else:
		return [false, self]
	
	# # if the raycast collides with an object
	# if result.has("collider"):
	# 	var collider_ref = result["collider"]
	# 	var parent_tile = collider_ref.get_parent()
	# 	return parent_tile.tile_index
	# else:
	# 	return -1

# REMARK: From a management/logic separation perspective not ideal to get the mouse 
# position in the camera script
func _input(event):
	if event is InputEventMouse:
		if raycasting_permitted:
			_mouse_position = event.position
		
		
func _process(delta):
	if raycasting_permitted: # if raycast operation is allowed
		_current_collision = get_object()
		if _current_collision[0]:
			if _last_collision[1] != _current_collision[1]:
				emit_signal("camera_raycast_result",_current_collision)
				_last_collision = _current_collision
		else:
			if _last_collision[0] != _current_collision[0]:
				emit_signal("camera_raycast_result",_current_collision)
				_last_collision = _current_collision

