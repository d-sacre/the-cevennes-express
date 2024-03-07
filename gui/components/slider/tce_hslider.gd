extends Control

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "userSettingsManager": res://managers/userSettingsManager/userSettingsManager.tscn

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const FONT_MODULATE_DISABLED = Color8(120,120,120, 255)

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _context : String

var _disabled : bool

var _description : String = ""
var _value : String = ""
var _valueMax
var _unit : String = ""
var _valueSeperator : String = "/"

var _error : int

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var hSlider : HSlider = $GridContainer/HSlider
onready var descriptionLabel : Label = $GridContainer/descriptionLabel
onready var valueLabel : Label = $GridContainer/valueLabel

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _set_description_label_text(text : String) -> void:
	self._description = text
	self.descriptionLabel.text = self._description

func _set_value_label_text(value : String) -> void:
	self._value = value
	# REMARK: Needs to be changed as it will cause issues, e.g. if the number is in range 0...1
	self.valueLabel.text = self._value + self._valueSeperator + str(int(self._valueMax))

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
# REMARK: Seems to be called in menuGameMainPopupSettings.gd::_initialize()
# before the onready vars are valid
func initialize(context : String, data : Dictionary) -> void:
	self._context = context

	self._disabled = data["disabled"]

	# DESCRIPTION: Modulate the font color when disabled
	if self._disabled:
		self.descriptionLabel.modulate = self.FONT_MODULATE_DISABLED
		self.valueLabel.modulate = self.FONT_MODULATE_DISABLED

	# DESCRIPTION: Initializing the labels
	self._set_description_label_text(data["description"])
	self._valueMax = data["max"]
	# REMARK: Needs to be changed as it will cause issues, e.g. if the number is in range 0...1
	self._set_value_label_text(str(int(0)))

	# DESCRIPTION: Initializing the slider
	self.hSlider.initialize(self._context, data)

func set_slider_to_default_value() -> void:
	self.hSlider.set_to_default_value(userSettingsManager.get_user_settings())

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_slider_value_changed(value) -> void:
	self._set_value_label_text(str(int(value)))

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	self._error = hSlider.connect("value_changed", self, "_on_slider_value_changed")
