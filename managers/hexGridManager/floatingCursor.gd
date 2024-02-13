extends Spatial

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _movement_by_asmr_allowed : bool = false
var _asmr : Vector2 = Vector2(0,0)
var _last_asmr : Vector2 = Vector2(0,0)
var _asmr_repetition_delay : float = 0.75

var _position_current : Vector3
var _position_requested : Vector3

var _error : int

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var _hexGridManager : Spatial = get_parent().get_node("hexGridManager")
onready var _asmrRepetitionDelayTimer : Timer = $asmrRepetitionDelayTimer

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _move_and_highlight() -> void:
	var _tmp_position : Vector3 = self._hexGridManager.calculate_new_floating_selector_postion_by_action_strength(self._last_asmr)
	if _tmp_position != Vector3.INF:
		self._hexGridManager.move_floating_selector_and_highlight()

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func set_last_asmr(asmr : Vector2) -> void:
	self._last_asmr = asmr

func enable_movement_by_asmr() -> void:
	self._movement_by_asmr_allowed = true
	self._position_current = self.transform.origin
	self._position_requested = self._position_current

	self._asmrRepetitionDelayTimer.start(self._asmr_repetition_delay)

func disable_movement_by_asmr() -> void:
	self._movement_by_asmr_allowed = false
	self._asmrRepetitionDelayTimer.stop()

func request_movement_by_action_strength(asmr: Vector2) -> void:
	# DESCRIPTION: Store the last action strength movement request value
	self.set_last_asmr(asmr)

	# DESCRIPTION: Move floating cursor one step
	self._move_and_highlight()

	# DESCRIPTION: Setup the timer for the repetition in the case that the user continues
	# the input or changes it
	if asmr == Vector2(0,0):
		if not self._asmrRepetitionDelayTimer.is_stopped():
			self._asmrRepetitionDelayTimer.stop()
	else:
		if self._asmrRepetitionDelayTimer.is_stopped():
			self._asmrRepetitionDelayTimer.start(self._asmr_repetition_delay)
		else:
			self._asmrRepetitionDelayTimer.stop()
			self._asmrRepetitionDelayTimer.start(self._asmr_repetition_delay)

func request_new_position(position : Vector3) -> void:
	self._position_requested = position

func force_move_to(position : Vector3) -> void:
	self.set_global_translation(position)

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_asmr_repetition_timeout() -> void:
	self._move_and_highlight()

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	self._asmrRepetitionDelayTimer.set_wait_time(self._asmr_repetition_delay)
	self._error = self._asmrRepetitionDelayTimer.connect("timeout", self, "_on_asmr_repetition_timeout")
