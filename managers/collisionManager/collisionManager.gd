extends Node

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal collision_detected(tce_signaling_uuid, collision_information)

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _context : String
var _managerReferences : Dictionary = {}

var _error : int

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(ctxt: String, mr : Dictionary) -> void:
	self._context = ctxt
	self._managerReferences = mr
	self._error = self._managerReferences["cameraManager"].connect("raycast_result",self,"_on_raycast_result")

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################

# REMARK: Hardcoded for the case of only hitting a hex tile. 
# Other collisions like with trains have to be implemented differently!
func _on_raycast_result(current_collision_information : Array) -> void:
	var _collisionInformation : Dictionary = {
		"colliding": {
			"status": false,
			"objects": []
		},
		"grid_index": self._managerReferences["hexGridManager"].INDEX_OUT_OF_BOUNDS,
	}

	if current_collision_information[0] != false:
		var _collider_ref = current_collision_information[1]
		var _collider_parent_object = _collider_ref.get_parent()
		
		_collisionInformation["colliding"] = {
			"status": true, 
			"objects": [_collider_parent_object]
		}
		_collisionInformation["grid_index"] = _collider_parent_object.grid_index

	var _tmp_signaling_keychain : Array = ["internal", "collision", "detected"]
	var _tmp_tce_signaling_uuid : String = UserInputManager.create_tce_signaling_uuid(self._context,  _tmp_signaling_keychain)

	emit_signal("collision_detected", _tmp_tce_signaling_uuid, _collisionInformation)

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	_error = self.connect("collision_detected", UserInputManager, "_on_special_user_input")
