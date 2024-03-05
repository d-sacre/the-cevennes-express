extends CenterContainer

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn
# "audioManager": res://managers/audioManager/audioManager.tscn
# "sfxManager": res://managers/audioManager/sfx/sfxManager.tscn
# "musicManager": res://managers/audioManager/music/musicManager.tscn

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const MENU_STATE = {HIDDEN = 0, ROOT = 1, SETTINGS = 2}

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _tce_event_and_gui_uuid_lut : Dictionary = {
	"gui": {
		MENU_STATE.ROOT: {
			"list": ["gui", "menu", "main", "popup", "root"],
			"string": ""
		},
		MENU_STATE.SETTINGS:  {
			"list": ["gui", "menu", "main", "popup", "settings"],
			"string": ""
		}
	}
}
var _state : int

var _error : int

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var _rootContext : PanelContainer = $rootContext
onready var _settingsContext : PanelContainer = $settingsContext

onready var _buttonClusterRoot : Object = $rootContext/GridContainer/buttonClusterRoot
# onready var settingsPopout : Object = $settingsContext/settingsCluster

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _initialize_root_context() -> void:
	# DESCRIPITON: Initialize default focus
	# REMARK: Disable audio request processing temporarily to prevent
	# a mistriggering due to the connection of the "focus_entered" 
	# signal to the AudioManager.play_sfx() functionality
	audioManager.disable_request_processing()
	_buttonClusterRoot.set_focus_to_default()
	audioManager.enable_request_processing()

func _get_tce_event_and_gui_uuid_string(keyChain : Array) -> String:
	keyChain.append("string")
	return DictionaryParsing.get_dict_element_via_keychain(self._tce_event_and_gui_uuid_lut, keyChain)

func _context_fsm() -> void:
	match self._state:
		MENU_STATE.HIDDEN:
			self.visible = true
			get_tree().paused = true

			self._initialize_root_context()
			self._state = MENU_STATE.ROOT

			UserInputManager.set_current_gui_context(self._get_tce_event_and_gui_uuid_string(["gui", MENU_STATE.ROOT]), "entered")

		MENU_STATE.ROOT:
			self.visible = false
			get_tree().paused = false
			self._state = MENU_STATE.HIDDEN

			# REMARK: Needs to be adapted if not in a Input Method mode that supports the mouse
			if UserInputManager.get_current_gui_context().match("*mouse*"):
				UserInputManager.set_current_gui_context_to_void()
			else:
				UserInputManager.set_current_gui_context_to_grid()

		MENU_STATE.SETTINGS:
			self._settingsContext.visible = false
			self._rootContext.visible = true

			self._initialize_root_context()
			self._state = MENU_STATE.ROOT

			UserInputManager.set_current_gui_context(self._get_tce_event_and_gui_uuid_string(["gui", MENU_STATE.ROOT]), "entered")

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(context : String) -> void:
	# DESCRIPTION: Setting up the gui uuids
	for _guiContext in [MENU_STATE.ROOT, MENU_STATE.SETTINGS]:
		self._tce_event_and_gui_uuid_lut["gui"][_guiContext]["string"] = UserInputManager.create_tce_event_uuid(UserInputManager.get_context(), self._tce_event_and_gui_uuid_lut["gui"][_guiContext]["list"])

	# DESCRIPTION: Initialize the root button cluster and set focus neighbours
	self._buttonClusterRoot.initialize(context)
	self._buttonClusterRoot.visible = true

	self._rootContext.visible = true
	self._settingsContext.visible = false
	self.visible = false
	self._state = MENU_STATE.HIDDEN

	var _data : Dictionary = {
		"disabled": true,
		"default": true,
		"default_value": 50,
		"min": 0,
		"max": 100,
		"step": 1,
		"description": "Audio",
		"tce_event_uuid_suffix": "volume::audio"
	}

	$settingsContext/TCEHSlider.initialize(context, _data)

	# # DESCRIPTION: Initialize the settings
	# settingsPopout.slider_initialize(userSettingsManager.get_user_settings())
	# settingsPopout.button_initialize(userSettingsManager.get_user_settings())

	# DESCRIPTION: Set the correct size and viewport position
	# REMARK: Is required due to the fact that Godot can not handle the sizes of class inherited
	# objects properly and the calculations during _ready do not show any effect
	_buttonClusterRoot.update_size()

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_user_input_manager_global_command(tce_event_uuid : String, _value) -> void:
	# DESCRIPTION: Toggle the visibility of the popup menu and its components 
	# by evaluated user inputs 
	var _tmp_eventKeychain : Array = ["*", "UserInputManager", "requesting", "global", "execution", "toggle", "game", "menu", "main", "context"]

	if UserInputManager.match_tce_event_uuid(tce_event_uuid, _tmp_eventKeychain):
		self._context_fsm()

	_tmp_eventKeychain = ["*","UserInputManager", "requesting", "global", "execution", "toggle", "game", "menu", "settings", "context"]
	if UserInputManager.match_tce_event_uuid(tce_event_uuid, _tmp_eventKeychain):
		self._rootContext.visible = !self._rootContext.visible
		self._settingsContext.visible = !self._settingsContext.visible
		
		if self._settingsContext.visible:
			self._state = MENU_STATE.SETTINGS
			UserInputManager.set_current_gui_context(self._get_tce_event_and_gui_uuid_string(["gui", MENU_STATE.SETTINGS]), "entered")
		else:
			self._state = MENU_STATE.ROOT
			UserInputManager.set_current_gui_context(self._get_tce_event_and_gui_uuid_string(["gui", MENU_STATE.ROOT]), "entered")

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready():
	_error = UserInputManager.connect("transmit_global_event", self, "_on_user_input_manager_global_command")

	# DESCRIPTION: Set AudioManager/sfxManager pause mode, so that sounds play in the ingame menu
	audioManager.pause_mode = PAUSE_MODE_PROCESS
	sfxManager.pause_mode = PAUSE_MODE_PROCESS
	musicManager.pause_mode = PAUSE_MODE_PROCESS


