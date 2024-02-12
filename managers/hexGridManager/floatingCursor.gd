extends Spatial

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _movement_by_asmr_allowed : bool = false
var _asmr : Vector2 = Vector2(0,0)
var _last_asmr : Vector2 = Vector2(0,0)

var _position_current : Vector3
var _position_requested : Vector3

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var _hexGridManager : Spatial = get_parent().get_node("hexGridManager")

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func set_last_asmr(asmr : Vector2) -> void:
	self._last_asmr = asmr

func enable_movement_by_asmr() -> void:
	self._movement_by_asmr_allowed = true
	self._position_current = self.transform.origin
	self._position_requested = self._position_current

func disable_movement_by_asmr() -> void:
	self._movement_by_asmr_allowed = false

func request_movement_by_action_strength(asmr: Vector2) -> void:
	print("floatingSelector: asmr")
	self.set_last_asmr(asmr)

func request_new_position(position : Vector3) -> void:
	self._position_requested = position

func force_move_to(position : Vector3) -> void:
	self.set_global_translation(position)

# func _process(_delta : float) -> void:
# 	if self._floating_selector_movement_by_asmr_allowed:

# 		if self._last_floating_selector_asmr != Vector2(0,0):
# 			self._floating_selector_asmr += Vector2(abs(self._last_floating_selector_asmr.x), abs(self._last_floating_selector_asmr.y))
# 			if (int(self._floating_selector_asmr.x) % 64 == 63) and (int(self._floating_selector_asmr.y) % 64 != 63):
# 				self._move_floating_selector_by_action_strength(self._last_floating_selector_asmr)
# 			elif (int(self._floating_selector_asmr.x) % 64 != 63) and (int(self._floating_selector_asmr.y) % 64 == 63):
# 				self._move_floating_selector_by_action_strength(self._last_floating_selector_asmr)
# 			elif (int(self._floating_selector_asmr.x) % 64 == 63) and (int(self._floating_selector_asmr.y) % 64 == 63):
# 				self._move_floating_selector_by_action_strength(self._last_floating_selector_asmr)
			
# 		else:
# 			self._floating_selector_asmr = Vector2(0,0)