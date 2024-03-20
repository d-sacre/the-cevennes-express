extends Control

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal hide_gui(tce_event_uuid, status)

################################################################################
#### PUBLIC MEMBER VARIABLES ###################################################
################################################################################
var tce_event_uuid : Dictionary = {
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
	self.tce_event_uuid["gui"]["string"] = UserInputManager.create_tce_event_uuid(ctxt, self.tce_event_uuid["gui"]["list"])
	self.tce_event_uuid["actions"]["show_gui"]["string"] = UserInputManager.create_tce_event_uuid(ctxt, self.tce_event_uuid["actions"]["show_gui"]["list"])

func deactivate_and_hide() -> void:
	TransitionManager.slide_element_out_to_top_center(self)

func reactivate_and_unhide() -> void:
	TransitionManager.slide_element_in_from_top_center(self)

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_unhideGUIButton_pressed() -> void:
	print_debug("Emitting %s" %[self.tce_event_uuid["actions"]["show_gui"]["string"]])
	emit_signal("hide_gui", self.tce_event_uuid["actions"]["show_gui"]["string"], "NONE")

func _on_mouse_entered() -> void:
	emit_signal("hide_gui", self.tce_event_uuid["gui"]["string"], "entered")

func _on_mouse_exited() -> void:
	emit_signal("hide_gui", self.tce_event_uuid["gui"]["string"], "exited")

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready():
	_unhideGUIButton.connect("pressed", self, "_on_unhideGUIButton_pressed")
	self.connect("hide_gui", UserInputManager, "_on_special_user_input")
	_panelContainer.connect("mouse_entered", self, "_on_mouse_entered")
	_panelContainer.connect("mouse_exited", self, "_on_mouse_exited")

	self.initialize(UserInputManager.get_context())
	
	TransitionManager.initialize_sliding_element_top_center_to_invisible(self)


