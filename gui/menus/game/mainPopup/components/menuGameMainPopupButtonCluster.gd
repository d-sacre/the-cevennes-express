tool

extends TCEButtonCluster

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const buttons : Array = [
	{
		"text": "Resume Game",
		"tce_event_uuid_suffix": "resume",
		"default": true,
		"disabled": false,
		"export": {
			"javascript": true
		}
	},
	{
		"text": "Settings",
		"tce_event_uuid_suffix": "settings",
		"default": false,
		"disabled": true,
		"export": {
			"javascript": true
		}
	},
	{
		"text": "Return to Main Menu",
		"tce_event_uuid_suffix": "menu::main",
		"default": false,
		"disabled": true,
		"export": {
			"javascript": true
		}
	},
	{
		"text": "Exit to System",
		"tce_event_uuid_suffix": "exit",
		"default": false,
		"disabled": false,
		"export": {
			"javascript": false
		}
	},
]

################################################################################
#### PARENT CLASS PUBLIC MEMBER FUNCTION OVERRIDES #############################
################################################################################
func initialize(context : String) -> void:
	self._buttonContainer = $VBoxContainer #$CenterContainer #$CenterContainer/GridContainer
	.initialize(context + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "menu" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "root" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "button" + UserInputManager.TCE_EVENT_UUID_SEPERATOR)
	self.pause_mode = PAUSE_MODE_PROCESS

func _ready():
	# only for testing purposes
	# self.initialize("editorTest")
	
	if Engine.editor_hint:
		self.initialize("editorTest")
