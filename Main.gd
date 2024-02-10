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
onready var collisionManager : Object = $collisionManager
onready var settingsPopout : Object = $guiPopupCanvasLayer/PopupMenu/settings_popup_panelContainer

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	# Initialize Reference Databases
	self._managerReferences = {
		"cameraManager": cameraManager,
		"tileDefinitionManager": tileDefinitionManager,
		"hexGridManager": hexGridManager,
		"cppBridge": cppBridge,
		"collisionManager" : collisionManager
	}

	self._guiLayerReferences = {
		"overlay": get_node("guiOverlayCanvasLayer"),
		"hidden": get_node("guiHiddenCanvasLayer"),
		"popup": get_node("guiPopupCanvasLayer")
	}

	# Initialize user settings
	userSettingsManager.initialize_user_settings()

	print("\n<CONTEXT>\n=> Initializing a Game in \"", self.context.trim_prefix("game::"), "\" Mode...")
	
	# initialize the C++-Bridge and the C++-Backend
	print("\t-> Initialize C++ Backend...")
	cppBridge.initialize_cpp_bridge(self.HEX_GRID_SIZE_X, self.HEX_GRID_SIZE_Y)
	cppBridge.pass_tile_definition_database_to_cpp_backend(tileDefinitionManager.get_tile_definition_database())
	cppBridge.initialize_grid_in_cpp_backend(0)
	
	# setting up the grid
	print("\t-> Initialize hexGridManager...")
	hexGridManager.set_current_grid_index(15)
	hexGridManager.set_last_index_within_grid_boundary(15)
	hexGridManager.set_highlight_persistence("void", true)
	hexGridManager.load_rotation_persistence_default(self.context.trim_prefix("game::"))
	hexGridManager.generate_grid(self.HEX_GRID_SIZE_X, self.HEX_GRID_SIZE_Y)
	hexGridManager.manage_highlighting_due_to_cursor() # set the highlight correctly

	# Initialize collisionManager
	print("\t-> Initialize collisionManager...")
	collisionManager.initialize(self.context, self._managerReferences)

	# contextual logic
	print("\t-> Configure UserInputManager...")
	print("\t\t-> Load Game Variant specific Contextual Logic...")
	var _scene2 : Resource = load("res://managers/userInputManager/game/game.tscn")
	var _contextualLogic =  _scene2.instance()
	add_child(_contextualLogic)
	_contextualLogic.initialize(self.context, self._managerReferences, self._guiLayerReferences)
	_contextualLogic.logic.initialize_floating_tile() # initialize the floating tile over the grid

	# Initialize User Input Manager
	print("\t\t-> Initialize UserInputManager")
	UserInputManager.initialize(self.context, "mouse::keyboard::mixed", _contextualLogic, self._managerReferences, self._guiLayerReferences)

	# initialize audio manager singleton correctly and set the user sepcific volume levels
	print("\t-> Initialize AudioManager...")
	audioManager.initialize_volume_levels(userSettingsManager.get_user_settings())

	print("\t-> Initialize GUI...")
	settingsPopout.slider_initialize(userSettingsManager.get_user_settings())
	settingsPopout.button_initialize(userSettingsManager.get_user_settings())

	# Initialize debug
	$guiPopupCanvasLayer/debugPanelContainer.initialize(self._managerReferences)
