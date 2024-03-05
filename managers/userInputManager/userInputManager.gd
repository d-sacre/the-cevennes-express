extends Node

################################################################################
################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
################################################################################
# The scene this script is attached to is autoloaded as "UserInputManager".    #
################################################################################

################################################################################
################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
################################################################################
signal transmit_global_event(tce_event_uuid, value)

################################################################################
################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
################################################################################
# TO-DO: should be moved into another autoload, so that other parts can access
# it in a more logical/orderly manner
const TCE_EVENT_UUID_SEPERATOR : String = "::" 

const INPUT_METHOD_MODES : Dictionary = {
	"MOUSE_ONLY": {
		"TEXT": "Mouse (only)",
		"TCE_INPUT_METHOD_UUID": "mouse" + TCE_EVENT_UUID_SEPERATOR + "only",
		"AVAILABLE": false
	},
	"MOUSE_KEYBOARD_MIXED": {
		"TEXT": "Mouse & Keyboard (mixed)",
		"TCE_INPUT_METHOD_UUID": "mouse" + TCE_EVENT_UUID_SEPERATOR + "keyboard" + TCE_EVENT_UUID_SEPERATOR + "mixed",
		"AVAILABLE": true
	},
	"KEYBOARD_ONLY": {
		"TEXT": "Keyboard (only)",
		"TCE_INPUT_METHOD_UUID": "keyboard" + TCE_EVENT_UUID_SEPERATOR + "only",
		"AVAILABLE": true
	},
	"CONTROLLER_ONLY": {
		"TEXT": "Controller (only)",
		"TCE_INPUT_METHOD_UUID": "controller" + TCE_EVENT_UUID_SEPERATOR + "only",
		"AVAILABLE": false
	},
	"TOUCH_ONLY": {
		"TEXT": "Touch (only)",
		"TCE_INPUT_METHOD_UUID": "touch" + TCE_EVENT_UUID_SEPERATOR + "only",
		"AVAILABLE": false
	}
}

const TCE_INPUT_EVENTS_TO_TCE_EVENT_UUID_LUT : Dictionary = {
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

const GODOT_MISC_INPUT_EVENTS_TO_TCE_INPUT_EVENTS_LUT : Dictionary = {
	"mouse_click_left": {
		"PROCESS_MODE": ["just_pressed"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["confirm"]
	},
	"mouse_click_right":  {
		"PROCESS_MODE": ["just_pressed"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["option", "general"]
	},
	"mouse_wheel_up" : {
		"PROCESS_MODE": ["just_released"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["increment"]
	}, 
	"mouse_wheel_down": {
		"PROCESS_MODE": ["just_released"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["decrement"]
	}, 
	"keyboard_modifier": {
		"PROCESS_MODE": ["just_pressed", "just_released"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["modifier"]
	},
	"keyboard_cancel": {
		"PROCESS_MODE": ["just_released"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["cancel"]
	},
	"keyboard_confirm": {
		"PROCESS_MODE": ["just_released"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["confirm"]
	},
	"keyboard_option_general": {
		"PROCESS_MODE": ["just_released"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["option", "general"]
	},
	"keyboard_increment": {
		"PROCESS_MODE": ["just_pressed", "pressed", "just_released"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["increment"]
	},
	"keyboard_decrement": {
		"PROCESS_MODE": ["just_pressed", "pressed", "just_released"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["decrement"]
	},
	"controller_home": {
		"PROCESS_MODE": ["just_released"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["cancel"]
	},
	"controller_action_button_y": {
		"PROCESS_MODE": ["just_released"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["previous_option"]
	},
	"controller_action_button_a": {
		"PROCESS_MODE": ["just_released"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["next_option"]
	},
	"controller_L1": {
		"PROCESS_MODE": ["just_released"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["rotate_tile_clockwise"]
	},
	"controller_L2": {
		"PROCESS_MODE": ["just_released"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["perform_tile_action"]
	},
	"controller_R1": {
		"PROCESS_MODE": ["just_pressed", "pressed", "just_released"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["increment"]
	},
	"controller_R2": {
		"PROCESS_MODE": ["just_pressed", "pressed", "just_released"],
		"TCE_EVENT_UUID_LUT_KEYCHAIN": ["decrement"]
	}
}

################################################################################
################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
################################################################################
var _context : String
var _base : String
var _variant : String

var _managerReferences : Dictionary = {}
var _guiLayerReferences : Dictionary = {}

var _currentGuiContext : String 
var _currentGuiFocus : Object
var _currentInputMethod : String
var _deviceResponsibleForCurrentInput : String
var _miscInputEventsToProcess : Dictionary = {}

var _lastMovementRequest : Dictionary = {
	"channel1": Vector2(0,0),
	"channel2": Vector2(0,0),
	"channel3": Vector2(0,0)
}

var _curentTileDefinitionUUID : String = "" # REMARK: only temporary; has to be replaced with proper logic

var _logic : Object

var _error : int

################################################################################
################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
################################################################################
func _create_string_with_tce_event_uuid_seperator(keyChain : Array) -> String:
	var _tmpString : String = ""
	var _keyChainLength : int = len(keyChain)

	for _i in range(_keyChainLength):
		_tmpString += keyChain[_i]
		if _i != _keyChainLength - 1:
			_tmpString +=  self.TCE_EVENT_UUID_SEPERATOR

	return _tmpString

func _set_device_responsible_for_current_input(device : String) -> void:
	self._deviceResponsibleForCurrentInput = device

func _create_dictionary_of_misc_current_input_events() -> void:
	var _db : Dictionary = self.GODOT_MISC_INPUT_EVENTS_TO_TCE_INPUT_EVENTS_LUT
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
		var _tmp_eventKeychain : Array = DictionaryParsing.get_dict_element_via_keychain(self.TCE_INPUT_EVENTS_TO_TCE_EVENT_UUID_LUT, ["movement", "channel"+str(channelNo)])
		self.call_contextual_logic_with_tce_event_keychain(_tmp_eventKeychain, _movementRequest)
		self._lastMovementRequest["channel" + str(channelNo)] = _movementRequest

func _process_input_event_by_method_name(event : String, methodName : String) -> void:
	if Input.call("is_action_" + methodName,event):
		if self.GODOT_MISC_INPUT_EVENTS_TO_TCE_INPUT_EVENTS_LUT.has(event):
			self._set_device_responsible_for_current_input(event.split("_")[0])
			var _input_uuid_keychain : Array = self.GODOT_MISC_INPUT_EVENTS_TO_TCE_INPUT_EVENTS_LUT[event]["TCE_EVENT_UUID_LUT_KEYCHAIN"]
			var _tmp_eventKeychain : Array = DictionaryParsing.get_dict_element_via_keychain(self.TCE_INPUT_EVENTS_TO_TCE_EVENT_UUID_LUT, _input_uuid_keychain)
			self.call_contextual_logic_with_tce_event_keychain(_tmp_eventKeychain, methodName)
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
################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
################################################################################

################################################################################
#### PUBLIC MEMBER FUNCTIONS: CONTEXT SETTER/GETTER ############################
################################################################################
func set_context(tce_context_uuid : String) -> void:
	self._context = tce_context_uuid

func get_context() -> String:
	return self._context

################################################################################
#### PUBLIC MEMBER FUNCTIONS: CURRENT GUI FOCUS SETTER/GETTER ##################
################################################################################
func get_control_currently_in_focus() -> Object:
	return self._currentGuiFocus

################################################################################
#### PUBLIC MEMBER FUNCTIONS: CURRENT INPUT METHOD SETTER/GETTER ###############
################################################################################
func set_current_input_method(method : String) -> void:
	self._currentInputMethod = method
	print("=> UserInputManager: Current Input Method changed to ", self._currentInputMethod)

	if self.get_context().match("game*"):
		if method == "keyboard::only":
			self._managerReferences["hexGridManager"].enable_floating_selector_movement_by_asmr()
			self._managerReferences["cameraManager"].disable_raycasting()
			
			# Debug Panel is possible. Might be only temporarily required.
			self._managerReferences["hexGridManager"].set_current_grid_index(self._managerReferences["hexGridManager"].get_last_index_within_grid_boundary())
			# self._currentGuiContext = self._context + self.TCE_EVENT_UUID_SEPERATOR + "game"	# REMARK: Needs to be verified if important!
			self.set_current_gui_context_to_grid()

		else:
			self._managerReferences["hexGridManager"].disable_floating_selector_movement_by_asmr()
			self._managerReferences["cameraManager"].enable_raycasting()
			self.set_current_gui_context_to_void()

	# DESCRIPTION: Update the misc input events to process according to current input method
	self._create_dictionary_of_misc_current_input_events()

func get_current_input_method() -> String:
	return self._currentInputMethod

func get_device_responsible_for_current_input() -> String:
	return self._deviceResponsibleForCurrentInput

################################################################################
#### PUBLIC MEMBER FUNCTIONS: CURRENT GUI CONTEXT SETTER/GETTER ################
################################################################################
func set_current_gui_context(tce_event_uuid : String, interaction : String) -> void:
	self._currentGuiContext = tce_event_uuid
	self._logic.gui_context_management_pipeline(tce_event_uuid, interaction)
	# print(self._currentGuiContext) # REMARK: Only for debugging purposes

func set_current_gui_context_to_grid() -> void:
	var _tmp_gui_context_uuid : String = self.create_tce_event_uuid(self.get_context(), ["gui", "grid"])
	self.set_current_gui_context(_tmp_gui_context_uuid, "entered")

func set_current_gui_context_to_void() -> void:
	var _tmp_gui_context_uuid : String = self.create_tce_event_uuid(self.get_context(), ["gui", "void"])
	self.set_current_gui_context(_tmp_gui_context_uuid, "entered")

func get_current_gui_context() -> String:
	return self._currentGuiContext

################################################################################
#### PUBLIC MEMBER FUNCTIONS: BOOL INPUT METHODS ###############################
################################################################################
func is_current_input_method_matching(regex : String) -> bool:
	return self.get_current_input_method().match(regex)

func is_current_input_method_keyboard_only() -> bool:
	return self.is_current_input_method_matching("keyboard::only")

func is_current_input_method_controller_only() -> bool:
	return self.is_current_input_method_matching("controller::only")

func is_current_input_method_including_mouse() -> bool:
	return self.is_current_input_method_matching("*mouse*")

func is_current_input_method_including_keyboard() -> bool:
	return self.is_current_input_method_matching("*keyboard*")

func is_current_input_method_including_controller() -> bool:
	return self.is_current_input_method_matching("*controller*")

func is_device_responsible_for_current_input_mouse() -> bool:
	return self.get_device_responsible_for_current_input().match("*mouse*")

################################################################################
#### PUBLIC MEMBER FUNCTIONS: BOOL CURRENT GUI CONTEXT #########################
################################################################################
func is_current_gui_context_grid() -> bool:
	return self.get_current_gui_context().match("*" + TCE_EVENT_UUID_SEPERATOR + "grid")

func is_current_gui_context_void() -> bool:
	return self.get_current_gui_context().match("*" + TCE_EVENT_UUID_SEPERATOR + "void")

func is_current_gui_context_menu() -> bool: 
	return self.get_current_gui_context().match("*menu*")

################################################################################
#### PUBLIC MEMBER FUNCTIONS: INITIALIZATION ###################################
################################################################################
func initialize(_base_context : String, cim: String, clr : Object, mr : Dictionary, glr : Dictionary) -> void:
	self._managerReferences = mr
	self._guiLayerReferences = glr
	self.set_context(_base_context)
	self._currentInputMethod = cim
	self._logic = clr.logic 

	var _base_context_list : Array = self.get_context().split(self.TCE_EVENT_UUID_SEPERATOR)
	self._base = _base_context_list[0]

	# DESCRIPTION: Select the misc input events to process according to current input method
	self._create_dictionary_of_misc_current_input_events()

	if self._base == "game":
		self._variant = _base_context_list[1]
		self._managerReferences["cameraManager"].enable_raycasting()
		
		if self.is_current_input_method_including_mouse():
			self.set_current_gui_context_to_void()
		else:
			self.set_current_gui_context_to_grid()	

		# REMARK: Only temporary, until proper tile definition contextual logic is implemented
		# Could it cause the issue of overwriting other settings?
		var _tmp = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
		if _tmp.has("TILE_DEFINITION_UUID"):
			self._curentTileDefinitionUUID = _tmp["TILE_DEFINITION_UUID"]

################################################################################
#### PUBLIC MEMBER FUNCTIONS: EVENT TOOLS AND MANAGEMENT #######################
################################################################################
func create_tce_event_uuid(ctxt : String, keyChain : Array) -> String:
	var _tmpString : String =  ctxt + self.TCE_EVENT_UUID_SEPERATOR
	_tmpString += self._create_string_with_tce_event_uuid_seperator(keyChain)

	return _tmpString

func match_tce_event_uuid(tce_event_uuid : String, keyChain : Array) -> bool:
	var _tmpString = self._create_string_with_tce_event_uuid_seperator(keyChain)
	return tce_event_uuid.match(_tmpString)

func transmit_global_event(tce_event_uuid : String, value) -> void:
	emit_signal("transmit_global_event", tce_event_uuid, value)

func transmit_global_event_from_keychain(keyChain : Array, value) -> void:
	var _tmp_event_uuid : String = self.create_tce_event_uuid(self.get_context(), keyChain)
	self.transmit_global_event(_tmp_event_uuid, value)

# REMARK: Removed typesafety for value to be more flexible and require less signals/parsing logic
func call_contextual_logic_with_tce_event_keychain(keyChain : Array, value) -> void:
	var _tmp_tce_event_uuid : String = self.create_tce_event_uuid(self.get_context(), keyChain)
	self._logic.general_processing_pipeline(_tmp_tce_event_uuid, value)

################################################################################
#### PUBLIC MEMBER FUNCTIONS: TOOLS ############################################
################################################################################

# source: https://docs.godotengine.org/en/3.5/classes/class_input.html#class-input-method-parse-input-event
func trigger_fake_input_event(event : String, pressed : bool) -> void:
	var _fakeInputEvent = InputEventAction.new()
	_fakeInputEvent.action = event
	_fakeInputEvent.pressed = pressed
	Input.parse_input_event(_fakeInputEvent)

################################################################################
################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
################################################################################
func _on_gui_context_changed(tce_event_uuid : String, interaction : String) -> void:
	self.set_current_gui_context(tce_event_uuid, interaction)

# REMARK: Removed typesafety for value to be more flexible and require less signals/parsing logic
func _on_special_user_input(tce_event_uuid : String, value) -> void:
	# print(tce_event_uuid) # REMARK: For debugging purposes only
	self._logic.general_processing_pipeline(tce_event_uuid, value)

func _on_gui_focus_changed(control : Control) -> void:
	self._currentGuiFocus = control

################################################################################
################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
################################################################################
func _ready() -> void:
	print("\t-> Load UserInputManager...")
	self._error = get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")

################################################################################
################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
################################################################################
func _input(event : InputEvent) -> void:
	# REMARK: Temporary Limitation to "game" context required until Main Menu is updated!
	if self._base == "game": # temporary!

		# DESCRIPTION: Process mouse inputs only when mouse is selected as an input method
		if self.is_current_input_method_including_mouse():
			# mouse position (floating (tile) position)
			if event is InputEventMouse:
				var _tmp_eventKeychain : Array = ["user", "interaction", "mouse", "movement"]
				self.call_contextual_logic_with_tce_event_keychain(_tmp_eventKeychain, event.position)

func _process(_delta : float) -> void:
	# DESCRIPTION: General keyboard input handling
	# DESCRIPTION: Process keyboard inputs only when keyboard is selected as an input method
	if self.is_current_input_method_including_keyboard():
		for _i in range(1,6):
			if Input.is_action_just_pressed("keyboard_option" + str(_i)):
				var _tmp_eventKeychain : Array = self.TCE_INPUT_EVENTS_TO_TCE_EVENT_UUID_LUT["option"][str(_i)]#["user", "interaction", "keyboard", "option"+str(_i)]
				self.call_contextual_logic_with_tce_event_keychain(_tmp_eventKeychain, "just_pressed")

		# REMARK: Cannot be outsourced into game logic, since _process not working in the classes
		if self._base == "game":
			# REMARK: Temporary restriction to "game" base necessary to avoid issues with the Main Menu. Can be chnaged
			# after Main Menu has been replaced

			# DESCRIPTION: Checking for movement requests on all channels
			for _channelNo in range(1,3): 
				self._process_movement_request_on_device_channel("keyboard", _channelNo)

	if self.is_current_input_method_including_controller():
		if self._base == "game":
			# REMARK: Temporary restriction to "game" base necessary to avoid issues with the Main Menu. Can be chnaged
			# after Main Menu has been replaced
			for _channelNo in range(1,3): 
				self._process_movement_request_on_device_channel("controller", _channelNo)
	
	# REMARK: Cannot be outsourced into game logic, since _process not working in the classes
	if self._base == "game":
		# REMARK: Temporary restriction to "game" base necessary to avoid issues with the Main Menu. Can be chnaged
		# after Main Menu has been replaced

		self._process_misc_input_events()
	
