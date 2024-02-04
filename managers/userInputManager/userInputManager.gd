extends Node

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# The scene this script is attached to is autoloaded as "UserInputManager".    #
################################################################################

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal new_tile_selected(_tile_definition_uuid)

# # Definition of global user interaction signals
# signal button_interaction(tce_signaling_uuid, object_type, interaction_type)
# signal user_changed_string(tce_signaling_uuid, object_type, value)
# signal user_changed_float(tce_signaling_uuid, object_type, value)
# signal user_changed_integer(tce_signaling_uuid, object_type, value)
# signal gui_selector_context_changed(tce_signaling_uuid, interaction_type)

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
var currentGuiMouseContext : String 

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _managerReferences : Dictionary = {}

var _guiLayerReferences : Dictionary = {}

var _lastCameraMovementRequest : Vector2 = Vector2(0,0)

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _hide_gui(status : bool) -> void:
	match self.variant:
		"creative":
			self._guiLayerReferences["overlay"].visible = not status

	if status:
		self.currentGuiMouseContext = "grid"
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
# func initialize(_base_context : String, cm : Object, tdm : Object, hgm : Object, gocl : Object, gpucl : Object) -> void:
	# # TO-DO: needs to be rewritten in such form that two dictionaries are passed as arguments.
	# # Otherwise this approach is not really modular/adaptable to main menu
	# self._managerReferences["cameraManager"] = cm
	# self._managerReferences["tileDefinitionManager"] = tdm
	# self._managerReferences["hexGridManager"] = hgm
	# self._guiLayerReferences["overlay"] = gocl
	# self._guiLayerReferences["popup"] = gpucl

func initialize(_base_context : String, mr : Dictionary, glr : Dictionary) -> void:
	self._managerReferences = mr
	self._guiLayerReferences = glr
	self.context = _base_context

	var _base_context_list : Array = self.context.split(self.TCE_SIGNALING_UUID_SEPERATOR)
	self.base = _base_context_list[0]

	if self.base == "game":
		self.variant = _base_context_list[1]
		self._managerReferences["cameraManager"].enable_raycasting()

	if self.variant == "creative":
		self.currentGuiMouseContext = "grid"

func create_tce_signaling_uuid(ctxt : String, keyChain : Array) -> String:
	var _tmpString : String =  ctxt + self.TCE_SIGNALING_UUID_SEPERATOR
	var _keyChainLength : int = len(keyChain)

	for i in range(_keyChainLength):
		_tmpString += keyChain[i]
		if i != _keyChainLength - 1:
			_tmpString +=  self.TCE_SIGNALING_UUID_SEPERATOR

	return _tmpString

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_gui_selector_context_changed(tce_signaling_uuid : String, interaction : String) -> void:
	# print("<User Input Manager :: gui> received ", tce_signaling_uuid, " with status ", interaction)
	if tce_signaling_uuid.match("game::creative::gui::*"):
		var _subuuid : String = tce_signaling_uuid.trim_prefix("game::creative::gui::")
		if _subuuid.match("sidepanel::right::selector::tile::definition"):
			if interaction == "entered":
				currentGuiMouseContext = tce_signaling_uuid
				_managerReferences["cameraManager"].disable_zooming()
				_managerReferences["cameraManager"].disable_raycasting()
			else:
				currentGuiMouseContext = "grid"
				_managerReferences["cameraManager"].enable_zooming()
				_managerReferences["cameraManager"].enable_raycasting()
		elif _subuuid.match("hud::selector::action"):
			if interaction == "entered":
				currentGuiMouseContext = tce_signaling_uuid
				_managerReferences["cameraManager"].disable_zooming()
				_managerReferences["cameraManager"].disable_raycasting()
			else:
				currentGuiMouseContext = "grid"
				_managerReferences["cameraManager"].enable_zooming()
				_managerReferences["cameraManager"].enable_raycasting()
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
				emit_signal("new_tile_selected", value)

		elif _subuuid.match("gui::hide"):
			print("Hide GUI: ", true)
			_hide_gui(true)

		elif _subuuid.match("gui::show"):
			_hide_gui(false)
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
# REMARKS: Logic can be improved if currentGuiMouseContext = "grid" -> "game::creative::gui::grid"
# Then the following would be possible: if currentGuiMouseContext.match("game::*::gui::grid"):
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
				_managerReferences["cameraManager"].request_zoom_out()
			if event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
				_managerReferences["cameraManager"].request_zoom_in()
	
	# camera movement speed modifier
	if event is InputEventKey and event.pressed:
		if event.shift:
			_managerReferences["cameraManager"].set_movement_speed_mode("fast")
		else:
			_managerReferences["cameraManager"].set_movement_speed_mode("slow")

func _process(_delta : float) -> void:
	if self.base == "game":
		# checking for camera movement request
		var _cameraMovementRequest : Vector2 = Vector2(
			Input.get_action_strength("camera_move_left") - Input.get_action_strength("camera_move_right"),
				Input.get_action_strength("camera_move_forward") - Input.get_action_strength("camera_move_backward")
		)

		# to reduce the amount of unnecessary function calls when no camera movement is requested
		if _lastCameraMovementRequest != _cameraMovementRequest:
			_managerReferences["cameraManager"].request_movement(_cameraMovementRequest)
			_lastCameraMovementRequest = _cameraMovementRequest
