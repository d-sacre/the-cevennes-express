extends PanelContainer

const BUTTON_SOURCES : Array = ["ingameMenu_buttons"]
const BUTTON_SIGNALS : Array = ["button_pressed", "button_entered_hover", "button_exited_hover"]

var buttonText : Dictionary = {
	"play": "Return to Game",
	"settings": "Settings",
	"credits": "Exit to Main Menu",
	"exit": "Exit to System"
} 

onready var audioManager : Node = get_parent().get_parent().get_node("audioManager")

func _on_button_pressed(buttonContext, buttonId, buttonRef) -> void:
	# play button sound only if corresponding bus audio level is above 0:
	var _tmp_user_settings : Dictionary = {"volume":{"sfx": {"ui": 10}}} # just for testing; normally: userSettingsManager.get_user_settings()
	if _tmp_user_settings["volume"]["sfx"]["ui"] > 0:
		audioManager.play_sfx(["ui", "button", "pressed"]) # play the button pressed sound
	
#	# button pressed FSM
	match buttonId:
		"play":
			# needs some delay so any audio can finish playing; perhaps similar solution to exit?
			self.visible = false
			get_tree().paused = false
		
		# "settings":
		# 	settingsPopout.visible = not settingsPopout.visible
		# 	creditsPopout.visible = false
		"credits":
			get_tree().change_scene("res://menus/mainMenu/mainMenu.tscn")
		
			
		"exit":
			get_tree().quit()

func _on_button_entered_hover(buttonContext, buttonId, buttonRef) -> void:
	var _tmp_user_settings : Dictionary = {"volume":{"sfx": {"ui": 10}}} # userSettingsManager.get_user_settings()
	if _tmp_user_settings["volume"]["sfx"]["ui"] > 0:
		audioManager.play_sfx(["ui", "button", "hover"])

	if not buttonRef.disabled:
		buttonRef.text = "«" + buttonText[buttonId] + "»"
	
func _on_button_exited_hover(buttonContext, buttonId, buttonRef) -> void:
	if not buttonRef.disabled:
		buttonRef.text = buttonText[buttonId]

func _ready():
	self.visible = false

#	# connect the button signals
#	for _source in BUTTON_SOURCES:
#		var _sourceRef = get_node(_source)
#
#		for _signal in BUTTON_SIGNALS:
#			_sourceRef.connect(_signal, self, "_on_"+_signal)
	

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		self.visible = !self.visible
		get_tree().paused = !get_tree().paused 
