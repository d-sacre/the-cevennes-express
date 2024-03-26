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
onready var rootContextCredits : Object = $slidingElements/slidingCreditsContent/creditsSlidingElement

onready var _settingsContext : Object = $slidingElements/slidingSettingsContext
onready var _settingsCluster : Object = $slidingElements/slidingSettingsContext/PanelContainer/settingsSubmenu

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
	self._state = self.MENU_STATE.ROOT
	UserInputManager.disable_gui_input_hsplit()
	audioManager.disable_request_processing()
	self.rootContextButtons.enable_ui_focus_mode_all()
	self.rootContextButtons.set_focus_to_default()
	self._settingsCluster.disable_ui_focus_mode_all()
	audioManager.enable_request_processing()

func _initialize_settings_context_state() -> void:
	self._settingsContext.visible = true
	self.rootContextButtons.disable_ui_focus_mode_all()
	self._settingsCluster.enable_ui_focus_mode_all()
	TransitionManager.slide_element_in_from_top_left(self._settingsContext)
	TransitionManager.wait_until_tween_is_finished_and_execute(self._settingsCluster, "set_focus_to_default")
	UserInputManager.enable_gui_input_hsplit()
	UserInputManager.set_gui_input_split_column_to_stereo_l()
	self._state = self.MENU_STATE.SETTINGS

func _clear_settings_context_before_switching_state() -> void:
	self._settingsContext.visible = true
	TransitionManager.slide_element_out_to_top_left(self._settingsContext)

func _initialize_credits_context_state() -> void:
	TransitionManager.slide_element_in_from_top_left(self.rootContextCredits)
	UserInputManager.enable_gui_input_hsplit()
	UserInputManager.set_gui_input_split_column_to_stereo_l()
	self._state = self.MENU_STATE.CREDITS

func _clear_credits_context_before_switching_state() -> void:
	TransitionManager.slide_element_out_to_top_left(self.rootContextCredits)

func _context_fsm(tce_event_uuid : String, _value) -> void:
	var _tmp_eventKeychain : Array = []
	
	match self._state:
		MENU_STATE.ROOT:
			if self._is_tce_uuid_matching_toggle_settings(tce_event_uuid):
				self._initialize_settings_context_state()

			if self._is_tce_uuid_matching_toggle_credits(tce_event_uuid):
				self._initialize_credits_context_state()

		MENU_STATE.SETTINGS:
			if self._is_tce_uuid_matching_toggle_settings(tce_event_uuid):
				self._clear_settings_context_before_switching_state()
				self._initialize_root_context_state()

			if self._is_tce_uuid_matching_toggle_credits(tce_event_uuid):
				self._clear_settings_context_before_switching_state()
				self._initialize_credits_context_state()

			if self._is_tce_uuid_matching_toggle_context(tce_event_uuid):
				self._clear_settings_context_before_switching_state()
				self._initialize_root_context_state()

		MENU_STATE.CREDITS:
			if self._is_tce_uuid_matching_toggle_credits(tce_event_uuid):
				self._clear_credits_context_before_switching_state()
				self._initialize_root_context_state()

			if self._is_tce_uuid_matching_toggle_settings(tce_event_uuid):
				self._clear_credits_context_before_switching_state()
				self._initialize_settings_context_state()

			if self._is_tce_uuid_matching_toggle_context(tce_event_uuid):
				self._clear_credits_context_before_switching_state()
				self._initialize_root_context_state()

func _initialize() -> void:
	self._settingsCluster.initialize(self._context)
	self._initialize_root_context_state()

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_user_input_manager_global_command(tce_event_uuid : String, _value) -> void:
	  self._context_fsm(tce_event_uuid, _value)

func _on_gui_input_column_change_requested(col : int) -> void:
	match col:
		UserInputManager.GUI_HSPLIT.STEREO_L:
			if UserInputManager.is_gui_input_hsplit():
				match self._state:
					MENU_STATE.SETTINGS:
						self._settingsCluster.set_focus_to_default()

				UserInputManager.set_gui_input_split_column_to_stereo_l()

		UserInputManager.GUI_HSPLIT.MONO_R:
			self.rootContextButtons.set_focus_to_default()
			UserInputManager.set_gui_input_split_column_to_mono_r()

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready():
	
	self.rootContextButtons.initialize(self._context)
	self._initialize_root_context_state()

	# DESCRIPTION: Move Sliding Elements out of view
	TransitionManager.initialize_sliding_element_left(self._settingsContext)
	TransitionManager.initialize_sliding_element_left(self.rootContextCredits)

	# Initialize user settings
	userSettingsManager.initialize_user_settings()

	# Initialize User Input Manager
	print("\t\t-> Initialize UserInputManager")
	self.contextualLogic.initialize(self._context)
	UserInputManager.initialize(self._context, "mouse::keyboard::mixed", self.contextualLogic, {}, {})

	self._initialize()

	# DESCRIPTION: Configure external signaling
	self._error = UserInputManager.connect("transmit_global_event", self, "_on_user_input_manager_global_command")
	self._error = UiActionManager.connect("request_current_gui_input_column_change", self, "_on_gui_input_column_change_requested")

	print("\n<MAIN MENU>")
