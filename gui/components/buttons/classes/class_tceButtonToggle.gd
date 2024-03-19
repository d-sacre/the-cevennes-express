tool

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "audioManager": res://managers/audioManager/audioManager.tscn
# "NodeHandling": res://utils/nodeHandling/nodeHandling.gd
# Other autoloads that are indirectly required:
# "sfxManager": res://managers/audioManager/sfx/sfxManager.tscn
# "musicManager": res://managers/audioManager/music/musicManager.tscn

extends CheckButton

class_name TCEButtonToggle

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal user_settings_changed(settingKeychain, setterType, settingValue)

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _tce_event_uuid : String 
var _default : bool

var _settingsKeychain : Array = []

var _context : String = "test"

var _error : int

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(context : String, data : Dictionary) -> void:
	self._context = context
	self.disabled = data["disabled"]
	self._tce_event_uuid = self._context + data["tce_event_uuid_suffix"]
	self._settingsKeychain = data["keychain"]
	self._default = data["default"]	
	self.pause_mode = PAUSE_MODE_PROCESS

	# DESCRIPTION: If button is disabled, set overrides for focus and hover, so 
	# that its appearence is always the same/correct.
	# REMARK: Later has to be adapted to suit the new paths
	if self.disabled:
		pass
		# TO-DO: Define style boxes for toggle button
		# NodeHandling.override_styleboxes(self, [
		# 	{
		# 		"override": "hover",
		# 		"stylebox_path": "res://themes/button_disabled.stylebox"
		# 	},
		# 	{
		# 		"override": "focus",
		# 		"stylebox_path": "res://themes/button_disabled.stylebox"
		# 	}
		# ])

func set_to_default_value(userSettings : Dictionary) -> void:
	self.pressed = DictionaryParsing.get_dict_element_via_keychain(userSettings, self._settingsKeychain)

func enable_ui_focus_mode_all() -> void:
	self.focus_mode = FOCUS_ALL

func disable_ui_focus_mode_all() -> void:
	self.focus_mode = FOCUS_NONE

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_mouse_entered() -> void:
	if not self.disabled:
		self.grab_focus()

func _on_focus_entered() -> void:
	# DESCRIPTION: Calculate the position of the mouse cursor, so that in the mixed 
	# keyboard and mouse mode the mouse cursor follows the keyboard selection
	if not UserInputManager.is_device_responsible_for_current_input_mouse():
		var _center : Vector2 =  0.5 * self.rect_size
		self.warp_mouse(_center)
	audioManager.play_sfx(["ui", "button", "hover"])

func _on_button_toggled(value) -> void:
	audioManager.play_sfx(["ui", "button", "pressed"])
	emit_signal("user_settings_changed", self._settingsKeychain, self._tce_event_uuid, value)
	
################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	# DESCRIPTION: Internal signal handling
	self._error = self.connect("mouse_entered", self, "_on_mouse_entered")
	self._error = self.connect("focus_entered", self, "_on_focus_entered")
	self._error = self.connect("toggled", self, "_on_button_toggled")

	# DESCRIPTION: External signal handling
	self._error = self.connect("user_settings_changed", userSettingsManager, "_on_user_settings_changed")
