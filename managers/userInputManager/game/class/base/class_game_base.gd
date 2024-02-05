class_name game_base

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn
# "audioManager": res://managers/audioManager/audioManager.tscn

################################################################################
#### IMPORTANT REMARKS #########################################################
################################################################################
# It is not possible to specify an override for the _process() function, as it 
# does not seem to be run, even after the class being properly initialized 

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _managerReferences : Dictionary = {}

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
# REMARK: Private functions in the sense as they should neither be accessed nor
# changed outside of the parent class or inherited classes

func _is_tile_placeable() -> bool:
    return false

func _is_tile_placeable_with_current_rotation() -> bool:
    return false

func _next_tile_definition_uuid() -> String:
    # REMARK: Not a good solution; could crash the game if the function is not properly overwritten
    var _new_tduuid : String = "" 
    return _new_tduuid

func _get_floating_tile_status() -> Dictionary:
    var _dict : Dictionary = {}
    if not self._managerReferences["hexGridManager"].is_current_grid_index_out_of_bounds():
         _dict = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()

    return _dict

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func place_tile() -> void:
    if not self._managerReferences["hexGridManager"].is_current_grid_index_out_of_bounds():
        var _floating_tile_status : Dictionary = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
        var _is_placeable : bool = false
        
        if _floating_tile_status.has("TILE_DEFINITION_UUID"): # required to prevent issues when no floating tile exists
            _is_placeable = self._is_tile_placeable()

        if _is_placeable:
            self._managerReferences["hexGridManager"].set_status_placeholder(true, false)
            self._managerReferences["hexGridManager"].place_floating_tile()#_at_index(_current_tile_index)
            audioManager.play_sfx(["game", "tile", "success"])
            
            # REMARK: Only temporary solution, until proper logic separation into different variants is in place!
            var _tile_definition_uuid : String = self._next_tile_definition_uuid()

            if _tile_definition_uuid != "": 
                var _tile_definition = self._managerReferences["tileDefinitionManager"].get_tile_definition_database_entry(_tile_definition_uuid) 
                self._managerReferences["hexGridManager"].create_floating_tile(_tile_definition)
        else:
            self._managerReferences["hexGridManager"].set_status_placeholder(false, true)
            audioManager.play_sfx(["game", "tile", "fail"])

func rotate_tile_clockwise() -> void:
    self._managerReferences["hexGridManager"].rotate_floating_tile_clockwise() # rotate tile
    audioManager.play_sfx(["game", "tile", "rotate"])
    
    if not self._managerReferences["hexGridManager"].is_current_grid_index_out_of_bounds(): # safety to absolutely ensure that cursor is not out of grid bounds 
        var _floating_tile_status = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
        
        if _floating_tile_status.has("TILE_DEFINITION_UUID"): # if a floating tile exists
            # inquire at C++ Backend whether the tile would fit
            var _is_placeable : bool = self._is_tile_placeable_with_current_rotation()
            
            # set the highlight according to the answer of the C++ Backend
            if _is_placeable:
                self._managerReferences["hexGridManager"].set_status_placeholder(true, false)
            else:
                self._managerReferences["hexGridManager"].set_status_placeholder(false, true)

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _init(mr : Dictionary) -> void:
    self._managerReferences = mr
