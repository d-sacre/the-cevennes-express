extends Node

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
var cppBackend = load("res://lib/tile.gdns").new()

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
var hex_grid_size_x : int 
var hex_grid_size_y : int 

################################################################################
#### Private Member Variables ##################################################
################################################################################

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

func _convert_1D_index_to_2D(index) -> Vector2:
	var x : int = index % self.hex_grid_size_x
	var y : int = index / self.hex_grid_size_y

	return Vector2(x,y)

func initialize_cpp_bridge(x : int, y : int):
	self.hex_grid_size_x = x
	self.hex_grid_size_y = y

func pass_tile_definition_database_to_cpp_backend(dict) -> void:
	var result : Dictionary = cppBackend.SetTileSet(dict)
	print("Print from Godot:", result)

func initialize_grid_in_cpp_backend(creator : int) -> void:
	cppBackend.CreateGame(self.hex_grid_size_x, self.hex_grid_size_y, creator)

# RETURNS: 
#	1) tile_definition_uuid : String 
#	2) empty string when no next tile is available
func request_next_tile_definition_uuid() -> String:
	var _definition_uuid : String = ""
	_definition_uuid = cppBackend.GetIDForNextTile()

	return _definition_uuid

# will only work (and be tested) properly when rotation is implemented in the C++ Backend 
func check_whether_tile_would_fit(grid_index, tile_definition_uuid, rotation) -> bool:
	var _is_placeable : bool = false

	var _index2D = _convert_1D_index_to_2D(grid_index)
	_is_placeable = cppBackend.OnHover(_index2D.x,_index2D.y)

	return _is_placeable

func can_tile_be_placed_here(grid_index, tile_definition_uuid, rotation) -> bool:
	var _is_placeable : bool = false

	# convert index from 1D array to 2D array
	var _index2D = _convert_1D_index_to_2D(grid_index)

	_is_placeable = cppBackend.OnSet(_index2D.x,_index2D.y)

	return _is_placeable

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
