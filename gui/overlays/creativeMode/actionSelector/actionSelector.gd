tool

extends Control

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal gui_mouse_context(tce_signaling_uuid, value)
signal action_mode(tce_signaling_uuid, value)

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const ACTION_ITEM_LIST_DEFAULT : Array = [
	{"text": "Place", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/place_icon.png"},"default": true, "selectable": true, "disabled": false, "metadata": "user::selected::tile::action::place"},
	{"text": "Replace", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/replace_icon.png"},"default": false, "selectable": false, "disabled": true, "metadata": "user::selected::tile::action::replace"},
	{"text": "Pick", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/pick_icon.png"},"default": false, "selectable": false, "disabled": true, "metadata": "user::selected::tile::action::pick"},
	{"text": "Delete", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/delete_icon.png"},"default": false, "selectable": false, "disabled": true, "metadata": "user::selected::tile::action::delete"},
	{"text": "Hide GUI", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/hide-gui_icon.png"},"default": false, "selectable": true, "disabled": false, "metadata": "user::selected::gui::hide"}
]

################################################################################
#### PUBLIC MEMBER VARIABLES ###################################################
################################################################################
var tce_signaling_uuid : Dictionary = {
	"gui": {
		"list" : ["gui", "hud", "selector", "action"],
		"string": ""
	},
	"actions" : {
		"prefix": ""
	}
}

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _context : String
var mode : String

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var _actionItemList : Object = $PanelContainer/CenterContainer/actionItemList

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _item_selected(index : int) -> void:
	var _is_selectable : bool = not self._actionItemList.is_item_disabled(index)

	if _is_selectable:
		var _actionMode = self._actionItemList.get_item_metadata(index)
		self.mode = _actionMode
		emit_signal("action_mode", self.tce_signaling_uuid["actions"]["prefix"]+_actionMode, "NONE")

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(context : String) -> void:
	self._context = context
	self.tce_signaling_uuid["gui"]["string"] = UserInputManager.create_tce_signaling_uuid(self._context, self.tce_signaling_uuid["gui"]["list"])
	self.tce_signaling_uuid["actions"]["prefix"] = UserInputManager.create_tce_signaling_uuid(self._context, [])

func initialize_selection_to_default() -> void:
	var _index = 0 # TO-DO: Add logic to find the default
	self._actionItemList.select(_index, true)
	self._item_selected(_index)

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_mouse_entered() -> void:
	emit_signal("gui_mouse_context", self.tce_signaling_uuid["gui"]["string"], "entered")

func _on_mouse_exited() -> void:
	emit_signal("gui_mouse_context", self.tce_signaling_uuid["gui"]["string"], "exited")

func _on_item_selected(index : int) -> void:
	self._item_selected(index)
	
################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	# required due to tool functionality to ensure that the same items are not 
	# instanciated multiple times 
	var _amount_of_items_present = self._actionItemList.get_item_count()
	if _amount_of_items_present != 0:
		self._actionItemList.clear()

	var _counter = 0
	for _entry in ACTION_ITEM_LIST_DEFAULT:
		var _iconTexture = load(_entry["icon"]["path"])
		self._actionItemList.add_item(_entry["text"], _iconTexture, _entry["selectable"])
		self._actionItemList.set_item_disabled(_counter, _entry["disabled"])
		self._actionItemList.set_item_metadata(_counter, _entry["metadata"])
		_counter += 1

	self._actionItemList.select(0,true)
	var _defaultMetadata : String = self._actionItemList.get_item_metadata(0) 
	emit_signal("action_mode", _defaultMetadata)
	self.mode = _defaultMetadata

	# initialize internal signal handling
	self._actionItemList.connect("mouse_entered", self, "_on_mouse_entered")
	self._actionItemList.connect("mouse_exited", self, "_on_mouse_exited")
	self._actionItemList.connect("item_selected", self, "_on_item_selected")

	# initialize signaling to User Input Manager
	self.connect("action_mode", UserInputManager, "_on_user_selected")
	self.connect("gui_mouse_context", UserInputManager, "_on_gui_selector_context_changed")
