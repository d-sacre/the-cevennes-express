extends Camera

# This code is inspired by https://www.youtube.com/watch?v=42q6vZSvtxc

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal camera_raycast_result(current_collision_information) 

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
# public member variables
# property to ensure that ray casting can be switched off when it might cause
# undesired behavior, e.g. when a menu pop-up is on screen
var raycasting_permitted : bool = false 

################################################################################
#### Private Member Variables ##################################################
################################################################################
var _last_screenspace_position : Vector2 = Vector2(0,0)
var _last_collision : Array = [false, self]
var _current_collision : Array = [false, self]

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################
func initiate_raycast_from_last_position() -> void:
	if raycasting_permitted:
		# raycast operation
		var worldspace = get_world().direct_space_state
		var start = project_ray_origin(_last_screenspace_position) 
		var end = project_position(_last_screenspace_position,1000)
		var raycast_result = worldspace.intersect_ray(start,end)

		# if the raycast collides with an object
		if raycast_result.has("collider"):
			var collider_ref = raycast_result["collider"]
			self._current_collision = [true, collider_ref]
		else: # if the ray does not collide with an object
			# IMPORTANT: Always pass an (collider) object to the logic, even if no collision has occured
			# Passing a string or anything else fails, as the later comparison between last and current
			# collision will fail if both comparators are not of the same (object) type
			self._current_collision = [false, self]

func initiate_raycast_from_position(position) -> void:
	_last_screenspace_position = position
	initiate_raycast_from_last_position()
	

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _process(delta) -> void:
	if raycasting_permitted: # if raycast operation is allowed
		# raycast called each frame, even if not necessary (e.g. no mouse or 
		# camera movement) could lead to performance issues when alot is going on
		# Advantage: Only few callers for raycast if centralized like this, which 
		# could help to omit problems with who calls/called when
		initiate_raycast_from_last_position() 
		if _current_collision[0]:
			if _last_collision[1] != _current_collision[1]:
				emit_signal("camera_raycast_result",_current_collision)
				_last_collision = _current_collision
		else:
			if _last_collision[0] != _current_collision[0]:
				emit_signal("camera_raycast_result",_current_collision)
				_last_collision = _current_collision
