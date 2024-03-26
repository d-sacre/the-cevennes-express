extends Control

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
var _bbcodeparser = dictionaryToBBCodeParser.new()

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var _richtextLabel : RichTextLabel = $PanelContainer/creditsPopup_VBoxContainer/creditsContentRichTextLabel

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	var _credits = JsonFio.load_json("res://gui/menus/main/components/root/credits.json")
	_richtextLabel.bbcode_enabled = true
	_richtextLabel.bbcode_text = _bbcodeparser.parse_dictionary_to_bbcode(_credits)
