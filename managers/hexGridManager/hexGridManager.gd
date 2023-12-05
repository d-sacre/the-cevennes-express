tool
extends Spatial

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
const PLACEHOLDER_TILE : Resource = preload("res://assets/3D/tiles/placeholder/hexTile_placeholder.tscn")
var rng = RandomNumberGenerator.new()

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const TILE_SIZE : float = 1.0

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
export (int, 2, 200) var grid_size : int = 10 # good values: 10, 50

var tile_reference = []

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

func _generate_grid():
	var tile_index : int = 0
	for x in range(grid_size):
		var tile_coordinates := Vector2.ZERO
		tile_coordinates.x = x * TILE_SIZE * cos(deg2rad(30))
		tile_coordinates.y = 0 if x % 2 == 0 else TILE_SIZE / 2

		for y in range(grid_size):
			var tile = PLACEHOLDER_TILE.instance()
			add_child(tile)
			tile_reference.append(tile)
			tile.translate(Vector3(tile_coordinates.x, 0, tile_coordinates.y))
			tile_coordinates.y += TILE_SIZE
			tile.initial_placeholder_configuration()
			tile.tile_index = tile_index
			tile_index += 1

func set_single_tile_highlight(index, highlight_status):
	var _tile = self.tile_reference[index]
	_tile.highlight = highlight_status
	_tile.change_material = true

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





