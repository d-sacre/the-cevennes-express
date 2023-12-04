extends Node

onready var hexGridManager = $hexGridManager
onready var cameraManager = $cameraManager

var _last_collison_object 
var _current_collision_object 
var _last_tile_index : int = -1
var _current_tile_index : int = -1

# func _on_cursor_over_tile(current_tile_index,last_tile_index):
# 	print("current tile: ", current_tile_index, ", last tile: ", last_tile_index)
# 	if current_tile_index != -1:
# 		var current_tile = hexGridManager.tile_reference[current_tile_index]
# 		current_tile.highlight=true
# 		current_tile.change_material = true
		
# 	if last_tile_index != -1:
# 		var last_tile = hexGridManager.tile_reference[last_tile_index]
# 		last_tile.highlight = false
# 		last_tile.change_material = true

func _on_raycast_result(current_collision_information):
	_last_tile_index = _current_tile_index
	if current_collision_information[0] != false:
		var collider_ref = current_collision_information[1]#["collider"]
		var parent_tile = collider_ref.get_parent()
		# hardcoded for the case of only hitting a hex tile. Other collisions like with trains have to be implemented differently!
		_current_tile_index = parent_tile.tile_index
	else:
		_current_tile_index = -1

	print("current tile: ", _current_tile_index, ", last tile: ", _last_tile_index)
	if _current_tile_index != -1:
		var current_tile = hexGridManager.tile_reference[_current_tile_index]
		current_tile.highlight=true
		current_tile.change_material = true
		
	if _last_tile_index != -1:
		var last_tile = hexGridManager.tile_reference[_last_tile_index]
		last_tile.highlight = false
		last_tile.change_material = true

		

func _ready():
	# cameraManager.connect("cursor_over_tile",self,"_on_cursor_over_tile")
	cameraManager.connect("raycast_result",self,"_on_raycast_result")
	cameraManager.enable_raycasting()
	

