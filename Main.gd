extends Node

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "userSettingsManager": res://managers/userSettingsManager/userSettingsManager.tscn
# "audioManager": res://managers/audioManager/audioManager.tscn
# Other autoloads that are indirectly required:
# "JsonFio": res://utils/fileHandling/json_fio.gd
# "DictionaryParsing": res://utils/dataHandling/dictionaryParsing.gd
# "AudioManagerNodeHandling": res://managers/audioManager/utils/audioManager_node-handling.gd
# "sfxManager": res://managers/audioManager/sfx/sfxManager.tscn
# "musicManager": res://managers/audioManager/music/musicManager.tscn
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const HEX_GRID_SIZE_X : int = 10
const HEX_GRID_SIZE_Y : int = 10

################################################################################
#### PUBLIC MEMBER VARIABLES ###################################################
################################################################################

# REMARK: Cannot be set at instantiation (e.g. when scene is switched); 
# has to be set afterwards (which requires an AutoLoad and a custom initialization 
# function called in _ready)
# see for example: https://forum.godotengine.org/t/transfering-a-variable-over-to-another-scene/33407/8
var context : String = "game::creative" # available: "game::default", "game::creative"

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _current_collision_object : Object

var _managerReferences : Dictionary
var _guiLayerReferences : Dictionary

var _error : int

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var hexGridManager : Object = $hexGridManager
onready var cameraManager : Object = $cameraManager
onready var tileDefinitionManager : Object = $tileDefinitionManager
onready var cppBridge : Object = $cppBridge
onready var settingsPopout : Object = $guiPopupCanvasLayer/PopupMenu/settings_popup_panelContainer

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
# REMARK: hardcoded for the case of only hitting a hex tile. 
# Other collisions like with trains have to be implemented differently!
func _on_raycast_result(current_collision_information : Array) -> void:
	hexGridManager.set_last_grid_index_to_current()
	if current_collision_information[0] != false:
		var collider_ref = current_collision_information[1]
		var collider_parent_object = collider_ref.get_parent()
		# REMARK: hardcoded for the case of only hitting a hex tile. 
		# Other collisions like with trains have to be implemented differently!
		# _current_tile_index = collider_parent_object.tile_index
		hexGridManager.set_current_grid_index(collider_parent_object.tile_index)
	else:
		hexGridManager.set_current_grid_index_out_of_bounds()

	if not hexGridManager.is_last_grid_index_equal_current():
		audioManager.play_sfx(["game", "tile", "move"])
		hexGridManager.move_floating_tile_and_highlight()

# func _on_user_settings_changed(settingKeychain : Array, setterType, settingValue) -> void:
# 	var _audioManagerSignalResult : Dictionary = userSettingsManager.update_user_settings(settingKeychain, setterType, settingValue)
# 	if _audioManagerSignalResult.has("keyChain"):
# 		audioManager.set_volume_level(_audioManagerSignalResult["keyChain"], _audioManagerSignalResult["value"])

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	# Initialize Reference Databases
	self._managerReferences = {
		"cameraManager": cameraManager,
		"tileDefinitionManager": tileDefinitionManager,
		"hexGridManager": hexGridManager,
		"cppBridge": cppBridge
	}

	self._guiLayerReferences = {
		"overlay": get_node("guiOverlayCanvasLayer"),
		"hidden": get_node("guiHiddenCanvasLayer"),
		"popup": get_node("guiPopupCanvasLayer")
	}

	# Initialize user settings
	userSettingsManager.initialize_user_settings()
	# _error = settingsPopout.connect("user_settings_changed", self, "_on_user_settings_changed")
	settingsPopout.slider_initialize(userSettingsManager.get_user_settings())
	settingsPopout.button_initialize(userSettingsManager.get_user_settings())

	# initialize audio manager singleton correctly and set the user sepcific volume levels
	audioManager.initialize_volume_levels(userSettingsManager.get_user_settings())

	# setting up all camera related stuff
	# TO-DO: Set starting position to the center of the grid
	_error = cameraManager.connect("raycast_result",self,"_on_raycast_result")

	# setting up the grid
	hexGridManager.set_current_grid_index(15)
	hexGridManager.generate_grid(self.HEX_GRID_SIZE_X, self.HEX_GRID_SIZE_Y)
	hexGridManager.manage_highlighting_due_to_cursor() # set the highlight correctly

	# initialize the C++-Bridge and the C++-Backend
	cppBridge.initialize_cpp_bridge(self.HEX_GRID_SIZE_X, self.HEX_GRID_SIZE_Y)
	cppBridge.pass_tile_definition_database_to_cpp_backend(tileDefinitionManager.get_tile_definition_database())
	cppBridge.initialize_grid_in_cpp_backend(0)

	# contextual logic
	var _scene2 : Resource = load("res://managers/userInputManager/game/game.tscn")
	var _contextualLogic =  _scene2.instance()
	add_child(_contextualLogic)
	_contextualLogic.initialize(self.context, self._managerReferences, self._guiLayerReferences)
	_contextualLogic.logic.initialize_floating_tile() # initialize the floating tile over the grid

	# Initialize User Input Manager
	UserInputManager.initialize(self.context, _contextualLogic, self._managerReferences, self._guiLayerReferences)
