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
		"disabled": false,
		"export": {
			"javascript": true
		}
	},
	{
		"text": "Exit to Main Menu",
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
# func initialize(context : String) -> void:
# 	self._buttonContainer = $VBoxContainer #$CenterContainer #$CenterContainer/GridContainer
# 	.initialize(context + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "menu" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "root" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "button" + UserInputManager.TCE_EVENT_UUID_SEPERATOR)
# 	self.pause_mode = PAUSE_MODE_PROCESS

# 	self._set_focus_neighbours()

func initialize(context : String) -> void:
	#$CenterContainer #$CenterContainer/GridContainer
	var _tmp_context : String = context + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "menu" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "root" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "button" + UserInputManager.TCE_EVENT_UUID_SEPERATOR
	.initialize_button_cluster(_tmp_context, $VBoxContainer, self.buttons)
	self.pause_mode = PAUSE_MODE_PROCESS

	self.set_focus_neighbours(self.get_focus_reference())

func _ready():
	# only for testing purposes
	# self.initialize("editorTest")
	
	if Engine.editor_hint:
		self.initialize("editorTest")
