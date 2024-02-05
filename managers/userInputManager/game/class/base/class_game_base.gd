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
var _guiLayerReferences : Dictionary = {}
var _context : String

var _tileDefinitionUuid : String = "" # REMARK: Not a good solution; could crash the game if the function is not properly overwritten
var _currentGuiMouseContext : String 

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
# REMARK: Private functions in the sense as they should neither be accessed nor
# changed outside of the parent class or inherited classes

################################################################################
#### SETTER AND GETTER
func _get_next_tile_definition_uuid() -> String:
    # REMARK: Not a good solution; could crash the game if the function is not properly overwritten
    return self._tileDefinitionUuid

func _get_floating_tile_status() -> Dictionary:
    var _dict : Dictionary = {}
    if not self._managerReferences["hexGridManager"].is_current_grid_index_out_of_bounds():
         _dict = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()

    return _dict

func _hide_gui(status : bool) -> void:
    pass

################################################################################
#### BOOLS
func _is_tile_placeable() -> bool:
    return false

func _is_tile_placeable_with_current_rotation() -> bool:
    return false

## event handling
func _is_mouse_event(tce_signaling_uuid : String) -> bool: 
    if tce_signaling_uuid.match("*::user::interaction::*"):
        if tce_signaling_uuid.match("*::mouse::*"):
            return true

    return false

func _is_mouse_left_click(tce_signaling_uuid : String) -> bool:
    return self._is_mouse_event(tce_signaling_uuid) and tce_signaling_uuid.match("*::click::left")

func _is_mouse_right_click(tce_signaling_uuid : String) -> bool:
    return self._is_mouse_event(tce_signaling_uuid) and tce_signaling_uuid.match("*::click::right")
    

func _is_correct_context_for_placing_tile(tce_signaling_uuid : String) -> bool:
    return self._is_mouse_left_click(tce_signaling_uuid) and self._currentGuiMouseContext.match("*::grid")
    # if tce_signaling_uuid.match("*::user::interaction::*"):
    #     if tce_signaling_uuid.match("*::mouse::*"):
    #         if tce_signaling_uuid.match("*::click::left"):  
    #             if self._currentGuiMouseContext.match("*::grid"):
    #                 return true
    # return false

func _is_correct_context_for_rotating_tile_clockwise(tce_signaling_uuid : String) -> bool:
    return self._is_mouse_right_click(tce_signaling_uuid) and self._currentGuiMouseContext.match("*::grid")

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize_floating_tile() -> void:
    var tile_definition_uuid = self._get_next_tile_definition_uuid()
    if tile_definition_uuid != "": 
        var tile_definition = self._managerReferences["tileDefinitionManager"].get_tile_definition_database_entry(tile_definition_uuid) 
        self._managerReferences["hexGridManager"].create_floating_tile(tile_definition)

func update_tile_definition_uuid(uuid : String) -> void:
    self._tileDefinitionUuid = uuid

func change_floating_tile_type() -> void:
    var tile_definition_uuid = self._get_next_tile_definition_uuid()
    if tile_definition_uuid != "": 
        var tile_definition = self._managerReferences["tileDefinitionManager"].get_tile_definition_database_entry(tile_definition_uuid) 
        self._managerReferences["hexGridManager"].change_floating_tile_type(tile_definition)

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
            var _tile_definition_uuid : String = self._get_next_tile_definition_uuid()

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

func user_input_pipeline(tce_signaling_uuid : String, value : String) -> void:
    # print("<Game Base::UI Command Pipeline> received: <", tce_signaling_uuid, "> with value: <", value, ">") 
    if tce_signaling_uuid.match("game::*"): # Safety to ensure that only valid requests are processed
        # print("Success: <TCE_SIGNALING_UUID|",tce_signaling_uuid, "> can be processed!")
        # if tce_signaling_uuid.match("*::user::interaction::*"):
        #     if tce_signaling_uuid.match("*::mouse::*"):
        #         if tce_signaling_uuid.match("*::click::left"):  
        #             if self._currentGuiMouseContext.match("*::grid"):
        #                 self.place_tile()
        #         elif tce_signaling_uuid.match("*::click::right"):
        #             if self._currentGuiMouseContext.match("*::grid"):
        #                 self.rotate_tile_clockwise()
        #     else:
        #         pass
        # else:
        #     pass
        if self._is_correct_context_for_placing_tile(tce_signaling_uuid):
            self.place_tile()

        if self._is_correct_context_for_rotating_tile_clockwise(tce_signaling_uuid):
            self.rotate_tile_clockwise()
        if tce_signaling_uuid.match("*::user::selected::gui::show"):
            self._hide_gui(false)

        if tce_signaling_uuid.match("*::user::selected::gui::hide"):
            self._hide_gui(true)
    else:
        print("Error: <TCE_SIGNALING_UUID|",tce_signaling_uuid, "> could not be processed!")

func gui_management_pipeline(tce_signaling_uuid : String, value : String) -> void:
    # print("<Game Base::GUI Management Pipeline> received: <", tce_signaling_uuid, "> with value: <", value, ">")
    if tce_signaling_uuid.match("game::*::gui::*"):
        pass
    else:
        print("Error: <TCE_SIGNALING_UUID|",tce_signaling_uuid, "> could not be processed!")

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _init(ctxt : String, mr : Dictionary, glr : Dictionary) -> void:
    self._context = ctxt
    self._managerReferences = mr
    self._currentGuiMouseContext = self._context + UserInputManager.TCE_SIGNALING_UUID_SEPERATOR+ "grid"
    self._guiLayerReferences = glr
