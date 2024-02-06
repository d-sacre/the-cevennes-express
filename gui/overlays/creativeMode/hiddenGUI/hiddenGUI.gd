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

################################################################################
#### PUBLIC MEMBER VARIABLES ###################################################
################################################################################
var tce_signaling_uuid : Dictionary = {
	"gui": {
		"list" : ["gui", "hud", "selector", "gui", "show"],
		"string": ""
	},
	"actions" : {
		"show_gui": {
			"list": ["user", "selected", "gui", "show"],
			"string": ""
		}
	}
}

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var _unhideGUIButton : Object = $PanelContainer/unhideGUIButton
onready var _panelContainer : Object = $PanelContainer

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(ctxt : String):
	self.tce_signaling_uuid["gui"]["string"] = UserInputManager.create_tce_signaling_uuid(ctxt, self.tce_signaling_uuid["gui"]["list"])
	self.tce_signaling_uuid["actions"]["show_gui"]["string"] = UserInputManager.create_tce_signaling_uuid(ctxt, self.tce_signaling_uuid["actions"]["show_gui"]["list"])

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_unhideGUIButton_pressed() -> void:
	emit_signal("hide_gui", self.tce_signaling_uuid["actions"]["show_gui"]["string"], "NONE")
	self.queue_free()

func _on_mouse_entered() -> void:
	emit_signal("hide_gui", self.tce_signaling_uuid["gui"]["string"], "entered")

func _on_mouse_exited() -> void:
	emit_signal("hide_gui", self.tce_signaling_uuid["gui"]["string"], "exited")

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready():
	_unhideGUIButton.connect("pressed", self, "_on_unhideGUIButton_pressed")
	self.connect("hide_gui", UserInputManager, "_on_user_selected")
	_panelContainer.connect("mouse_entered", self, "_on_mouse_entered")
	_panelContainer.connect("mouse_exited", self, "_on_mouse_exited")


