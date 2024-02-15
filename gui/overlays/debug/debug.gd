extends PanelContainer

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const _controls_description_lut : Dictionary = {
	"MOUSE_KEYBOARD_MIXED": """ (QWERTZ Keyboard & Mouse)\n\n12345: Select Tile Action Mode, \nWASD: Move Camera along X and Z,\nMOUSE WHEEL: Zoom in/out,\nSHIFT: Increase Camera/Zoom Speed,\nRIGHT CLICK: Rotate Tile,\nLEFT CLICK: Request Tile Action,\nESC/BACKSPACE: Menu""",
	"KEYBOARD_ONLY": " (QWERTZ Keyboard)\n\n12345 = Select Tile Action Mode, \nWASD: Move Floating Cursor, \nE: Rotate Tile,\nQ/ENTER: Request Tile Action, \nARROWS: Select New Tile Definition, \nSHIFT: Increase Movement/Zoom Speed, \nPOINT: Zoom in,\nCOMMA: Zoom out, \nESC/BACKSPACE: Menu",
	"CONTROLLER_ONLY" : " (Nitendo Style Controller)\n\nLEFT STICK: Move Floating Cursor, \nL1: Rotate Tile Clockwise,\nL2: Tile Action, \nRIGHT STICK: Select New Tile Definition,\nY: Previous Tile Action, \nA: Next Tile Action, \nR1/R2: Zoom in/out, \nHOME: Menu"
}

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _geometry_info_prefix : String = ""
var _managerReferences : Dictionary = {}
var _inputMethod : String = "MOUSE_KEYBOARD_MIXED"

onready var _debugText : RichTextLabel = $GridContainer/debugInfoRichText
onready var _inputOptionsButton : OptionButton = $GridContainer/inputMethodOptionButton

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(mr : Dictionary) -> void:
	self._managerReferences = mr

func _on_input_method_selected(index : int) -> void:
	self._inputMethod = (_inputOptionsButton.get_item_metadata(index))["key"]
	UserInputManager.set_current_input_method((_inputOptionsButton.get_item_metadata(index))["TCE_INPUT_METHOD_UUID"])

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	_debugText.set_use_bbcode(true)
	_inputOptionsButton.connect("item_selected",self, "_on_input_method_selected")

	# DESCRIPTION: Add Options to Option Button
	var _keys : Array = ["MOUSE_ONLY", "MOUSE_KEYBOARD_MIXED", "KEYBOARD_ONLY", "CONTROLLER_ONLY", "TOUCH_ONLY"]

	var _counter = 0
	for _key in _keys:
		var _data : Dictionary = UserInputManager.INPUT_METHOD_MODES[_key]
		var _optionText : String = _data["TEXT"]
		var _metadata : Dictionary = {"key": _key, "TCE_INPUT_METHOD_UUID": _data["TCE_INPUT_METHOD_UUID"]}

		_inputOptionsButton.add_item(_optionText, _counter)
		_inputOptionsButton.set_item_metadata(_counter, _metadata)
		_inputOptionsButton.set_item_disabled(_counter, not _data["AVAILABLE"])

		if _key == "MOUSE_KEYBOARD_MIXED":
			_inputOptionsButton.select(_counter)

		_counter += 1

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _process(_delta : float) -> void:
	var _audioLatency : String =  "%.2f" % (Performance.get_monitor(Performance.AUDIO_OUTPUT_LATENCY)*1000)
	var _display : Vector2 = OS.get_window_size()
	var _fps : String = str(Engine.get_frames_per_second())
	var _static_memory : String = "%.2f" % (OS.get_static_memory_usage()/1000000.0)
	var _rendered_vertices : String = str(Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME))

	var _hgm : Object = self._managerReferences["hexGridManager"]
	var tmp_grid_size : int = _hgm._hex_grid_size_x * _hgm._hex_grid_size_y
	self._geometry_info_prefix = str(tmp_grid_size) + " Hexagons,\n"

	var _debug_info_string : String = "[u]Performance[/u]\n\nFrame Rate: " + _fps + " fps,"

	if not OS.has_feature("JavaScript"):
		_debug_info_string += "\nStatic Memory: " +  _static_memory + " MByte"

	_debug_info_string += "\nResolution: " + str(_display.x) +"x" + str(_display.y) + " px, "
	_debug_info_string +=  "\nAudio Latency: "  + str(_audioLatency) + str(" ms")
	_debug_info_string += "\n\n[u]Geometry[/u]\n\n" + self._geometry_info_prefix + _rendered_vertices + " Vertices, "

	_debug_info_string += "\n\n Camera Zoom = " + str(self._managerReferences["cameraManager"]._zoom_current.x)
	_debug_info_string += "\n\n[u]Controls[/u]" + self._controls_description_lut[self._inputMethod]

	_debugText.set_bbcode(_debug_info_string)
