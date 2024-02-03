extends Control

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal hide_gui(tce_signaling_uuid, status)

var tce_signaling_uuid : Dictionary = {
	"gui": "",
	"actions" : {
		"show_gui": ""
	}
}

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var _unhideGUIButton : Object = $PanelContainer/unhideGUIButton

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(context : String):
	self.tce_signaling_uuid["actions"]["show_gui"] = context + "::user::selected::gui::show"

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_unhideGUIButton_pressed():
	emit_signal("hide_gui", self.tce_signaling_uuid["actions"]["show_gui"], "NONE")
	self.queue_free()

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready():
	_unhideGUIButton.connect("pressed", self, "_on_unhideGUIButton_pressed")
	self.connect("hide_gui", UserInputManager, "_on_user_selected")


