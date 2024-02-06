extends CanvasLayer

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "userSettingsManager": res://managers/userSettingsManager/userSettingsManager.tscn
# "audioManager": res://managers/audioManager/audioManager.tscn
# Other autoloads that are indirectly required:
# "JsonFio": res://utils/fileHandling/json_fio.gd
# "DictionaryParsing": res://utils/dataHandling/dictionaryParsing.gd
# "AudioManagerNodeHandling": res://managers/audioManager/utils/audioManager_node-handling.gd
# "sfxManager": res://managers/audioManager/sfx/sfxManager.tscn
# "musicManager": res://managers/audioManager/music/musicManager.tscn

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const BUTTON_SOURCES : Array = ["mainMenu_buttons"]
const BUTTON_SIGNALS : Array = ["button_pressed", "button_entered_hover", "button_exited_hover"]

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
var buttonText : Dictionary = {
	"play": "Play",
	"settings": "Settings",
	"credits": "Credits",
	"exit": "Exit"
} 

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var settingsPopout : Node = $settingsPopout
onready var creditsPopout : Node = $creditsPopout

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_button_pressed(buttonContext, buttonId, buttonRef) -> void:
	var _tmp_user_settings : Dictionary = userSettingsManager.get_user_settings()
	audioManager.play_sfx(["ui", "button", "pressed"]) # play the button pressed sound
	
#	# button pressed FSM
	match buttonId:
		"play":
			# needs some delay so any audio can finish playing; perhaps similar solution to exit?
			get_tree().change_scene("res://Main.tscn")
			
			# interesting sources: 
			# https://forum.godotengine.org/t/how-to-load-and-change-scenes/28466
			# https://docs.godotengine.org/en/3.0/tutorials/io/background_loading.html
			
		"credits":
			creditsPopout.visible = not creditsPopout.visible
			settingsPopout.visible = false
			
		"settings":
			settingsPopout.visible = not settingsPopout.visible
			creditsPopout.visible = false
			
		"exit":
			get_tree().quit()

func _on_button_entered_hover(buttonContext, buttonId, buttonRef) -> void:
	var _tmp_user_settings : Dictionary = userSettingsManager.get_user_settings()

	audioManager.play_sfx(["ui", "button", "hover"])

	if not buttonRef.disabled:
		buttonRef.text = "«" + buttonText[buttonId] + "»"
	
func _on_button_exited_hover(buttonContext, buttonId, buttonRef) -> void:
	if not buttonRef.disabled:
		buttonRef.text = buttonText[buttonId]

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################			
func _ready():
	# load the user settings
	userSettingsManager.initialize_user_settings()

	# initialize audio manager singleton correctly and set the default values
	audioManager.initialize_volume_levels(userSettingsManager.get_user_settings())

#	# ensure that popups are hidden
	settingsPopout.visible = false
	creditsPopout.visible = false

	# connect the button signals
	for _source in BUTTON_SOURCES:
		var _sourceRef = get_node(_source)
		
		for _signal in BUTTON_SIGNALS:
			_sourceRef.connect(_signal, self, "_on_"+_signal)
			
	# initialize all the settings elements to the correct values
	settingsPopout.slider_initialize(userSettingsManager.get_user_settings())
	settingsPopout.button_initialize(userSettingsManager.get_user_settings())

	

	
