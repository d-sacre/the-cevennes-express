class_name game_base

################################################################################
################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn
# "audioManager": res://managers/audioManager/audioManager.tscn

################################################################################
################################################################################
#### IMPORTANT REMARKS #########################################################
################################################################################
################################################################################
# It is not possible to specify an override for the _process() function, as it 
# does not seem to be run, even after the class being properly initialized 

################################################################################
################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
################################################################################
var _managerReferences : Dictionary = {}
var _guiLayerReferences : Dictionary = {}
var _context : String

var _tileDefinitionUuid : String = "" # REMARK: Not a good solution; could crash the game if the function is not properly overwritten
var _currentGuiMouseContext : String 

const _separator : String = UserInputManager.TCE_SIGNALING_UUID_SEPERATOR

################################################################################
################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
################################################################################
# REMARK: Private functions in the sense as they should neither be accessed nor
# changed outside of the parent class or inherited classes

################################################################################
#### PRIVATE MEMBER FUNCTIONS: SETTER AND GETTER ###############################
################################################################################
func _get_next_tile_definition_uuid() -> String:
	# REMARK: Not a good solution; could crash the game if the function is not properly overwritten
	return self._tileDefinitionUuid

func _get_floating_tile_status() -> Dictionary:
	var _dict : Dictionary = {}
	if not self._managerReferences["hexGridManager"].is_current_grid_index_out_of_bounds():
		 _dict = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()

	return _dict

################################################################################
#### PRIVATE MEMBER FUNCTIONS: BOOL EXPRESSIONS ################################
################################################################################
func _is_tile_placeable() -> bool:
	return false

func _is_tile_placeable_with_current_rotation() -> bool:
	return false

func _is_tce_signaling_uuid_matching(tce_signaling_uuid : String, keyChain : Array) -> bool:
	return UserInputManager.match_tce_signaling_uuid(tce_signaling_uuid, keyChain)

################################################################################
#### PRIVATE MEMBER FUNCTIONS: BOOL EVENTS #####################################
################################################################################
func _is_mouse_event(tce_signaling_uuid : String) -> bool: 
	if self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*", "user", "interaction", "*"]):
		if self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*", "mouse", "*"]):
			return true

	return false

func _is_input_event_confirm(tce_signaling_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_signaling_uuid,["*", "user", "interaction", "confirm"])

func _is_input_event_option_general(tce_signaling_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*", "user", "interaction", "option", "general"])

func _is_input_event_modifier(tce_signaling_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*","user", "interaction", "modifier"])

################################################################################
#### PRIVATE MEMBER FUNCTIONS: BOOL CONTEXT ####################################
################################################################################
func _is_correct_context_for_placing_tile(tce_signaling_uuid : String) -> bool:
	return self._is_input_event_confirm(tce_signaling_uuid) and self._is_current_gui_context_grid()

func _is_correct_context_for_rotating_tile_clockwise(tce_signaling_uuid : String) -> bool:
	return self._is_input_event_option_general(tce_signaling_uuid) and self._is_current_gui_context_grid()

func _is_correct_context_for_zooming(tce_signaling_uuid : String) -> bool:
	if (self._is_current_gui_context_grid()) or (self._currentGuiMouseContext.match("*void")):
		if self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*", "user", "interaction", "scroll", "*"]):
			return true

	return false

func _is_current_gui_context_grid() -> bool:
	return self._currentGuiMouseContext.match("*" + self._separator + "grid")

func _is_correct_context_for_movement_channel1(tce_signaling_uuid : String) -> bool:
	return self._is_tce_signaling_uuid_matching(tce_signaling_uuid,["*", "user", "interaction", "movement", "channel1"])

################################################################################
#### PRIVATE MEMBER FUNCTIONS: TILE MANIPULATION ###############################
################################################################################
func change_floating_tile_type() -> void:
	var tile_definition_uuid = self._get_next_tile_definition_uuid()
	if tile_definition_uuid != "": 
		var tile_definition = self._managerReferences["tileDefinitionManager"].get_tile_definition_database_entry(tile_definition_uuid) 
		self._managerReferences["hexGridManager"].change_floating_tile_type(tile_definition)

func rotate_tile_clockwise() -> void:
	self._managerReferences["hexGridManager"].rotate_floating_tile_clockwise() # rotate tile
	audioManager.play_sfx(["game", "tile", "rotate"])
	
	if not self._managerReferences["hexGridManager"].is_current_grid_index_out_of_bounds(): # safety to absolutely ensure that cursor is not out of grid bounds 
		var _floating_tile_status = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
		
		if _floating_tile_status.has("TILE_DEFINITION_UUID"): # if a floating tile exists
			# inquire at C++ Backend whether the tile would fit
			var _is_placeable : bool = self._is_tile_placeable_with_current_rotation()
			
			# set the highlight according to the answer of the C++ Backend
			if _is_placeable:
				self._managerReferences["hexGridManager"].set_status_placeholder(true, false)
			else:
				self._managerReferences["hexGridManager"].set_status_placeholder(false, true)

func place_tile() -> void:
	if not self._managerReferences["hexGridManager"].is_current_grid_index_out_of_bounds():
		var _floating_tile_status : Dictionary = self._managerReferences["hexGridManager"].get_floating_tile_definition_uuid_and_rotation()
		var _is_placeable : bool = false
		
		if _floating_tile_status.has("TILE_DEFINITION_UUID"): # required to prevent issues when no floating tile exists
			_is_placeable = self._is_tile_placeable()

		if _is_placeable:
			self._managerReferences["hexGridManager"].set_status_placeholder(true, false)
			self._managerReferences["hexGridManager"].place_floating_tile()
			audioManager.play_sfx(["game", "tile", "success"])
			
			self._create_new_floating_tile()
			
		else:
			self._managerReferences["hexGridManager"].set_status_placeholder(false, true)
			audioManager.play_sfx(["game", "tile", "fail"])

################################################################################
#### PRIVATE MEMBER FUNCTIONS: TOOLS ###########################################
################################################################################
func _hide_gui(_status : bool) -> void:
	pass

func _create_new_floating_tile() -> void:
	var _tile_definition_uuid : String = self._get_next_tile_definition_uuid()

	if _tile_definition_uuid != "": 
		var _tile_definition = self._managerReferences["tileDefinitionManager"].get_tile_definition_database_entry(_tile_definition_uuid) 
		self._managerReferences["hexGridManager"].create_floating_tile(_tile_definition)

################################################################################
################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
################################################################################
func initialize_floating_tile() -> void:
	var tile_definition_uuid = self._get_next_tile_definition_uuid()
	if tile_definition_uuid != "": 
		var tile_definition = self._managerReferences["tileDefinitionManager"].get_tile_definition_database_entry(tile_definition_uuid) 
		self._managerReferences["hexGridManager"].create_floating_tile(tile_definition)

func update_tile_definition_uuid(uuid : String) -> void:
	self._tileDefinitionUuid = uuid

################################################################################
#### PUBLIC MEMBER FUNCTIONS: USER INPUT PIPELINE ##############################
################################################################################
# REMARK: Removed typesafety for value to be more flexible and require less signals/parsing logic
func user_input_pipeline(tce_signaling_uuid : String, value) -> void: 
	if self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["game", "*"]): # Safety to ensure that only valid requests are processed
		if self._is_correct_context_for_placing_tile(tce_signaling_uuid):
			self.place_tile()

		if self._is_correct_context_for_rotating_tile_clockwise(tce_signaling_uuid):
			self.rotate_tile_clockwise()

		if self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*", "user", "selected", "gui", "show"]):
			self._hide_gui(false)
		
		if self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*", "user", "selected", "gui", "hide"]):
			self._hide_gui(true)

		if self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*", "user", "interaction", "mouse", "movement"]):
			if value is Vector2:
				self._managerReferences["cameraManager"].initiate_raycast_from_position(value)
			else:
				print("Error: Variable type does not match")

		if self._is_correct_context_for_movement_channel1(tce_signaling_uuid):
			if value is Vector2:
				self._managerReferences["cameraManager"].request_movement(value)

		if self._is_input_event_modifier(tce_signaling_uuid):
			if value is String:
				if value == "just_pressed":
					self._managerReferences["cameraManager"].set_movement_speed_mode("fast")
				else:
					self._managerReferences["cameraManager"].set_movement_speed_mode("slow")

		if self._is_correct_context_for_zooming(tce_signaling_uuid):
			if self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*", "up"]):
				self._managerReferences["cameraManager"].request_zoom_out()
			elif self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*", "down"]):
				self._managerReferences["cameraManager"].request_zoom_in()

		# if self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*", "user", "interaction", "mouse", "wheel", "*"]):
		# 	if self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*", "up"]):
		# 		if (self._is_current_gui_context_grid()) or (self._currentGuiMouseContext.match("*void")):
		# 			self._managerReferences["cameraManager"].request_zoom_out()

		# 	elif self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*", "down"]):
		# 		if (self._is_current_gui_context_grid()) or (self._currentGuiMouseContext.match("*void")):
		# 			self._managerReferences["cameraManager"].request_zoom_in()

		if self._is_tce_signaling_uuid_matching(tce_signaling_uuid, ["*","internal", "collision", "detected"]):
			if value is Dictionary:
				if value.has("colliding"):
					var _tmp_collision_status = value["colliding"]["status"]

					# REMARK: Required to set highlighting correctly. But might this be the culprit 
					# for the "placement and removal of floating tile at index 0 when new tile definition is selected" bug?
					self._managerReferences["hexGridManager"].set_last_grid_index_to_current()

					# REMARK: Hardcoded for the case of only hitting a hex tile. 
					# Other collisions like with trains have to be implemented differently!
					if _tmp_collision_status:
						self._managerReferences["hexGridManager"].set_current_grid_index(value["grid_index"])
						self._managerReferences["hexGridManager"].set_last_index_within_grid_boundary_to_current()
						self._currentGuiMouseContext = self._context + UserInputManager.TCE_SIGNALING_UUID_SEPERATOR + "grid"
					else:
						self._managerReferences["hexGridManager"].set_current_grid_index_out_of_bounds()
						self._currentGuiMouseContext = self._context + UserInputManager.TCE_SIGNALING_UUID_SEPERATOR + "void"

					if not self._managerReferences["hexGridManager"].is_last_grid_index_equal_current():
						audioManager.play_sfx(["game", "tile", "move"])
						self._managerReferences["hexGridManager"].move_floating_tile_and_highlight()
	else:
		pass
		# REMARK: Disabled for the time being until Main Menu is updated to prevent enormous amount of printing
		# print("Error: <TCE_SIGNALING_UUID|",tce_signaling_uuid, "> could not be processed!")

################################################################################
#### PUBLIC MEMBER FUNCTIONS: GUI MANAGEMENT PIPELINE ##########################
################################################################################
func gui_management_pipeline(tce_signaling_uuid : String, _value : String) -> void:
	if tce_signaling_uuid.match("game" + self._separator + "*" + self._separator + "gui" + self._separator + "*"):
		pass
	else:
		pass
		# REMARK: Disabled for the time being until Main Menu is updated to prevent enormous amount of printing
		# print("Error: <TCE_SIGNALING_UUID|",tce_signaling_uuid, "> could not be processed!")

################################################################################
################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
################################################################################
func _init(ctxt : String, mr : Dictionary, glr : Dictionary) -> void:
	self._context = ctxt
	self._managerReferences = mr
	self._currentGuiMouseContext = self._context + UserInputManager.TCE_SIGNALING_UUID_SEPERATOR + "grid"
	self._guiLayerReferences = glr

