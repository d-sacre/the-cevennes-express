extends PanelContainer

const BUTTON_SOURCES : Array = ["ingameMenu_buttons"]
const BUTTON_SIGNALS : Array = ["button_pressed", "button_entered_hover", "button_exited_hover"]

func _ready():
	self.visible = false
	$VBoxContainer.visible = true
	$settings_popup_panelContainer.visible = false
	
	if OS.has_feature("JavaScript"):
		$VBoxContainer/exitButtonHBox.visible = false

		

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		self.visible = !self.visible
		get_tree().paused = !get_tree().paused 


func _on_resumeButton_pressed():
	self.visible = false
	$settings_popup_panelContainer.visible = false
	get_tree().paused = false


func _on_returnToMainMenuButton_pressed():
	get_tree().paused = false
	# REMARK: Change UserInputManager context manually as a temporary solution 
	# until new Main Menu supporting the logic is created
	UserInputManager.context = "menu:main"
	get_tree().change_scene("res://menus/mainMenu/mainMenu.tscn")


func _on_exitButton_pressed():
	get_tree().quit()


func _on_settingsButton_pressed():
	$VBoxContainer.visible = false
	$settings_popup_panelContainer.visible = true


func _on_returnToInGameMenu_pressed():
	$VBoxContainer.visible = true
	$settings_popup_panelContainer.visible = false
	
func _on_button_hover():
	pass
