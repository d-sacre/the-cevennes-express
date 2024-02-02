extends Camera

# This code is inspired by https://www.youtube.com/watch?v=42q6vZSvtxc

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal camera_raycast_result(current_collision_information) 

################################################################################
#### PUBLIC MEMBER VARIABLES ###################################################
################################################################################
# property to ensure that ray casting can be switched off when it might cause
# undesired behavior, e.g. when a menu pop-up is on screen
var raycasting_permitted : bool = false 

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _last_screenspace_position : Vector2 = Vector2(0,0)
var _last_collision : Array = [false, self]
var _current_collision : Array = [false, self]

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _initiate_raycast_from_last_position() -> void:
	if self.raycasting_permitted:
		# raycast operation
		var _worldspace = get_world().direct_space_state
		var _start = project_ray_origin(_last_screenspace_position) 
		var _end = project_position(_last_screenspace_position, 1000)
		var _raycast_result = _worldspace.intersect_ray(_start, _end)

		# if the raycast collides with an object
		if _raycast_result.has("collider"):
			var _collider_ref = _raycast_result["collider"]
			self._current_collision = [true, _collider_ref]
		else: # if the ray does not collide with an object
			# IMPORTANT: Always pass an (collider) object to the logic, even if no collision has occured
			# Passing a string or anything else fails, as the later comparison between last and current
			# collision will fail if both comparators are not of the same (object) type
			self._current_collision = [false, self]

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initiate_raycast_from_position(_position : Vector2) -> void:
	self._last_screenspace_position = _position
	self._initiate_raycast_from_last_position()

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _process(_delta : float) -> void:
	if self.raycasting_permitted: # if raycast operation is allowed
		# raycast called each frame, even if not necessary (e.g. no mouse or 
		# camera movement) could lead to performance issues when alot is going on
		# Advantage: Only few callers for raycast if centralized like this, which 
		# could help to omit problems with who calls/called when
		self._initiate_raycast_from_last_position() 
		if self._current_collision[0]:
			if self._last_collision[1] != self._current_collision[1]:
				emit_signal("camera_raycast_result", self._current_collision)
				self._last_collision = self._current_collision
		else:
			if self._last_collision[0] != self._current_collision[0]:
				emit_signal("camera_raycast_result", self._current_collision)
				self._last_collision = self._current_collision
