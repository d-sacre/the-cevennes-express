extends Node

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
var cppBackend = load("res://lib/tile.gdns").new()
var rng = RandomNumberGenerator.new()

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
var hex_grid_size_x : int 
var hex_grid_size_y : int 

################################################################################
#### Private Member Variables ##################################################
################################################################################
var _blocked_grid_position : Array = [] # just for testing purposes; will later be done by C++ Backend

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################
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

	# ##################################################################
	# ########### BEGIN CODE JUST FOR TESTING ##########################
	# ##################################################################
	# # hardcoded; normally would call C++ logic
	# # hardcoded to always get the default grassy meadow tile
	# _definition_uuid = "7bddebca65fad08b3ee56a152b682109" 
	

	# # hardcoded to select from the 3 basic tiles
	# # WARNING: Hashes might change when database is rebuild. So the hardcoded
	# # ones might not work anymore and the game crash!
	# # Order: 0 = grassy meadow, 1 = track straight, 2= track curve
	# var _uuid_array : Array = ["7bddebca65fad08b3ee56a152b682109", "804f1087ee53a834de7005c8881b20dd", "ff33f959f76686ede746cf5f534d2e65"] 

	# rng.randomize()
	# var _index = rng.randi_range(0, 2)

	# _definition_uuid = _uuid_array[_index]
	# ##################################################################
	# ########### END CODE JUST FOR TESTING ############################
	# ##################################################################

	_definition_uuid = cppBackend.GetIDForNextTile()
	print(_definition_uuid)

	return _definition_uuid

func can_tile_be_placed_here(grid_index, tile_definition_uuid, rotation) -> bool:

	# IMPORTANT: grid index has to be converted from 1d array to 2d array for C++ Backend!

	var _is_placeable : bool = false

	# ##################################################################
	# ########### BEGIN CODE JUST FOR TESTING ##########################
	# ##################################################################
	# # This is just for testing; normally would call C++ Backend logic
	# rng.randomize()
	# var _odd_even = rng.randi_range(0, 100) % 2
	# if _odd_even == 0:
	# 	_is_placeable = true

	# if grid_index in _blocked_grid_position:
	# 	_is_placeable = false

	# if len(_blocked_grid_position)<100:
	# 	pass
	# else:
	# 	_is_placeable = false

	# if _is_placeable:
	# 	_blocked_grid_position.append(grid_index)

	# ##################################################################
	# ########### END CODE JUST FOR TESTING ############################
	# ##################################################################

	# convert index from 1D array to 2D array
	var x : int = grid_index % self.hex_grid_size_x
	var y : int = grid_index / self.hex_grid_size_y

	print("Original index: ",grid_index,"Converted index: ", str(Vector2(x,y)))

	_is_placeable = cppBackend.OnSet(x,y)

	return _is_placeable

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
