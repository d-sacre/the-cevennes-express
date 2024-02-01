tool

extends Control

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal gui_mouse_context(context, status)
signal action_mode(mode)

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const ACTION_ITEM_LIST_DEFAULT : Array = [
	{"text": "Place", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/place_icon.png"},"default": true, "selectable": true, "disabled": false, "metadata": "selector::tile::action::place"},
	{"text": "Replace", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/replace_icon.png"},"default": false, "selectable": false, "disabled": true, "metadata": "selector::tile::action::replace"},
	{"text": "Pick", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/pick_icon.png"},"default": false, "selectable": false, "disabled": true, "metadata": "selector::tile::action::pick"},
	{"text": "Delete", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/delete_icon.png"},"default": false, "selectable": false, "disabled": true, "metadata": "selector::tile::action::delete"},
	{"text": "Hide GUI", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/hide-gui_icon.png"},"default": false, "selectable": true, "disabled": false, "metadata": "selector::gui::hide"}
]

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
var mode : String
onready var actionItemList : Object = $PanelContainer/CenterContainer/actionItemList

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################
func _item_selected(index):
	var _is_selectable : bool = not actionItemList.is_item_disabled(index)

	if _is_selectable:
		var _actionMode = actionItemList.get_item_metadata(index)
		self.mode = _actionMode
		emit_signal("action_mode", _actionMode)

func initialize_selection_to_default():
	var _index = 0 # TO-DO: Add logic to find the default
	actionItemList.select(_index,true)
	self._item_selected(_index)

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_mouse_entered():
	emit_signal("gui_mouse_context", "actionSelector", "entered")

func _on_mouse_exited():
	emit_signal("gui_mouse_context", "actionSelector", "exited")

func _on_item_selected(index):
	self._item_selected(index)
	

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready():
	# required due to tool functionality to ensure that the same items are not 
	# instanciated multiple times 
	var _amount_of_items_present = actionItemList.get_item_count()
	if _amount_of_items_present != 0:
		actionItemList.clear()

	var _counter = 0
	for entry in ACTION_ITEM_LIST_DEFAULT:
		var _iconTexture = load(entry["icon"]["path"])
		actionItemList.add_item(entry["text"], _iconTexture, entry["selectable"])
		actionItemList.set_item_disabled(_counter, entry["disabled"])
		actionItemList.set_item_metadata(_counter, entry["metadata"])
		_counter += 1

	actionItemList.select(0,true)
	var _defaultMetadata : String = actionItemList.get_item_metadata(0) 
	emit_signal("action_mode",_defaultMetadata)
	self.mode = _defaultMetadata

	actionItemList.connect("mouse_entered", self, "_on_mouse_entered")
	actionItemList.connect("mouse_exited", self, "_on_mouse_exited")
	actionItemList.connect("item_selected", self, "_on_item_selected")
