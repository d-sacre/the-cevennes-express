extends PanelContainer

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _error : int

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var descriptionLabel : Label = $GridContainer/Label
onready var toggleButton : CheckButton = $GridContainer/toggleButton

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(context : String, data : Dictionary) -> void:
	self.toggleButton.initialize(context, data)
	self.descriptionLabel.text = data["description"]

func set_toggle_button_to_default_value() -> void:
	self.toggleButton.set_to_default_value(userSettingsManager.get_user_settings())

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_mouse_entered() -> void:
	self.toggleButton.grab_focus()

func _on_toggle_button_focus_entered() -> void:
	NodeHandling.override_styleboxes(
		self, 
		[
			{
				"override": "panel",
				"stylebox_path": "res://gui/themes/components/slider/tceHSlider_focus-highlight.stylebox"
			}
		]
	)

func _on_toggle_button_focus_exited() -> void:
	NodeHandling.override_styleboxes(
		self, 
		[
			{
				"override": "panel",
				"stylebox_path": "res://gui/themes/components/slider/tceHSlider_default.stylebox"
			}
		]
	)

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	# DESCRIPTION: Connecting parent signals
	self._error = self.connect("mouse_entered", self, "_on_mouse_entered")
	
	# DESCRIPTION: Connecting to child signals
	self._error = toggleButton.connect("focus_entered", self, "_on_toggle_button_focus_entered")
	self._error = toggleButton.connect("focus_exited", self, "_on_toggle_button_focus_exited")
