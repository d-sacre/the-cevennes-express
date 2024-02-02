extends Spatial

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
var _zoom_current : Vector2 = Vector2(CAMERA_FOV_DEFAULTS["default"],0)
var _zoom_requested : Vector2 = Vector2(CAMERA_FOV_DEFAULTS["default"],0)

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

func initiate_raycast_from_position(screenspace_position : Vector2) -> void:
	self._camera.initiate_raycast_from_position(screenspace_position)

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_camera_raycast_result(current_collision_information : Array) -> void:
	emit_signal("raycast_result", current_collision_information)

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready() -> void:
	self._camera.connect("camera_raycast_result", self, "_on_camera_raycast_result")
	
# REMARK: From a management/logic separation perspective not ideal to get the mouse 
# buttons/user input in the camera manager script
func _input(event : InputEvent) -> void:
	# https://docs.godotengine.org/en/3.5/tutorials/inputs/input_examples.html
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP and event.pressed:
			if self._zooming_permitted:
				self._zoom_requested += Vector2(self.CAMERA_SPEED["zoom"][self._current_camera_speed_mode],0)
				if self._zoom_requested.x > self.CAMERA_FOV_DEFAULTS["max"]:
					self._zoom_requested.x =  self.CAMERA_FOV_DEFAULTS["max"]
			
		if event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
			if self._zooming_permitted:
				self._zoom_requested -= Vector2(self.CAMERA_SPEED["zoom"][self._current_camera_speed_mode],0)
				if self._zoom_requested.x < self.CAMERA_FOV_DEFAULTS["min"]:
					self._zoom_requested.x =  self.CAMERA_FOV_DEFAULTS["min"]
				
	if event is InputEventKey and event.pressed:
		if event.shift:
			self._current_camera_speed_mode = "fast"
		else:
			self._current_camera_speed_mode = "slow"
	
func _process(_delta : float) -> void:
	# Input strength
	var _cameraMovementRequest : Vector2 = Vector2(
		Input.get_action_strength("camera_move_left") - Input.get_action_strength("camera_move_right"),
			Input.get_action_strength("camera_move_forward") - Input.get_action_strength("camera_move_backward")
	)
	
	self._position_requested += Vector3(
		_cameraMovementRequest.x*self.CAMERA_SPEED["x"][self._current_camera_speed_mode],
		0,
		_cameraMovementRequest.y*self.CAMERA_SPEED["z"][self._current_camera_speed_mode]
	)
	
	self._position_current = self.transform.origin
	if self._position_current != self._position_requested:
		# fix to move highlighted position with camera movement; should lead to less raycast calls than when implemented
		# in _process()@cameraRaycast.gd
		# Problem: The more callers for the raycast method, the less reliable the process could get 
		# self._camera.initiate_raycast_from_last_position() 
		self._position_current = self._position_current.linear_interpolate(self._position_requested,0.1)
		self.transform.origin = self._position_current
		
	self._zoom_current = Vector2(self._camera.transform.origin.z,0)
	if self._zoom_current != self._zoom_requested:
		self._zoom_current = self._zoom_current.linear_interpolate(self._zoom_requested,0.125)
		self._camera.transform.origin.z = self._zoom_current.x
