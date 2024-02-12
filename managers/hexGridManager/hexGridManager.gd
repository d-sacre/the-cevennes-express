# tool
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
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
################################################################################
var _hex_grid_size_x : int = 10
var _hex_grid_size_y : int = 10

var _gridReferenceArray : Array = []

var _current_grid_index : int = self.INDEX_OUT_OF_BOUNDS
var _last_grid_index : int = self.INDEX_OUT_OF_BOUNDS
var _last_index_within_grid_boundary : int = 0
var _last_index_within_grid_boundary_highlight : int = 0

var _floatingTileReference = self # REMARK: Always needs a reference, even when no floating tile
var _floatingTileRotation : int = 0 # REMARK: Angle in degree, but only allowing 60° increments!
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

var _managerReferences : Dictionary = {}

################################################################################
################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
################################################################################
onready var _floatingCursor : Spatial = get_parent().get_node("floatingCursor")
onready var _gridObjects : Node = get_parent().get_parent().find_node("objects")

################################################################################
################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
################################################################################
func _manage_rotation_persistence() -> void:
	if not self._rotation_persistence["persistence"]:
		self._floatingTileRotation = 0
	else:
		if str(self._rotation_persistence["mode"]) == "always":
			pass
		elif str(self._rotation_persistence["mode"]) == "type":
			if self.is_floating_tile_reference_valid(): # REMARK: Safety
				if self._lastTileDefinitionUuid == self._floatingTileReference.tile_definition_uuid:
					pass
				else:
					self._floatingTileRotation = 0
					self._lastTileDefinitionUuid = self._floatingTileReference.tile_definition_uuid
			else:
				self._floatingTileRotation = 0
				print("Error: Floating Tile does not exist")

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
		self._gridObjects.add_child(_tile) # REMARK: Not very pretty/safe; might have to find another way
		self._gridReferenceArray.append({"type": "placeholder", "reference": _tile})
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

func set_last_index_within_grid_boundary_highlight(value : int):
	self._last_index_within_grid_boundary_highlight = value

func get_last_index_within_grid_boundary_highlight() -> int:
	return self._last_index_within_grid_boundary_highlight

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

func set_last_grid_index_within_boundary_highlight_to_last_grid_index_within_boundary() -> void:
	self.set_last_index_within_grid_boundary_highlight(self.get_last_index_within_grid_boundary())

func set_grid_element_information_at_index(index : int, type : String, ref : Object) -> void:
	if not self.is_index_out_of_bounds(index):
		self._gridReferenceArray[index]["type"] = type
		self._gridReferenceArray[index]["reference"] = ref

func get_grid_element_information_from_index(index : int) -> Dictionary:
	var _return : Dictionary = {}
	
	if not self.is_index_out_of_bounds(index):
		_return = self._gridReferenceArray[index]

	return _return

func get_grid_element_reference_from_index(index : int) -> Spatial:
	return (self.get_grid_element_information_from_index(index))["reference"]

func get_current_grid_element_information() -> Dictionary:
	return get_grid_element_information_from_index(self.get_current_grid_index())

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
func is_index_out_of_bounds(index : int) -> bool:
	return index == self.INDEX_OUT_OF_BOUNDS

func is_last_grid_index_equal_current() -> bool:
	return self.get_current_grid_index() == self.get_last_grid_index()

func is_current_grid_index_out_of_bounds() -> bool:
	return self.is_index_out_of_bounds(self.get_current_grid_index())

func is_last_grid_index_equal_last_grid_index_within_boundary_highlight() -> bool:
	return self.get_last_grid_index() == self.get_last_index_within_grid_boundary_highlight()

func is_last_grid_index_out_of_bounds() -> bool:
	return self.is_index_out_of_bounds(self.get_last_grid_index())

func is_last_index_within_grid_boundary_equal_current_grid_index() -> bool: 
	return self.get_last_index_within_grid_boundary() == self.get_current_grid_index()

func is_last_index_within_grid_boundary_highlight_equal_last_index_within_grid_boundary() -> bool: 
	return self.get_last_index_within_grid_boundary_highlight() == self.get_last_index_within_grid_boundary()

func is_last_index_within_grid_boundary_highlight_equal_current_index() -> bool:
	return self.get_last_index_within_grid_boundary_highlight() == self.get_current_grid_index()

func is_grid_element_type_at_index_equal(index : int, type : String) -> bool:
	return (self.get_grid_element_information_from_index(index))["type"] == type

func is_grid_element_type_tile_at_index(index):
	return self.is_grid_element_type_at_index_equal(index, "tile")

func is_current_grid_element_placeholder() -> bool:
	return (self.get_current_grid_element_information())["type"] == "placeholder"

func is_highlight_persistence_void() -> bool:
	return self._highlight_persistence["void"]["persistence"]

func is_floating_tile_reference_valid() -> bool:
	if self._floatingTileReference != self:
		return true

	return false

################################################################################
#### PUBLIC MEMBER FUNCTIONS: GRID CELL HIGHLIGHTING ###########################
################################################################################
func set_single_grid_cell_highlight(index : int, highlight_status : bool) -> void:
	var _tile = self.get_grid_element_reference_from_index(index)
	_tile.highlight = highlight_status
	_tile.change_material = true

# REMARK: Requires more logic to not interfer with chain highlighting set by the logic
func manage_highlighting_due_to_cursor() -> void:
	if not self.is_current_grid_index_out_of_bounds():
		self.set_single_grid_cell_highlight(self.get_current_grid_index(), true)

	if not self.is_last_grid_index_out_of_bounds(): # REMARK: This on its own erases the highlight of the last cursor position when cursor in void -> undesirable behavior if floating tile!
		# REMARK: Approach a bit hacky and unflexible for potential changes in the future
		if self.is_highlight_persistence_void(): # DESCRIPTION: When highlight persistence enabled, use last valid position for cursor highlight
			if not self.is_last_index_within_grid_boundary_equal_current_grid_index():  # DESCRIPTION: When the last valid grid position is not identical to the current one
				# DESCRIPTION: Copy the last index within grid boundaries to a storage variable and highlight
				# the tile at the corresponding position
				self.set_last_grid_index_within_boundary_highlight_to_last_grid_index_within_boundary()
				self.set_single_grid_cell_highlight(self.get_last_index_within_grid_boundary_highlight(), true)
			else: # DESCRIPTION: If the last valid index within grid boundaries is identical to the current grid position
				# DESCRIPTION: If the highlighted cell is not identical with the currently valid last index within the boundaries,
				# than remove the highlight
				if not self.is_last_index_within_grid_boundary_highlight_equal_last_index_within_grid_boundary():
					self.set_single_grid_cell_highlight(self.get_last_index_within_grid_boundary_highlight(), false)
			
			# DESCRIPTION: If last grid index is not identical to last index within grid boundaries,
			# than remove the highlight of the tile at last index to prevent leaving tiles highlighted
			# which should not be
			if not self.is_last_grid_index_equal_last_grid_index_within_boundary_highlight():
				self.set_single_grid_cell_highlight(self.get_last_grid_index(), false)
		
		else:
			self.set_single_grid_cell_highlight(self.get_last_grid_index(), false)
	else:
		if self.is_highlight_persistence_void(): # DESCRIPTION: When highlight persistence avtivated
			# DESCRIPTION: User did not move the cursor to the last highlighted tile
			if not self.is_last_index_within_grid_boundary_highlight_equal_current_index():
				self.set_single_grid_cell_highlight(self.get_last_index_within_grid_boundary_highlight(), false)

func set_status_placeholder_at_index(index : int, _possible : bool, _impossible : bool) -> void: # needs more arguments in the future to pass status
	var _tile = self.get_grid_element_reference_from_index(index)

	# only temporary to test possible/impossible texture change
	if self.is_grid_element_type_at_index_equal(index, "placeholder"):
		_tile.placement_possible = _possible
		_tile.placement_impossible = _impossible
	
	_tile.change_material = true

func set_status_placeholder(_possible : bool, _impossible : bool) -> void:
	self.set_status_placeholder_at_index(self.get_current_grid_index(), _possible, _impossible)

################################################################################
#### PUBLIC MEMBER FUNCTIONS: FLOATING SELECTOR ################################
################################################################################
func enable_floating_selector_movement_by_asmr() -> void:
	self._floatingCursor.enable_movement_by_asmr()

func disable_floating_selector_movement_by_asmr() -> void:
	self._floatingCursor.disable_movement_by_asmr()

func request_floating_selector_movement(asmr : Vector2) -> void:
	self._floatingCursor.request_movement_by_action_strength(asmr)

func calculate_new_floating_selector_postion_by_action_strength(asmr : Vector2) -> Vector3:
	var _tmp_current_index : int 

	if asmr != Vector2(0,0):
		if not self.is_current_grid_index_out_of_bounds():
			_tmp_current_index = self.get_current_grid_index()
		else:
			_tmp_current_index = self.get_last_index_within_grid_boundary()

		var _tmp_index2D : Vector2 = self._managerReferences["cppBridge"]._convert_1D_index_to_2D(_tmp_current_index)
		_tmp_index2D += asmr
		var _tmp_index1D : int = self._managerReferences["cppBridge"]._convert_2D_index_to_1D(_tmp_index2D)

		# DESCRIPTION: Check whether new index is valid
		# REMARK: Simplified case for a "square" grid; must be generalized!
		if _tmp_index1D <= self._hex_grid_size_x * self._hex_grid_size_y - 1: # DESCRIPTION: To prevent exceeding boundaries at the top
			if _tmp_index1D >= 0: # DESCRIPTION: To prevent exceeding boundaries at the bottom
				if _tmp_index1D != self.get_current_grid_index():
					# DESCRIPTION: To prevent jumping from one edge of the grid to the other
					if not ((int(_tmp_index2D.x) == self._hex_grid_size_x) or (int(_tmp_index2D.x) == -1)):
						self.set_last_grid_index_to_current()
						self.set_current_grid_index(_tmp_index1D)
						self.set_last_index_within_grid_boundary(_tmp_index1D)

						var _tmp_floating_selector_target_position : Vector3 = (self.get_current_grid_element_information())["reference"].transform.origin
						
						return _tmp_floating_selector_target_position

	return Vector3.INF

func request_floating_selector_position(position : Vector3) -> void:
	self._floatingCursor.request_new_position(position)

func move_floating_selector_to(index : int) -> void:
	if not self.is_index_out_of_bounds(index): # ensures that tile does not move if cursor is over an area outside the allowed grid area
		var _grid_reference = self.get_grid_element_reference_from_index(index)
		var _grid_position_physical = _grid_reference.transform.origin
		self._floatingCursor.force_move_to(_grid_position_physical)
		
		if self.is_floating_tile_reference_valid():
			self._floatingTileReference.grid_index = index		
			self._floatingTileReference.transform.origin = Vector3(0, self.FLOATING_TILE_DISTANCE_ABOVE_GRID,0)

func move_floating_selector_to_and_highlight(next : int) -> void:
	self.manage_highlighting_due_to_cursor()
	self.move_floating_selector_to(next)

func move_floating_selector_and_highlight() -> void:
	self.move_floating_selector_to_and_highlight(self.get_current_grid_index())

################################################################################
#### PUBLIC MEMBER FUNCTIONS: FLOATING TILE ####################################
################################################################################
func create_floating_tile_at_index(index : int, tile_definition : Dictionary) -> void:
	# DESCRIPTION: Instance tile, add it to the scene tree and update reference
	var _tile = BASE_TILE.instance()
	self._floatingCursor.add_child(_tile)
	self._floatingTileReference = _tile

	# DESCRIPTION: Configure the tile
	_tile.initial_tile_configuration(tile_definition)
	# REMARK: Collision needs to be switched off for all child elements, otherwise the raycast will falsely detect a hit,
	# which leads to jumping of the tile; includes all the assets that will be placed on the tile!
	# TO-DO: Write for loop to obtain all collision objects and disable them
	_tile.get_node("hexCollider/CollisionShape2").disabled = true

	# DESCRIPTION: Reset rotation according to rules if necessary, apply rotation and move to new position
	self._manage_rotation_persistence()
	self._floatingTileReference.rotation_degrees = Vector3(0,self._floatingTileRotation,0)
	self.move_floating_selector_to(index)

func create_floating_tile(tile_definition : Dictionary) -> void:
	self.create_floating_tile_at_index(self._last_index_within_grid_boundary, tile_definition) # Change

func get_floating_tile_definition_uuid_and_rotation() -> Dictionary:
	var _tmp_uuid_and_rotation : Dictionary = {}

	if self.is_floating_tile_reference_valid(): # REMARK: Safety to prevent issues when no floating tile exists
		_tmp_uuid_and_rotation["TILE_DEFINITION_UUID"] = self._floatingTileReference.tile_definition_uuid
		var _tmp_floating_tile_rotation : int = self._floatingTileReference.get_rotation_degrees().y
		_tmp_uuid_and_rotation["rotation"] = _tmp_floating_tile_rotation
	
	return _tmp_uuid_and_rotation

func delete_floating_tile() -> void:
	if self.is_floating_tile_reference_valid(): # REMARK: Safety to prevent issues when no floating tile exists
		# DESCRIPTION: Reset rotation according to rules if necessary;
		# REMARK: Has to be called before floating tile is queued free (will not work otherwise)
		self._manage_rotation_persistence()

		# DESCRIPTION: Delete the floating tile and reset the reference variable
		self._floatingTileReference.queue_free()
		self._floatingTileReference = self

func change_floating_tile_type(tile_definition : Dictionary) -> void:
	if self.is_floating_tile_reference_valid(): # REMARK: Safety to prevent issues when no floating tile exists
		var _index = self._floatingTileReference.grid_index
		self.delete_floating_tile()
		self.create_floating_tile_at_index(_index, tile_definition) # REMARK: Seems to be the fix for "placement and removal of floating tile at index 0 when new tile definition is selected" bug
			
func rotate_floating_tile_clockwise() -> void:
	if self.is_floating_tile_reference_valid(): # REMARK: Safety to prevent issues when no floating tile exists
		self._floatingTileRotation -= 60
		self._floatingTileRotation = self._floatingTileRotation % 360
		self._floatingTileReference.rotation_degrees = Vector3(0,self._floatingTileRotation,0)

func replace_grid_object_at_index_with(index : int, replacement : Object, replacement_object_type : String) -> void:
	var _grid_element : Object = self.get_grid_element_reference_from_index(index)
	var _grid_physical_position : Vector3 = _grid_element.transform.origin

	# DESCRIPTION: Set replacement object grid index and physically place it on grid layer 
	# REMARK: Perhaps apply animation/tween/smoothing
	replacement.grid_index = index
	replacement.transform.origin = _grid_physical_position 

	# DESCRIPTION: Replace reference and type with new data
	self.set_grid_element_information_at_index(index, replacement_object_type, replacement)

	# DESCRIPTION: Reparent replacement object to logicially conclusive parent
	# soure: https://forum.godotengine.org/t/reparent-node-at-runtime/31124/4
	var _old_parent : Object = replacement.get_parent()
	var _new_parent : Object = _grid_element.get_parent()
	_old_parent.remove_child(replacement)
	_new_parent.add_child(replacement)

	# DESCRIPTION: Remove old grid element
	_grid_element.queue_free()

func place_floating_tile_at_index(index : int) -> void:
	var _ft_starting_position : Vector3 =  self._floatingCursor.transform.origin 
	var _grid_physical_position : Vector3 = self.get_grid_element_reference_from_index(index).transform.origin

	if self.is_floating_tile_reference_valid(): # REMARK: Safety to prevent issues when no floating tile exists
		# for safety: check whether floating tile is still at the correct position
		if (_ft_starting_position.x == _grid_physical_position.x) and (_ft_starting_position.z == _grid_physical_position.z):
			self.replace_grid_object_at_index_with(index, self._floatingTileReference, "tile")

			# Description: Collision needs to be switched on again on all child elements, 
			# otherwise the raycast will not detect the placed tile; 
			# includes all the assets that will be placed on the tile!
			# TO-DO: Write for loop to obtain all collision objects and re-enable them
			self._floatingTileReference.get_node("hexCollider/CollisionShape2").disabled = false

			# DESCRIPTION: Reset rotation according to rules if necessary and free the floating tile reference
			# REMARK: has to be called before floating tile is queued free (will not work otherwise)
			self._manage_rotation_persistence()
			self._floatingTileReference = self # clear the floating tile reference

func place_floating_tile() -> void:
	if not self.is_current_grid_index_out_of_bounds():
		self.place_floating_tile_at_index(self.get_current_grid_index())

################################################################################
#### PUBLIC MEMBER FUNCTIONS: PLACED TILE MANIPULATION #########################
################################################################################
func replace_tile() -> void:
	if  not self.is_current_grid_index_out_of_bounds(): 
		self.place_floating_tile()

func get_tile_definition_uuid_from_tile_at_index(index: int) -> String:
	var _tmp_string : String = ""

	if not self.is_index_out_of_bounds(index):
		if self.is_grid_element_type_tile_at_index(index):
			_tmp_string = self.get_grid_element_reference_from_index(index).tile_definition_uuid

	return _tmp_string

func get_tile_definition_uuid_from_current_grid_index() -> String:
	return self.get_tile_definition_uuid_from_tile_at_index(self.get_current_grid_index())

func delete_tile() -> void:
	if not self.is_current_grid_index_out_of_bounds():
		# DESCRIPTION: Instantiate a placeholder object 
		var _tile = PLACEHOLDER_TILE.instance()
		self._gridObjects.add_child(_tile)
		_tile.initial_placeholder_configuration()

		self.replace_grid_object_at_index_with(self.get_current_grid_index(), _tile, "placeholder")
		self.manage_highlighting_due_to_cursor()
