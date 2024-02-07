class_name game_creative

extends game_base

################################################################################
################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn

################################################################################
################################################################################
#### PARENT CLASS PRIVATE MEMBER FUNCTION OVERRIDES ############################
################################################################################
################################################################################

################################################################################
#### PARENT CLASS PRIVATE MEMBER FUNCTION OVERRIDES: BOOL EXPRESSIONS ##########
################################################################################
func _is_tile_placeable() -> bool:
	return true

func _is_tile_placeable_with_current_rotation() -> bool:
	return true

func _is_current_gui_mouse_context_grid() -> bool:
	# print("Game Class: _is_currentGUIMouseContext == grid: ", self._currentGuiMouseContext)
	return self._currentGuiMouseContext.match("*grid")

func _is_correct_context_for_placing_tile(tce_signaling_uuid : String) -> bool:
	if ._is_correct_context_for_placing_tile(tce_signaling_uuid):
		if (self._is_current_gui_mouse_context_grid()):  
			if self._selectorOperationMode == "place":
				if not self._is_gui_hidden:
					return true

	return false

################################################################################
#### PARENT CLASS PRIVATE MEMBER FUNCTION OVERRIDES: TOOLS #####################
################################################################################
func _hide_gui(status : bool) -> void:
	self._is_gui_hidden = status
	# REMARK: Should be implemented properly at a later date
	self._selectorOperationMode = "NONE" 

	self._guiLayerReferences["overlay"].visible = not status

	if status:
		self._currentGuiMouseContext = self._context + UserInputManager.TCE_SIGNALING_UUID_SEPERATOR+ "grid"
		self._managerReferences["cameraManager"].enable_zooming()
		self._managerReferences["cameraManager"].enable_raycasting()

		var _scene = load("res://gui/overlays/creativeMode/hiddenGUI/hiddenGUI.tscn")
		var _instance = _scene.instance()
		_instance.initialize(self._context)
		self._guiLayerReferences["hidden"].add_child(_instance)

		# remove floating tile
		var _floating_tile_status : Dictionary = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
		self._last_tile_definition_uuid = _floating_tile_status["TILE_DEFINITION_UUID"]
		self._managerReferences["hexGridManager"].delete_floating_tile()
		self._managerReferences["hexGridManager"].set_single_grid_cell_highlight(self._managerReferences["hexGridManager"].get_last_index_within_grid_boundary(), false)
		self._managerReferences["hexGridManager"].set_highlight_persistence("void", false)
		
	else:
		self._guiLayerReferences["overlay"].get_node("creativeModeOverlay").set_creative_mode_gui_to_default()
		self._selectorOperationMode = "place" # REMARK: Should be implemented properly at a later date
		var _tmp_tile_definition = self._managerReferences["tileDefinitionManager"].get_tile_definition_database_entry(self._last_tile_definition_uuid)
		self._managerReferences["hexGridManager"].create_floating_tile(_tmp_tile_definition)
		self._managerReferences["hexGridManager"]._last_index_within_grid_boundary_highlight = self._managerReferences["hexGridManager"].get_last_index_within_grid_boundary()
		self._managerReferences["hexGridManager"].set_single_grid_cell_highlight(self._managerReferences["hexGridManager"]._last_index_within_grid_boundary_highlight, true)
		self._managerReferences["hexGridManager"].set_highlight_persistence("void", true)

################################################################################
################################################################################
#### PARENT CLASS PUBLIC MEMBER FUNCTION OVERRIDES #############################
################################################################################
################################################################################

################################################################################
#### PARENT CLASS PUBLIC MEMBER FUNCTION OVERRIDES: GUI MANAGEMENT PIPELINE ####
################################################################################
func gui_management_pipeline(tce_signaling_uuid : String, value) -> void:
	.gui_management_pipeline(tce_signaling_uuid, value) # execute base class function definition

	# Extend base class functionality
	if tce_signaling_uuid.match("game::*::gui::*"):
		if tce_signaling_uuid.match("*::sidepanel::right::selector::tile::definition"):
			if value is String:
				self._manage_grid_to_gui_transition(tce_signaling_uuid, value)

		elif tce_signaling_uuid.match("*::hud::selector::action"):
			if value is String:
				self._manage_grid_to_gui_transition(tce_signaling_uuid, value)
	else:
		pass
		# REMARK: Disabled for the time being until Main Menu is updated to prevent enormous amount of printing
		# print("Error: <TCE_SIGNALING_UUID|",tce_signaling_uuid, "> could not be processed!")

################################################################################
#### PARENT CLASS PUBLIC MEMBER FUNCTION OVERRIDES USER INPUT PIPELINE #########
################################################################################
# REMARK: Removed typesafety for value to be more flexible and require less signals/parsing logic
func user_input_pipeline(tce_signaling_uuid : String, value) -> void: 
	.user_input_pipeline(tce_signaling_uuid, value) # execute base class function definition

	# Extend base class functionality
	if tce_signaling_uuid.match("game::creative::*"): # Safety to ensure that only valid requests are processed
		if self._is_correct_context_for_obtaining_new_tile_definition(tce_signaling_uuid):
			if value is String:
				self.update_tile_definition_uuid(value)
				self.change_floating_tile_type()
	else:
		pass
		# REMARK: Disabled for the time being until Main Menu is updated to prevent enormous amount of printing
		# print("Error: <TCE_SIGNALING_UUID|",tce_signaling_uuid, "> could not be processed!")

################################################################################
################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
################################################################################
var _selectorOperationMode : String = "place" #"place"
var _is_gui_hidden : bool = false
var _last_tile_definition_uuid : String 

################################################################################
################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
################################################################################

################################################################################
#### PRIVATE MEMBER FUNCTIONS: BOOL CONTEXT ####################################
################################################################################
func _is_correct_context_for_obtaining_new_tile_definition(tce_signaling_uuid : String) -> bool:
	if tce_signaling_uuid.match("*::user::selected::tile::definition"):
		if self._selectorOperationMode == "place":
			return true

	return false

################################################################################
#### PRIVATE MEMBER FUNCTIONS: TOOLS ###########################################
################################################################################
func _manage_grid_to_gui_transition(tce_signaling_uuid : String, value : String) -> void:
	if value == "entered":
		self._currentGuiMouseContext = tce_signaling_uuid
		self._managerReferences["cameraManager"].disable_zooming()
		self._managerReferences["cameraManager"].disable_raycasting()
	else:
		self._currentGuiMouseContext = self._context + UserInputManager.TCE_SIGNALING_UUID_SEPERATOR + "grid"
		self._managerReferences["cameraManager"].enable_zooming()
		self._managerReferences["cameraManager"].enable_raycasting()

################################################################################
################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
################################################################################
# REMARK: It is necessary to call the base class _init function
# source: https://forum.godotengine.org/t/how-do-i-pass-in-arguments-to-parent-script-when-extending-a-script/24883/2
func _init(ctxt, mr, glr).(ctxt, mr, glr) -> void:
	self.update_tile_definition_uuid(UserInputManager._curentTileDefinitionUUID)

