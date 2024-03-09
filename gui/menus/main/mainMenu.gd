extends Control

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const _context : String = "menu" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "main"

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var rootContext : HBoxContainer = $MarginContainer/contentVBoxContainer/rootContext
onready var rootContextButtons : Object = $MarginContainer/contentVBoxContainer/rootContext/buttons/buttonClusterRoot

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready():
	self.rootContext.visible = true
	self.rootContextButtons.initialize(self._context)

	# Initialize User Input Manager
	print("\t\t-> Initialize UserInputManager")
	$contextualLogic.initialize(self._context)
	UserInputManager.initialize(self._context, "mouse::keyboard::mixed", $contextualLogic, {}, {})


