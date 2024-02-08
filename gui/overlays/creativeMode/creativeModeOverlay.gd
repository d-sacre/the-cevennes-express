extends Control

################################################################################
#### IMPORTANT REMARKS #########################################################
################################################################################
# (1) actionSelector.tscn has to instanced as child scene in tree before       
#     tileSelector.tscn. Otherwise, the tiles are not selectable

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
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize_creative_mode_gui(context: String, tdm : Object) -> void:
	self._tileDefinitionManager = tdm
	self._tileSelector.initialize(context, self._tileDefinitionManager)
	self._actionSelector.initialize(context)

func set_creative_mode_gui_to_default() -> void:
	self._actionSelector.initialize_selection_to_default()

func deactivate_and_hide_tile_selector() -> void:
	self._tileSelector.deactivate_and_hide()

func reactivate_and_unhide_tile_selector() -> void:
	self._tileSelector.reactivate_and_unhide()

	
