tool
extends Spatial

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
const PLACEHOLDER_TILE : Resource = preload("res://assets/3D/tiles/placeholder/hexTile_placeholder.tscn")
const BASE_TILE : Resource = preload("res://assets/3D/tiles/base/hexTile_base.tscn")

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const TILE_SIZE : float = 1.0
const FLOATING_TILE_DISTANCE_ABOVE_GRID : float = 1.0

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
var hex_grid_size_x : int = 10
var hex_grid_size_y : int = 10

var tile_reference : Array = []
var floating_tile_reference = self # always needs a reference, even when no floating tile
var floating_tile_rotation : int = 0 # angle in degree, but only allowing 60° increments!

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################
# creates a hexagonal grid and fills it with the placeholder tiles
# REMARK: For performance reasons, this should be changed in the future
# to a different approach (e.g. calculating all the positions, but 
# only instancing the tiles which are set from the start)
func generate_grid(x : int, y : int):
	self.hex_grid_size_x = x 
	self.hex_grid_size_y = y

	var is_tile_offset_y : bool = false

	for tile_index in range(self.hex_grid_size_x*self.hex_grid_size_y):
		var tile_coordinates : Vector2 = Vector2.ZERO
		tile_coordinates.x = (tile_index % self.hex_grid_size_x) * TILE_SIZE * cos(deg2rad(30))
		tile_coordinates.y = (tile_index / self.hex_grid_size_x) * TILE_SIZE

		if is_tile_offset_y:
			tile_coordinates.y += TILE_SIZE/2

		is_tile_offset_y = !is_tile_offset_y

		var tile = PLACEHOLDER_TILE.instance()
		add_child(tile)
		tile_reference.append({"type": "placeholder", "reference": tile})
		tile.translate(Vector3(tile_coordinates.x, 0, tile_coordinates.y))
		tile.initial_placeholder_configuration()
		tile.tile_index = tile_index

func set_single_tile_highlight(index, highlight_status):
	var _tile = self.tile_reference[index]["reference"]
	_tile.highlight = highlight_status
	_tile.change_material = true

func set_status_placeholder(index, _possible, _impossible): # needs more arguments in the future to pass status
	var _tile = self.tile_reference[index]["reference"]

	# only temporary to test possible/impossible texture change
	if self.tile_reference[index]["type"]=="placeholder":
		_tile.placement_possible = _possible
		_tile.placement_impossible = _impossible
	
	_tile.change_material = true

func move_floating_tile_to(index):
	if index != -1: # ensures that tile does not move if cursor is over an area outside the allowed grid area
		if floating_tile_reference != self:
			var grid_reference = self.tile_reference[index]["reference"]
			var grid_position_physical = grid_reference.transform.origin
			floating_tile_reference.set_global_translation(Vector3(grid_position_physical.x, FLOATING_TILE_DISTANCE_ABOVE_GRID, grid_position_physical.z)) # translate to above the desired grid position

func create_tile_floating_over_grid(index,tile_definition):
	# create tile and add it to the scene tree
	var tile = BASE_TILE.instance()
	add_child(tile)

	floating_tile_reference = tile

	# configure the tile
	tile.initial_tile_configuration(tile_definition)
	# collision needs to be switched off on all child elements, otherwise the raycast will falsely detect a hit,
	# which leads to jumping of the tile; includes all the assets that will be placed on the tile!
	# TO-DO: Write for loop to obtain all collision objects and disable them
	tile.get_node("hexCollider/CollisionShape2").disabled = true
	move_floating_tile_to(index)

func get_floating_tile_definition_uuid_and_rotation() -> Dictionary:
	var _tmp_uuid_and_rotation : Dictionary = {}

	if floating_tile_reference != self: # safety to prevent issues when no floating tile exists
		_tmp_uuid_and_rotation["TILE_DEFINITION_UUID"] = floating_tile_reference.tile_definition_uuid
		var _floating_tile_rotation : int = floating_tile_reference.get_rotation_degrees().y
		_tmp_uuid_and_rotation["rotation"] = _floating_tile_rotation
	
	return _tmp_uuid_and_rotation

func rotate_floating_tile_clockwise():
	if floating_tile_reference != self: # to prevent rotation of the grid when no floating tile available
		floating_tile_rotation -= 60
		floating_tile_rotation = floating_tile_rotation % 360
		floating_tile_reference.rotation_degrees = Vector3(0,floating_tile_rotation,0)

func place_floating_tile_at_index(index):
	var grid_element  = self.tile_reference[index]["reference"]
	var ft_starting_position : Vector3 = floating_tile_reference.transform.origin
	var grid_physical_position : Vector3 = grid_element.transform.origin

	var ft_current_position : Vector3 = ft_starting_position

	if floating_tile_reference != self: # safety to prevent issues trying to set non-existing values when no floating tile is loaded
		# for safety: check whether floating tile is still at the correct position
		if (ft_starting_position.x == grid_physical_position.x) and (ft_starting_position.z == grid_physical_position.z):
			# setting the tile_index to the correct value
			floating_tile_reference.tile_index = index
			floating_tile_reference.transform.origin = grid_physical_position # set floating tile on grid layer (perhaps some smoothing)
			
			# collision needs to be switched on again on all child elements, otherwise the raycast will not detect the placed tile; 
			# includes all the assets that will be placed on the tile!
			# TO-DO: Write for loop to obtain all collision objects and re-enable them
			floating_tile_reference.get_node("hexCollider/CollisionShape2").disabled = false

			# add floating tile to the tile reference
			self.tile_reference[index]["reference"] = floating_tile_reference
			self.tile_reference[index]["type"] = "tile"

			# clean up
			floating_tile_reference = self # clear the floating tile reference
			grid_element.queue_free()# remove placeholder
		

# REMARK: Requires more logic to not interfer with chain highlighting set by the logic
func manage_highlighting_due_to_cursor(_current_tile_index, _last_tile_index):
	# print("current tile: ", _current_tile_index, ", last tile: ", _last_tile_index)
	if _current_tile_index != -1:
		self.set_single_tile_highlight(_current_tile_index, true)

	if _last_tile_index != -1:
		self.set_single_tile_highlight(_last_tile_index, false)

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################






