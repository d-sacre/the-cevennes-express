extends Control

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const _context : String = "menu" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "main"

const MENU_STATE = {ROOT = 0, SETTINGS = 1, CREDITS = 2}

const EVENT_MANAGER_REQUESTS_TO_PROCESS : Dictionary = {
	"credits_toggle": ["*", "UserInputManager", "requesting", "global", "execution", "toggle", "game", "menu", "credits", "context"],
	"settings_toggle": ["*", "UserInputManager", "requesting", "global", "execution", "toggle", "game", "menu", "settings", "context"],
	"context_toggle" : ["*", "UserInputManager", "requesting", "global", "execution", "toggle", "menu", "context"]
}

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _state : int

var _error : int

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var rootContext : HBoxContainer = $MarginContainer/contentVBoxContainer/rootContext
onready var rootContextButtons : Object = $MarginContainer/contentVBoxContainer/rootContext/buttons/buttonClusterRoot
onready var rootContextCredits : Object = $MarginContainer/contentVBoxContainer/rootContext/content/credits_popup_panel

onready var _settingsCluster : Object = $MarginContainer/contentVBoxContainer/rootContext/content/settingsSubmenu

onready var contextualLogic : Node = $contextualLogic

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _is_tce_uuid_matching_toggle_credits(tce_event_uuid : String) -> bool:
	return UserInputManager.match_tce_event_uuid(tce_event_uuid, self.EVENT_MANAGER_REQUESTS_TO_PROCESS["credits_toggle"])

func _is_tce_uuid_matching_toggle_settings(tce_event_uuid : String) -> bool:
	return UserInputManager.match_tce_event_uuid(tce_event_uuid, self.EVENT_MANAGER_REQUESTS_TO_PROCESS["settings_toggle"])

func _is_tce_uuid_matching_toggle_context(tce_event_uuid : String) -> bool:
	return UserInputManager.match_tce_event_uuid(tce_event_uuid, self.EVENT_MANAGER_REQUESTS_TO_PROCESS["context_toggle"])

func _initialize_root_context_state() -> void:
	self._settingsCluster.visible = false
	self.rootContextCredits.visible = false
	self._state = self.MENU_STATE.ROOT
	audioManager.disable_request_processing()
	self.rootContextButtons.set_focus_to_default()
	audioManager.enable_request_processing()

func _initialize_settings_context_state() -> void:
	self._settingsCluster.visible = true
	self._settingsCluster.set_focus_to_default()
	self._state = self.MENU_STATE.SETTINGS

func _initialize_credits_context_state() -> void:
	self.rootContextCredits.visible = true
	self.rootContextCredits.grab_focus()
	self._state = self.MENU_STATE.CREDITS

func _context_fsm(tce_event_uuid : String, _value) -> void:
	var _tmp_eventKeychain : Array = []
	
	match self._state:
		MENU_STATE.ROOT:
			self.rootContextCredits.visible = false
			if self._is_tce_uuid_matching_toggle_settings(tce_event_uuid):
				self._initialize_settings_context_state()

			if self._is_tce_uuid_matching_toggle_credits(tce_event_uuid):
				self._initialize_credits_context_state()

		MENU_STATE.SETTINGS:
			if self._is_tce_uuid_matching_toggle_settings(tce_event_uuid):
				self._initialize_root_context_state()

			if self._is_tce_uuid_matching_toggle_credits(tce_event_uuid):
				self._settingsCluster.visible = false
				self._initialize_credits_context_state()

			if self._is_tce_uuid_matching_toggle_context(tce_event_uuid):
				self._initialize_root_context_state()

		MENU_STATE.CREDITS:
			if self._is_tce_uuid_matching_toggle_credits(tce_event_uuid):
				self._initialize_root_context_state()

			if self._is_tce_uuid_matching_toggle_settings(tce_event_uuid):
				self.rootContextCredits.visible = false
				self._initialize_settings_context_state()

			if self._is_tce_uuid_matching_toggle_context(tce_event_uuid):
				self._initialize_root_context_state()

func _initialize() -> void:
	self.rootContextCredits.visible = false

	self._settingsCluster.initialize(self._context)
	self._settingsCluster.visible = false

	self._initialize_root_context_state()

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_user_input_manager_global_command(tce_event_uuid : String, _value) -> void:
	  self._context_fsm(tce_event_uuid, _value)

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready():
	# self._state = self.MENU_STATE.ROOT
	
	self.rootContextButtons.initialize(self._context)
	self._initialize_root_context_state()

	# Initialize user settings
	userSettingsManager.initialize_user_settings()

	# Initialize User Input Manager
	print("\t\t-> Initialize UserInputManager")
	self.contextualLogic.initialize(self._context)
	UserInputManager.initialize(self._context, "mouse::keyboard::mixed", self.contextualLogic, {}, {})

	self._initialize()

	# DESCRIPTION: Configure external signaling
	self._error = UserInputManager.connect("transmit_global_event", self, "_on_user_input_manager_global_command")

	print("\n<MAIN MENU>")

