extends GridContainer

var _error : int

onready var descriptionLabel : Label = $Label
onready var toggleButton : CheckButton = $toggleButton


func initialize(context : String, data : Dictionary) -> void:
	self.toggleButton.initialize(context, data)
	self.descriptionLabel.text = data["description"]

func set_toggle_button_to_default_value() -> void:
	self.toggleButton.set_to_default_value(userSettingsManager.get_user_settings())
