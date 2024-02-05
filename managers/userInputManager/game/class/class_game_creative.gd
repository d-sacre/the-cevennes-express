class_name game_creative

extends game_base

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _selectorOperationMode : String = "place" #"place"

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn

################################################################################
#### PARENT CLASS PRIVATE MEMBER FUNCTION OVERRIDES ############################
################################################################################
func _is_tile_placeable() -> bool:
	return true

func _is_tile_placeable_with_current_rotation() -> bool:
	return true

func _is_correct_context_for_placing_tile(tce_signaling_uuid : String) -> bool:
	return ._is_correct_context_for_placing_tile(tce_signaling_uuid) and (self._selectorOperationMode == "place")


func _hide_gui(status : bool) -> void:
	self._guiLayerReferences["overlay"].visible = not status

	if status:
		self._currentGuiMouseContext = self._context + UserInputManager.TCE_SIGNALING_UUID_SEPERATOR+ "grid"
		self._managerReferences["cameraManager"].enable_zooming()
		self._managerReferences["cameraManager"].enable_raycasting()

		var _scene = load("res://gui/overlays/creativeMode/hiddenGUI/hiddenGUI.tscn")
		var _instance = _scene.instance()
		_instance.initialize(self._context)
		self._guiLayerReferences["hidden"].add_child(_instance)
		
	else:
		self._guiLayerReferences["overlay"].get_node("creativeModeOverlay").set_creative_mode_gui_to_default()

# # REMARK: Temporary workaround; only until game logic is outsourced from UserInputManager
# func _get_next_tile_definition_uuid() -> String:
#     self.update_tile_definition_uuid(UserInputManager._curentTileDefinitionUUID)

#     return self._tileDefinitionUuid

################################################################################
#### PARENT CLASS PUBLIC MEMBER FUNCTION OVERRIDES #############################
################################################################################
func gui_management_pipeline(tce_signaling_uuid : String, value : String) -> void:
	.gui_management_pipeline(tce_signaling_uuid, value) # execute base class function definition

	# Extend base class functionality
	if tce_signaling_uuid.match("game::*::gui::*"):
		if tce_signaling_uuid.match("*::sidepanel::right::selector::tile::definition"):
			self._manage_grid_to_gui_transition(tce_signaling_uuid, value)

		elif tce_signaling_uuid.match("*::hud::selector::action"):
			self._manage_grid_to_gui_transition(tce_signaling_uuid, value)
	else:
		print("Error: <TCE_SIGNALING_UUID|",tce_signaling_uuid, "> could not be processed!")

func user_input_pipeline(tce_signaling_uuid : String, value : String) -> void: 
	.user_input_pipeline(tce_signaling_uuid, value) # execute base class function definition

	# Extend base class functionality
	if tce_signaling_uuid.match("game::creative::*"): # Safety to ensure that only valid requests are processed
		if self._is_correct_context_for_obtaining_new_tile_definition(tce_signaling_uuid):
			self.update_tile_definition_uuid(value)
			self.change_floating_tile_type()
	else:
		print("Error: <TCE_SIGNALING_UUID|",tce_signaling_uuid, "> could not be processed!")

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################

# bool
func _is_correct_context_for_obtaining_new_tile_definition(tce_signaling_uuid : String) -> bool:
	if tce_signaling_uuid.match("*::user::selected::tile::definition"):
		if self._selectorOperationMode == "place":
			return true

	return false

# tools
func _manage_grid_to_gui_transition(tce_signaling_uuid : String, value : String) -> void:
	if value == "entered":
		self._currentGuiMouseContext = tce_signaling_uuid
		self._managerReferences["cameraManager"].disable_zooming()
		self._managerReferences["cameraManager"].disable_raycasting()
	else:
		self._currentGuiMouseContext = self._context + UserInputManager.TCE_SIGNALING_UUID_SEPERATOR+ "grid"
		self._managerReferences["cameraManager"].enable_zooming()
		self._managerReferences["cameraManager"].enable_raycasting()

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
# REMARK: It is necessary to call the base class _init function
# source: https://forum.godotengine.org/t/how-do-i-pass-in-arguments-to-parent-script-when-extending-a-script/24883/2
func _init(ctxt, mr, glr).(ctxt, mr, glr) -> void:
	self.update_tile_definition_uuid(UserInputManager._curentTileDefinitionUUID)

