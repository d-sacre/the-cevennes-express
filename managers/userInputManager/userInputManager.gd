extends Node

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# The scene this script is attached to is autoloaded as "UserInputManager".    #
################################################################################

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal user_input_manager_send_public_command(tce_signaling_uuid, value)

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

const TCE_SIGNALING_UUID_INPUT_EVENTS : Dictionary = {
	"confirm": ["user", "interaction", "confirm"],
	"option": {
		"general": ["user", "interaction", "option", "general"],
		"1": ["user", "interaction", "option", "1"],
		"2": ["user", "interaction", "option", "2"],
		"3": ["user", "interaction", "option", "3"],
		"4": ["user", "interaction", "option", "4"],
		"5": ["user", "interaction", "option", "5"]
	},
	"scroll": {
		"up": ["user", "interaction", "scroll", "up"],
		"down": ["user", "interaction", "scroll", "down"]
	},
	"modifier": ["user", "interaction", "modifier"],
	"movement": {
		"channel1": ["user", "interaction", "movement", "channel1"],
		"channel2": ["user", "interaction", "movement", "channel2"],
		"channel3": ["user", "interaction", "movement", "channel3"]
	},
	"cancel": ["user", "interaction", "cancel"]
}

const GODOT_INPUT_EVENT_TO_TCE_SIGNALING_UUID_LUT : Dictionary = {
	"mouse_click_left": ["confirm"],
	"mouse_click_right":  ["option", "general"],
	"mouse_wheel_up" : ["scroll", "up"],
	"mouse_wheel_down": ["scroll", "down"],
	"keyboard_modifier": ["modifier"],
	"keyboard_cancel": ["cancel"]
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
var _lastMovementRequestChannel1 : Vector2 = Vector2(0,0) # REMARK: only temporary; has to be replaced with proper logic

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

	if self.base == "game":
		self.variant = _base_context_list[1]
		self._managerReferences["cameraManager"].enable_raycasting()
		self._currentGuiMouseContext = self.context + UserInputManager.TCE_SIGNALING_UUID_SEPERATOR+ "grid"	

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
	emit_signal("user_input_manager_send_public_command", tce_signaling_uuid, value)

# REMARK: Removed typesafety for value to be more flexible and require less signals/parsing logic
func call_contextual_logic_with_signaling_keychain(keyChain : Array, value) -> void:
	var _tmp_signaling_uuid : String = self.create_tce_signaling_uuid(self.context, keyChain)
	self._logic.user_input_pipeline(_tmp_signaling_uuid, value)

func get_current_gui_context() -> String:
	return self._currentGuiMouseContext

func set_current_input_method(method : String) -> void:
	self._currentInputMethod = method
	print("Current Input Method changed to ", self._currentInputMethod)

	if method == "keyboard::only":
		self._managerReferences["hexGridManager"].enable_floating_selector_movement_by_asmr()
	else:
		self._managerReferences["hexGridManager"].disable_floating_selector_movement_by_asmr()

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_gui_selector_context_changed(tce_signaling_uuid : String, interaction : String) -> void:
	_logic.gui_management_pipeline(tce_signaling_uuid, interaction)

# REMARK: Removed typesafety for value to be more flexible and require less signals/parsing logic
func _on_user_selected(tce_signaling_uuid : String, value) -> void:
	_logic.user_input_pipeline(tce_signaling_uuid, value)

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
				var _tmp_signaling_keychain : Array = self.TCE_SIGNALING_UUID_INPUT_EVENTS["option"][str(_i)]#["user", "interaction", "keyboard", "option"+str(_i)]
				self.call_contextual_logic_with_signaling_keychain(_tmp_signaling_keychain, "just_pressed")

		# REMARK: Cannot be outsourced into game logic, since _process not working in the classes
		if self.base == "game":
			# REMARK: Temporary restriction to "game" base necessary to avoid issues with the Main Menu. Can be chnaged
			# after Main Menu has been replaced
			# DESCRIPTION: Checking for movement request on movement channel 1
			var _movementRequestChannel1 : Vector2 = Vector2(
				Input.get_action_strength("keyboard_move_channel1_left") - Input.get_action_strength("keyboard_move_channel1_right"),
					Input.get_action_strength("keyboard_move_channel1_up") - Input.get_action_strength("keyboard_move_channel1_down")
			)

			# DESCRIPTION: To reduce the amount of unnecessary function calls when no camera movement is requested, check whether
			# current request is identical to previous request
			# REMARK: Does not work in the case of keyboard/controller only input, as the tile can only be moved
			# one grid per key press. Keeping a key pressed does not allow for moving multiple grids at a time
			if self._lastMovementRequestChannel1 != _movementRequestChannel1:
				var _tmp_signaling_keychain : Array = DictionaryParsing.get_dict_element_via_keychain(self.TCE_SIGNALING_UUID_INPUT_EVENTS, ["movement", "channel1"])
				self.call_contextual_logic_with_signaling_keychain(_tmp_signaling_keychain, _movementRequestChannel1)
				self._lastMovementRequestChannel1 = _movementRequestChannel1
	
	# REMARK: Cannot be outsourced into game logic, since _process not working in the classes
	if self.base == "game":
		# REMARK: Temporary restriction to "game" base necessary to avoid issues with the Main Menu. Can be chnaged
		# after Main Menu has been replaced
		
		# REMARK: Should be outsourced into function!
		# REMARK: Mouse Wheel does only have the "just released" function
		# source: https://forum.godotengine.org/t/how-do-i-get-input-from-the-mouse-wheel/27979/3
		var _events : Array = ["mouse_wheel_up", "mouse_wheel_down", "keyboard_modifier"]
		for _event in _events:
			var _event_split : PoolStringArray = _event.split("_")

			if self._currentInputMethod.match("*" + _event_split[0] + "*"):
				if Input.is_action_just_released(_event):
					if self.GODOT_INPUT_EVENT_TO_TCE_SIGNALING_UUID_LUT.has(_event):
						var _input_uuid_keychain : Array = self.GODOT_INPUT_EVENT_TO_TCE_SIGNALING_UUID_LUT[_event]
						var _tmp_signaling_keychain : Array = DictionaryParsing.get_dict_element_via_keychain(self.TCE_SIGNALING_UUID_INPUT_EVENTS, _input_uuid_keychain)
						self.call_contextual_logic_with_signaling_keychain(_tmp_signaling_keychain, "just_released")
					else:
						print("Error: Godot Input Event not found in LUT!")

		_events = ["mouse_click_left", "mouse_click_right", "keyboard_modifier", "keyboard_cancel"]
		for _event in _events:
			var _event_split : PoolStringArray = _event.split("_")

			if self._currentInputMethod.match("*" + _event_split[0] + "*"):
				if Input.is_action_just_pressed(_event):
					if self.GODOT_INPUT_EVENT_TO_TCE_SIGNALING_UUID_LUT.has(_event):
						var _input_uuid_keychain : Array = self.GODOT_INPUT_EVENT_TO_TCE_SIGNALING_UUID_LUT[_event]
						var _tmp_signaling_keychain : Array = DictionaryParsing.get_dict_element_via_keychain(self.TCE_SIGNALING_UUID_INPUT_EVENTS, _input_uuid_keychain)
						self.call_contextual_logic_with_signaling_keychain(_tmp_signaling_keychain, "just_pressed")
					else:
						print("Error: Godot Input Event not found in LUT!")
	
