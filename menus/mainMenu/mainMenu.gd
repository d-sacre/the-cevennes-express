extends CanvasLayer

signal set_audio_volume(settingKeychain, settingValue)

const BUTTON_SOURCES : Array = ["mainMenu_buttons"]
const BUTTON_SIGNALS : Array = ["button_pressed", "button_entered_hover", "button_exited_hover"]

var buttonText : Dictionary = {
	"play": "Play",
	"settings": "Settings",
	"credits": "Credits",
	"exit": "Exit"
} 

onready var audioManager : Node = $audioManager
onready var userSettingsManager : Node = $userSettingsManager
onready var settingsPopout : Node = $settingsPopout
onready var creditsPopout : Node = $creditsPopout


func _on_button_pressed(buttonContext, buttonId, buttonRef) -> void:
	# play button sound only if corresponding bus audio level is above 0:
	var _tmp_user_settings : Dictionary = userSettingsManager.get_user_settings()
	if _tmp_user_settings["volume"]["sfx"]["ui"] > 0:
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
	print(_tmp_user_settings["volume"]["sfx"]["ui"])
	if _tmp_user_settings["volume"]["sfx"]["ui"] > 0:
		audioManager.play_sfx(["ui", "button", "hover"])

	if not buttonRef.disabled:
		buttonRef.text = "«" + buttonText[buttonId] + "»"
	
func _on_button_exited_hover(buttonContext, buttonId, buttonRef) -> void:
	if not buttonRef.disabled:
		buttonRef.text = buttonText[buttonId]
		
func _on_user_settings_changed(settingKeychain, setterType, settingValue) -> void:
	var _audioManagerSignalResult : Dictionary = userSettingsManager.update_user_settings(settingKeychain, setterType, settingValue)
	if _audioManagerSignalResult.has("keyChain"):
		emit_signal("set_audio_volume", _audioManagerSignalResult["keyChain"], _audioManagerSignalResult["value"]) # send the volume change signal
	
			
func _ready():
	userSettingsManager.initialize_user_settings()
	
#	# ensure that popups are hidden
#	settingsPopout.visible = false
	creditsPopout.visible = false

	# connect the button signals
	for _source in BUTTON_SOURCES:
		var _sourceRef = get_node(_source)
		
		for _signal in BUTTON_SIGNALS:
			_sourceRef.connect(_signal, self, "_on_"+_signal)
			
	# connect to the user settings changed signal
	settingsPopout.connect("user_settings_changed", self, "_on_user_settings_changed")

	# initialize all the settings elements to the correct values
	settingsPopout.slider_initialize(userSettingsManager.get_user_settings())
	settingsPopout.button_initialize(userSettingsManager.get_user_settings())

