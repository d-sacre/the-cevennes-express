extends Node

class_name game_base

################################################################################
################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn
# "UiActionManager": res://managers/uiActionManager/uiActionManager.tscn
# "TransistionManager": res://managers/transitionManager/transitionManager.tscn
# "audioManager": res://managers/audioManager/audioManager.tscn
# Indirectly, it requires the following AutoLoads
# "sfxManager": res://managers/audioManager/sfx/sfxManager.tscn
# "musicManager": res://managers/audioManager/music/musicManager.tscn

################################################################################
################################################################################
#### IMPORTANT REMARKS #########################################################
################################################################################
################################################################################
# It is not possible to specify an override for the _process() function, as it 
# does not seem to be run, even after the class being properly initialized 

################################################################################
################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
################################################################################
var _managerReferences : Dictionary = {}
var _guiLayerReferences : Dictionary = {}
var _context : String

var _tileDefinitionUuid : String = "" # REMARK: Not a good solution; could crash the game if the function is not properly overwritten

const _separator : String = UserInputManager.TCE_EVENT_UUID_SEPERATOR

var _deInCrementStatus : String = "NONE"
var _is_gui_hidden : bool = false

################################################################################
################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
################################################################################
# REMARK: Private functions in the sense as they should neither be accessed nor
# changed outside of the parent class or inherited classes

################################################################################
#### PRIVATE MEMBER FUNCTIONS: SETTER AND GETTER ###############################
################################################################################
func _get_next_tile_definition_uuid() -> String:
	# REMARK: Not a good solution; could crash the game if the function is not properly overwritten
	return self._tileDefinitionUuid

func _get_floating_tile_status() -> Dictionary:
	var _dict : Dictionary = {}
	if not self._managerReferences["hexGridManager"].is_current_grid_index_out_of_bounds():
		 _dict = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()

	return _dict

################################################################################
#### PRIVATE MEMBER FUNCTIONS: BOOL EXPRESSIONS ################################
################################################################################
func _is_tile_placeable() -> bool:
	return false

func _is_tile_placeable_with_current_rotation() -> bool:
	return false

func _is_tce_signaling_uuid_matching(tce_event_uuid : String, keyChain : Array) -> bool:
	return UserInputManager.match_tce_event_uuid(tce_event_uuid, keyChain)

################################################################################
#### PRIVATE MEMBER FUNCTIONS: BOOL EVENTS #####################################
################################################################################
func _is_mouse_event(tce_event_uuid : String) -> bool: 
	if self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "user", "interaction", "*"]):
		if self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "mouse", "*"]):
			return true

	return false

func _is_input_event_confirm(tce_event_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_event_uuid,["*", "user", "interaction", "confirm"])

func _is_input_event_option_general(tce_event_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "user", "interaction", "option", "general"])

func _is_input_event_modifier(tce_event_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*","user", "interaction", "modifier"])

func _is_input_event_cancel(tce_event_uuid: String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "user", "interaction", "cancel"])

################################################################################
#### PRIVATE MEMBER FUNCTIONS: BOOL CONTEXT ####################################
################################################################################
func _is_correct_context_for_placing_tile(tce_event_uuid : String) -> bool:
	var _condition : bool = false
	if UserInputManager.is_current_input_method_including_mouse():
		_condition = self._is_input_event_confirm(tce_event_uuid) and UserInputManager.is_current_gui_context_grid()
	elif UserInputManager.is_current_input_method_keyboard_only(): 
		_condition = self._is_input_event_confirm(tce_event_uuid)
	elif UserInputManager.is_current_input_method_controller_only():
		_condition = self._is_tce_signaling_uuid_matching(tce_event_uuid,["*", "user", "interaction", "perform", "tile", "action"])

	return _condition

func _is_correct_context_for_rotating_tile_clockwise(tce_event_uuid : String) -> bool:
	var _condition : bool = false

	if UserInputManager.is_current_input_method_including_mouse():
		_condition =  self._is_input_event_option_general(tce_event_uuid) and UserInputManager.is_current_gui_context_grid()
	elif UserInputManager.is_current_input_method_keyboard_only():
		_condition = self._is_input_event_option_general(tce_event_uuid)
	elif UserInputManager.is_current_input_method_controller_only():
		_condition = self._is_tce_signaling_uuid_matching(tce_event_uuid,["*", "user", "interaction", "rotate", "tile", "clockwise"])

	return _condition

func _is_correct_context_for_zooming(tce_event_uuid : String) -> bool:
	if (UserInputManager.is_current_gui_context_grid()) or (UserInputManager.is_current_gui_context_void()):
		var _cond_zoom_out : bool = self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "user", "interaction", "decrement"])
		var _cond_zoom_in : bool = self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "user", "interaction", "increment"])
	
		if _cond_zoom_out or _cond_zoom_in:
			return true

	return false

func _is_correct_context_for_movement_channelNumber(tce_event_uuid : String, channelNo : int) -> bool:
	if not UserInputManager.is_current_gui_context_menu():
		return self._is_tce_signaling_uuid_matching(tce_event_uuid,["*", "user", "interaction", "movement", "channel"+str(channelNo)])
	
	return false

################################################################################
#### PRIVATE MEMBER FUNCTIONS: TILE MANIPULATION ###############################
################################################################################
func change_floating_tile_type() -> void:
	var tile_definition_uuid = self._get_next_tile_definition_uuid()
	if tile_definition_uuid != "": 
		var tile_definition = self._managerReferences["tileDefinitionManager"].get_tile_definition_database_entry(tile_definition_uuid) 
		self._managerReferences["hexGridManager"].change_floating_tile_type(tile_definition)

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

func place_tile() -> void:
	if not self._managerReferences["hexGridManager"].is_current_grid_index_out_of_bounds():
		var _floating_tile_status : Dictionary = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
		var _is_placeable : bool = false
		
		if _floating_tile_status.has("TILE_DEFINITION_UUID"): # required to prevent issues when no floating tile exists
			_is_placeable = self._is_tile_placeable()

		if _is_placeable:
			self._managerReferences["hexGridManager"].set_status_placeholder(true, false)
			self._managerReferences["hexGridManager"].place_floating_tile()
			audioManager.play_sfx(["game", "tile", "success"])
			
			self._create_new_floating_tile()
			
		else:
			self._managerReferences["hexGridManager"].set_status_placeholder(false, true)
			audioManager.play_sfx(["game", "tile", "fail"])

################################################################################
#### PRIVATE MEMBER FUNCTIONS: TOOLS ###########################################
################################################################################
func _toggle_gui_visibility() -> void:
	self._is_gui_hidden = !self._is_gui_hidden

func _hide_gui(_status : bool) -> void:
	pass

func _create_new_floating_tile() -> void:
	var _tile_definition_uuid : String = self._get_next_tile_definition_uuid()

	if _tile_definition_uuid != "": 
		var _tile_definition = self._managerReferences["tileDefinitionManager"].get_tile_definition_database_entry(_tile_definition_uuid) 
		self._managerReferences["hexGridManager"].create_floating_tile(_tile_definition)

func _camera_zooming_handler(operation: String, signalStatus : String) -> void:
	var _tmp_function_name : String = ""

	# DESCRIPTION: Determine by the operation name which cameraManager function name
	# has to be called
	if operation == "decrement":
		_tmp_function_name = "request_zoom_out"
	elif operation == "increment":
		_tmp_function_name = "request_zoom_in"

	if signalStatus is String:
		if _tmp_function_name != "": # DESCRIPTION: Safety to ensure that the logic continues only when valid function name is given
			# DESCRIPTION: If the previous Input Status is not undefined 
			if self._deInCrementStatus != "NONE":
				# DESCRIPTION: If the Input had been previously in the "pressed" state and is
				# now "just_released" -> remove "pressed" status and disable asr zooming
				if self._deInCrementStatus == "pressed" and signalStatus == "just_released":
					self._deInCrementStatus = "NONE"
					self._managerReferences["cameraManager"].disable_asr_zooming()

				# DESCRIPTION: If the Input is now in the "pressed" state and before was not
				# -> set status to "pressed" and enable asr zooming with the correct operation
				elif signalStatus == "pressed" and self._deInCrementStatus != "pressed":
					self._deInCrementStatus = "pressed"
					self._managerReferences["cameraManager"].enable_asr_zooming(operation)

				# DESCRIPTION: If the Input has been "just_released" and previously was not "pressed"
				# -> Trigger one increment of zooming 
				# REMARK: This case should in theory only occur when the Mouse Wheel is used for zooming,
				# since it only provides the "just_released" method and no others.
				elif signalStatus == "just_released" and self._deInCrementStatus != "pressed":
					self._managerReferences["cameraManager"].call(_tmp_function_name)

			# DESCRIPTION: If the previous Input Status is undefined, set the status and trigger
			# one zooming increment
			else:  
				self._deInCrementStatus = signalStatus
				self._managerReferences["cameraManager"].call(_tmp_function_name)

func _movement_channel2(_asmr : Vector2) -> void:
	pass

################################################################################
################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
################################################################################
func initialize_floating_tile() -> void:
	var tile_definition_uuid = self._get_next_tile_definition_uuid()
	if tile_definition_uuid != "": 
		var tile_definition = self._managerReferences["tileDefinitionManager"].get_tile_definition_database_entry(tile_definition_uuid) 
		self._managerReferences["hexGridManager"].create_floating_tile(tile_definition)

func _update_tile_definition_uuid(uuid : String) -> void:
	self._tileDefinitionUuid = uuid

################################################################################
#### PUBLIC MEMBER FUNCTIONS: USER INPUT PIPELINE ##############################
################################################################################
# REMARK: Removed typesafety for value to be more flexible and require less signals/parsing logic
func general_processing_pipeline(tce_event_uuid : String, value) -> void: 
	if self._is_tce_signaling_uuid_matching(tce_event_uuid, ["game", "*"]): # Safety to ensure that only valid requests are processed
		if self._is_correct_context_for_placing_tile(tce_event_uuid):
			self.place_tile()

		if self._is_correct_context_for_rotating_tile_clockwise(tce_event_uuid):
			self.rotate_tile_clockwise()

		if self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "user", "selected", "gui", "show"]):
			print_debug("Show Gui")
			# self._toggle_gui_visibility()
			self._hide_gui(false)
		
		if self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "user", "selected", "gui", "hide"]):
			self._toggle_gui_visibility()
			# self._hide_gui(true)

		if self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "button", "resume", "pressed"]):
			var _tmp_eventKeychain : Array = ["UserInputManager", "requesting", "global", "execution", "toggle", "game", "menu", "main", "context"]
			var _tmp_eventString : String = UserInputManager.create_tce_event_uuid(self._context, _tmp_eventKeychain)
			UserInputManager.transmit_global_event(_tmp_eventString, self._tileDefinitionUuid)

		if self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "button", "settings", "pressed"]):
			var _tmp_eventKeychain : Array = ["UserInputManager", "requesting", "global", "execution", "toggle", "game", "menu", "settings", "context"]
			var _tmp_eventString : String = UserInputManager.create_tce_event_uuid(self._context, _tmp_eventKeychain)
			UserInputManager.transmit_global_event(_tmp_eventString, self._tileDefinitionUuid)

		if self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "button", "menu", "main", "pressed"]):
			TransitionManager.transition_to_main_menu()

		if self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "button", "exit", "pressed"]):
			TransitionManager.exit_to_system()

		if self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "user", "interaction", "mouse", "movement"]):
			if value is Vector2:
				# DESCRIPTION: Only initiate raycast from camera when Input Mode uses mouse information
				if UserInputManager.is_current_input_method_including_mouse():
					self._managerReferences["cameraManager"].initiate_raycast_from_position(value)
			else:
				print("Error: Variable type does not match")

		if self._is_correct_context_for_movement_channelNumber(tce_event_uuid, 1):
			if value is Vector2:
				# DESCRIPTION: Request camera movement only in Input Mode which uses mouse information
				# In all other cases: Manipulate the position of the floating tile
				if UserInputManager.is_current_input_method_including_mouse():
					self._managerReferences["cameraManager"].request_movement(value)
				else: # REMARK: Temporary solution; it would be better to outsource floating tile into own dedicated scene
					self._managerReferences["hexGridManager"].request_floating_selector_movement(value)

		if self._is_correct_context_for_movement_channelNumber(tce_event_uuid, 2):
			if value is Vector2:
				self._movement_channel2(value)

		if self._is_input_event_modifier(tce_event_uuid):
			if value is String:
				if value == "just_pressed":
					self._managerReferences["cameraManager"].set_movement_speed_mode("fast")
				else:
					self._managerReferences["cameraManager"].set_movement_speed_mode("slow")

		if self._is_correct_context_for_zooming(tce_event_uuid):
			if self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "decrement"]):
				self._camera_zooming_handler("decrement", value)
				
			elif self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "increment"]):
				self._camera_zooming_handler("increment", value)

		if self._is_input_event_cancel(tce_event_uuid):
			var _tmp_eventKeychain : Array = ["UserInputManager", "requesting", "global", "execution", "toggle", "game", "menu", "main", "context"]
			var _tmp_eventString : String = UserInputManager.create_tce_event_uuid(self._context, _tmp_eventKeychain)
			UserInputManager.transmit_global_event(_tmp_eventString, self._tileDefinitionUuid)

		if self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*","internal", "collision", "detected"]):
			if UserInputManager.is_current_input_method_including_mouse(): # REMARK: Without if, culprit for movement issues in keyboard::only mode?
				if value is Dictionary:
					if value.has("colliding"):
						var _tmp_collision_status = value["colliding"]["status"]

						# REMARK: Required to set highlighting correctly. But might this be the culprit 
						# for the "placement and removal of floating tile at index 0 when new tile definition is selected" bug?
						self._managerReferences["hexGridManager"].set_last_grid_index_to_current()

						# REMARK: Hardcoded for the case of only hitting a hex tile. 
						# Other collisions like with trains have to be implemented differently!
						if _tmp_collision_status:
							self._managerReferences["hexGridManager"].set_current_grid_index(value["grid_index"])
							self._managerReferences["hexGridManager"].set_last_index_within_grid_boundary_to_current()
							UserInputManager.set_current_gui_context_to_grid()
						else:
							self._managerReferences["hexGridManager"].set_current_grid_index_out_of_bounds()
							UserInputManager.set_current_gui_context_to_void()

						if not self._managerReferences["hexGridManager"].is_last_grid_index_equal_current():
							audioManager.play_sfx(["game", "tile", "move"])
							self._managerReferences["hexGridManager"].move_floating_selector_and_highlight() 
		
		if self._is_tce_signaling_uuid_matching(tce_event_uuid, ["*", "internal", "cursor", "floating", "position", "update"]):
			if value is Vector3:
				var _tmp_eventKeychain : Array = ["UserInputManager", "requesting", "global", "execution", "cursor", "floating", "position", "update"]
				var _tmp_eventString : String = UserInputManager.create_tce_event_uuid(self._context, _tmp_eventKeychain)
				UserInputManager.transmit_global_event(_tmp_eventString, value)

		if UserInputManager.is_current_gui_context_menu():
			UiActionManager.manage_ui_action_mapping(tce_event_uuid, value)

	else:
		pass
		# REMARK: Disabled for the time being until Main Menu is updated to prevent enormous amount of printing
		# print("Error: <TCE_SIGNALING_UUID|",tce_event_uuid, "> could not be processed!")

################################################################################
#### PUBLIC MEMBER FUNCTIONS: GUI MANAGEMENT PIPELINE ##########################
################################################################################
func gui_context_management_pipeline(tce_event_uuid : String, _value : String) -> void:
	pass

################################################################################
################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
################################################################################
func _init(ctxt : String, mr : Dictionary, glr : Dictionary) -> void:
	self._context = ctxt
	self._managerReferences = mr
	self._guiLayerReferences = glr

