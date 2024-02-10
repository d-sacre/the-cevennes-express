tool
extends Spatial

################################################################################
################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
################################################################################
const PLACEHOLDER_TILE : Resource = preload("res://assets/3D/tiles/placeholder/hexTile_placeholder.tscn")
const BASE_TILE : Resource = preload("res://assets/3D/tiles/placeable/base/hexTile_base.tscn")

################################################################################
################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
################################################################################
const TILE_SIZE : float = 1.0
const FLOATING_TILE_DISTANCE_ABOVE_GRID : float = 1.0
const INDEX_OUT_OF_BOUNDS : int = -1

const _highlight_persistence_default : Dictionary = {
	"void": {
		"persistence": true,
		"intensity": 1
	}
}

const _rotation_persistence_defaults : Dictionary = {
	"default" : {
		"persistence": false,
		"mode": "always" # Available Options: "always", "type"
	},
	"creative" : {
		"persistence": true,
		"mode": "always" # Available Options: "always", "type"
	}
}

################################################################################
################################################################################
#### PUBLIC MEMBER VARIABLES ###################################################
################################################################################
################################################################################
var tile_reference : Array = []
var floating_tile_reference = self # REMARK: Always needs a reference, even when no floating tile
var floating_tile_rotation : int = 0 # REMARK: Angle in degree, but only allowing 60° increments!

################################################################################
################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
################################################################################
var _hex_grid_size_x : int = 10
var _hex_grid_size_y : int = 10

var _current_grid_index : int = self.INDEX_OUT_OF_BOUNDS
var _last_grid_index : int = self.INDEX_OUT_OF_BOUNDS
var _last_index_within_grid_boundary : int = 0
var _last_index_within_grid_boundary_highlight : int = 0

var _lastTileDefinitionUuid : String = ""

# FUTURE: Add more contexts, allow for highlight intensity modulation/mixing with
# other highlights (needs also work in placeholderManager.gd, tileManager.gd)
var _highlight_persistence : Dictionary = {
	"void": {
		"persistence": true,
		"intensity": 1
	}
}

var _rotation_persistence : Dictionary = {
	"persistence": false,
	"mode": "always" # Available Options: "always", "type"
}

# REMARK: Should be outsourced with complete floating tile logic into own scene
var _floating_tile_position_current : Vector3 = Vector3(0,0,0)
var _floating_tile_position_requested : Vector3 = Vector3(0,0,0)
var _floating_tile_asmr : Vector2 = Vector2(0,0)
var _floating_tile_movement_by_asmr_allowed : bool = true
var _last_floating_tile_asmr : Vector2 = Vector2(0,0)

var _managerReferences : Dictionary = {}

################################################################################
################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
################################################################################
func _manage_rotation_persistence() -> void:
	if not self._rotation_persistence["persistence"]:
		self.floating_tile_rotation = 0
	else:
		if str(self._rotation_persistence["mode"]) == "always":
			pass
		elif str(self._rotation_persistence["mode"]) == "type":
			if self.floating_tile_reference != self: # REMARK: Safety
				if self._lastTileDefinitionUuid == self.floating_tile_reference.tile_definition_uuid:
					pass
				else:
					self.floating_tile_rotation = 0
					self._lastTileDefinitionUuid = self.floating_tile_reference.tile_definition_uuid
			else:
				self.floating_tile_rotation = 0
				print("Error: Floating Tile does not exist")

func _move_floating_tile_by_action_strength(asmr : Vector2) -> void:
	var _tmp_current_index : int 

	if asmr != Vector2(0,0):
		if not self.is_current_grid_index_out_of_bounds():
			_tmp_current_index = self._current_grid_index
		else:
			_tmp_current_index = self._last_index_within_grid_boundary

		var _tmp_index2D : Vector2 = self._managerReferences["cppBridge"]._convert_1D_index_to_2D(_tmp_current_index)
		_tmp_index2D += asmr
		var _tmp_index1D : int = self._managerReferences["cppBridge"]._convert_2D_index_to_1D(_tmp_index2D)

		# DESCRIPTION: Check whether new index is valid
		# REMARK: Simplified case for a "square" grid; must be generalized!
		if _tmp_index1D <= self._hex_grid_size_x * self._hex_grid_size_y - 1: # DESCRIPTION: To prevent exceeding boundaries at the top
			if _tmp_index1D >= 0: # DESCRIPTION: To prevent exceeding boundaries at the bottom
				if _tmp_index1D != self._current_grid_index:
					# DESCRIPTION: To prevent jumping from one edge of the grid to the other
					if not ((int(_tmp_index2D.x) == self._hex_grid_size_x) or (int(_tmp_index2D.x) == -1)):
						self.set_last_grid_index_to_current()
						self.set_current_grid_index(_tmp_index1D)
						self._last_index_within_grid_boundary = _tmp_index1D

						var _tmp_camera_target_position : Vector3 = (self.get_current_grid_element_information())["reference"].transform.origin
						var _camera_offset : Vector3 = self._managerReferences["cameraManager"].CAMERA_POSITION_DEFAULT

						_tmp_camera_target_position.y += _camera_offset.y
						_tmp_camera_target_position.z += _camera_offset.z

						self._managerReferences["cameraManager"].request_new_position(_tmp_camera_target_position)

						if self.floating_tile_reference != self:
							self.move_floating_tile_and_highlight()
							 


# func _move_floating_tile_by_action_strength(asmr : Vector2) -> void:
# 	self._last_floating_tile_asmr = asmr
# 	var _tmp_current_index : int 

# 	if not self.is_current_grid_index_out_of_bounds():
# 		_tmp_current_index = self._current_grid_index
# 	else:
# 		_tmp_current_index = self._last_index_within_grid_boundary

# 	var _tmp_index2D : Vector2 = self._managerReferences["cppBridge"]._convert_1D_index_to_2D(_tmp_current_index)
# 	_tmp_index2D += self._last_floating_tile_asmr
# 	var _tmp_index1D : int = self._managerReferences["cppBridge"]._convert_2D_index_to_1D(_tmp_index2D)

# 	# DESCRIPTION: Check whether new index is valid
# 	# REMARK: Simplified case for a "square" grid; must be generalized!
# 	if _tmp_index1D <= self._hex_grid_size_x * self._hex_grid_size_y - 1: # DESCRIPTION: To prevent exceeding boundaries at the top
# 		if _tmp_index1D >= 0: # DESCRIPTION: To prevent exceeding boundaries at the bottom
# 			# DESCRIPTION: To prevent jumping from one edge of the grid to the other
# 			if not ((int(_tmp_index2D.x) == self._hex_grid_size_x) or (int(_tmp_index2D.x) == -1)):
# 				self.set_last_grid_index_to_current()
# 				self.set_current_grid_index(_tmp_index1D)
# 				self._last_index_within_grid_boundary = _tmp_index1D

# 				if self.floating_tile_reference != self:
# 					self.move_floating_tile_and_highlight()

# 					var _tmp_grid_position = self.floating_tile_reference.transform.origin
# 					_tmp_grid_position -= Vector3(0,self.FLOATING_TILE_DISTANCE_ABOVE_GRID,0)
					
# 					# return _tmp_grid_position

# 	# return Vector3.INF

# func _calculate_new_requested_position(time : float) -> Vector3:
# 	var _tmp_current_index : int = 0

# 	var _tmp_floating_tile_position = self.tile_reference[self._last_index_within_grid_boundary]["reference"].transform.origin
# 	_tmp_floating_tile_position.y += self.FLOATING_TILE_DISTANCE_ABOVE_GRID


# 	if self._floating_tile_asmr != Vector2(0,0):
# 		if not self.is_current_grid_index_out_of_bounds():
# 			_tmp_current_index = self._current_grid_index
# 		else:
# 			_tmp_current_index = self._last_index_within_grid_boundary

# 		var _tmp_index2D : Vector2 = self._managerReferences["cppBridge"]._convert_1D_index_to_2D(_tmp_current_index)
# 		_tmp_index2D += Vector2(int(self._floating_tile_asmr.x * 50* time), int(self._floating_tile_asmr.y *50* time))
		
# 		var _tmp_index1D : int = self._managerReferences["cppBridge"]._convert_2D_index_to_1D(_tmp_index2D)
# 		print(_tmp_index2D, " ", _tmp_index1D)
# 		# DESCRIPTION: Check whether new index is valid
# 		# REMARK: Simplified case for a "square" grid; must be generalized!
# 		if _tmp_index1D <= self._hex_grid_size_x * self._hex_grid_size_y - 1: # DESCRIPTION: To prevent exceeding boundaries at the top
# 			if _tmp_index1D >= 0: # DESCRIPTION: To prevent exceeding boundaries at the bottom
# 				# DESCRIPTION: To prevent jumping from one edge of the grid to the other
# 				if not ((int(_tmp_index2D.x) == self._hex_grid_size_x) or (int(_tmp_index2D.x) == -1)):
# 					# DESCRIPTION: Manage grid indices and highlighting
# 					self.set_last_grid_index_to_current()
# 					self.set_current_grid_index(_tmp_index1D)
# 					self._last_index_within_grid_boundary = _tmp_index1D

# 					self.manage_highlighting_due_to_cursor()

# 					# DESCRIPTION: Calculate the new floating tile position
# 					_tmp_floating_tile_position = self.tile_reference[_tmp_index1D]["reference"].transform.origin
# 					_tmp_floating_tile_position.y += self.FLOATING_TILE_DISTANCE_ABOVE_GRID

# 	return _tmp_floating_tile_position

################################################################################
################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
################################################################################
func initialize(mr : Dictionary) -> void:
	self._managerReferences = mr

# creates a hexagonal grid and fills it with the placeholder tiles
# REMARK: For performance reasons, this should be changed in the future
# to a different approach (e.g. calculating all the positions, but 
# only instancing the tiles which are set from the start)
func generate_grid(x : int, y : int) -> void:
	self._hex_grid_size_x = x 
	self._hex_grid_size_y = y

	var _is_tile_offset_y : bool = false

	for _grid_index in range(self._hex_grid_size_x*self._hex_grid_size_y):
		var _tile_coordinates : Vector2 = Vector2.ZERO
		_tile_coordinates.x = (_grid_index % self._hex_grid_size_x) * TILE_SIZE * cos(deg2rad(30))
		_tile_coordinates.y = (_grid_index / self._hex_grid_size_x) * TILE_SIZE

		if _is_tile_offset_y:
			_tile_coordinates.y += TILE_SIZE/2

		_is_tile_offset_y = !_is_tile_offset_y

		var _tile = PLACEHOLDER_TILE.instance()
		add_child(_tile)
		self.tile_reference.append({"type": "placeholder", "reference": _tile})
		_tile.translate(Vector3(_tile_coordinates.x, 0, _tile_coordinates.y))
		_tile.initial_placeholder_configuration()
		_tile.grid_index = _grid_index

################################################################################
#### PUBLIC MEMBER FUNCTIONS: SETTER AND GETTER ################################
################################################################################
func set_last_grid_index(value : int) -> void:
	self._last_grid_index = value

func get_last_grid_index() -> int:
	return self._last_grid_index

func set_current_grid_index(value : int) -> void:
	self._current_grid_index = value

func get_current_grid_index() -> int:
	return self._current_grid_index

func set_last_index_within_grid_boundary(value : int) -> void:
	self._last_index_within_grid_boundary = value

func get_last_index_within_grid_boundary() -> int:
	return self._last_index_within_grid_boundary

func set_current_and_last_grid_index(current : int, last : int) -> void:
	self.set_current_grid_index(current)
	self.set_last_grid_index(last)

func set_last_grid_index_to_current() -> void:
	var _tmp : int = self.get_current_grid_index()
	self.set_last_grid_index(_tmp)

func set_last_index_within_grid_boundary_to_current() -> void:
	var _tmp : int = self.get_current_grid_index()
	self.set_last_index_within_grid_boundary(_tmp)

func set_current_grid_index_out_of_bounds() -> void:
	self.set_current_grid_index(self.INDEX_OUT_OF_BOUNDS)

# FUTURE: Needs to be extended to accept more parameters and not necessarily a fixed amount!
func set_highlight_persistence(mode : String, status : bool) -> void: 
	self._highlight_persistence[mode]["persistence"] = status

func load_rotation_persistence_default(name : String) -> void:
	self._rotation_persistence = self._rotation_persistence_defaults[name]

func set_rotation_persistence(status : bool, mode : String) -> void:
	self._rotation_persistence["persistence"] = status
	self._rotation_persistence["mode"] = mode

################################################################################
#### PUBLIC MEMBER FUNCTIONS: BOOL EXPRESSIONS #################################
################################################################################
func is_last_grid_index_equal_current() -> bool:
	return self._current_grid_index == self._last_grid_index

func is_current_grid_index_out_of_bounds() -> bool:
	return self._current_grid_index == self.INDEX_OUT_OF_BOUNDS

func is_highlight_persistence_void() -> bool:
	return self._highlight_persistence["void"]["persistence"]

################################################################################
#### PUBLIC MEMBER FUNCTIONS: GRID INFORMATION #################################
################################################################################
func get_current_grid_element_information() -> Dictionary:
	var _return : Dictionary = {}

	if self._current_grid_index != self.INDEX_OUT_OF_BOUNDS:
		_return = self.tile_reference[self._current_grid_index]

	return _return

################################################################################
#### PUBLIC MEMBER FUNCTIONS: GRID CELL HIGHLIGHTING ###########################
################################################################################
func set_single_grid_cell_highlight(index : int, highlight_status : bool) -> void:
	var _tile = self.tile_reference[index]["reference"]
	_tile.highlight = highlight_status
	_tile.change_material = true

# REMARK: Requires more logic to not interfer with chain highlighting set by the logic
func manage_highlighting_due_to_cursor() -> void:
	if self._current_grid_index != self.INDEX_OUT_OF_BOUNDS:
		self.set_single_grid_cell_highlight(self._current_grid_index, true)

	if self._last_grid_index != self.INDEX_OUT_OF_BOUNDS: # REMARK: This on its own erases the highlight of the last cursor position when cursor in void -> undesirable behavior if floating tile!
		# REMARK: Approach a bit hacky and unflexible for potential changes in the future
		if self.is_highlight_persistence_void(): # DESCRIPTION: When highlight persistence enabled, use last valid position for cursor highlight
			if self._last_index_within_grid_boundary != self.get_current_grid_index(): # DESCRIPTION: When the last valid grid position is not identical to the current one
				# DESCRIPTION: Copy the last index within grid boundaries to a storage variable and highlight
				# the tile at the corresponding position
				self._last_index_within_grid_boundary_highlight = self._last_index_within_grid_boundary 
				self.set_single_grid_cell_highlight(self._last_index_within_grid_boundary_highlight, true)
			else: # DESCRIPTION: If the last valid index within grid boundaries is identical to the current grid position
				# DESCRIPTION: If the highlighted cell is not identical with the currently valid last index within the boundaries,
				# than remove the highlight
				if self._last_index_within_grid_boundary_highlight != self._last_index_within_grid_boundary:
					self.set_single_grid_cell_highlight(self._last_index_within_grid_boundary_highlight, false)
			
			# DESCRIPTION: If last grid index is not identical to last index within grid boundaries,
			# than remove the highlight of the tile at last index to prevent leaving tiles highlighted
			# which should not be
			if self._last_grid_index != self._last_index_within_grid_boundary_highlight:
				self.set_single_grid_cell_highlight(self._last_grid_index, false)
		
		else:
			self.set_single_grid_cell_highlight(self._last_grid_index, false)
	else:
		if self.is_highlight_persistence_void(): # DESCRIPTION: When highlight persistence avtivated
			# DESCRIPTION: User did not move the cursor to the last highlighted tile
			if self._last_index_within_grid_boundary_highlight != self.get_current_grid_index():
				self.set_single_grid_cell_highlight(self._last_index_within_grid_boundary_highlight, false)

func set_status_placeholder_at_index(index : int, _possible : bool, _impossible : bool) -> void: # needs more arguments in the future to pass status
	var _tile = self.tile_reference[index]["reference"]

	# only temporary to test possible/impossible texture change
	if self.tile_reference[index]["type"] == "placeholder":
		_tile.placement_possible = _possible
		_tile.placement_impossible = _impossible
	
	_tile.change_material = true

func set_status_placeholder(_possible : bool, _impossible : bool) -> void:
	self.set_status_placeholder_at_index(self._current_grid_index, _possible, _impossible)

################################################################################
#### PUBLIC MEMBER FUNCTIONS: FLOATING TILE ####################################
################################################################################
func enable_floating_tile_movement_by_asmr() -> void:
	self._floating_tile_position_current = self.floating_tile_reference.transform.origin
	self._floating_tile_position_requested = self._floating_tile_position_current
	self._floating_tile_movement_by_asmr_allowed = true

func disable_floating_tile_movement_by_asmr() -> void:
	self._floating_tile_movement_by_asmr_allowed = false

func request_floating_tile_movement(asmr : Vector2) -> void:
	self._last_floating_tile_asmr = asmr
	print(asmr)
	self._move_floating_tile_by_action_strength(self._last_floating_tile_asmr)


# func move_floating_tile_by_action_strength(asmr : Vector2) -> Vector3:
# 	self._last_floating_tile_asmr = asmr
# 	var _tmp_current_index : int 

# 	if not self.is_current_grid_index_out_of_bounds():
# 		_tmp_current_index = self._current_grid_index
# 	else:
# 		_tmp_current_index = self._last_index_within_grid_boundary

# 	var _tmp_index2D : Vector2 = self._managerReferences["cppBridge"]._convert_1D_index_to_2D(_tmp_current_index)
# 	_tmp_index2D += self._last_floating_tile_asmr
# 	var _tmp_index1D : int = self._managerReferences["cppBridge"]._convert_2D_index_to_1D(_tmp_index2D)

# 	# DESCRIPTION: Check whether new index is valid
# 	# REMARK: Simplified case for a "square" grid; must be generalized!
# 	if _tmp_index1D <= self._hex_grid_size_x * self._hex_grid_size_y - 1: # DESCRIPTION: To prevent exceeding boundaries at the top
# 		if _tmp_index1D >= 0: # DESCRIPTION: To prevent exceeding boundaries at the bottom
# 			# DESCRIPTION: To prevent jumping from one edge of the grid to the other
# 			if not ((int(_tmp_index2D.x) == self._hex_grid_size_x) or (int(_tmp_index2D.x) == -1)):
# 				self.set_last_grid_index_to_current()
# 				self.set_current_grid_index(_tmp_index1D)
# 				self._last_index_within_grid_boundary = _tmp_index1D

# 				if self.floating_tile_reference != self:
# 					self.move_floating_tile_and_highlight()

# 					var _tmp_grid_position = self.floating_tile_reference.transform.origin
# 					_tmp_grid_position -= Vector3(0,self.FLOATING_TILE_DISTANCE_ABOVE_GRID,0)
					
# 					return _tmp_grid_position

# 	return Vector3.INF

func move_floating_tile_to(index : int) -> void:
	if index != self.INDEX_OUT_OF_BOUNDS: # ensures that tile does not move if cursor is over an area outside the allowed grid area
		if self.floating_tile_reference != self:
			var _grid_reference = self.tile_reference[index]["reference"]
			var _grid_position_physical = _grid_reference.transform.origin
			var _tmp_translation : Vector3 = Vector3(_grid_position_physical.x, FLOATING_TILE_DISTANCE_ABOVE_GRID, _grid_position_physical.z)
			self.floating_tile_reference.set_global_translation(_tmp_translation) # translate to above the desired grid position
			self.floating_tile_reference.grid_index = index
#			self._floating_tile_position_current = _tmp_translation
			

func create_floating_tile_at_index(index : int, tile_definition : Dictionary) -> void:
	# create tile and add it to the scene tree
	var _tile = BASE_TILE.instance()
	add_child(_tile)

	self.floating_tile_reference = _tile

	# DESCRIPTION: Configure the tile
	_tile.initial_tile_configuration(tile_definition)
	# REMARK: Collision needs to be switched off for all child elements, otherwise the raycast will falsely detect a hit,
	# which leads to jumping of the tile; includes all the assets that will be placed on the tile!
	# TO-DO: Write for loop to obtain all collision objects and disable them
	_tile.get_node("hexCollider/CollisionShape2").disabled = true

	# DESCRIPTION: Reset rotation according to rules if necessary, apply rotation and move to new position
	self._manage_rotation_persistence()
	self.floating_tile_reference.rotation_degrees = Vector3(0,self.floating_tile_rotation,0)
	self.move_floating_tile_to(index)

func create_floating_tile(tile_definition : Dictionary) -> void:
	self.create_floating_tile_at_index(self._last_index_within_grid_boundary, tile_definition) # Change

func get_floating_tile_definition_uuid_and_rotation() -> Dictionary:
	var _tmp_uuid_and_rotation : Dictionary = {}

	if self.floating_tile_reference != self: # REMARK: Safety to prevent issues when no floating tile exists
		_tmp_uuid_and_rotation["TILE_DEFINITION_UUID"] = self.floating_tile_reference.tile_definition_uuid
		var _floating_tile_rotation : int = self.floating_tile_reference.get_rotation_degrees().y
		_tmp_uuid_and_rotation["rotation"] = _floating_tile_rotation
	
	return _tmp_uuid_and_rotation

func delete_floating_tile() -> void:
	if self.floating_tile_reference != self: # REMARK: Safety to prevent issues when no floating tile exists
		# DESCRIPTION: Reset rotation according to rules if necessary;
		# REMARK: Has to be called before floating tile is queued free (will not work otherwise)
		self._manage_rotation_persistence()

		# DESCRIPTION: Delete the floating tile and reset the reference variable
		self.floating_tile_reference.queue_free()
		self.floating_tile_reference = self
		

func change_floating_tile_type(tile_definition : Dictionary) -> void:
	if self.floating_tile_reference != self: # REMARK: Safety to prevent issues when no floating tile exists
		var _index = self.floating_tile_reference.grid_index
		self.delete_floating_tile()
		self.create_floating_tile_at_index(_index, tile_definition) # REMARK: Seems to be the fix for "placement and removal of floating tile at index 0 when new tile definition is selected" bug
			
func rotate_floating_tile_clockwise() -> void:
	if self.floating_tile_reference != self: # REMARK: Safety to prevent issues when no floating tile exists
		self.floating_tile_rotation -= 60
		self.floating_tile_rotation = self.floating_tile_rotation % 360
		self.floating_tile_reference.rotation_degrees = Vector3(0,self.floating_tile_rotation,0)

func move_floating_tile_to_and_highlight(next : int) -> void:
	self.manage_highlighting_due_to_cursor()
	self.move_floating_tile_to(next)

func move_floating_tile_and_highlight() -> void:
	self.move_floating_tile_to_and_highlight(self._current_grid_index)

func replace_grid_object_at_index_with(index : int, replacement : Object, replacement_object_type : String) -> void:
	var _grid_element : Object = self.tile_reference[index]["reference"]
	var _grid_physical_position : Vector3 = _grid_element.transform.origin

	# DESCRIPTION: Set replacement object grid index and physically place it on grid layer 
	# REMARK: Perhaps apply animation/tween/smoothing
	replacement.grid_index = index
	replacement.transform.origin = _grid_physical_position 

	# DESCRIPTION: Replace reference and type with new data
	self.tile_reference[index]["reference"] = replacement
	self.tile_reference[index]["type"] = replacement_object_type

	# DESCRIPTION: Remove old grid element
	_grid_element.queue_free()

func place_floating_tile_at_index(index : int) -> void:
	# var _grid_element : Object = self.tile_reference[index]["reference"]
	var _ft_starting_position : Vector3 = floating_tile_reference.transform.origin
	var _grid_physical_position : Vector3 = self.tile_reference[index]["reference"].transform.origin

	if self.floating_tile_reference != self: # REMARK: Safety to prevent issues when no floating tile exists
		# for safety: check whether floating tile is still at the correct position
		if (_ft_starting_position.x == _grid_physical_position.x) and (_ft_starting_position.z == _grid_physical_position.z):
			self.replace_grid_object_at_index_with(index, self.floating_tile_reference, "tile")

			# Description: Collision needs to be switched on again on all child elements, 
			# otherwise the raycast will not detect the placed tile; 
			# includes all the assets that will be placed on the tile!
			# TO-DO: Write for loop to obtain all collision objects and re-enable them
			self.floating_tile_reference.get_node("hexCollider/CollisionShape2").disabled = false

			# DESCRIPTION: Reset rotation according to rules if necessary and free the floating tile reference
			# REMARK: has to be called before floating tile is queued free (will not work otherwise)
			self._manage_rotation_persistence()
			self.floating_tile_reference = self # clear the floating tile reference

func place_floating_tile() -> void:
	if self._current_grid_index != self.INDEX_OUT_OF_BOUNDS:
		self.place_floating_tile_at_index(self._current_grid_index)

################################################################################
#### PUBLIC MEMBER FUNCTIONS: PLACED TILE MANIPULATION #########################
################################################################################
func replace_tile() -> void:
	var _tmp_index : int = self.get_current_grid_index()
	if  _tmp_index != self.INDEX_OUT_OF_BOUNDS:
		self.place_floating_tile()

func get_tile_definition_uuid_from_tile_at_grid_index(index: int) -> String:
	var _tmp_string : String = ""

	if index != self.INDEX_OUT_OF_BOUNDS:
		if self.tile_reference[index]["type"] == "tile":
			_tmp_string = self.tile_reference[index]["reference"].tile_definition_uuid

	return _tmp_string

func get_tile_definition_uuid_from_current_grid_index() -> String:
	return self.get_tile_definition_uuid_from_tile_at_grid_index(self._current_grid_index)

func delete_tile() -> void:
	var _tmp_index : int = self.get_current_grid_index()
	if  _tmp_index != self.INDEX_OUT_OF_BOUNDS:

		# DESCRIPTION: Instantiate a placeholder object 
		var _tile = PLACEHOLDER_TILE.instance()
		add_child(_tile)
		_tile.initial_placeholder_configuration()

		self.replace_grid_object_at_index_with(_tmp_index, _tile, "placeholder")

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
# func _process(delta : float) -> void:
# 	if self._floating_tile_movement_by_asmr_allowed:
		
# 		self._floating_tile_position_requested = self._calculate_new_requested_position(delta)

# 		# DESCRIPTION: Catch case that position request is invalid
# 		if self._floating_tile_position_requested != Vector3.INF:
# 			self._floating_tile_position_current = self.floating_tile_reference.transform.origin
# 			# print("Requested: ", _floating_tile_position_requested, "Current", _floating_tile_position_current)
# 			if self._floating_tile_position_current != self._floating_tile_position_requested:
# 				self._floating_tile_position_current = self._floating_tile_position_current.linear_interpolate(self._floating_tile_position_requested,0.1)
# 				self.floating_tile_reference.transform.origin = self._floating_tile_position_current
		
func _process(delta : float) -> void:
	if self._floating_tile_movement_by_asmr_allowed:

		if self._last_floating_tile_asmr != Vector2(0,0):
			self._floating_tile_asmr += Vector2(abs(self._last_floating_tile_asmr.x), abs(self._last_floating_tile_asmr.y))
			if (int(self._floating_tile_asmr.x) % 64 == 63) and (int(self._floating_tile_asmr.y) % 64 != 63):
				self._move_floating_tile_by_action_strength(self._last_floating_tile_asmr)
			elif (int(self._floating_tile_asmr.x) % 64 != 63) and (int(self._floating_tile_asmr.y) % 64 == 63):
				self._move_floating_tile_by_action_strength(self._last_floating_tile_asmr)
			elif (int(self._floating_tile_asmr.x) % 64 == 63) and (int(self._floating_tile_asmr.y) % 64 == 63):
				self._move_floating_tile_by_action_strength(self._last_floating_tile_asmr)
			
		else:
			self._floating_tile_asmr = Vector2(0,0)

		
