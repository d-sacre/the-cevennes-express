extends Control

# REMARK: actionSelector.tscn has to instanced as child scene in tree before tileSelector.tscn.
# Otherwise, the tiles are not selectable

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal gui_mouse_context_changed(context, status)
signal new_tile_selected(_tile_definition_uuid)
signal action_mode_changed(mode)

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _tileDefinitionManager : Object 

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var _tileSelector : Object = $tileSelector
onready var _actionSelector : Object = $actionSelector

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################
func _adaptModeString(mode : String) -> String:
	return "creativeMode::" + mode

func initialize_creative_mode_gui(tdm : Object) -> void:
	self._tileDefinitionManager = tdm
	self._tileSelector.initialize_tile_list(self._tileDefinitionManager)
	emit_signal("action_mode_changed", self._adaptModeString(_actionSelector.mode))

func set_creative_mode_gui_to_default() -> void:
	self._actionSelector.initialize_selection_to_default()

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_new_tile_selected(_tile_definition_uuid : String) -> void:
	emit_signal("new_tile_selected", _tile_definition_uuid)

func _on_gui_mouse_context_changed(context : String, status: String) -> void:
	emit_signal("gui_mouse_context_changed", context, status)

func _on_action_mode_changed(mode : String) -> void:
	emit_signal("action_mode_changed", self._adaptModeString(mode))

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready():
	self._tileSelector.connect("new_selection", self, "_on_new_tile_selected") # to get information of newly selected tile
	self._tileSelector.connect("gui_mouse_context", self, "_on_gui_mouse_context_changed")
	self._actionSelector.connect("gui_mouse_context", self, "_on_gui_mouse_context_changed")
	self._actionSelector.connect("action_mode", self, "_on_action_mode_changed")

	# connect signals to UserInputManager
	self.connect("gui_mouse_context_changed", UserInputManager, "_on_gui_mouse_context_changed")
	self.connect("action_mode_changed", UserInputManager, "_on_action_mode_changed")
	self.connect("new_tile_selected", UserInputManager, "_on_new_tile_selected")
