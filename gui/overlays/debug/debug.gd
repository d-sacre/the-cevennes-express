extends PanelContainer

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const _controls_description_lut : Dictionary = {
	"mouse": """12345 = Select Tile Action Mode, \nWASD = Move Camera along X and Z,\nShift: Increase Camera Speed\nMouse Wheel: Zoom in/out,\nRight Click: Rotate Tile,\nLeft Click: Request Tile Action""",
	"keyboard": "12345 = Select Tile Action Mode, \nNot implemented yet!"
}

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _geometry_info_prefix : String = ""
var _managerReferences : Dictionary = {}
var _inputMethod : String = "mouse"

onready var _debugText : RichTextLabel = $GridContainer/debugInfoRichText

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(mr : Dictionary) -> void:
	self._managerReferences = mr

func _on_input_method_selected(index : int) -> void:
	match index:
		0 :
			self._inputMethod = "mouse"
		1: 
			self._inputMethod = "keyboard"

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	_debugText.set_use_bbcode(true)
	$GridContainer/inputMethodOptionButton.connect("item_selected",self, "_on_input_method_selected")

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
	_debug_info_string += "\n\n[u]Controls[/u]\n\n" + self._controls_description_lut[self._inputMethod]

	_debugText.set_bbcode(_debug_info_string)
