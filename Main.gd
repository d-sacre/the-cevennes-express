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

