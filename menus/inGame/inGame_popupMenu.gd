extends PanelContainer

const BUTTON_SOURCES : Array = ["ingameMenu_buttons"]
const BUTTON_SIGNALS : Array = ["button_pressed", "button_entered_hover", "button_exited_hover"]

var buttonText : Dictionary = {
	"play": "Return to Game",
	"settings": "Settings",
	"credits": "Exit to Main Menu",
	"exit": "Exit to System"
} 

func _ready():
	self.visible = false
	
	if OS.has_feature("JavaScript"):
		$VBoxContainer/exitButtonHBox.visible = false

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		self.visible = !self.visible
		get_tree().paused = !get_tree().paused 


func _on_resumeButton_pressed():
	self.visible = false
	get_tree().paused = false


func _on_returnToMainMenuButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://menus/mainMenu/mainMenu.tscn")


func _on_exitButton_pressed():
	get_tree().quit()
