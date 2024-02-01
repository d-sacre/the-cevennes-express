extends Control

# REMARK: actionSelector.tscn has to instanced as child scene in tree before tileSelector.tscn.
# Otherwise, the tiles are not selectable

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal gui_mouse_context_changed(context, status)
signal new_tile_selected(_tile_definition_uuid)
signal action_mode_changed(mode)

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
var tileDefinitionManager : Object 
onready var _tileSelector = $tileSelector
onready var _actionSelector = $actionSelector

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################
func _adaptModeString(mode) -> String:
	return "creativeMode::" + mode

func initialize_creative_mode_gui(_tileDefinitionManager):
	self.tileDefinitionManager = _tileDefinitionManager
	_tileSelector.initialize_tile_list(self.tileDefinitionManager)
	emit_signal("action_mode_changed", _adaptModeString(_actionSelector.mode))

func set_creative_mode_gui_to_default():
	_actionSelector.initialize_selection_to_default()

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_new_tile_selected(_tile_definition_uuid):
	emit_signal("new_tile_selected", _tile_definition_uuid)

func _on_gui_mouse_context_changed(context, status):
	emit_signal("gui_mouse_context_changed", context, status)

func _on_action_mode_changed(mode):
	emit_signal("action_mode_changed", _adaptModeString(mode))

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready():
	_tileSelector.connect("new_selection", self, "_on_new_tile_selected") # to get information of newly selected tile
	_tileSelector.connect("gui_mouse_context", self, "_on_gui_mouse_context_changed")
	_actionSelector.connect("gui_mouse_context", self, "_on_gui_mouse_context_changed")
	_actionSelector.connect("action_mode", self, "_on_action_mode_changed")
