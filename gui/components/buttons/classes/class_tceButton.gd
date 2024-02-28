tool

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "audioManager": res://managers/audioManager/audioManager.tscn
# Other autoloads that are indirectly required:
# "sfxManager": res://managers/audioManager/sfx/sfxManager.tscn
# "musicManager": res://managers/audioManager/music/musicManager.tscn

extends Button

class_name TCEButton

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _tce_event_uuid : String 
var _default : bool

var _context : String = "test"

var _error : int

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(context : String, data : Dictionary) -> void:
	self._context = context
	self.text = data["text"]
	self.disabled = data["disabled"]
	self._tce_event_uuid = self._context + data["tce_event_uuid_suffix"]
	self._default = data["default"]	
	self.pause_mode = PAUSE_MODE_PROCESS

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_mouse_entered() -> void:
	self.grab_focus()

func _on_focus_entered() -> void:
	audioManager.play_sfx(["ui", "button", "hover"])

func _on_button_pressed() -> void:
	UserInputManager._on_special_user_input(self._tce_event_uuid + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "pressed", "pressed")
	audioManager.play_sfx(["ui", "button", "pressed"])

