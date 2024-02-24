extends Spatial

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal raycast_result(current_collision_information)

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
# zoom: min = -3 to prevent clipping with floating tile; old min: -2, -4
const CAMERA_FOV_DEFAULTS : Dictionary = {"default": 0, "min": -3, "max": 15} # 
const CAMERA_POSITION_DEFAULT : Vector3 = Vector3(3.6,3,-3)
const CAMERA_SPEED : Dictionary = {
	"x": {"slow": 0.1, "fast": 0.5},
	"z": {"slow": 0.1, "fast": 0.5},
	"zoom": {"slow": 0.5, "fast": 1} # old: "zoom": {"slow": 1, "fast": 2}
}

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _zooming_permitted : bool = true
var _zooming_by_asr_permitted : bool = false
var _zoom_current : Vector2 = Vector2(CAMERA_FOV_DEFAULTS["default"],0)
var _zoom_requested : Vector2 = Vector2(CAMERA_FOV_DEFAULTS["default"],0)
var _zoomSpeedModifier : float = 1.0
var _asr_zooming_action : String = "NONE"

var _cameraMovementRequest : Vector2
var _position_current : Vector3 = CAMERA_POSITION_DEFAULT
var _position_requested : Vector3 = CAMERA_POSITION_DEFAULT
var _current_camera_speed_mode : String = "slow"

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var _camera = $cameraRotator/camera

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func enable_raycasting() -> void:
	self._camera.raycasting_permitted = true

func disable_raycasting() -> void:
	self._camera.raycasting_permitted = false

func enable_zooming() -> void:
	self._zooming_permitted = true

func disable_zooming() -> void:
	self._zooming_permitted = false

func set_zoom_temporary_speed_modifier(value : float) -> void:
	self._zoomSpeedModifier = value

func set_zoom_temporary_speed_modifier_to_asr() -> void:
	self.set_zoom_temporary_speed_modifier(0.1)

func reset_zoom_temporary_speed_modifier_to_default() -> void:
	self.set_zoom_temporary_speed_modifier(1.0)

func enable_asr_zooming(mode : String) -> void:
	self._zooming_by_asr_permitted = true
	self._asr_zooming_action = mode
	self.set_zoom_temporary_speed_modifier_to_asr()

func disable_asr_zooming() -> void:
	self._zooming_by_asr_permitted = false
	self._asr_zooming_action = "NONE"
	self.reset_zoom_temporary_speed_modifier_to_default()

func initiate_raycast_from_position(screenspace_position : Vector2) -> void:
	self._camera.initiate_raycast_from_position(screenspace_position)

func request_movement(asmr : Vector2) -> void:
	self._cameraMovementRequest = asmr

func request_new_position(pos : Vector3) -> void:
	self._position_requested = pos

func request_zoom_in() -> void:
	if self._zooming_permitted:
		self._zoom_requested -= Vector2(self._zoomSpeedModifier * self.CAMERA_SPEED["zoom"][self._current_camera_speed_mode],0)

		if self._zoom_requested.x < self.CAMERA_FOV_DEFAULTS["min"]:
			self._zoom_requested.x =  self.CAMERA_FOV_DEFAULTS["min"]

func request_zoom_out() -> void:
	if self._zooming_permitted:
		self._zoom_requested += Vector2(self._zoomSpeedModifier * self.CAMERA_SPEED["zoom"][self._current_camera_speed_mode],0)
		
		if self._zoom_requested.x > self.CAMERA_FOV_DEFAULTS["max"]:
			self._zoom_requested.x =  self.CAMERA_FOV_DEFAULTS["max"]

func set_movement_speed_mode(mode : String) -> void:
	self._current_camera_speed_mode = mode

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_camera_raycast_result(current_collision_information : Array) -> void:
	emit_signal("raycast_result", current_collision_information)

func _on_user_input_manager_global_command(tce_event_uuid : String, value) -> void:
	var _tmp_eventKeychain : Array  = ["*UserInputManager", "requesting", "global", "execution", "cursor", "floating", "position", "update"]

	if UserInputManager.match_tce_event_uuid(tce_event_uuid, _tmp_eventKeychain):
		if value is Vector3:
			self._position_requested = value + Vector3(-0.75, self.CAMERA_POSITION_DEFAULT.y, self.CAMERA_POSITION_DEFAULT.z-2)

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	self._camera.connect("camera_raycast_result", self, "_on_camera_raycast_result")
	UserInputManager.connect("transmit_global_event", self, "_on_user_input_manager_global_command")

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _process(_delta : float) -> void:

	# DESCRIPTION: Catch case that position request is invalid
	if self._position_requested != Vector3.INF:
		# print("status: ", self._position_requested != Vector3.INF)
		# print("position requested: ", self._position_requested, "current: ", self._position_current)
		self._position_requested += Vector3(
			self._cameraMovementRequest.x*self.CAMERA_SPEED["x"][self._current_camera_speed_mode],
			0,
			self._cameraMovementRequest.y*self.CAMERA_SPEED["z"][self._current_camera_speed_mode]
		)
		
		self._position_current = self.transform.origin
		if self._position_current != self._position_requested:
			# fix to move highlighted position with camera movement; should lead to less raycast calls than when implemented
			# in _process()@cameraRaycast.gd
			# Problem: The more callers for the raycast method, the less reliable the process could get 
			# self._camera.initiate_raycast_from_last_position() 
			self._position_current = self._position_current.linear_interpolate(self._position_requested,0.1)
			self.transform.origin = self._position_current
	
	# DESCRIPTION: Handle asr zooming
	if self._zooming_by_asr_permitted:
		if self._asr_zooming_action == "decrement":
			self.request_zoom_out()
		elif self._asr_zooming_action == "increment":
			self.request_zoom_in()

	self._zoom_current = Vector2(self._camera.transform.origin.z,0)
	if self._zoom_current != self._zoom_requested:
		self._zoom_current = self._zoom_current.linear_interpolate(self._zoom_requested,0.125)
		self._camera.transform.origin.z = self._zoom_current.x
