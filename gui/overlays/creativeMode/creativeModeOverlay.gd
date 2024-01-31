extends Control

# REMARK: actionSelector.tscn has to instanced as child scene in tree before tileSelector.tscn.
# Otherwise, the tiles are not selectable

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal new_tile_selected(_tile_definition_uuid)
signal gui_mouse_context_changed(context, status)

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
var tileDefinitionManager : Object 
onready var _tileSelector = $tileSelector
onready var _actionSelector = $actionSelector

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################
func initialize_creative_mode_gui(_tileDefinitionManager):
	self.tileDefinitionManager = _tileDefinitionManager
	_tileSelector.initialize_tile_list(self.tileDefinitionManager)

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_new_tile_selected(_tile_definition_uuid):
	emit_signal("new_tile_selected", _tile_definition_uuid)

func _on_gui_mouse_context_changed(context, status):
	emit_signal("gui_mouse_context_changed", context, status)

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready():
	_tileSelector.connect("new_selection", self, "_on_new_tile_selected") # to get information of newly selected tile
	_tileSelector.connect("gui_mouse_context", self, "_on_gui_mouse_context_changed")
	_actionSelector.connect("gui_mouse_context", self, "_on_gui_mouse_context_changed")
