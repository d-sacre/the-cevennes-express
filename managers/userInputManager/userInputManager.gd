extends Node

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# The scene this script is attached to is autoloaded as "UserInputManager".    #
################################################################################

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal new_tile_selected(_tile_definition_uuid)

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################

var mode : String
var currentGuiMouseContext : String 

var _managerReferences : Dictionary = {
	"cameraManager": null,
	"tileDefinitionManager": null,
	"hexGridManager": null
}

var _guiLayerReferences : Dictionary = {
	"overlay": null,
	"popup": null
}

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################
func initialize(_mode : String, cm : Object, tdm : Object, hgm : Object, gocl : Object, gpucl : Object) -> void:
	_managerReferences["cameraManager"] = cm
	_managerReferences["tileDefinitionManager"] = tdm
	_managerReferences["hexGridManager"] = hgm
	_guiLayerReferences["overlay"] = gocl
	_guiLayerReferences["popup"] = gpucl

	self.mode = _mode

	print(_managerReferences)
	print(_guiLayerReferences)

func hide_gui(status : bool) -> void:
	match self.mode:
		"creativeMode":
			_guiLayerReferences["overlay"].visible = not status

	if status:
		currentGuiMouseContext = "grid"
		_managerReferences["cameraManager"].enable_zooming()
		_managerReferences["cameraManager"].enable_raycasting()

		var scene = load("res://gui/overlays/creativeMode/hiddenGUI/hiddenGUI.tscn")
		var instance = scene.instance()
		_guiLayerReferences["popup"].add_child(instance)

	else:
		match self.mode:
			"creativeMode":
				_guiLayerReferences["overlay"].get_node("creativeModeOverlay").set_creative_mode_gui_to_default()

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_gui_mouse_context_changed(context : String, status : String) -> void:
	# print("User Input Manager received ", context, " with status ", status)
	match context:
		"tileSelector":
			if status == "entered":
				currentGuiMouseContext = context
				_managerReferences["cameraManager"].disable_zooming()
				_managerReferences["cameraManager"].disable_raycasting()
			else:
				currentGuiMouseContext = "grid"
				_managerReferences["cameraManager"].enable_zooming()
				_managerReferences["cameraManager"].enable_raycasting()
		"actionSelector":
			if status == "entered":
				currentGuiMouseContext = context
				_managerReferences["cameraManager"].disable_zooming()
				_managerReferences["cameraManager"].disable_raycasting()
			else:
				currentGuiMouseContext = "grid"
				_managerReferences["cameraManager"].enable_zooming()
				_managerReferences["cameraManager"].enable_raycasting()

func _on_action_mode_changed(action_mode : String) -> void:
	# Select Mode specific behavior
	if action_mode.match("creativeMode::*"): # creative mode
		action_mode = action_mode.trim_prefix("creativeMode::")

		if action_mode.match("selector::*"):
			action_mode = action_mode.trim_prefix("selector::")

			if action_mode.match("tile::*"):
				action_mode = action_mode.trim_prefix("tile::")

				if action_mode.match("action::*"):
					action_mode = action_mode.trim_prefix("action::")

					match action_mode:
						"place":
							print("place")
						"replace":
							pass
						"pick":
							pass
						"delete":
							pass

			elif action_mode.match("gui::*"):
				action_mode = action_mode.trim_prefix("gui::")
				match action_mode:
					"hide":
						print("Hide GUI: ", true)
						hide_gui(true) # to make it neater, this should be a clean function call

func _on_hide_gui_changed(status : bool) -> void:
	print("User Input Manager received: Hide GUI = ", status)
	hide_gui(status)

func _on_new_tile_selected(_tile_definition_uuid : String) -> void:
	# TO-DO: logic to process whether new tile selection is allowed at all
	emit_signal("new_tile_selected", _tile_definition_uuid)

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready() -> void:
	print("\t-> Initialize UserInputManager...")


