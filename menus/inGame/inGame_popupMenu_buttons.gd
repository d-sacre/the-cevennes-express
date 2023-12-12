extends PanelContainer

signal button_pressed(buttonContext, buttonId, buttonRef)
signal button_entered_hover(buttonContext, buttonId, buttonRef)
signal button_exited_hover(buttonContext, buttonId, buttonRef)

onready var button_references : Dictionary = {
	"default": {
		"include": {
			"play": $VBoxContainer/playButtonHBox/playButton,
			"settings": $VBoxContainer/settingsButtonHBox/settingsButton,
			"credits": $VBoxContainer/creditsButtonHBox/creditsButton,
			"exit": $VBoxContainer/exitButtonHBox/exitButton
		}
	},
	"web": {"exclude": ["exit"]}
}

func _on_button_pressed_play() -> void:
	emit_signal("button_pressed", "mainMenu", "play", button_references["default"]["include"]["play"])
	
func _on_button_pressed_settings() -> void:
	emit_signal("button_pressed", "mainMenu", "settings", button_references["default"]["include"]["settings"])
	
func _on_button_pressed_credits() -> void:
	emit_signal("button_pressed", "mainMenu", "credits", button_references["default"]["include"]["credits"])

func _on_button_pressed_exit() -> void:
	emit_signal("button_pressed", "mainMenu", "exit", button_references["default"]["include"]["exit"])

func _on_button_entered_hover_play() -> void:
	emit_signal("button_entered_hover", "mainMenu", "play", button_references["default"]["include"]["play"])
	
func _on_button_entered_hover_settings() -> void:
	emit_signal("button_entered_hover", "mainMenu", "settings", button_references["default"]["include"]["settings"])
	
func _on_button_entered_hover_credits() -> void:
	emit_signal("button_entered_hover", "mainMenu", "credits", button_references["default"]["include"]["credits"])

func _on_button_entered_hover_exit() -> void:
	emit_signal("button_entered_hover", "mainMenu", "exit", button_references["default"]["include"]["exit"])
	
func _on_button_exited_hover_play() -> void:
	emit_signal("button_exited_hover", "mainMenu", "play", button_references["default"]["include"]["play"])
	
func _on_button_exited_hover_settings() -> void:
	emit_signal("button_exited_hover", "mainMenu", "settings", button_references["default"]["include"]["settings"])
	
func _on_button_exited_hover_credits() -> void:
	emit_signal("button_exited_hover", "mainMenu", "credits", button_references["default"]["include"]["credits"])

func _on_button_exited_hover_exit() -> void:
	emit_signal("button_exited_hover", "mainMenu", "exit", button_references["default"]["include"]["exit"])

# Called when the node enters the scene tree for the first time.
func _ready():
	var _list_of_buttons = button_references["default"]["include"].keys()
	
	if OS.has_feature("JavaScript"):
		# Remove/add elements for web export
		if button_references["web"].has("exclude"):
			for _entry in  button_references["web"]["exclude"]:
				_list_of_buttons.erase(_entry) # remove it from the signal connection list
				# find parent of button and delete it
				var _button_to_delete = button_references["default"]["include"][_entry]
				var _parent_to_delete = _button_to_delete.get_parent()
				_parent_to_delete.queue_free()
		else:
			pass
	else:
		pass
	
	# connect the signals of the buttons in the list to the respective functions
	for buttonId in _list_of_buttons:
		var _button = button_references["default"]["include"][buttonId]
		_button.connect("mouse_entered",self,"_on_button_entered_hover_"+buttonId)
		_button.connect("mouse_exited",self,"_on_button_exited_hover_"+buttonId)
		_button.connect("focus_entered",self,"_on_button_entered_hover_"+buttonId)
		_button.connect("focus_exited",self,"_on_button_exited_hover_"+buttonId)
		_button.connect("pressed",self,"_on_button_pressed_"+buttonId)
			



