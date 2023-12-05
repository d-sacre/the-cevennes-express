extends Spatial

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal raycast_result(current_collision_information)

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const CAMERA_FOV_DEFAULTS : Dictionary = {"default": 0, "min": -4, "max": 15} # min: -2

const CAMERA_POSITION_DEFAULT = Vector3(3.6,3,-3)
const CAMERA_SPEED : Dictionary = {
	"x": {"slow": 0.1, "fast": 0.5},
	"z": {"slow": 0.1, "fast": 0.5},
	"zoom": {"slow": 0.5, "fast": 1} # old: "zoom": {"slow": 1, "fast": 2}
}

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
var zoom_current = Vector2(CAMERA_FOV_DEFAULTS["default"],0)
var zoom_requested = Vector2(CAMERA_FOV_DEFAULTS["default"],0)
var position_current = CAMERA_POSITION_DEFAULT
var position_requested = CAMERA_POSITION_DEFAULT
var current_camera_speed_mode = "slow"

################################################################################
#### Onready Member Variables ##################################################
################################################################################
onready var _camera = $cameraRotator/camera

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################
func enable_raycasting() -> void:
	_camera.raycasting_permitted = true

func disable_raycasting() -> void:
	_camera.raycasting_permitted = false

func initiate_raycast_from_position(screenspace_position) -> void:
	_camera.initiate_raycast_from_position(screenspace_position)

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_camera_raycast_result(current_collision_information) -> void:
	emit_signal("raycast_result", current_collision_information)

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready() -> void:
	_camera.connect("camera_raycast_result", self, "_on_camera_raycast_result")
	
# REMARK: From a management/logic separation perspective not ideal to get the mouse 
# buttons/user input in the camera manager script
func _input(event) -> void:
	# https://docs.godotengine.org/en/3.5/tutorials/inputs/input_examples.html
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP and event.pressed:
			zoom_requested += Vector2(CAMERA_SPEED["zoom"][current_camera_speed_mode],0)
			if zoom_requested.x > CAMERA_FOV_DEFAULTS["max"]:
				zoom_requested.x =  CAMERA_FOV_DEFAULTS["max"]
			
		if event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
			zoom_requested -= Vector2(CAMERA_SPEED["zoom"][current_camera_speed_mode],0)
			if zoom_requested.x < CAMERA_FOV_DEFAULTS["min"]:
				zoom_requested.x =  CAMERA_FOV_DEFAULTS["min"]
				
	if event is InputEventKey and event.pressed:
		if event.shift:
			current_camera_speed_mode = "fast"
		else:
			current_camera_speed_mode = "slow"
	
func _process(delta) -> void:
	# Input strength
	var cameraMovementRequest : Vector2 = Vector2(
		Input.get_action_strength("camera_move_left") - Input.get_action_strength("camera_move_right"),
			Input.get_action_strength("camera_move_forward") - Input.get_action_strength("camera_move_backward")
	)
	
	position_requested += Vector3(
		cameraMovementRequest.x*CAMERA_SPEED["x"][current_camera_speed_mode],
		0,
		cameraMovementRequest.y*CAMERA_SPEED["z"][current_camera_speed_mode]
	)
	
	position_current = self.transform.origin
	if position_current != position_requested:
		# fix to move highlighted position with camera movement; should lead to less raycast calls than when implemented
		# in _process()@cameraRaycast.gd
		# Problem: The more callers for the raycast method, the less reliable the process could get 
		# _camera.initiate_raycast_from_last_position() 
		position_current = position_current.linear_interpolate(position_requested,0.1)
		self.transform.origin = position_current
		
	zoom_current = Vector2(_camera.transform.origin.z,0)
	if zoom_current != zoom_requested:
		zoom_current = zoom_current.linear_interpolate(zoom_requested,0.125)
		_camera.transform.origin.z = zoom_current.x
