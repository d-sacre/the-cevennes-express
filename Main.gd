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

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
var rng = RandomNumberGenerator.new()

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const HEX_GRID_SIZE_X : int = 10
const HEX_GRID_SIZE_Y : int = 10

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _last_collison_object 
var _current_collision_object 
var _last_tile_index : int = -1
var _current_tile_index : int = -1

var raycast_screenspace_position : Vector2 = Vector2(0,0)

var _creativeMode : Object
var _currentGuiMouseContext : String = "grid"

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var hexGridManager = $hexGridManager
onready var cameraManager = $cameraManager
onready var tileDefinitionManager = $tileDefinitionManager
onready var cppBridge = $cppBridge
onready var settingsPopout = $CanvasLayer/PopupMenu/settings_popup_panelContainer

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_raycast_result(current_collision_information):
	_last_tile_index = _current_tile_index
	if current_collision_information[0] != false:
		var collider_ref = current_collision_information[1]
		var collider_parent_object = collider_ref.get_parent()
		# REMARK: hardcoded for the case of only hitting a hex tile. 
		# Other collisions like with trains have to be implemented differently!
		_current_tile_index = collider_parent_object.tile_index
	else:
		_current_tile_index = -1

	if _current_tile_index != _last_tile_index:
		audioManager.play_sfx(["game", "tile", "move"])
		hexGridManager.manage_highlighting_due_to_cursor(_current_tile_index, _last_tile_index)
		hexGridManager.move_floating_tile_to(_current_tile_index)

func _on_user_settings_changed(settingKeychain, setterType, settingValue) -> void:
	var _audioManagerSignalResult : Dictionary = userSettingsManager.update_user_settings(settingKeychain, setterType, settingValue)
	if _audioManagerSignalResult.has("keyChain"):
		audioManager.set_volume_level(_audioManagerSignalResult["keyChain"], _audioManagerSignalResult["value"])

func _on_new_tile_selected(_tile_definition_uuid):
	hexGridManager.floating_tile_reference.queue_free()
	hexGridManager.floating_tile_reference = hexGridManager
	var tile_definition = tileDefinitionManager.get_tile_definition_database_entry(_tile_definition_uuid) 
	hexGridManager.create_tile_floating_over_grid(_current_tile_index,tile_definition)

func _on_gui_mouse_context_changed(context, status):
	match context:
		"tileSelector":
			if status == "entered":
				_currentGuiMouseContext = context
				cameraManager.disable_zooming()
				cameraManager.disable_raycasting()
			else:
				_currentGuiMouseContext = "grid"
				cameraManager.enable_zooming()
				cameraManager.enable_raycasting()

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready() -> void:
	userSettingsManager.initialize_user_settings()
	settingsPopout.connect("user_settings_changed", self, "_on_user_settings_changed")
	settingsPopout.slider_initialize(userSettingsManager.get_user_settings())
	settingsPopout.button_initialize(userSettingsManager.get_user_settings())

	# initialize audio manager singleton correctly and set the user sepcific volume levels
	audioManager.initialize_volume_levels(userSettingsManager.get_user_settings())

	# setting up all camera related stuff
	# TO-DO: Set starting position to the center of the grid
	cameraManager.connect("raycast_result",self,"_on_raycast_result")
	cameraManager.enable_raycasting()

	# setting up the grid
	_current_tile_index = 15 # to set a position for the cursor; should be later adapted to be in the center of the grid
	hexGridManager.generate_grid(HEX_GRID_SIZE_X, HEX_GRID_SIZE_Y)
	hexGridManager.manage_highlighting_due_to_cursor(_current_tile_index, _last_tile_index) # set the highlight correctly

	# initialize the C++-Bridge and the C++-Backend
	cppBridge.initialize_cpp_bridge(HEX_GRID_SIZE_X, HEX_GRID_SIZE_Y)
	cppBridge.pass_tile_definition_database_to_cpp_backend(tileDefinitionManager.tile_definition_database)
	cppBridge.initialize_grid_in_cpp_backend(0)

	# settings for creative mode (currently hardcoded, has to be made more flexible)
	var scene = load("res://gui/overlays/tileSelector/tileSelector.tscn")
	var instance = scene.instance()
	add_child(instance)
	_creativeMode = get_node("tileSelector")
	_creativeMode.connect("new_selection", self, "_on_new_tile_selected") # to get information of newly selected tile
	_creativeMode.connect("gui_mouse_context", self, "_on_gui_mouse_context_changed")

	# initialize the floating tile over the grid
	var tile_definition_uuid = _creativeMode.selectedTile # cppBridge.request_next_tile_definition_uuid() # for testing the creative mode
	if tile_definition_uuid != "": 
		var tile_definition = tileDefinitionManager.get_tile_definition_database_entry(tile_definition_uuid) 
		hexGridManager.create_tile_floating_over_grid(_current_tile_index,tile_definition)
	
# REMARK: Should be moved to userInputManager (when created)
func _input(event) -> void:
	if event is InputEventMouse:
		raycast_screenspace_position = event.position
		cameraManager.initiate_raycast_from_position(raycast_screenspace_position)

func _process(delta):
	if Input.is_action_just_pressed("place_tile"):
		if _currentGuiMouseContext == "grid":
			if _current_tile_index != -1:
				# print("place tile at ", _current_tile_index)

				var floating_tile_status = hexGridManager.get_floating_tile_definition_uuid_and_rotation()
				
				var tile_is_placeable = false
				
				if floating_tile_status.has("TILE_DEFINITION_UUID"): # required to prevent issues when no floating tile exists
					tile_is_placeable = true # cppBridge.can_tile_be_placed_here(_current_tile_index, floating_tile_status["TILE_DEFINITION_UUID"], floating_tile_status["rotation"]) # needs to be updated (Bridge + Backend)

				# print("tile is placeable: ", tile_is_placeable)

				if tile_is_placeable:
					hexGridManager.set_status_placeholder(_current_tile_index,true, false)
					hexGridManager.place_floating_tile_at_index(_current_tile_index)

					# test for sfx
					audioManager.play_sfx(["game", "tile", "success"])

					var tile_definition_uuid = _creativeMode.selectedTile # cppBridge.request_next_tile_definition_uuid() # not required for creative mode
					if tile_definition_uuid != "": 
						var tile_definition = tileDefinitionManager.get_tile_definition_database_entry(tile_definition_uuid) 
						hexGridManager.create_tile_floating_over_grid(_current_tile_index,tile_definition)
				else:
					hexGridManager.set_status_placeholder(_current_tile_index,false, true)
					# test for sfx
					audioManager.play_sfx(["game", "tile", "fail"])
			
	# rotation of the tile
	if Input.is_action_just_pressed("rotate_tile_clockwise"):
		if _currentGuiMouseContext == "grid":
			hexGridManager.rotate_floating_tile_clockwise() # rotate tile
			audioManager.play_sfx(["game", "tile", "rotate"])
			
			if _current_tile_index != -1: # safety to absolutely ensure that cursor is not out of grid bounds 
				var floating_tile_status = hexGridManager.get_floating_tile_definition_uuid_and_rotation()
				
				if floating_tile_status.has("TILE_DEFINITION_UUID"): # if a floating tile exists
					# inquire at C++ Backend whether the tile would fit
					var is_tile_placeable : bool = cppBridge.check_whether_tile_would_fit(_current_tile_index, floating_tile_status["TILE_DEFINITION_UUID"], floating_tile_status["rotation"])
					
					# set the highlight according to the answer of the C++ Backend
					if is_tile_placeable:
						hexGridManager.set_status_placeholder(_current_tile_index,true, false)
					else:
						hexGridManager.set_status_placeholder(_current_tile_index,false, true)

