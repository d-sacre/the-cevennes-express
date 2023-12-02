extends Spatial

#const CAMERA_FOV_DEFAULTS : Dictionary = {"default": 70,"min": 15, "max": 150}

const CAMERA_FOV_DEFAULTS : Dictionary = {"default": 0, "min": -4, "max": 15} # min: -2

const CAMERA_POSITION_DEFAULT = Vector3(3.6,3,-3)
const CAMERA_SPEED : Dictionary = {
	"x": {"slow": 0.1, "fast": 0.5},
	"z": {"slow": 0.1, "fast": 0.5},
	"zoom": {"slow": 0.5, "fast": 1} # old: "zoom": {"slow": 1, "fast": 2}
}

var fov_current = Vector2(CAMERA_FOV_DEFAULTS["default"],0)
var fov_requested = Vector2(CAMERA_FOV_DEFAULTS["default"],0)
var position_current = CAMERA_POSITION_DEFAULT
var position_requested = CAMERA_POSITION_DEFAULT
var current_camera_speed_mode = "slow"

func _input(event):
	# https://docs.godotengine.org/en/3.5/tutorials/inputs/input_examples.html
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP and event.pressed:
			fov_requested += Vector2(CAMERA_SPEED["zoom"][current_camera_speed_mode],0)
			if fov_requested.x > CAMERA_FOV_DEFAULTS["max"]:
				fov_requested.x =  CAMERA_FOV_DEFAULTS["max"]
			
		if event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
			fov_requested -= Vector2(CAMERA_SPEED["zoom"][current_camera_speed_mode],0)
			if fov_requested.x < CAMERA_FOV_DEFAULTS["min"]:
				fov_requested.x =  CAMERA_FOV_DEFAULTS["min"]
				
	if event is InputEventKey and event.pressed:
		if event.shift:
			current_camera_speed_mode = "fast"
		else:
			current_camera_speed_mode = "slow"
		
			

func _process(delta):
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
		#print("Position change requested")
		position_current = position_current.linear_interpolate(position_requested,0.1)
		self.transform.origin = position_current
		
	fov_current = Vector2($cameraRotator/Camera.transform.origin.z,0)
	if fov_current != fov_requested:
		#print("Zoom change requested")
		fov_current = fov_current.linear_interpolate(fov_requested,0.125)
		#$Camera.fov = fov_current.x old fov logic via focal length
		$cameraRotator/Camera.transform.origin.z = fov_current.x
