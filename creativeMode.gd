extends Node


func _ready():
	pass # Replace with function body.


# func _process(delta):
# 	if Input.is_action_just_pressed("place_tile"):
# 		if _currentGuiMouseContext == "grid":
# 			if _current_tile_index != -1:
# 				# print("place tile at ", _current_tile_index)

# 				var floating_tile_status = hexGridManager.get_floating_tile_definition_uuid_and_rotation()
				
# 				var tile_is_placeable = false
				
# 				if floating_tile_status.has("TILE_DEFINITION_UUID"): # required to prevent issues when no floating tile exists
# 					tile_is_placeable = true # cppBridge.can_tile_be_placed_here(_current_tile_index, floating_tile_status["TILE_DEFINITION_UUID"], floating_tile_status["rotation"]) # needs to be updated (Bridge + Backend)

# 				# print("tile is placeable: ", tile_is_placeable)

# 				if tile_is_placeable:
# 					hexGridManager.set_status_placeholder(_current_tile_index,true, false)
# 					hexGridManager.place_floating_tile_at_index(_current_tile_index)

# 					# test for sfx
# 					audioManager.play_sfx(["game", "tile", "success"])

# 					var tile_definition_uuid = _tileSelector.selectedTile # cppBridge.request_next_tile_definition_uuid() # not required for creative mode
# 					if tile_definition_uuid != "": 
# 						var tile_definition = tileDefinitionManager.get_tile_definition_database_entry(tile_definition_uuid) 
# 						hexGridManager.create_tile_floating_over_grid(_current_tile_index,tile_definition)
# 				else:
# 					hexGridManager.set_status_placeholder(_current_tile_index,false, true)
# 					# test for sfx
# 					audioManager.play_sfx(["game", "tile", "fail"])
			
# 	# rotation of the tile
# 	if Input.is_action_just_pressed("rotate_tile_clockwise"):
# 		if _currentGuiMouseContext == "grid":
# 			hexGridManager.rotate_floating_tile_clockwise() # rotate tile
# 			audioManager.play_sfx(["game", "tile", "rotate"])
			
# 			if _current_tile_index != -1: # safety to absolutely ensure that cursor is not out of grid bounds 
# 				var floating_tile_status = hexGridManager.get_floating_tile_definition_uuid_and_rotation()
				
# 				if floating_tile_status.has("TILE_DEFINITION_UUID"): # if a floating tile exists
# 					# inquire at C++ Backend whether the tile would fit
# 					var is_tile_placeable : bool = cppBridge.check_whether_tile_would_fit(_current_tile_index, floating_tile_status["TILE_DEFINITION_UUID"], floating_tile_status["rotation"])
					
# 					# set the highlight according to the answer of the C++ Backend
# 					if is_tile_placeable:
# 						hexGridManager.set_status_placeholder(_current_tile_index,true, false)
# 					else:
# 						hexGridManager.set_status_placeholder(_current_tile_index,false, true)
	
