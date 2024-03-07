tool

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "audioManager": res://managers/audioManager/audioManager.tscn
# "DictionaryParsing": res://utils/dataHandling/dictionaryParsing.gd
# Other autoloads that are indirectly required:
# "sfxManager": res://managers/audioManager/sfx/sfxManager.tscn
# "musicManager": res://managers/audioManager/music/musicManager.tscn

extends HSlider

class_name TCEHSlider

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal user_settings_changed(settingKeychain, setterType, settingValue)

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _tce_event_uuid : String 
var _default : bool

var _context : String = "test"
var _settingsKeychain : Array = []

var _processingAllowed : bool = false

var _minSize : Vector2 = Vector2(256,48)

var _error : int

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func enable_processing() -> void:
	self._processingAllowed = true

func disable_processing() -> void:
	self._processingAllowed = false

func initialize(context : String, data : Dictionary) -> void:
	self._context = context
	self._settingsKeychain = data["keychain"]

	# DESCRIPTION: General setup
	self.editable = not data["disabled"]
	self._tce_event_uuid = self._context + data["tce_event_uuid_suffix"]
	self._default = data["default"]	
	self.pause_mode = PAUSE_MODE_PROCESS

	# DESCRIPTION: Setup of the slider
	self.min_value = data["min"]
	self.max_value = data["max"]
	self.step = data["step"]
	self.value = 0.0

	# DESCRIPTION: Setting the correct size
	self.rect_min_size = self._minSize

	# DESCRIPTION: If button is disabled, set overrides for focus and hover, so 
	# that its appearence is always the same/correct.
	# REMARK: Later has to be adapted to suit the new paths
	if self.editable:
		for _override in ["hover", "focus"]:
			if self.has_stylebox_override(_override):
				self.remove_stylebox_override(_override)
	
		# FUTURE: Need to implement disabled style box!
		# self.add_stylebox_override("hover", load("res://themes/button_disabled.stylebox"))
		# self.add_stylebox_override("focus", load("res://themes/button_disabled.stylebox"))

	if not Engine.editor_hint:
		self.enable_processing()

func set_to_default_value(userSettings : Dictionary) -> void:
	self.value = DictionaryParsing.get_dict_element_via_keychain(userSettings, self._settingsKeychain)

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_mouse_entered() -> void:
	if self.editable:
		self.grab_focus()

func _on_focus_entered() -> void:
	if self.editable:
		# DESCRIPTION: Calculate the position of the mouse cursor, so that in the mixed 
		# keyboard and mouse mode the mouse cursor follows the keyboard selection
		if not UserInputManager.is_device_responsible_for_current_input_mouse():
			var _center : Vector2 =  0.5 * self.rect_size
			self.warp_mouse(_center)

		audioManager.play_sfx(["ui", "button", "hover"])

func _on_value_changed(value) -> void:
	if self._processingAllowed:
		if self._settingsKeychain != []:
			emit_signal("user_settings_changed", self._settingsKeychain, self._tce_event_uuid, value)

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	self._error = self.connect("user_settings_changed", userSettingsManager, "_on_user_settings_changed")

