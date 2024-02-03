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
# signal gui_mouse_context_changed(context, status)
# signal new_tile_selected(_tile_definition_uuid)
# signal action_mode(mode)

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
func initialize_creative_mode_gui(context: String, tdm : Object) -> void:
	self._tileDefinitionManager = tdm
	self._tileSelector.initialize(context, self._tileDefinitionManager)
	self._actionSelector.initialize(context)

func set_creative_mode_gui_to_default() -> void:
	self._actionSelector.initialize_selection_to_default()

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
# func _on_new_tile_selected(_tile_definition_uuid : String) -> void:
# 	emit_signal("new_tile_selected", _tile_definition_uuid)

# func _on_gui_mouse_context_changed(context : String, status: String) -> void:
# 	emit_signal("gui_selector_context_changed", context, status)

# func _on_action_mode_changed(mode : String) -> void:
# 	emit_signal("action_mode_changed", self._adaptModeString(mode))

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready():
	# self._tileSelector.connect("new_selection", self, "_on_new_tile_selected") # to get information of newly selected tile
	# self._tileSelector.connect("gui_mouse_context", self, "_on_gui_mouse_context_changed")
	# self._actionSelector.connect("gui_mouse_context", self, "_on_gui_mouse_context_changed")
	# self._actionSelector.connect("action_mode", self, "_on_action_mode_changed")

	# connect signals to UserInputManager
	# self.connect("gui_mouse_context_changed", UserInputManager, "_on_gui_mouse_context_changed")
	self._tileSelector.connect("new_tile_definition_selected", UserInputManager, "_on_user_selected")
	self._actionSelector.connect("action_mode", UserInputManager, "_on_user_selected")

	self._tileSelector.connect("gui_mouse_context", UserInputManager, "_on_gui_selector_context_changed")
	self._actionSelector.connect("gui_mouse_context", UserInputManager, "_on_gui_selector_context_changed")
	
