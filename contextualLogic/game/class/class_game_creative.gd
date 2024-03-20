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
func _update_tile_definition_uuid(uuid : String) -> void:
	._update_tile_definition_uuid(uuid)
	var _tmp_eventKeychain : Array = ["UserInputManager", "requesting", "global", "update", "tile", "definition", "uuid"]
	var _tmp_eventString : String = UserInputManager.create_tce_event_uuid(self._context, _tmp_eventKeychain)
	UserInputManager.transmit_global_event(_tmp_eventString, self._tileDefinitionUuid)

################################################################################
#### PARENT CLASS PRIVATE MEMBER FUNCTION OVERRIDES: BOOL EXPRESSIONS ##########
################################################################################
func _is_tile_placeable() -> bool:
	# REMARK: Needs to be adapted when C++ Backend has been updated; needs to take into account
	# the difference between place (Backend request required) and replace (always allowed)
	return true

func _is_tile_placeable_with_current_rotation() -> bool:
	# REMARK: Needs to be adapted when C++ Backend has been updated; needs to take into account
	# the difference between place (Backend request required) and replace (always allowed)
	return true

func _is_correct_context_for_placing_tile(tce_event_uuid : String) -> bool:
	if ._is_correct_context_for_placing_tile(tce_event_uuid):
		if self._selectorOperationMode == "place":
			if not self._is_gui_hidden:
				if UserInputManager._currentInputMethod.match("*mouse*"):
					if (UserInputManager.is_current_gui_context_grid()):  # REMARK: Already in base class definition?
						return true
				else:
					return true
	return false

func _is_input_event_option_general(tce_event_uuid : String) -> bool:
	return ._is_input_event_option_general(tce_event_uuid) and not ((self._selectorOperationMode == "pick") or (self._selectorOperationMode == "delete") or self._is_gui_hidden)

################################################################################
#### PARENT CLASS PRIVATE MEMBER FUNCTION OVERRIDES: TOOLS #####################
################################################################################
func _hide_gui_creative_mode(status : bool) -> void:
	# REMARK: Should be implemented properly at a later date
	self._selectorOperationMode = "NONE" 
	var _creativeModeOverlay : Object = self._guiLayerReferences["overlay"].get_node("creativeModeOverlay")
	var _hiddenGuiElement : Object = self._guiLayerReferences["hidden"].get_node("hiddenGUI")

	# self._guiLayerReferences["overlay"].visible = true # not status

	if status:
		_creativeModeOverlay.enable_hidden_overlay_mode()
		UserInputManager.set_current_gui_context_to_grid()
		
		self._managerReferences["cameraManager"].enable_zooming()
		self._managerReferences["cameraManager"].enable_raycasting()

		# # REMARK:/FUTURE: Should be instanced @ ready and only visibility set, not deleted
		# if not self._is_gui_hidden:  # REMARK: To remove multiple "Unhide GUI" Buttons
		# 	var _scene = load("res://gui/overlays/creativeMode/hiddenGUI/hiddenGUI.tscn")
		# 	var _instance = _scene.instance()
		# 	_instance.initialize(self._context)
		# 	self._guiLayerReferences["hidden"].add_child(_instance)

		_hiddenGuiElement.reactivate_and_unhide()

		# DESCRIPTION: Remove floating tile if existing
		if self._managerReferences["hexGridManager"].is_floating_tile_reference_valid():
			var _floating_tile_status : Dictionary = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
			self._last_tile_definition_uuid = _floating_tile_status["TILE_DEFINITION_UUID"]
			self._managerReferences["hexGridManager"].delete_floating_tile()
		
		self._managerReferences["hexGridManager"].set_single_grid_cell_highlight(self._managerReferences["hexGridManager"].get_last_index_within_grid_boundary(), false)
		self._managerReferences["hexGridManager"].set_highlight_persistence("void", false)

	else:
		# # DESCRIPTION: Delete unhide GUI button if still existing
		# if self._guiLayerReferences["hidden"].has_node("hiddenGUI"):
		# 	# FUTURE: Play hiding animation before deleting element
		# 	self._guiLayerReferences["hidden"].get_node("hiddenGUI").queue_free()
		_hiddenGuiElement.deactivate_and_hide()

		
		_creativeModeOverlay.disable_hidden_overlay_mode()
		_creativeModeOverlay.set_creative_mode_gui_to_default()
		self._selectorOperationMode = "place" # REMARK: Should be implemented properly at a later date to reflect the actually selected mode

		if not self._managerReferences["hexGridManager"].is_floating_tile_reference_valid():
			var _tmp_tile_definition = self._managerReferences["tileDefinitionManager"].get_tile_definition_database_entry(self._last_tile_definition_uuid)
			self._managerReferences["hexGridManager"].create_floating_tile(_tmp_tile_definition)
		
		self._managerReferences["hexGridManager"]._last_index_within_grid_boundary_highlight = self._managerReferences["hexGridManager"].get_last_index_within_grid_boundary()
		self._managerReferences["hexGridManager"].set_single_grid_cell_highlight(self._managerReferences["hexGridManager"]._last_index_within_grid_boundary_highlight, true)
		self._managerReferences["hexGridManager"].set_highlight_persistence("void", true)

	self._is_gui_hidden = status
	print_debug(self._is_gui_hidden)

func _hide_gui(status : bool) -> void:
	self._hide_gui_creative_mode(status)

func _toggle_gui_visibility() -> void:
	._toggle_gui_visibility()
	self._hide_gui_creative_mode(self._is_gui_hidden)

func _movement_channel2(asmr : Vector2) -> void:
	var _tmp_eventKeychain : Array = ["UserInputManager", "requesting", "global", "update", "tile", "definition", "selector", "position"]
	var _tmp_eventString : String = UserInputManager.create_tce_event_uuid(self._context, _tmp_eventKeychain)
	UserInputManager.transmit_global_event(_tmp_eventString, asmr)

################################################################################
################################################################################
#### PARENT CLASS PUBLIC MEMBER FUNCTION OVERRIDES #############################
################################################################################
################################################################################

################################################################################
#### PARENT CLASS PUBLIC MEMBER FUNCTION OVERRIDES: GUI MANAGEMENT PIPELINE ####
################################################################################
func gui_context_management_pipeline(tce_event_uuid : String, value) -> void:
	.gui_context_management_pipeline(tce_event_uuid, value) # execute base class function definition
	self._manage_grid_to_gui_transition(tce_event_uuid, value)

################################################################################
#### PARENT CLASS PUBLIC MEMBER FUNCTION OVERRIDES GENERAL PROCESSING PIPELINE #
################################################################################
# REMARK: Removed typesafety for value to be more flexible and require less signals/parsing logic
func general_processing_pipeline(tce_event_uuid : String, value) -> void: 
	.general_processing_pipeline(tce_event_uuid, value) # execute base class function definition

	var _creativeModeOverlay : Object = self._guiLayerReferences["overlay"].get_node("creativeModeOverlay")

	# Extend base class functionality
	if tce_event_uuid.match("game::creative::*"): # Safety to ensure that only valid requests are processed
		if self._is_next_action_mode_requested(tce_event_uuid):
			var _tmp_eventKeychain : Array = ["UserInputManager", "requesting", "global", "execution", "change", "tile", "action", "mode", "index", "by"]
			var _tmp_eventString : String = UserInputManager.create_tce_event_uuid(self._context, _tmp_eventKeychain)
			UserInputManager.transmit_global_event(_tmp_eventString, 1)

		if self._is_previous_action_mode_requested(tce_event_uuid):
			var _tmp_eventKeychain : Array = ["UserInputManager", "requesting", "global", "execution", "change", "tile", "action", "mode", "index", "by"]
			var _tmp_eventString : String = UserInputManager.create_tce_event_uuid(self._context, _tmp_eventKeychain)
			UserInputManager.transmit_global_event(_tmp_eventString, -1)
		
		# DESCRIPTION: Handling of setting the different action mode
		if self._is_tile_action_mode_changed_to_place(tce_event_uuid):
			self._selectorOperationMode = "place"
			_creativeModeOverlay.reactivate_and_unhide_tile_selector()

			if not self._managerReferences["hexGridManager"].is_floating_tile_reference_valid():
				self._create_new_floating_tile()

		if self._is_tile_action_mode_changed_to_replace(tce_event_uuid):
			self._selectorOperationMode = "replace"
			_creativeModeOverlay.reactivate_and_unhide_tile_selector()
			
			if not self._managerReferences["hexGridManager"].is_floating_tile_reference_valid():
				self._create_new_floating_tile()

		if self._is_tile_action_mode_changed_to_pick(tce_event_uuid):
			self._selectorOperationMode = "pick"
			_creativeModeOverlay.reactivate_and_unhide_tile_selector()

			if not self._managerReferences["hexGridManager"].is_floating_tile_reference_valid():
				self._create_new_floating_tile()

		if self._is_tile_action_mode_changed_to_delete(tce_event_uuid):
			self._selectorOperationMode = "delete"
			_creativeModeOverlay.deactivate_and_hide_tile_selector()

			# remove floating tile if existing
			if self._managerReferences["hexGridManager"].is_floating_tile_reference_valid():
				var _floating_tile_status : Dictionary = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
				self._last_tile_definition_uuid = _floating_tile_status["TILE_DEFINITION_UUID"]
				self._managerReferences["hexGridManager"].delete_floating_tile()
		
		# DESCRIPTION: Checking for option key presses
		for _i in range(1,6):
			var _tmp_eventKeychain : Array = ["user", "interaction", "option", str(_i)]
			var _tmp_eventString : String = UserInputManager.create_tce_event_uuid(self._context, _tmp_eventKeychain)
			if tce_event_uuid.match(_tmp_eventString):
				# DESCRIPTION: Unhide GUI first if it should be hidden and the hide gui options has not been requested
				if self._is_gui_hidden:
					print_debug(self._is_gui_hidden)
					if _i!= 5:
						self._hide_gui(false)

					# self._hide_gui(false)
				
				# DESCRIPTION: Send a execution request via the InputManager Command Signal to ensure that all relevant
				# entities can react properly.
				_tmp_eventKeychain  = ["UserInputManager", "requesting", "global", "execution", "option", str(_i)]
				_tmp_eventString  = UserInputManager.create_tce_event_uuid(self._context, _tmp_eventKeychain)
				UserInputManager.transmit_global_event(_tmp_eventString, _i)

		# DESCRIPTION: Handling of selections
		if self._is_correct_context_for_obtaining_new_tile_definition(tce_event_uuid):
			if value is String:
				self._update_tile_definition_uuid(value)
				self.change_floating_tile_type()

		# DESCRIPTION: Handling of grid interaction
		if self._is_correct_context_for_replacing_tile(tce_event_uuid):
			self.replace_tile()

		if self._is_correct_context_for_deleting_tile(tce_event_uuid):
			self.delete_tile()

		if self._is_correct_context_for_picking_tile_definition_uuid(tce_event_uuid):
			var _tmp_tduuid : String = self._managerReferences["hexGridManager"].get_tile_definition_uuid_from_current_grid_index()
			
			if _tmp_tduuid != "":
				self._update_tile_definition_uuid(_tmp_tduuid)
				audioManager.play_sfx(["game", "tile", "pick"])

				# DESCRIPTION: Change automatically to "place" mode as a quality of life measure
				var _tmp_eventKeychain : Array  = ["UserInputManager", "requesting", "global", "execution", "option1"]
				var _tmp_eventString : String  = UserInputManager.create_tce_event_uuid(self._context, _tmp_eventKeychain)
				UserInputManager.transmit_global_event(_tmp_eventString, 1)

			else:
				self._managerReferences["hexGridManager"].set_status_placeholder(false, true)
				audioManager.play_sfx(["game", "tile", "fail"])

			self.change_floating_tile_type()
	else:
		pass
		# REMARK: Disabled for the time being until Main Menu is updated to prevent enormous amount of printing
		# print("Error: <TCE_SIGNALING_UUID|",tce_event_uuid, "> could not be processed!")

################################################################################
################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
################################################################################
var _selectorOperationMode : String = "place" #"place"
var _last_tile_definition_uuid : String 

################################################################################
################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
################################################################################

################################################################################
#### PRIVATE MEMBER FUNCTIONS: BOOL ACTION MODE ################################
################################################################################
func _is_tile_action_mode_changed_to_place(tce_event_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "user", "selected", "tile", "action", "place"])

func _is_tile_action_mode_changed_to_replace(tce_event_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "user", "selected", "tile", "action", "replace"])

func _is_tile_action_mode_changed_to_pick(tce_event_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "user", "selected", "tile", "action", "pick"])

func _is_tile_action_mode_changed_to_delete(tce_event_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "user", "selected", "tile", "action", "delete"])

func _is_next_action_mode_requested(tce_event_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "user", "interaction", "option", "next"])

func _is_previous_action_mode_requested(tce_event_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "user", "interaction", "option", "previous"])

################################################################################
#### PRIVATE MEMBER FUNCTIONS: BOOL CONTEXT ####################################
################################################################################
func _is_correct_context_for_obtaining_new_tile_definition(tce_event_uuid : String) -> bool:
	if tce_event_uuid.match("*::user::selected::tile::definition"):
		if (self._selectorOperationMode == "place") or (self._selectorOperationMode == "replace"):
			return true

	return false

func _is_grid_interaction_permitted(tce_event_uuid : String) -> bool:
	if ._is_correct_context_for_placing_tile(tce_event_uuid):
		if UserInputManager.is_current_gui_context_grid():  
			if not self._is_gui_hidden:
				return true

	return false

func _is_correct_context_for_replacing_tile(tce_event_uuid : String) -> bool:
	if self._is_grid_interaction_permitted(tce_event_uuid):
		if self._selectorOperationMode == "replace":
			return true

	return false

func _is_correct_context_for_picking_tile_definition_uuid(tce_event_uuid : String) -> bool:
	if self._is_grid_interaction_permitted(tce_event_uuid):
		if self._selectorOperationMode == "pick":
			return true
	
	return false

func _is_correct_context_for_deleting_tile(tce_event_uuid : String) -> bool:
	if self._is_grid_interaction_permitted(tce_event_uuid):
		if self._selectorOperationMode == "delete":
			return true

	return false

################################################################################
#### PRIVATE MEMBER FUNCTIONS: TOOLS ###########################################
################################################################################
# FUTURE: Make sure that this is only called in the appropriate Input Method modes
# (mouse, touch?)
func _manage_grid_to_gui_transition(tce_event_uuid : String, value : String) -> void:
	if UserInputManager.is_current_gui_context_grid():
		self._managerReferences["cameraManager"].enable_zooming()
		self._managerReferences["cameraManager"].enable_raycasting() # REMARK: Should only be called in "*mouse*" Input Method Modes

	elif UserInputManager.is_current_gui_context_void():
		self._managerReferences["cameraManager"].enable_zooming()
		self._managerReferences["cameraManager"].enable_raycasting() # REMARK: Should only be called in "*mouse*" Input Method Modes

	else:
		if value == "entered":
			self._managerReferences["cameraManager"].disable_zooming()
			self._managerReferences["cameraManager"].disable_raycasting()
		else:
			if UserInputManager.match_tce_event_uuid(tce_event_uuid, ["*", "gui", "sidepanel", "right", "selector", "tile", "definition"]):
				UserInputManager.set_current_gui_context_to_grid()
			elif UserInputManager.match_tce_event_uuid(tce_event_uuid, ["*", "gui", "hud", "selector", "action"]):
				if UserInputManager.is_current_input_method_including_mouse():
					UserInputManager.set_current_gui_context_to_void()
				else:
					UserInputManager.set_current_gui_context_to_grid()

func replace_tile() -> void:
	if not self._managerReferences["hexGridManager"].is_current_grid_index_out_of_bounds():
		var _floating_tile_status : Dictionary = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
		var _is_placeable : bool = false
		
		if _floating_tile_status.has("TILE_DEFINITION_UUID"): # required to prevent issues when no floating tile exists
			_is_placeable = not self._managerReferences["hexGridManager"].is_current_grid_element_placeholder() #(self._managerReferences["hexGridManager"].get_current_grid_element_information())["type"] != "placeholder"

		if _is_placeable:
			var _tmp_tduuid : String = _floating_tile_status["TILE_DEFINITION_UUID"]
			var _tmp_index : int = self._managerReferences["hexGridManager"].get_current_grid_index()
			self._managerReferences["cppBridge"].replace_tile_at_index_with(_tmp_index, _tmp_tduuid, _floating_tile_status["rotation"]) # DESCRIPTION: Pass change of tile definition to C++ Backend
			self._managerReferences["hexGridManager"].replace_tile()
			audioManager.play_sfx(["game", "tile", "success"])

			self._create_new_floating_tile()
			
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
			var _tmp_index : int = self._managerReferences["hexGridManager"].get_current_grid_index()
			self._managerReferences["cppBridge"].delete_tile_at_index(_tmp_index)
			self._managerReferences["hexGridManager"].delete_tile()
			audioManager.play_sfx(["game", "tile", "delete"])
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
	self._update_tile_definition_uuid(UserInputManager._curentTileDefinitionUUID)

