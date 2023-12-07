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
var _last_collison_object 
var _current_collision_object 
var _last_tile_index : int = -1
var _current_tile_index : int = -1

var raycast_screenspace_position : Vector2 = Vector2(0,0)

################################################################################
#### Onready Member Variables ##################################################
################################################################################
onready var hexGridManager = $hexGridManager
onready var cameraManager = $cameraManager
onready var tileDefinitionManager = $tileDefinitionManager

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_raycast_result(current_collision_information):
	_last_tile_index = _current_tile_index
	if current_collision_information[0] != false:
		var collider_ref = current_collision_information[1]#["collider"]
		var collider_parent_object = collider_ref.get_parent()
		# REMARK: hardcoded for the case of only hitting a hex tile. 
		# Other collisions like with trains have to be implemented differently!
		_current_tile_index = collider_parent_object.tile_index
	else:
		_current_tile_index = -1

	if _current_tile_index != _last_tile_index:
		hexGridManager.manage_highlighting_due_to_cursor(_current_tile_index, _last_tile_index)
		hexGridManager.move_floating_tile_to(_current_tile_index)

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready() -> void:
	# setting up all camera related stuff
	# TO-DO: Set starting position to the center of the grid
	cameraManager.connect("raycast_result",self,"_on_raycast_result")
	cameraManager.enable_raycasting()

	# setting up the grid
	_current_tile_index = 15 # to set a position for the cursor; should be later adapted to be in the center of the grid
	hexGridManager.manage_highlighting_due_to_cursor(_current_tile_index, _last_tile_index) # set the highlight correctly

	var tile_definition = tileDefinitionManager.get_tile_definition_database_entry("7bddebca65fad08b3ee56a152b682109") # hardcoded to get the default grassy meadow tile
	hexGridManager.create_tile_floating_over_grid(_current_tile_index,tile_definition)
	
# REMARK: Should be moved to userInputManager (when created)
func _input(event) -> void:
	if event is InputEventMouse:
		raycast_screenspace_position = event.position
		cameraManager.initiate_raycast_from_position(raycast_screenspace_position)

func _process(delta):
	# REMARK: Only temporary test function to check placeholder status functionality
	# Normally, this would have to call C++ Logic Backend and request placement information
	if Input.is_action_just_pressed("place_tile"):
		if _current_tile_index != -1:
			print("place tile at ", _current_tile_index)

			rng.randomize()
			var _odd_even = rng.randi_range(0, 100) % 2
			if _odd_even == 0:
				hexGridManager.set_status_placeholder(_current_tile_index,true, false)
				hexGridManager.place_floating_tile_at_index(_current_tile_index)
			else:
				hexGridManager.set_status_placeholder(_current_tile_index,false, true)
			
	# rotation of the tile
	if Input.is_action_just_pressed("rotate_tile_clockwise"):
		hexGridManager.rotate_floating_tile_clockwise()

