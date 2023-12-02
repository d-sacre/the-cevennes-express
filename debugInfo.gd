extends PanelContainer

var geometry_info_prefix = ""

func _ready():
	$debugInfoRichtText.set_use_bbcode(true)

func _process(delta):
	var audioLatency =  "%.2f" % (Performance.get_monitor(Performance.AUDIO_OUTPUT_LATENCY)*1000)
	var display = OS.get_window_size()
	var fps = str(Engine.get_frames_per_second())
	var static_memory = "%.2f" % (OS.get_static_memory_usage()/1000000.0)
	var rendered_vertices = str(Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME))
	
#	var tmp_grid_size = self.get_parent().get_parent().get_node("HexGrid").grid_size
#	geometry_info_prefix = str(tmp_grid_size*tmp_grid_size) + " Hexagons,\n"
	
	var debug_info_string = "[u]Performance[/u]\n\nFrame Rate: " + fps + " fps,"
	
	if not OS.has_feature("JavaScript"):
		debug_info_string += "\nStatic Memory: " +  static_memory + " MByte"
	debug_info_string += "\nResolution: " + str(display.x) +"x" + str(display.y) + " px, "
	debug_info_string +=  "\nAudio Latency: "  + str(audioLatency) + str(" ms")
	debug_info_string += "\n\n[u]Geometry[/u]\n\n" + geometry_info_prefix + rendered_vertices + " Vertices, "

	debug_info_string += "\n\n[u]Controls[/u]\n\nWASD = Move Camera along X and Z,\nShift: Increase Camera Speed\nMouse Wheel: Zoom in/out"
	
	$debugInfoRichtText.set_bbcode(debug_info_string)
	
	
