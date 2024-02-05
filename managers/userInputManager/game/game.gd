extends Node

var _managerReferences : Dictionary = {}
var _guiLayerReferences : Dictionary = {}

var logic : Object 

func initialize(context : String, mr : Dictionary, glr : Dictionary) -> void:
	self._managerReferences = mr
	self._guiLayerReferences = glr

	if context.match("*creative"):
		print("Creative Game")
		# GUI
		var _scene = load("res://gui/overlays/creativeMode/creativeModeOverlay.tscn")
		var _instance = _scene.instance()
		self._guiLayerReferences["overlay"].add_child(_instance)
		# var _creativeMode : Object = get_node("guiOverlayCanvasLayer/creativeModeOverlay")
		_instance.initialize_creative_mode_gui(context, self._managerReferences["tileDefinitionManager"])
		
		# Logic
		logic = game_creative.new(self._managerReferences)

	elif context.match("*default"):
		print("Default Game")

		# logic
		logic = game_default.new(self._managerReferences)
