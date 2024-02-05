class_name game_creative

extends game_base

################################################################################
#### PARENT CLASS MEMBER FUNCTION OVERRIDES ####################################
################################################################################
func _is_tile_placeable() -> bool:
    return true

func _is_tile_placeable_with_current_rotation() -> bool:
    return true

# REMARK: Temporary workaround; only until game logic is outsourced from UserInputManager
func _get_next_tile_definition_uuid() -> String:
    self.update_tile_definition_uuid(UserInputManager._curentTileDefinitionUUID)

    return self._tileDefinitionUuid

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
# REMARK: It is necessary to call the base class _init function
# source: https://forum.godotengine.org/t/how-do-i-pass-in-arguments-to-parent-script-when-extending-a-script/24883/2
func _init(mr).(mr) -> void:
    self.update_tile_definition_uuid(UserInputManager._curentTileDefinitionUUID)

