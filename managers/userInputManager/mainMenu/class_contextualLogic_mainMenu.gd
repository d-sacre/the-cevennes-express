extends Node

class_name TCEMainMenuContextualLogic

################################################################################
################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn
# "UiActionManager": res://managers/uiActionManager/uiActionManager.tscn
# "TransistionManager": res://managers/transitionManager/transitionManager.tscn

var _context : String

func _is_tce_signaling_uuid_matching(tce_event_uuid : String, keyChain : Array) -> bool:
	return UserInputManager.match_tce_event_uuid(tce_event_uuid, keyChain)

################################################################################
################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
################################################################################

func initialize(context : String) -> void:
    self._context = context

################################################################################
#### PUBLIC MEMBER FUNCTIONS: USER INPUT PIPELINE ##############################
################################################################################
# REMARK: Removed typesafety for value to be more flexible and require less signals/parsing logic
func general_processing_pipeline(tce_event_uuid : String, value) -> void: 
    print(tce_event_uuid)
    if self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "root", "button", "play", "pressed"]):
        get_tree().change_scene("res://Main.tscn")

    if self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "root", "button", "exit", "pressed"]):
        TransitionManager.exit_to_system()

    UiActionManager.manage_ui_action_mapping(tce_event_uuid, value)

################################################################################
#### PUBLIC MEMBER FUNCTIONS: GUI MANAGEMENT PIPELINE ##########################
################################################################################
func gui_context_management_pipeline(tce_event_uuid : String, _value : String) -> void:
	pass