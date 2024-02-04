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
var context : String = "game::creative"

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _last_collison_object : Object
var _current_collision_object : Object

var _tileSelector : Object

var _error : int

var _managerReferences : Dictionary
var _guiLayerReferences : Dictionary

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

func _on_user_settings_changed(settingKeychain : Array, setterType, settingValue) -> void:
	var _audioManagerSignalResult : Dictionary = userSettingsManager.update_user_settings(settingKeychain, setterType, settingValue)
	if _audioManagerSignalResult.has("keyChain"):
		audioManager.set_volume_level(_audioManagerSignalResult["keyChain"], _audioManagerSignalResult["value"])

func _on_new_tile_selected(_tile_definition_uuid : String) -> void:
	var _tile_definition = tileDefinitionManager.get_tile_definition_database_entry(_tile_definition_uuid) 
	hexGridManager.change_floating_tile_type(_tile_definition)

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	# Initialize Reference Databases
	self._managerReferences = {
		"cameraManager": cameraManager,
		"tileDefinitionManager": tileDefinitionManager,
		"hexGridManager": hexGridManager
	}

	self._guiLayerReferences = {
		"overlay": get_node("guiOverlayCanvasLayer"),
		"hidden": get_node("guiHiddenCanvasLayer"),
		"popup": get_node("guiPopupCanvasLayer")
	}

	# Initialize user settings
	userSettingsManager.initialize_user_settings()
	_error = settingsPopout.connect("user_settings_changed", self, "_on_user_settings_changed")
	settingsPopout.slider_initialize(userSettingsManager.get_user_settings())
	settingsPopout.button_initialize(userSettingsManager.get_user_settings())

	# initialize audio manager singleton correctly and set the user sepcific volume levels
	audioManager.initialize_volume_levels(userSettingsManager.get_user_settings())

	# setting up all camera related stuff
	# TO-DO: Set starting position to the center of the grid
	_error = cameraManager.connect("raycast_result",self,"_on_raycast_result")

	# setting up the grid
	# _current_tile_index = 15 # to set a position for the cursor; should be later adapted to be in the center of the grid
	hexGridManager.set_current_grid_index(15)
	hexGridManager.generate_grid(HEX_GRID_SIZE_X, HEX_GRID_SIZE_Y)
	hexGridManager.manage_highlighting_due_to_cursor() # set the highlight correctly

	# initialize the C++-Bridge and the C++-Backend
	cppBridge.initialize_cpp_bridge(HEX_GRID_SIZE_X, HEX_GRID_SIZE_Y)
	cppBridge.pass_tile_definition_database_to_cpp_backend(tileDefinitionManager.get_tile_definition_database())
	cppBridge.initialize_grid_in_cpp_backend(0)

	# # initialize UserInputManager (correct position)
	# UserInputManager.initialize(self.context, _managerReferences, _guiLayerReferences)
	# _error = UserInputManager.connect("new_tile_selected", self, "_on_new_tile_selected")

	# settings for creative mode (currently hardcoded, has to be made more flexible)
	var _scene = load("res://gui/overlays/creativeMode/creativeModeOverlay.tscn")
	var _instance = _scene.instance()
	get_node("guiOverlayCanvasLayer").add_child(_instance)
	var _creativeMode : Object = get_node("guiOverlayCanvasLayer/creativeModeOverlay")
	_tileSelector = get_node("guiOverlayCanvasLayer/creativeModeOverlay/tileSelector")
	_creativeMode.initialize_creative_mode_gui(self.context, self.tileDefinitionManager)

	# initialize the floating tile over the grid
	# Depends on the Mode
	var tile_definition_uuid = _tileSelector.selectedTile # cppBridge.request_next_tile_definition_uuid() # for testing the creative mode
	if tile_definition_uuid != "": 
		var tile_definition = tileDefinitionManager.get_tile_definition_database_entry(tile_definition_uuid) 
		hexGridManager.create_floating_tile(tile_definition)

	# REMARK: temporary position, until tile definition code is properly implemented!
	UserInputManager.initialize(self.context, _managerReferences, _guiLayerReferences)
	_error = UserInputManager.connect("new_tile_selected", self, "_on_new_tile_selected")

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
# func _process(_delta : float) -> void:
# 	if Input.is_action_just_pressed("place_tile"):
# 		if UserInputManager.get_current_gui_context() == "grid":
# 			if not hexGridManager.is_current_grid_index_out_of_bounds():
# 				var _floating_tile_status = hexGridManager.get_floating_tile_definition_uuid_and_rotation()
# 				var _is_tile_placeable = false
				
# 				if _floating_tile_status.has("TILE_DEFINITION_UUID"): # required to prevent issues when no floating tile exists
# 					_is_tile_placeable = true # cppBridge.can_tile_be_placed_here(_current_tile_index, _floating_tile_status["TILE_DEFINITION_UUID"], _floating_tile_status["rotation"]) # needs to be updated (Bridge + Backend)

# 				if _is_tile_placeable:
# 					hexGridManager.set_status_placeholder(true, false)
# 					hexGridManager.place_floating_tile()#_at_index(_current_tile_index)
# 					audioManager.play_sfx(["game", "tile", "success"])

# 					var _tile_definition_uuid = _tileSelector.selectedTile # cppBridge.request_next_tile_definition_uuid() # not required for creative mode
# 					if _tile_definition_uuid != "": 
# 						var _tile_definition = tileDefinitionManager.get_tile_definition_database_entry(_tile_definition_uuid) 
# 						hexGridManager.create_floating_tile(_tile_definition)
# 				else:
# 					hexGridManager.set_status_placeholder(false, true)
# 					audioManager.play_sfx(["game", "tile", "fail"])
			
	# # rotation of the tile
	# if Input.is_action_just_pressed("rotate_tile_clockwise"):
	# 	if UserInputManager.get_current_gui_context() == "grid":
	# 		hexGridManager.rotate_floating_tile_clockwise() # rotate tile
	# 		audioManager.play_sfx(["game", "tile", "rotate"])
			
	# 		if not hexGridManager.is_current_grid_index_out_of_bounds(): # safety to absolutely ensure that cursor is not out of grid bounds 
	# 			var _floating_tile_status = hexGridManager.get_floating_tile_definition_uuid_and_rotation()
				
	# 			if _floating_tile_status.has("TILE_DEFINITION_UUID"): # if a floating tile exists
	# 				# inquire at C++ Backend whether the tile would fit
	# 				var _is_tile_placeable : bool = true #cppBridge.check_whether_tile_would_fit(hexGridManager.get_current_grid_index(), _floating_tile_status["TILE_DEFINITION_UUID"], _floating_tile_status["rotation"])
					
	# 				# set the highlight according to the answer of the C++ Backend
	# 				if _is_tile_placeable:
	# 					hexGridManager.set_status_placeholder(true, false)
	# 				else:
	# 					hexGridManager.set_status_placeholder(false, true)

