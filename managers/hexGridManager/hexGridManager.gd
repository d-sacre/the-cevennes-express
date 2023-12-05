tool
extends Spatial

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
const PLACEHOLDER_TILE : Resource = preload("res://assets/3D/tiles/placeholder/hexTile_placeholder.tscn")
const BASE_TILE : Resource = preload("res://assets/3D/tiles/base/hexTile_base.tscn")
var rng = RandomNumberGenerator.new()

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const TILE_SIZE : float = 1.0
const FLOATING_TILE_DISTANCE_ABOVE_GRID : float = 1.0

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
export (int, 2, 200) var grid_size : int = 10 # good values: 10, 50

var tile_reference : Array = []
var floating_tile_reference = self # always needs a reference, even when no floating tile

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################

# Conversion single array index to dual array index
# maxWidth, maxHeight
# x, y -> c
# x + y * maxWidth = c

# c -> x,y

# x = c % maxWidth
# y = c / maxWidth # normal integer division
# y = c / (maxWidth - c % maxWidth) 

# creates a hexagonal grid and fills it with the placeholder tiles
# REMARK: For performance reasons, this should be changed in the future
# to a different approach (e.g. calculating all the positions, but 
# only instancing the tiles which are set from the start)
func _generate_grid():
	var tile_index : int = 0
	for x in range(grid_size):
		var tile_coordinates := Vector2.ZERO
		tile_coordinates.x = x * TILE_SIZE * cos(deg2rad(30))
		tile_coordinates.y = 0 if x % 2 == 0 else TILE_SIZE / 2

		for y in range(grid_size):
			var tile = PLACEHOLDER_TILE.instance()
			add_child(tile)
			tile_reference.append({"type": "placeholder", "reference": tile})
			tile.translate(Vector3(tile_coordinates.x, 0, tile_coordinates.y))
			tile_coordinates.y += TILE_SIZE
			tile.initial_placeholder_configuration()
			tile.tile_index = tile_index
			tile_index += 1

func set_single_tile_highlight(index, highlight_status):
	var _tile = self.tile_reference[index]["reference"]
	_tile.highlight = highlight_status
	_tile.change_material = true

func set_status_placeholder(index): # needs more arguments in the future to pass status
	var _tile = self.tile_reference[index]["reference"]

	# only temporary to test possible/impossible texture change
	if self.tile_reference[index]["type"]=="placeholder":
		rng.randomize()
		var _odd_even = rng.randi_range(0, 100) % 2
		if _odd_even == 0:
			_tile.placement_possible = true
		else:
			_tile.placement_impossible = true
	
	_tile.change_material = true

func move_floating_tile_to(index):
	if index != -1: # ensures that tile does not move if cursor is over an area outside the allowed grid area
		if floating_tile_reference != self:
			var grid_reference = self.tile_reference[index]["reference"]
			var grid_position_physical = grid_reference.transform.origin
			print(grid_position_physical)
			floating_tile_reference.set_global_translation(Vector3(grid_position_physical.x, FLOATING_TILE_DISTANCE_ABOVE_GRID, grid_position_physical.z)) # translate to above the desired grid position

func create_tile_floating_over_grid(index,tile_id):
	# create tile and add it to the scene tree
	var tile = BASE_TILE.instance()
	add_child(tile)

	floating_tile_reference = tile

	# configure the tile
	tile.initial_tile_configuration(tile_id)
	# collision needs to be switched off on all child elements, otherwise the raycast will falsely detect a hit,
	# which leads to jumping of the tile; includes all the assets that will be placed on the tile!
	# TO-DO: Write for loop to obtain all collision objects and disable them
	tile.get_node("hexCollider/CollisionShape2").disabled = true
	move_floating_tile_to(index)


# REMARK: Requires more logic to not interfer with chain highlighting set by the logic
func manage_highlighting_due_to_cursor(_current_tile_index, _last_tile_index):
	print("current tile: ", _current_tile_index, ", last tile: ", _last_tile_index)
	if _current_tile_index != -1:
		self.set_single_tile_highlight(_current_tile_index, true)

	if _last_tile_index != -1:
		self.set_single_tile_highlight(_last_tile_index, false)

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready() -> void:
	_generate_grid()





