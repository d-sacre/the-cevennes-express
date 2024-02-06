extends Node

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# The scene this script is attached to is autoloaded as "UserInputManager".    #
################################################################################

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
# TO-DO: should be moved into another autoload, so that other parts can access
# it in a more logical/orderly manner
const TCE_SIGNALING_UUID_SEPERATOR : String = "::" 

################################################################################
#### PUBLIC MEMBER VARIABLES ###################################################
################################################################################
var context : String
var base : String
var variant : String

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _managerReferences : Dictionary = {}
var _guiLayerReferences : Dictionary = {}

var _currentGuiMouseContext : String 
var _lastCameraMovementRequest : Vector2 = Vector2(0,0) # REMARK: only temporarily; has to be replaced with proper logic

var _curentTileDefinitionUUID : String = "" # REMARK: only temporarily; has to be replaced with proper logic

var _logic 

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _create_string_with_tce_signaling_uuid_seperator(keyChain : Array) -> String:
	var _tmpString : String = ""
	var _keyChainLength : int = len(keyChain)

	for _i in range(_keyChainLength):
		_tmpString += keyChain[_i]
		if _i != _keyChainLength - 1:
			_tmpString +=  self.TCE_SIGNALING_UUID_SEPERATOR

	return _tmpString

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(_base_context : String, clr : Object, mr : Dictionary, glr : Dictionary) -> void:
	self._managerReferences = mr
	self._guiLayerReferences = glr
	self.context = _base_context
	self._logic = clr.logic 

	var _base_context_list : Array = self.context.split(self.TCE_SIGNALING_UUID_SEPERATOR)
	self.base = _base_context_list[0]

	if self.base == "game":
		self.variant = _base_context_list[1]
		self._managerReferences["cameraManager"].enable_raycasting()
		self._currentGuiMouseContext = self.context + UserInputManager.TCE_SIGNALING_UUID_SEPERATOR+ "grid"	

		# REMARK: Only temporary, until proper tile definition contextual logic is implemented
		# Could it cause the issue of overwriting other settings?
		var _tmp = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
		if _tmp.has("TILE_DEFINITION_UUID"):
			self._curentTileDefinitionUUID = _tmp["TILE_DEFINITION_UUID"]

func create_tce_signaling_uuid(ctxt : String, keyChain : Array) -> String:
	var _tmpString : String =  ctxt + self.TCE_SIGNALING_UUID_SEPERATOR
	# var _keyChainLength : int = len(keyChain)

	# for _i in range(_keyChainLength):
	# 	_tmpString += keyChain[_i]
	# 	if _i != _keyChainLength - 1:
	# 		_tmpString +=  self.TCE_SIGNALING_UUID_SEPERATOR

	_tmpString += self._create_string_with_tce_signaling_uuid_seperator(keyChain)

	return _tmpString

func match_tce_signaling_uuid(tce_signaling_uuid : String, keyChain : Array) -> bool:
	var _tmpString = self._create_string_with_tce_signaling_uuid_seperator(keyChain)
	return tce_signaling_uuid.match(_tmpString)

# REMARK: Removed typesafety for value to be more flexible and require less signals/parsing logic
func call_contextual_logic_with_custom_tce_signaling_uuid(keyChain : Array, value) -> void:
	var _tmp_signaling_uuid : String = self.create_tce_signaling_uuid(self.context, keyChain)
	self._logic.user_input_pipeline(_tmp_signaling_uuid, value)

func get_current_gui_context() -> String:
	return self._currentGuiMouseContext

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_gui_selector_context_changed(tce_signaling_uuid : String, interaction : String) -> void:
	_logic.gui_management_pipeline(tce_signaling_uuid, interaction)

# REMARK: Removed typesafety for value to be more flexible and require less signals/parsing logic
func _on_user_selected(tce_signaling_uuid : String, value) -> void:
	_logic.user_input_pipeline(tce_signaling_uuid, value)

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	print("\t-> Initialize UserInputManager...")

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _input(event : InputEvent) -> void:
	# REMARK: Temporary Limitation to "game" context required until Main Menu is updated!
	if self.base == "game": # temporary!
		# mouse position (floating (tile) position)
		if event is InputEventMouse:
			var _tmp_signaling_keychain : Array = ["user", "interaction", "mouse", "movement"]
			# self.call_contextual_logic_with_custom_tce_signaling_uuid(_tmp_signaling_keychain, str(event.position))
			self.call_contextual_logic_with_custom_tce_signaling_uuid(_tmp_signaling_keychain, event.position)
		
		# mouse scroll (camera zooming)
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_WHEEL_UP and event.pressed:
				var _tmp_signaling_keychain : Array = ["user", "interaction", "mouse", "wheel", "up"]
				self.call_contextual_logic_with_custom_tce_signaling_uuid(_tmp_signaling_keychain, "pressed")

			if event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
				var _tmp_signaling_keychain : Array = ["user", "interaction", "mouse", "wheel", "down"]
				self.call_contextual_logic_with_custom_tce_signaling_uuid(_tmp_signaling_keychain, "pressed")
		
		# camera movement speed modifier
		if event is InputEventKey and event.pressed:
			if event.shift:
				self._managerReferences["cameraManager"].set_movement_speed_mode("fast")
			else:
				self._managerReferences["cameraManager"].set_movement_speed_mode("slow")

func _process(_delta : float) -> void:
	# REMARK: Cannot be outsourced into game logic, since _process not working in the classes
	if self.base == "game":
		# checking for camera movement request
		var _cameraMovementRequest : Vector2 = Vector2(
			Input.get_action_strength("camera_move_left") - Input.get_action_strength("camera_move_right"),
				Input.get_action_strength("camera_move_forward") - Input.get_action_strength("camera_move_backward")
		)

		# to reduce the amount of unnecessary function calls when no camera movement is requested
		if self._lastCameraMovementRequest != _cameraMovementRequest:
			self._managerReferences["cameraManager"].request_movement(_cameraMovementRequest)
			self._lastCameraMovementRequest = _cameraMovementRequest

		# REMARK: Temporary restriction to "game" base necessary to avoid issues with the Main Menu. Can be chnaged
		# after Main Menu has been replaced
		if Input.is_action_just_pressed("place_tile"):
			var _tmp_signaling_keychain : Array = ["user", "interaction", "mouse", "click", "left"]
			self.call_contextual_logic_with_custom_tce_signaling_uuid(_tmp_signaling_keychain, "just_pressed")
				
		# rotation of the tile
		if Input.is_action_just_pressed("rotate_tile_clockwise"):
			var _tmp_signaling_keychain : Array = ["user", "interaction", "mouse", "click", "right"]
			self.call_contextual_logic_with_custom_tce_signaling_uuid(_tmp_signaling_keychain, "just_pressed")
	
