extends Node

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
var rng = RandomNumberGenerator.new()

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################

################################################################################
#### Private Member Variables ##################################################
################################################################################
var _blocked_grid_position : Array = [] # just for testing purposes; will later be done by C++ Backend

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################

# RETURNS: 
#	1) tile_definition_uuid : String 
#	2) empty string when no next tile is available
func request_next_tile_definition_uuid() -> String:
	var _definition_uuid : String = ""

	##################################################################
	########### BEGIN CODE JUST FOR TESTING ##########################
	##################################################################
	# hardcoded; normally would call C++ logic
	_definition_uuid = "7bddebca65fad08b3ee56a152b682109"  # hardcoded to get the default grassy meadow tile
	##################################################################
	########### END CODE JUST FOR TESTING ############################
	##################################################################

	return _definition_uuid

func can_tile_be_placed_here(grid_index, tile_definition_uuid, rotation) -> bool:

	# IMPORTANT: grid index has to be converted from 1d array to 2d array for C++ Backend!

	var _is_placeable : bool = false

	##################################################################
	########### BEGIN CODE JUST FOR TESTING ##########################
	##################################################################
	# This is just for testing; normally would call C++ Backend logic
	rng.randomize()
	var _odd_even = rng.randi_range(0, 100) % 2
	if _odd_even == 0:
		_is_placeable = true

	if grid_index in _blocked_grid_position:
		_is_placeable = false

	if _is_placeable:
		_blocked_grid_position.append(grid_index)

	##################################################################
	########### END CODE JUST FOR TESTING ############################
	##################################################################

	return _is_placeable

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
