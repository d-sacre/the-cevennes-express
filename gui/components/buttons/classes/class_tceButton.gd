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

extends Button

class_name TCEButton

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal pressed_animation_finished

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _tce_event_uuid : String 
var _default : bool

var _context : String = "test"

var _textDefault : String 
const _textFocusAddition : Dictionary = {"prefix": "«", "suffix": "»"}

var _error : int

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _set_to_pressed() -> void:
	NodeHandling.override_styleboxes(
		self, 
		[
			{
				"override": "hover",
				"stylebox_path": "res://themes/button_pressed.stylebox"
			},
			{
				"override": "focus",
				"stylebox_path": "res://themes/button_pressed.stylebox"
			}
		]
	)

func _reset_to_hover() -> void:
	NodeHandling.override_styleboxes(
		self, 
		[
			{
				"override": "hover",
				"stylebox_path": "res://themes/button_hover.stylebox"
			},
			{
				"override": "focus",
				"stylebox_path": "res://themes/button_hover.stylebox"
			}
		]
	)

func _play_pressed_animation() -> void:
	self.pressed = true
	self._set_to_pressed()
	
	yield(get_tree().create_timer(0.5), "timeout")
	self.pressed = false

	self._reset_to_hover()

	yield(get_tree().create_timer(0.25), "timeout")

	emit_signal("pressed_animation_finished")

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(context : String, data : Dictionary) -> void:
	self._context = context
	self._textDefault = data["text"]
	self.text = self._textDefault
	self.disabled = data["disabled"]
	self._tce_event_uuid = self._context + data["tce_event_uuid_suffix"]
	self._default = data["default"]	
	self.pause_mode = PAUSE_MODE_PROCESS

	# DESCRIPTION: If button is disabled, set overrides for focus and hover, so 
	# that its appearence is always the same/correct.
	# REMARK: Later has to be adapted to suit the new paths
	if self.disabled:
		NodeHandling.override_styleboxes(self, [
			{
				"override": "hover",
				"stylebox_path": "res://themes/button_disabled.stylebox"
			},
			{
				"override": "focus",
				"stylebox_path": "res://themes/button_disabled.stylebox"
			}
		])

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
	if not self.disabled:
		self.text = _textFocusAddition["prefix"] + self._textDefault + _textFocusAddition["suffix"]

	# DESCRIPTION: Calculate the position of the mouse cursor, so that in the mixed 
	# keyboard and mouse mode the mouse cursor follows the keyboard selection
	if not UserInputManager.is_device_responsible_for_current_input_mouse():
		var _center : Vector2 =  0.5 * self.rect_size
		self.warp_mouse(_center)
	audioManager.play_sfx(["ui", "button", "hover"])

func _on_focus_exited() -> void:
	self.text = self._textDefault

func _on_button_pressed() -> void:
	audioManager.play_sfx(["ui", "button", "pressed"])

	self._play_pressed_animation()
	yield(self, "pressed_animation_finished")

	UserInputManager._on_special_user_input(self._tce_event_uuid + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "pressed", "pressed")
	

