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
	return self._currentGuiMouseContext.match("*grid")

func _is_correct_context_for_placing_tile(tce_signaling_uuid : String) -> bool:
	if ._is_correct_context_for_placing_tile(tce_signaling_uuid):
		if (self._is_current_gui_mouse_context_grid()):  
			if self._selectorOperationMode == "place":
				if not self._is_gui_hidden:
					return true

	return false

func _is_mouse_right_click(tce_signaling_uuid : String) -> bool:
	return ._is_mouse_right_click(tce_signaling_uuid) and not ((self._selectorOperationMode == "pick") or (self._selectorOperationMode == "delete"))

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

		# remove floating tile if existing
		if self._managerReferences["hexGridManager"].floating_tile_reference != self._managerReferences["hexGridManager"]:
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
		# DESCRIPTION: Handling of setting the different action mode
		if self._is_tile_action_mode_changed_to_place(tce_signaling_uuid):
			self._selectorOperationMode = "place"

			if self._managerReferences["hexGridManager"].floating_tile_reference == self._managerReferences["hexGridManager"]:
				self._create_new_floating_tile()

		if self._is_tile_action_mode_changed_to_replace(tce_signaling_uuid):
			self._selectorOperationMode = "replace"

			if self._managerReferences["hexGridManager"].floating_tile_reference == self._managerReferences["hexGridManager"]:
				self._create_new_floating_tile()

		if self._is_tile_action_mode_changed_to_pick(tce_signaling_uuid):
			self._selectorOperationMode = "pick"

			if self._managerReferences["hexGridManager"].floating_tile_reference == self._managerReferences["hexGridManager"]:
				self._create_new_floating_tile()

		if self._is_tile_action_mode_changed_to_delete(tce_signaling_uuid):
			self._selectorOperationMode = "delete"

			# remove floating tile if existing
			if self._managerReferences["hexGridManager"].floating_tile_reference != self._managerReferences["hexGridManager"]:
				var _floating_tile_status : Dictionary = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
				self._last_tile_definition_uuid = _floating_tile_status["TILE_DEFINITION_UUID"]
				self._managerReferences["hexGridManager"].delete_floating_tile()

		# DESCRIPTION: Handling of selections
		if self._is_correct_context_for_obtaining_new_tile_definition(tce_signaling_uuid):
			if value is String:
				self.update_tile_definition_uuid(value)
				self.change_floating_tile_type()

		# DESCRIPTION: Handling of grid interaction
		if self._is_correct_context_for_replacing_tile(tce_signaling_uuid):
			self.replace_tile()

		if self._is_correct_context_for_deleting_tile(tce_signaling_uuid):
			self.delete_tile()

		if _is_correct_context_for_picking_tile_definition_uuid(tce_signaling_uuid):
			var _tmp_tduuid : String = self._managerReferences["hexGridManager"].get_tile_definition_uuid_from_current_grid_index()
			
			if _tmp_tduuid != "":
				self.update_tile_definition_uuid(_tmp_tduuid)
			else:
				self._managerReferences["hexGridManager"].set_status_placeholder(false, true)
				audioManager.play_sfx(["game", "tile", "fail"])

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
#### PRIVATE MEMBER FUNCTIONS: BOOL ACTION MODE ################################
################################################################################
func _is_tile_action_mode_changed_to_place(tce_signaling_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*", "user", "selected", "tile", "action", "place"])

func _is_tile_action_mode_changed_to_replace(tce_signaling_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*", "user", "selected", "tile", "action", "replace"])

func _is_tile_action_mode_changed_to_pick(tce_signaling_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*", "user", "selected", "tile", "action", "pick"])

func _is_tile_action_mode_changed_to_delete(tce_signaling_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*", "user", "selected", "tile", "action", "delete"])

################################################################################
#### PRIVATE MEMBER FUNCTIONS: BOOL CONTEXT ####################################
################################################################################
func _is_correct_context_for_obtaining_new_tile_definition(tce_signaling_uuid : String) -> bool:
	if tce_signaling_uuid.match("*::user::selected::tile::definition"):
		if (self._selectorOperationMode == "place") or (self._selectorOperationMode == "replace"):
			return true

	return false

func _is_grid_interaction_permitted(tce_signaling_uuid : String) -> bool:
	if ._is_correct_context_for_placing_tile(tce_signaling_uuid):
		if (self._is_current_gui_mouse_context_grid()):  
			if not self._is_gui_hidden:
				return true

	return false

func _is_correct_context_for_replacing_tile(tce_signaling_uuid : String) -> bool:
	if self._is_grid_interaction_permitted(tce_signaling_uuid):
		if self._selectorOperationMode == "replace":
			return true

	# if ._is_correct_context_for_placing_tile(tce_signaling_uuid):
	# 	if (self._is_current_gui_mouse_context_grid()):  
	# 		if self._selectorOperationMode == "replace":
	# 			if not self._is_gui_hidden:
	# 				return true

	return false

func _is_correct_context_for_picking_tile_definition_uuid(tce_signaling_uuid : String) -> bool:
	if self._is_grid_interaction_permitted(tce_signaling_uuid):
		if self._selectorOperationMode == "pick":
			return true
	
	return false


func _is_correct_context_for_deleting_tile(tce_signaling_uuid : String) -> bool:
	if self._is_grid_interaction_permitted(tce_signaling_uuid):
		if self._selectorOperationMode == "delete":
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

func replace_tile() -> void:
	if not self._managerReferences["hexGridManager"].is_current_grid_index_out_of_bounds():
		var _floating_tile_status : Dictionary = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
		var _is_placeable : bool = false
		
		if _floating_tile_status.has("TILE_DEFINITION_UUID"): # required to prevent issues when no floating tile exists
			_is_placeable = self._managerReferences["hexGridManager"].tile_reference[self._managerReferences["hexGridManager"].get_current_grid_index()]["type"] != "placeholder"

		if _is_placeable:
			self._managerReferences["hexGridManager"].replace_tile()
			audioManager.play_sfx(["game", "tile", "success"])

			self._create_new_floating_tile()
			# var _tile_definition_uuid : String = self._get_next_tile_definition_uuid()

			# if _tile_definition_uuid != "": 
			# 	var _tile_definition = self._managerReferences["tileDefinitionManager"].get_tile_definition_database_entry(_tile_definition_uuid) 
			# 	self._managerReferences["hexGridManager"].create_floating_tile(_tile_definition)
		else:
			self._managerReferences["hexGridManager"].set_status_placeholder(false, true)
			audioManager.play_sfx(["game", "tile", "fail"])

func delete_tile() -> void:
	if not self._managerReferences["hexGridManager"].is_current_grid_index_out_of_bounds():
		var _is_removable : bool = false

		var _grid_element_status : Dictionary = self._managerReferences["hexGridManager"].get_current_grid_element_information()
		
		if _grid_element_status.has("type"):
			if _grid_element_status["type"] != "placeholder":
				_is_removable = true

		# FUTURE: Perhaps outsource this into a function template that can be overwritten
		if _is_removable:
			self._managerReferences["hexGridManager"].delete_tile()
			audioManager.play_sfx(["game", "tile", "success"])
		else:
			self._managerReferences["hexGridManager"].set_status_placeholder(false, true)
			audioManager.play_sfx(["game", "tile", "fail"])

################################################################################
################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
################################################################################
# REMARK: It is necessary to call the base class _init function
# source: https://forum.godotengine.org/t/how-do-i-pass-in-arguments-to-parent-script-when-extending-a-script/24883/2
func _init(ctxt, mr, glr).(ctxt, mr, glr) -> void:
	self.update_tile_definition_uuid(UserInputManager._curentTileDefinitionUUID)

