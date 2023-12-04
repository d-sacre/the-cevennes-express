extends Node

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

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################
# REMARK: From a logic separation point of view, this should be outsourced to the hexGridManager 
# and separated even further to accomodate highlighting of multiple tiles at once (independent 
# of a ray cast event)
func highlight_tiles(_current_tile_index, _last_tile_index):
	print("current tile: ", _current_tile_index, ", last tile: ", _last_tile_index)
	if _current_tile_index != -1:
		var current_tile = hexGridManager.tile_reference[_current_tile_index]
		current_tile.highlight=true
		current_tile.change_material = true
		
	if _last_tile_index != -1:
		var last_tile = hexGridManager.tile_reference[_last_tile_index]
		last_tile.highlight = false
		last_tile.change_material = true

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

	highlight_tiles(_current_tile_index, _last_tile_index)

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready() -> void:
	cameraManager.connect("raycast_result",self,"_on_raycast_result")
	cameraManager.enable_raycasting()

func _input(event) -> void:
	if event is InputEventMouse:
		raycast_screenspace_position = event.position
		cameraManager.initiate_raycast_from_position(raycast_screenspace_position)

