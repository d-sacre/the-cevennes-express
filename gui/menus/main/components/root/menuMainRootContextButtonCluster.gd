tool

extends TCEClusterButton

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const buttons : Array = [
	{
		"text": "Play",
		"tce_event_uuid_suffix": "play",
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
		"text": "Credits",
		"tce_event_uuid_suffix": "credits",
		"default": false,
		"disabled": false,
		"export": {
			"javascript": true
		}
	},
	{
		"text": "Exit",
		"tce_event_uuid_suffix": "exit",
		"default": false,
		"disabled": false,
		"export": {
			"javascript": false
		}
	},
]

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(context : String) -> void:
	var _tmp_context : String = context + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "root" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "button" + UserInputManager.TCE_EVENT_UUID_SEPERATOR
	.initialize_button_cluster(_tmp_context, $VBoxContainer, self.buttons)
	self.pause_mode = PAUSE_MODE_PROCESS

	self.set_focus_neighbours(self.get_focus_reference())
	# self.set_focus_to_default()

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready():
	# only for testing purposes
	# self.initialize("editorTest")
	
	if Engine.editor_hint:
		self.initialize("editorTest")
