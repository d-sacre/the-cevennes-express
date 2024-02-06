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

# FUTURE: Add more contexts, allow for highlight intensity modulation/mixing with
# other highlights (needs also work in placeholderManager.gd, tileManager.gd)
var _highlight_persistence : Dictionary = {
	"void": {
		"persistence": true,
		"intensity": 1
	}
}

################################################################################
################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
################################################################################
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
		tile_reference.append({"type": "placeholder", "reference": _tile})
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
	if self.tile_reference[index]["type"]=="placeholder":
		_tile.placement_possible = _possible
		_tile.placement_impossible = _impossible
	
	_tile.change_material = true

func set_status_placeholder(_possible : bool, _impossible : bool) -> void:
	self.set_status_placeholder_at_index(self._current_grid_index, _possible, _impossible)

################################################################################
#### PUBLIC MEMBER FUNCTIONS: FLOATING TILE ####################################
################################################################################
func move_floating_tile_to(index : int) -> void:
	if index != self.INDEX_OUT_OF_BOUNDS: # ensures that tile does not move if cursor is over an area outside the allowed grid area
		if self.floating_tile_reference != self:
			var _grid_reference = self.tile_reference[index]["reference"]
			var _grid_position_physical = _grid_reference.transform.origin
			self.floating_tile_reference.set_global_translation(Vector3(_grid_position_physical.x, FLOATING_TILE_DISTANCE_ABOVE_GRID, _grid_position_physical.z)) # translate to above the desired grid position
			self.floating_tile_reference.grid_index = index

func create_floating_tile_at_index(index : int, tile_definition : Dictionary) -> void:
	# create tile and add it to the scene tree
	var _tile = BASE_TILE.instance()
	add_child(_tile)

	self.floating_tile_reference = _tile

	# configure the tile
	_tile.initial_tile_configuration(tile_definition)
	# REMARK: Collision needs to be switched off for all child elements, otherwise the raycast will falsely detect a hit,
	# which leads to jumping of the tile; includes all the assets that will be placed on the tile!
	# TO-DO: Write for loop to obtain all collision objects and disable them
	_tile.get_node("hexCollider/CollisionShape2").disabled = true
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
		self.floating_tile_rotation = floating_tile_rotation % 360
		self.floating_tile_reference.rotation_degrees = Vector3(0,floating_tile_rotation,0)

func move_floating_tile_to_and_highlight(next : int) -> void:
	self.manage_highlighting_due_to_cursor()
	self.move_floating_tile_to(next)

func move_floating_tile_and_highlight() -> void:
	self.move_floating_tile_to_and_highlight(self._current_grid_index)

func place_floating_tile_at_index(index : int) -> void:
	var _grid_element : Object = self.tile_reference[index]["reference"]
	var _ft_starting_position : Vector3 = floating_tile_reference.transform.origin
	var _grid_physical_position : Vector3 = _grid_element.transform.origin

	if self.floating_tile_reference != self: # REMARK: Safety to prevent issues when no floating tile exists
		# for safety: check whether floating tile is still at the correct position
		if (_ft_starting_position.x == _grid_physical_position.x) and (_ft_starting_position.z == _grid_physical_position.z):
			# setting the grid_index to the correct value
			self.floating_tile_reference.grid_index = index
			self.floating_tile_reference.transform.origin = _grid_physical_position # set floating tile on grid layer (perhaps some smoothing)
			
			# collision needs to be switched on again on all child elements, otherwise the raycast will not detect the placed tile; 
			# includes all the assets that will be placed on the tile!
			# TO-DO: Write for loop to obtain all collision objects and re-enable them
			self.floating_tile_reference.get_node("hexCollider/CollisionShape2").disabled = false

			# add floating tile to the tile reference
			self.tile_reference[index]["reference"] = floating_tile_reference
			self.tile_reference[index]["type"] = "tile"

			# clean up
			self.floating_tile_reference = self # clear the floating tile reference
			_grid_element.queue_free() # remove placeholder

func place_floating_tile() -> void:
	self.place_floating_tile_at_index(self._current_grid_index)







