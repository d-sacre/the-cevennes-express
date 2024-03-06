extends Node

################################################################################
################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
################################################################################
# The scene this script is attached to is autoloaded as "UiActionManager".     #
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn

################################################################################
################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
################################################################################
const TCE_EVENT_UUID_TO_GODOT_UI_ACTION_LUT : Array = [
	{"LUT": ["previous_option"], "UI_ACTION": ""},
	{"LUT":["next_option"], "UI_ACTION": ""},
	{"LUT":["cancel"], "UI_ACTION": "ui_cancel"},
	{"LUT":["increment"], "UI_ACTION": ""},
	{"LUT":["decrement"], "UI_ACTION": ""},
	{"LUT":["confirm"], "UI_ACTION": "ui_accept"},
	{"LUT": ["perform_tile_action"], "UI_ACTION": "ui_accept"}
]

const TCE_EVENT_UUID_MOVEMENT_CHANNEL_MAPPING_LUT : Array = [
	{"LUT":["movement", "channel1"]},
	{"LUT":["movement", "channel2"]},
	{"LUT":["movement", "channel3"]}
]

################################################################################
################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
################################################################################
var _lastMovementAction : String = ""
var _movement_by_asmr_allowed : bool = false

var _uiMovementRepetitionDelay : float = 0.3

var _error : int

################################################################################
################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
################################################################################
onready var uiMovementTimer : Timer = $uiMovementTimer

################################################################################
################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
################################################################################

################################################################################
#### PRIVATE MEMBER FUNCTIONS: BOOL EXPRESSIONS ################################
################################################################################
func _is_current_control(type : String) -> bool:
	var _currentControl : Object = UserInputManager.get_control_currently_in_focus()
	var _currentControlType : String = _currentControl.get_class()

	if _currentControlType == type:
		return true

	return false

func _is_current_control_hslider() -> bool:
	return self._is_current_control("HSlider")

################################################################################
#### PRIVATE MEMBER FUNCTIONS: UTILITIES AND TOOLS #############################
################################################################################
func _ui_move() -> void:
	if self._lastMovementAction != "":
		if not self._is_current_control_hslider():
			UserInputManager.trigger_fake_input_event(self._lastMovementAction, true)
		else:
			if (self._lastMovementAction != "ui_left") or (self._lastMovementAction != "ui_right"):
				# REMARK: Currently a hack, since it requires two movements to get the slider to change focus
				# Perhaps too many (hidden) sliders initialized?
				UserInputManager.trigger_fake_input_event(self._lastMovementAction, true)
				UserInputManager.trigger_fake_input_event(self._lastMovementAction, true)

################################################################################
################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
################################################################################
func enable_movement_by_asmr(timer : Timer, delay : float) -> void:
	self._movement_by_asmr_allowed = true

	if timer.is_stopped():
		timer.start(delay)
	else:
		timer.stop()
		timer.start(delay)

func disable_movement_by_asmr(timer : Timer) -> void:
	self._movement_by_asmr_allowed = false

	if not timer.is_stopped():
		timer.stop()

func manage_ui_action_mapping(tce_event_uuid : String, value) -> void:
	var _tmp_keyChain : Array = []

	for _event in self.TCE_EVENT_UUID_TO_GODOT_UI_ACTION_LUT:
		_tmp_keyChain = ["*"]
		_tmp_keyChain += DictionaryParsing.get_dict_element_via_keychain(UserInputManager.TCE_INPUT_EVENTS_TO_TCE_EVENT_UUID_LUT, _event["LUT"])
		if UserInputManager.match_tce_event_uuid(tce_event_uuid, _tmp_keyChain):
			if _event["UI_ACTION"] != "": # only for testing, until all actions are correctly mapped
				# REMARK: If a button should be pressed, make sure that there is a true/false
				# event; otherwise the button will not trigger. This causes issues when the input
				# was generated by a mouse click, as it will interpreted as a double action, making it 
				# impossible to open toggled things like the settings context by mouse
				if _event["UI_ACTION"] == "ui_accept":
					if not UserInputManager.is_device_responsible_for_current_input_mouse(): 
						UserInputManager.trigger_fake_input_event(_event["UI_ACTION"], true)
						UserInputManager.trigger_fake_input_event(_event["UI_ACTION"], false)

	for _event in self.TCE_EVENT_UUID_MOVEMENT_CHANNEL_MAPPING_LUT:
		_tmp_keyChain = ["*"]
		_tmp_keyChain += DictionaryParsing.get_dict_element_via_keychain(UserInputManager.TCE_INPUT_EVENTS_TO_TCE_EVENT_UUID_LUT, _event["LUT"])
		if UserInputManager.match_tce_event_uuid(tce_event_uuid, _tmp_keyChain):
			if value is Vector2:

				# REMARK: For debug purposes only
				print("Action Strength: ", value)

				var _upDown : float = value.y
				var _leftRight : float = value.x

				# DESCRIPTION: Translate up-down action strength to vertical movement
				if abs(_upDown) >= 0.501:
					if _upDown < 0:
						self._lastMovementAction = "ui_down"
						self.enable_movement_by_asmr(uiMovementTimer, self._uiMovementRepetitionDelay)

					elif _upDown > 0:
						self._lastMovementAction = "ui_up"
						self.enable_movement_by_asmr(uiMovementTimer, self._uiMovementRepetitionDelay)

				# DESCRIPTION: Translate left-right action strength to horizontal movement
				# REMARK: Needs a case for when a horizontal slider is the element currently in focus
				if abs(_leftRight) >= 0.501:
					if _leftRight > 0:
						self._lastMovementAction = "ui_left"
						self.enable_movement_by_asmr(uiMovementTimer, self._uiMovementRepetitionDelay)

					elif _leftRight < 0:
						self._lastMovementAction = "ui_right"
						self.enable_movement_by_asmr(uiMovementTimer, self._uiMovementRepetitionDelay)

				# REMARK: Might have to be adjusted for controller support
				if value == Vector2(0,0):
					self._lastMovementAction = ""
					self.disable_movement_by_asmr(uiMovementTimer)

				self._ui_move()

################################################################################
################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
################################################################################
func _on_ui_movement_timer_timeout() -> void:
	self._ui_move()

################################################################################
################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
################################################################################
func _ready() -> void:
	self._error = self.uiMovementTimer.connect("timeout", self, "_on_ui_movement_timer_timeout")
