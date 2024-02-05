class_name game_default

extends game_base

################################################################################
#### PARENT CLASS MEMBER FUNCTION OVERRIDES ####################################
################################################################################
func _is_tile_placeable() -> bool:
    var _floating_tile_status : Dictionary
    var _current_tile_index : int

    _floating_tile_status = self._get_floating_tile_status()
    _current_tile_index = self._managerReferences["hexGridManager"].get_current_grid_index()

    return self._managerReferences["cppBridge"].can_tile_be_placed_here(_current_tile_index, _floating_tile_status["TILE_DEFINITION_UUID"], _floating_tile_status["rotation"]) # needs to be updated (Bridge + Backend)

func _is_tile_placeable_with_current_rotation() -> bool:
    var _floating_tile_status : Dictionary
    var _current_tile_index : int

    _floating_tile_status = self._get_floating_tile_status()
    _current_tile_index = self._managerReferences["hexGridManager"].get_current_grid_index()

    return self._managerReferences["cppBridge"].check_whether_tile_would_fit(_current_tile_index, _floating_tile_status["TILE_DEFINITION_UUID"], _floating_tile_status["rotation"])

func _next_tile_definition_uuid() -> String:
    return self._managerReferences["cppBridge"].request_next_tile_definition_uuid()
    
################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
# REMARK: It is necessary to call the base class _init function
# source: https://forum.godotengine.org/t/how-do-i-pass-in-arguments-to-parent-script-when-extending-a-script/24883/2
func _init(mr).(mr) -> void:
    pass

