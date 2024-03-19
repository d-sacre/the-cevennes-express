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

var _context : String = ""

var _state : int

var _error : int

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var _rootContext : PanelContainer = $rootContext
onready var _settingsContext : PanelContainer = $settingsContext

onready var _buttonClusterRoot : Object = $rootContext/GridContainer/buttonClusterRoot
onready var _settingsScroll : Object = $settingsContext/ScrollContainer
onready var _settingsCluster : Object = $settingsContext/ScrollContainer/settings_popup_panelContainer2
onready var _settingsClusterContainer : Object = $settingsContext/ScrollContainer/settings_popup_panelContainer2/CenterContainer/GridContainer

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _is_tce_uuid_matching_toggle_game_menu_main(tce_event_uuid : String) -> bool:
	return UserInputManager.match_tce_event_uuid(tce_event_uuid, ["*", "UserInputManager", "requesting", "global", "execution", "toggle", "game", "menu", "main", "context"])

func _is_tce_uuid_matching_toggle_settings_context(tce_event_uuid : String) -> bool:
	return UserInputManager.match_tce_event_uuid(tce_event_uuid, ["*","UserInputManager", "requesting", "global", "execution", "toggle", "game", "menu", "settings", "context"])

func _get_tce_event_and_gui_uuid_string(keyChain : Array) -> String:
	keyChain.append("string")
	return DictionaryParsing.get_dict_element_via_keychain(self._tce_event_and_gui_uuid_lut, keyChain)

func _initialize_hidden_context() -> void:
	self.visible = false
	get_tree().paused = false
	self._state = MENU_STATE.HIDDEN

func _initialize_root_context() -> void:
	# DESCRIPITON: Initialize default focus
	# REMARK: Disable audio request processing temporarily to prevent
	# a mistriggering due to the connection of the "focus_entered" 
	# signal to the AudioManager.play_sfx() functionality
	audioManager.disable_request_processing()
	get_tree().paused = true
	self._rootContext.visible = true
	self._buttonClusterRoot.set_focus_to_default()
	audioManager.enable_request_processing()
	self._state = MENU_STATE.ROOT
	UserInputManager.set_current_gui_context(self._get_tce_event_and_gui_uuid_string(["gui", MENU_STATE.ROOT]), "entered")

func _clear_root_context_before_switching_state() -> void:
	self._buttonClusterRoot.disable_ui_focus_mode_all()
	self._rootContext.visible = false

func _initialize_settings_context() -> void:
	self._settingsContext.visible = true

	self._state = MENU_STATE.SETTINGS
	self._settingsCluster.set_focus_to_default()
	UserInputManager.set_current_gui_context(self._get_tce_event_and_gui_uuid_string(["gui", MENU_STATE.SETTINGS]), "entered")

func _clear_settings_context_before_switching_state() -> void:
	self._settingsCluster.disable_ui_focus_mode_all()
	self._settingsContext.visible = false

func _show_popup_menu() -> void:
	self.visible = true
	self._initialize_root_context()

func _hide_popup_menu() -> void:
	self._initialize_hidden_context()

	# REMARK: Needs to be adapted if not in a Input Method mode that supports the mouse
	if UserInputManager.get_current_gui_context().match("*mouse*"):
		UserInputManager.set_current_gui_context_to_void()
	else:
		UserInputManager.set_current_gui_context_to_grid()

# func _context_fsm() -> void:
# 	match self._state:
# 		MENU_STATE.HIDDEN:
# 			self.visible = true
# 			get_tree().paused = true

# 			self._initialize_root_context()
# 			self._state = MENU_STATE.ROOT

# 			UserInputManager.set_current_gui_context(self._get_tce_event_and_gui_uuid_string(["gui", MENU_STATE.ROOT]), "entered")

# 		MENU_STATE.ROOT:
# 			self.visible = false
# 			get_tree().paused = false
# 			self._state = MENU_STATE.HIDDEN

# 			# REMARK: Needs to be adapted if not in a Input Method mode that supports the mouse
# 			if UserInputManager.get_current_gui_context().match("*mouse*"):
# 				UserInputManager.set_current_gui_context_to_void()
# 			else:
# 				UserInputManager.set_current_gui_context_to_grid()

# 		MENU_STATE.SETTINGS:
# 			self._settingsContext.visible = false
# 			self._rootContext.visible = true

# 			self._initialize_root_context()
# 			self._state = MENU_STATE.ROOT

# 			UserInputManager.set_current_gui_context(self._get_tce_event_and_gui_uuid_string(["gui", MENU_STATE.ROOT]), "entered")

func _context_fsm(tce_event_uuid : String) -> void:
	match self._state:
		MENU_STATE.HIDDEN:
			if self._is_tce_uuid_matching_toggle_game_menu_main(tce_event_uuid):
				self._show_popup_menu()

		MENU_STATE.ROOT:
			if self._is_tce_uuid_matching_toggle_game_menu_main(tce_event_uuid):
				self._clear_root_context_before_switching_state()
				self._hide_popup_menu()
			elif self._is_tce_uuid_matching_toggle_settings_context(tce_event_uuid):
				self._clear_root_context_before_switching_state()
				self._initialize_settings_context()

		MENU_STATE.SETTINGS:
			if self._is_tce_uuid_matching_toggle_game_menu_main(tce_event_uuid) or self._is_tce_uuid_matching_toggle_settings_context(tce_event_uuid):
				self._clear_settings_context_before_switching_state()
				self._initialize_root_context()

func _update_size() -> void:
	# DESCRIPTION: Set the correct size and viewport position
	# REMARK: Is required due to the fact that Godot can not handle the sizes of class inherited
	# objects properly and the calculations during _ready do not show any effect
	self._buttonClusterRoot.update_size()
	self._settingsCluster.rect_min_size = self._settingsClusterContainer.rect_size
	self._settingsScroll.rect_min_size = self._settingsCluster.rect_min_size + Vector2(24,24)
	self._settingsContext.rect_min_size = self._settingsScroll.rect_min_size + Vector2(12,12)

	# DEBUG
	# print("Settings Cluster: min size: ", self._settingsCluster.rect_min_size)
	# print("Scroll Container: min size: ", self._settingsScroll.rect_min_size)
	# print("Settings: Panel Container : min size: ", self._settingsContext.rect_min_size)

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(context : String) -> void:
	self._context = context + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "menu"+ UserInputManager.TCE_EVENT_UUID_SEPERATOR + "main"+ UserInputManager.TCE_EVENT_UUID_SEPERATOR + "popup"

	# DESCRIPTION: Setting up the gui uuids
	for _guiContext in [MENU_STATE.ROOT, MENU_STATE.SETTINGS]:
		self._tce_event_and_gui_uuid_lut["gui"][_guiContext]["string"] = UserInputManager.create_tce_event_uuid(context, self._tce_event_and_gui_uuid_lut["gui"][_guiContext]["list"])

	# DESCRIPTION: Initialize the root button cluster and set focus neighbours
	self._buttonClusterRoot.initialize(self._context)
	self._buttonClusterRoot.visible = true

	self._rootContext.visible = true
	self._settingsContext.visible = false
	self.visible = false
	self._state = MENU_STATE.HIDDEN

	self._update_size()

	self._settingsCluster.initialize(self._context)

	var _height : int = min(self._settingsCluster.get_cluster_height() + 128, 750) 
	self._settingsScroll.rect_min_size.y = _height
	self._settingsContext.rect_min_size.y = _height

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_user_input_manager_global_command(tce_event_uuid : String, _value) -> void:
	self._context_fsm(tce_event_uuid)

	# # DESCRIPTION: Toggle the visibility of the popup menu and its components 
	# # by evaluated user inputs 
	# var _tmp_eventKeychain : Array = ["*", "UserInputManager", "requesting", "global", "execution", "toggle", "game", "menu", "main", "context"]

	# if UserInputManager.match_tce_event_uuid(tce_event_uuid, _tmp_eventKeychain):
	# 	self._context_fsm()

	# _tmp_eventKeychain = ["*","UserInputManager", "requesting", "global", "execution", "toggle", "game", "menu", "settings", "context"]
	# if UserInputManager.match_tce_event_uuid(tce_event_uuid, _tmp_eventKeychain):
	# 	self._rootContext.visible = !self._rootContext.visible
	# 	self._settingsContext.visible = !self._settingsContext.visible
		
	# 	if self._settingsContext.visible:
	# 		print("Opening Settings; has method: ", self._settingsCluster.has_method("set_focus_to_default"))
	# 		self._state = MENU_STATE.SETTINGS
	# 		self._settingsCluster.set_focus_to_default()
	# 		UserInputManager.set_current_gui_context(self._get_tce_event_and_gui_uuid_string(["gui", MENU_STATE.SETTINGS]), "entered")
	# 	else:
	# 		self._state = MENU_STATE.ROOT
	# 		UserInputManager.set_current_gui_context(self._get_tce_event_and_gui_uuid_string(["gui", MENU_STATE.ROOT]), "entered")

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready():
	_error = UserInputManager.connect("transmit_global_event", self, "_on_user_input_manager_global_command")

	# DESCRIPTION: Set AudioManager/sfxManager pause mode, so that sounds play in the ingame menu
	audioManager.pause_mode = PAUSE_MODE_PROCESS
	sfxManager.pause_mode = PAUSE_MODE_PROCESS
	musicManager.pause_mode = PAUSE_MODE_PROCESS


