extends Node

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# The scene this script is attached to is autoloaded as "UserInputManager".    #
################################################################################

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal transmit_global_command(tce_signaling_uuid, value)

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
# TO-DO: should be moved into another autoload, so that other parts can access
# it in a more logical/orderly manner
const TCE_SIGNALING_UUID_SEPERATOR : String = "::" 

const INPUT_METHOD_MODES : Dictionary = {
	"MOUSE_ONLY": {
		"TEXT": "Mouse (only)",
		"TCE_INPUT_METHOD_UUID": "mouse" + TCE_SIGNALING_UUID_SEPERATOR + "only",
		"AVAILABLE": false
	},
	"MOUSE_KEYBOARD_MIXED": {
		"TEXT": "Mouse & Keyboard (mixed)",
		"TCE_INPUT_METHOD_UUID": "mouse" + TCE_SIGNALING_UUID_SEPERATOR + "keyboard" + TCE_SIGNALING_UUID_SEPERATOR + "mixed",
		"AVAILABLE": true
	},
	"KEYBOARD_ONLY": {
		"TEXT": "Keyboard (only)",
		"TCE_INPUT_METHOD_UUID": "keyboard" + TCE_SIGNALING_UUID_SEPERATOR + "only",
		"AVAILABLE": true
	},
	"CONTROLLER_ONLY": {
		"TEXT": "Controller (only)",
		"TCE_INPUT_METHOD_UUID": "controller" + TCE_SIGNALING_UUID_SEPERATOR + "only",
		"AVAILABLE": false
	},
	"TOUCH_ONLY": {
		"TEXT": "Touch (only)",
		"TCE_INPUT_METHOD_UUID": "touch" + TCE_SIGNALING_UUID_SEPERATOR + "only",
		"AVAILABLE": false
	}
}

const TCE_SIGNALING_UUID_INPUT_EVENTS_LUT : Dictionary = {
	"confirm": ["user", "interaction", "confirm"],
	"option": {
		"general": ["user", "interaction", "option", "general"],
		"1": ["user", "interaction", "option", "1"],
		"2": ["user", "interaction", "option", "2"],
		"3": ["user", "interaction", "option", "3"],
		"4": ["user", "interaction", "option", "4"],
		"5": ["user", "interaction", "option", "5"]
	},
	"increment" : ["user", "interaction", "increment"],
	"decrement": ["user", "interaction", "decrement"],
	"modifier": ["user", "interaction", "modifier"],
	"movement": {
		"channel1": ["user", "interaction", "movement", "channel1"],
		"channel2": ["user", "interaction", "movement", "channel2"],
		"channel3": ["user", "interaction", "movement", "channel3"]
	},
	"cancel": ["user", "interaction", "cancel"],
	"perform_tile_action" : ["user", "interaction", "perform", "tile", "action"],
	"rotate_tile_clockwise": ["user", "interaction", "rotate", "tile", "clockwise"],
	"next_option": ["user", "interaction", "option", "next"],
	"previous_option": ["user", "interaction", "option", "previous"]
}

const GODOT_MISC_INPUT_EVENT_LUT : Dictionary = {
	"mouse_click_left": {
		"PROCESS_MODE": ["just_pressed"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["confirm"]
	},
	"mouse_click_right":  {
		"PROCESS_MODE": ["just_pressed"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["option", "general"]
	},
	"mouse_wheel_up" : {
		"PROCESS_MODE": ["just_released"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["increment"]
	}, 
	"mouse_wheel_down": {
		"PROCESS_MODE": ["just_released"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["decrement"]
	}, 
	"keyboard_modifier": {
		"PROCESS_MODE": ["just_pressed", "just_released"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["modifier"]
	},
	"keyboard_cancel": {
		"PROCESS_MODE": ["just_released"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["cancel"]
	},
	"keyboard_confirm": {
		"PROCESS_MODE": ["just_released"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["confirm"]
	},
	"keyboard_option_general": {
		"PROCESS_MODE": ["just_released"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["option", "general"]
	},
	"keyboard_increment": {
		"PROCESS_MODE": ["just_pressed", "pressed", "just_released"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["increment"]
	},
	"keyboard_decrement": {
		"PROCESS_MODE": ["just_pressed", "pressed", "just_released"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["decrement"]
	},
	"controller_home": {
		"PROCESS_MODE": ["just_released"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["cancel"]
	},
	"controller_action_button_y": {
		"PROCESS_MODE": ["just_released"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["previous_option"]
	},
	"controller_action_button_a": {
		"PROCESS_MODE": ["just_released"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["next_option"]
	},
	"controller_L1": {
		"PROCESS_MODE": ["just_released"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["rotate_tile_clockwise"]
	},
	"controller_L2": {
		"PROCESS_MODE": ["just_released"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["perform_tile_action"]
	},
	"controller_R1": {
		"PROCESS_MODE": ["just_pressed", "pressed", "just_released"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["increment"]
	},
	"controller_R2": {
		"PROCESS_MODE": ["just_pressed", "pressed", "just_released"],
		"SIGNALING_UUID_LUT_KEYCHAIN": ["decrement"]
	}
}

################################################################################
#### PUBLIC MEMBER VARIABLES ###################################################
################################################################################
var context : String
var base : String
var variant : String

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _managerReferences : Dictionary = {}
var _guiLayerReferences : Dictionary = {}

var _currentGuiMouseContext : String 
var _currentInputMethod : String
var _miscInputEventsToProcess : Dictionary = {}

var _lastMovementRequest : Dictionary = {
	"channel1": Vector2(0,0),
	"channel2": Vector2(0,0),
	"channel3": Vector2(0,0)
}

var _curentTileDefinitionUUID : String = "" # REMARK: only temporary; has to be replaced with proper logic

var _logic : Object

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _create_string_with_tce_signaling_uuid_seperator(keyChain : Array) -> String:
	var _tmpString : String = ""
	var _keyChainLength : int = len(keyChain)

	for _i in range(_keyChainLength):
		_tmpString += keyChain[_i]
		if _i != _keyChainLength - 1:
			_tmpString +=  self.TCE_SIGNALING_UUID_SEPERATOR

	return _tmpString

func _create_dictionary_of_misc_current_input_events() -> void:
	var _db : Dictionary = self.GODOT_MISC_INPUT_EVENT_LUT
	var _events : Array = _db.keys()
	var _eventsSortedByType : Dictionary = {
		"just_pressed" : [],
		"just_released": [],
		"pressed": []
	}

	for _event in _events:
		var _event_split : PoolStringArray = _event.split("_")

		if self._currentInputMethod.match("*" + _event_split[0] + "*"):
			for _mode in _db[_event]["PROCESS_MODE"]:
				match _mode:
					"just_pressed":
						_eventsSortedByType["just_pressed"].append(_event)
					"just_released":
						_eventsSortedByType["just_released"].append(_event)
					"pressed":
						_eventsSortedByType["pressed"].append(_event)
		
	self._miscInputEventsToProcess = _eventsSortedByType

func _process_movement_request_on_device_channel(device : String, channelNo : int) -> void:
	# DESCRIPTION: Checking for movement request on movement channel 1
	var _movementRequest : Vector2 = Vector2(
		Input.get_action_strength(device + "_move_channel" + str(channelNo) + "_left") - Input.get_action_strength(device + "_move_channel" + str(channelNo) + "_right"),
			Input.get_action_strength(device + "_move_channel" + str(channelNo) + "_up") - Input.get_action_strength(device + "_move_channel" + str(channelNo) + "_down")
	)

	# DESCRIPTION: To reduce the amount of unnecessary function calls when no camera movement is requested, check whether
	# current request is identical to previous request
	# REMARK: Does not work in the case of keyboard/controller only input, as the tile can only be moved
	# one grid per key press. Keeping a key pressed does not allow for moving multiple grids at a time. The solution
	# was to add a timer based retrigger system to the receiving component
	if self._lastMovementRequest["channel" + str(channelNo)] != _movementRequest:
		var _tmp_signaling_keychain : Array = DictionaryParsing.get_dict_element_via_keychain(self.TCE_SIGNALING_UUID_INPUT_EVENTS_LUT, ["movement", "channel"+str(channelNo)])
		self.call_contextual_logic_with_signaling_keychain(_tmp_signaling_keychain, _movementRequest)
		self._lastMovementRequest["channel" + str(channelNo)] = _movementRequest

func _process_input_event_by_method_name(event : String, methodName : String) -> void:
	if Input.call("is_action_" + methodName,event):
		if self.GODOT_MISC_INPUT_EVENT_LUT.has(event):
			var _input_uuid_keychain : Array = self.GODOT_MISC_INPUT_EVENT_LUT[event]["SIGNALING_UUID_LUT_KEYCHAIN"]
			var _tmp_signaling_keychain : Array = DictionaryParsing.get_dict_element_via_keychain(self.TCE_SIGNALING_UUID_INPUT_EVENTS_LUT, _input_uuid_keychain)
			self.call_contextual_logic_with_signaling_keychain(_tmp_signaling_keychain, methodName)
		else:
			print("Error: Godot Input Event not found in LUT!")

func _process_input_events_by_method_name(events : Array, methodName : String) -> void:
	for _event in events:
		_process_input_event_by_method_name(_event, methodName)

func _process_misc_input_events() -> void:
	var _db : Dictionary = self._miscInputEventsToProcess
	var _keys : Array = _db.keys()

	for _key in _keys:
		if _db[_key] != []:
			var _events : Array = _db[_key]
			self._process_input_events_by_method_name(_events, _key)

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(_base_context : String, cim: String, clr : Object, mr : Dictionary, glr : Dictionary) -> void:
	self._managerReferences = mr
	self._guiLayerReferences = glr
	self.context = _base_context
	self._currentInputMethod = cim
	self._logic = clr.logic 

	var _base_context_list : Array = self.context.split(self.TCE_SIGNALING_UUID_SEPERATOR)
	self.base = _base_context_list[0]

	# DESCRIPTION: Select the misc input events to process according to current input method
	self._create_dictionary_of_misc_current_input_events()

	if self.base == "game":
		self.variant = _base_context_list[1]
		self._managerReferences["cameraManager"].enable_raycasting()
		self._currentGuiMouseContext = self.context + UserInputManager.TCE_SIGNALING_UUID_SEPERATOR
		
		if self._currentInputMethod.match("*mouse*"):
			self._currentGuiMouseContext += "void"
		else:
			self._currentGuiMouseContext += "grid"	

		# REMARK: Only temporary, until proper tile definition contextual logic is implemented
		# Could it cause the issue of overwriting other settings?
		var _tmp = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
		if _tmp.has("TILE_DEFINITION_UUID"):
			self._curentTileDefinitionUUID = _tmp["TILE_DEFINITION_UUID"]

func create_tce_signaling_uuid(ctxt : String, keyChain : Array) -> String:
	var _tmpString : String =  ctxt + self.TCE_SIGNALING_UUID_SEPERATOR
	_tmpString += self._create_string_with_tce_signaling_uuid_seperator(keyChain)

	return _tmpString

func match_tce_signaling_uuid(tce_signaling_uuid : String, keyChain : Array) -> bool:
	var _tmpString = self._create_string_with_tce_signaling_uuid_seperator(keyChain)
	return tce_signaling_uuid.match(_tmpString)

func send_public_command(tce_signaling_uuid : String, value) -> void:
	emit_signal("transmit_global_command", tce_signaling_uuid, value)

# REMARK: Removed typesafety for value to be more flexible and require less signals/parsing logic
func call_contextual_logic_with_signaling_keychain(keyChain : Array, value) -> void:
	var _tmp_signaling_uuid : String = self.create_tce_signaling_uuid(self.context, keyChain)
	self._logic.general_processing_pipeline(_tmp_signaling_uuid, value)

func get_current_gui_context() -> String:
	return self._currentGuiMouseContext

func set_current_input_method(method : String) -> void:
	self._currentInputMethod = method
	print("=> UserInputManager: Current Input Method changed to ", self._currentInputMethod)

	if self.context.match("game*"):
		if method == "keyboard::only":
			self._managerReferences["hexGridManager"].enable_floating_selector_movement_by_asmr()
			self._managerReferences["cameraManager"].disable_raycasting()
			
			# Debug Panel is possible. Might be only temporarily required.
			self._managerReferences["hexGridManager"].set_current_grid_index(self._managerReferences["hexGridManager"].get_last_index_within_grid_boundary())
			self._currentGuiMouseContext = self.context + self.TCE_SIGNALING_UUID_SEPERATOR + "game"	

		else:
			self._managerReferences["hexGridManager"].disable_floating_selector_movement_by_asmr()
			self._managerReferences["cameraManager"].enable_raycasting()
			self._currentGuiMouseContext = self.context + self.TCE_SIGNALING_UUID_SEPERATOR + "void"

	# DESCRIPTION: Update the misc input events to process according to current input method
	self._create_dictionary_of_misc_current_input_events()

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_gui_context_changed(tce_signaling_uuid : String, interaction : String) -> void:
	_logic.gui_context_management_pipeline(tce_signaling_uuid, interaction)

# REMARK: Removed typesafety for value to be more flexible and require less signals/parsing logic
func _on_special_user_input(tce_signaling_uuid : String, value) -> void:
	# print(tce_signaling_uuid) # REMARK: For debugging purposes only
	self._logic.general_processing_pipeline(tce_signaling_uuid, value)

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	print("\t-> Load UserInputManager...")

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _input(event : InputEvent) -> void:
	# REMARK: Temporary Limitation to "game" context required until Main Menu is updated!
	if self.base == "game": # temporary!

		# DESCRIPTION: Process mouse inputs only when mouse is selected as an input method
		if self._currentInputMethod.match("*mouse*"):
			# mouse position (floating (tile) position)
			if event is InputEventMouse:
				var _tmp_signaling_keychain : Array = ["user", "interaction", "mouse", "movement"]
				self.call_contextual_logic_with_signaling_keychain(_tmp_signaling_keychain, event.position)

func _process(_delta : float) -> void:
	# DESCRIPTION: General keyboard input handling
	# DESCRIPTION: Process keyboard inputs only when keyboard is selected as an input method
	if self._currentInputMethod.match("*keyboard*"):
		for _i in range(1,6):
			if Input.is_action_just_pressed("keyboard_option" + str(_i)):
				var _tmp_signaling_keychain : Array = self.TCE_SIGNALING_UUID_INPUT_EVENTS_LUT["option"][str(_i)]#["user", "interaction", "keyboard", "option"+str(_i)]
				self.call_contextual_logic_with_signaling_keychain(_tmp_signaling_keychain, "just_pressed")

		# REMARK: Cannot be outsourced into game logic, since _process not working in the classes
		if self.base == "game":
			# REMARK: Temporary restriction to "game" base necessary to avoid issues with the Main Menu. Can be chnaged
			# after Main Menu has been replaced

			# DESCRIPTION: Checking for movement requests on all channels
			for _channelNo in range(1,3): 
				self._process_movement_request_on_device_channel("keyboard", _channelNo)

	if self._currentInputMethod.match("*controller*"):
		if self.base == "game":
			# REMARK: Temporary restriction to "game" base necessary to avoid issues with the Main Menu. Can be chnaged
			# after Main Menu has been replaced
			for _channelNo in range(1,3): 
				self._process_movement_request_on_device_channel("controller", _channelNo)
	
	# REMARK: Cannot be outsourced into game logic, since _process not working in the classes
	if self.base == "game":
		# REMARK: Temporary restriction to "game" base necessary to avoid issues with the Main Menu. Can be chnaged
		# after Main Menu has been replaced

		self._process_misc_input_events()
	
