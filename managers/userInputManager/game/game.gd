extends Node

################################################################################
#### PUBLIC MEMBER VARIABLES ###################################################
################################################################################
var logic : Object 

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _managerReferences : Dictionary = {}
var _guiLayerReferences : Dictionary = {}

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(context : String, mr : Dictionary, glr : Dictionary) -> void:
	self._managerReferences = mr
	self._guiLayerReferences = glr

	if context.match("*creative"):
		print("Creative Game")
		# GUI
		var _scene = load("res://gui/overlays/creativeMode/creativeModeOverlay.tscn")
		var _instance = _scene.instance()
		self._guiLayerReferences["overlay"].add_child(_instance)
		_instance.initialize_creative_mode_gui(context, self._managerReferences["tileDefinitionManager"])
		
		# Logic
		logic = game_creative.new(context, self._managerReferences, self._guiLayerReferences)

	elif context.match("*default"):
		print("Default Game")

		# logic
		logic = game_default.new(context, self._managerReferences, self._guiLayerReferences)
