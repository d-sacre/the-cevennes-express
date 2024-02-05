extends Node

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# The scene this script is attached to is autoloaded as "UserInputManager".    #
################################################################################

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
# signal new_tile_selected(_tile_definition_uuid)

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
func _hide_gui(status : bool) -> void:
	match self.variant:
		"creative":
			self._guiLayerReferences["overlay"].visible = not status

	if status:
		self._currentGuiMouseContext = "grid"
		self._managerReferences["cameraManager"].enable_zooming()
		self._managerReferences["cameraManager"].enable_raycasting()

		var _scene = load("res://gui/overlays/creativeMode/hiddenGUI/hiddenGUI.tscn")
		var _instance = _scene.instance()
		_instance.initialize(self.context)
		self._guiLayerReferences["hidden"].add_child(_instance)
		
	else:
		match self.variant:
			"creative":
				self._guiLayerReferences["overlay"].get_node("creativeModeOverlay").set_creative_mode_gui_to_default()

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(_base_context : String, mr : Dictionary, glr : Dictionary) -> void:
	self._managerReferences = mr
	self._guiLayerReferences = glr
	self.context = _base_context

	var _base_context_list : Array = self.context.split(self.TCE_SIGNALING_UUID_SEPERATOR)
	self.base = _base_context_list[0]

	if self.base == "game":
		self.variant = _base_context_list[1]
		self._managerReferences["cameraManager"].enable_raycasting()
		self._currentGuiMouseContext = "grid"

		if self.variant == "creative":
			self._logic = game_creative.new(self._managerReferences)

		# REMARK: Only temporary, until proper tile definition contextual logic is implemented
		var _tmp = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
		if _tmp.has("TILE_DEFINITION_UUID"):
			self._curentTileDefinitionUUID = _tmp["TILE_DEFINITION_UUID"]

func create_tce_signaling_uuid(ctxt : String, keyChain : Array) -> String:
	var _tmpString : String =  ctxt + self.TCE_SIGNALING_UUID_SEPERATOR
	var _keyChainLength : int = len(keyChain)

	for _i in range(_keyChainLength):
		_tmpString += keyChain[_i]
		if _i != _keyChainLength - 1:
			_tmpString +=  self.TCE_SIGNALING_UUID_SEPERATOR

	return _tmpString

func get_current_gui_context() -> String:
	return self._currentGuiMouseContext

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_gui_selector_context_changed(tce_signaling_uuid : String, interaction : String) -> void:
	# print("<User Input Manager :: gui> received ", tce_signaling_uuid, " with status ", interaction)
	if tce_signaling_uuid.match("game::creative::gui::*"):
		var _subuuid : String = tce_signaling_uuid.trim_prefix("game::creative::gui::")
		if _subuuid.match("sidepanel::right::selector::tile::definition"):
			if interaction == "entered":
				self._currentGuiMouseContext = tce_signaling_uuid
				self._managerReferences["cameraManager"].disable_zooming()
				self._managerReferences["cameraManager"].disable_raycasting()
			else:
				self._currentGuiMouseContext = "grid"
				self._managerReferences["cameraManager"].enable_zooming()
				self._managerReferences["cameraManager"].enable_raycasting()
		elif _subuuid.match("hud::selector::action"):
			if interaction == "entered":
				self._currentGuiMouseContext = tce_signaling_uuid
				self._managerReferences["cameraManager"].disable_zooming()
				self._managerReferences["cameraManager"].disable_raycasting()
			else:
				self._currentGuiMouseContext = "grid"
				self._managerReferences["cameraManager"].enable_zooming()
				self._managerReferences["cameraManager"].enable_raycasting()
	else:
		print("Error: <tce_signaling_uuid> ",tce_signaling_uuid, " could not be processed!")
	

func _on_user_selected(tce_signaling_uuid : String, value : String) -> void:
	# print("<User Input Manager :: user selected> received ", tce_signaling_uuid, " with value: ", value)
	
	# REMARK: very simplified code hardcoded for game::creative only;
	# Needs to be generalized and modularized!
	if tce_signaling_uuid.match("game::creative::user::selected::*"):
		var _subuuid : String = tce_signaling_uuid.trim_prefix("game::creative::user::selected::")

		if _subuuid.match("tile::*"):
			var _subsubuuid : String = _subuuid.trim_prefix("tile::")

			if _subsubuuid.match("action::*"):
				var _subsubsubuuid : String = _subsubuuid.trim_prefix("action::")
			
				match _subsubsubuuid:
					"place":
						print("place")
					"replace":
						pass
					"pick":
						pass
					"delete":
						pass
			
			elif _subsubuuid.match("definition"):
				# emit_signal("new_tile_selected", value)
				var _tile_definition = self._managerReferences["tileDefinitionManager"].get_tile_definition_database_entry(value) 
				self._managerReferences["hexGridManager"].change_floating_tile_type(_tile_definition)
				self._curentTileDefinitionUUID = value

		elif _subuuid.match("gui::hide"):
			print("Hide GUI: ", true)
			self._hide_gui(true)

		elif _subuuid.match("gui::show"):
			self._hide_gui(false)
	else:
		print("Error: <tce_signaling_uuid> ",tce_signaling_uuid, " could not be processed!")

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	print("\t-> Initialize UserInputManager...")

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
# TO-DO: Needs to be outsourced into gameHandler 
# REMARKS: Logic can be improved if _currentGuiMouseContext = "grid" -> "game::creative::gui::grid"
# Then the following would be possible: if _currentGuiMouseContext.match("game::*::gui::grid"):
# which would be independent of the game variant, but also more precise than if self.base == "game":
func _input(event : InputEvent) -> void:
	# mouse position (floating (tile) position)
	if event is InputEventMouse:
		if self.base == "game":
			self._managerReferences["cameraManager"].initiate_raycast_from_position(event.position)
	
	# mouse scroll (camera zooming)
	if event is InputEventMouseButton:
		if self.base == "game":
			if event.button_index == BUTTON_WHEEL_UP and event.pressed:
				self._managerReferences["cameraManager"].request_zoom_out()
			if event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
				self._managerReferences["cameraManager"].request_zoom_in()
	
	# camera movement speed modifier
	if event is InputEventKey and event.pressed:
		if event.shift:
			self._managerReferences["cameraManager"].set_movement_speed_mode("fast")
		else:
			self._managerReferences["cameraManager"].set_movement_speed_mode("slow")

func _process(_delta : float) -> void:
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

	if Input.is_action_just_pressed("place_tile"):
		if UserInputManager.get_current_gui_context() == "grid":
			self._logic.place_tile()
		# 	if not self._managerReferences["hexGridManager"].is_current_grid_index_out_of_bounds():
		# 		var _floating_tile_status = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
		# 		var _is_tile_placeable = false
				
		# 		if _floating_tile_status.has("TILE_DEFINITION_UUID"): # required to prevent issues when no floating tile exists
		# 			_is_tile_placeable = true # cppBridge.can_tile_be_placed_here(_current_tile_index, _floating_tile_status["TILE_DEFINITION_UUID"], _floating_tile_status["rotation"]) # needs to be updated (Bridge + Backend)

		# 		if _is_tile_placeable:
		# 			self._managerReferences["hexGridManager"].set_status_placeholder(true, false)
		# 			self._managerReferences["hexGridManager"].place_floating_tile()#_at_index(_current_tile_index)
		# 			audioManager.play_sfx(["game", "tile", "success"])
					
		# 			# REMARK: Only temporary solution, until proper logic separation into different variants is in place!
		# 			var _tile_definition_uuid = self._curentTileDefinitionUUID # cppBridge.request_next_tile_definition_uuid() # not required for creative mode

		# 			if _tile_definition_uuid != "": 
		# 				var _tile_definition = self._managerReferences["tileDefinitionManager"].get_tile_definition_database_entry(_tile_definition_uuid) 
		# 				self._managerReferences["hexGridManager"].create_floating_tile(_tile_definition)
		# 		else:
		# 			self._managerReferences["hexGridManager"].set_status_placeholder(false, true)
		# 			audioManager.play_sfx(["game", "tile", "fail"])
			
	# rotation of the tile
	if Input.is_action_just_pressed("rotate_tile_clockwise"):
		if UserInputManager.get_current_gui_context() == "grid":
			self._logic.rotate_tile_clockwise()
			# self._managerReferences["hexGridManager"].rotate_floating_tile_clockwise() # rotate tile
			# audioManager.play_sfx(["game", "tile", "rotate"])
			
			# if not self._managerReferences["hexGridManager"].is_current_grid_index_out_of_bounds(): # safety to absolutely ensure that cursor is not out of grid bounds 
			# 	var _floating_tile_status = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
				
			# 	if _floating_tile_status.has("TILE_DEFINITION_UUID"): # if a floating tile exists
			# 		# inquire at C++ Backend whether the tile would fit
			# 		var _is_tile_placeable : bool = true #cppBridge.check_whether_tile_would_fit(self._managerReferences["hexGridManager"].get_current_grid_index(), _floating_tile_status["TILE_DEFINITION_UUID"], _floating_tile_status["rotation"])
					
			# 		# set the highlight according to the answer of the C++ Backend
			# 		if _is_tile_placeable:
			# 			self._managerReferences["hexGridManager"].set_status_placeholder(true, false)
			# 		else:
			# 			self._managerReferences["hexGridManager"].set_status_placeholder(false, true)
	
