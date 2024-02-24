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
signal gui_mouse_context_changed(tce_event_uuid, value)
signal action_mode_changed(tce_event_uuid, value)

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const ACTION_ITEM_LIST_DEFAULT : Array = [
	{"text": "Place", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/place_icon.png"},"default": true, "selectable": true, "disabled": false, "metadata": "user::selected::tile::action::place"},
	{"text": "Replace", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/replace_icon.png"},"default": false, "selectable": true, "disabled": false, "metadata": "user::selected::tile::action::replace"},
	{"text": "Pick", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/pick_icon.png"},"default": false, "selectable": true, "disabled": false, "metadata": "user::selected::tile::action::pick"},
	{"text": "Delete", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/delete_icon.png"},"default": false, "selectable": true, "disabled": false, "metadata": "user::selected::tile::action::delete"},
	{"text": "Hide GUI", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/hide-gui_icon.png"},"default": false, "selectable": true, "disabled": false, "metadata": {"hide": "user::selected::gui::hide", "show": "user::selected::gui::show"}}
]

################################################################################
#### PUBLIC MEMBER VARIABLES ###################################################
################################################################################
var tce_signaling_uuid_lut : Dictionary = {
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
var _mode : String

var _error : int

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var _actionItemList : ItemList = $PanelContainer/CenterContainer/actionItemList
onready var _canvasLayerParent : CanvasLayer = get_parent().get_parent()

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _item_selected(index : int) -> void:
	var _is_selectable : bool = not self._actionItemList.is_item_disabled(index)

	if _is_selectable:
		var _actionMode : String

		# DESCRIPTION: As long as index does not equal "Hide GUI", simply obtain
		# the metadata string directly
		# REMARK: Should be solved with an enum, to ensure that even if the amount 
		# of buttons changes, always the correct condition is met!
		if index != 4:
			_actionMode = self._actionItemList.get_item_metadata(index)
		else: 
			# DESCRIPTION: If item selected is "Hide GUI", obtain the metadata from 
			# dictionary by comparing the visibility status of Canvas Layer parent
			if self._canvasLayerParent.visible:
				_actionMode = self._actionItemList.get_item_metadata(index)["hide"]
			else:
				_actionMode = self._actionItemList.get_item_metadata(index)["show"]

		self._mode = _actionMode
		emit_signal("action_mode_changed", self.tce_signaling_uuid_lut["actions"]["prefix"]+_actionMode, "NONE")

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(context : String) -> void:
	self._context = context
	self.tce_signaling_uuid_lut["gui"]["string"] = UserInputManager.create_tce_event_uuid(self._context, self.tce_signaling_uuid_lut["gui"]["list"])
	self.tce_signaling_uuid_lut["actions"]["prefix"] = UserInputManager.create_tce_event_uuid(self._context, [])

func initialize_selection_to_default() -> void:
	var _index = 0 # TO-DO: Add logic to find the default

	# REMARK: Safety to ensure only one item at a time can be selected
	self._actionItemList.unselect_all() 
	self._actionItemList.select(_index, true)
	self._item_selected(_index)

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_mouse_entered() -> void:
	emit_signal("gui_mouse_context_changed", self.tce_signaling_uuid_lut["gui"]["string"], "entered")

func _on_mouse_exited() -> void:
	emit_signal("gui_mouse_context_changed", self.tce_signaling_uuid_lut["gui"]["string"], "exited")

func _on_item_selected(index : int) -> void:
	self._item_selected(index)

func _on_user_input_manager_global_command(tce_event_uuid : String, value) -> void:
	var _tmp_eventKeychain : Array  = ["game", "creative", "UserInputManager", "requesting", "global", "execution", "option*"]

	# REMARK: Currently hardcoded to assume that the actionSelector.tscn will only 
	# be used in the game::creative context. To make it more flexible/less 
	# susceptible to errors, the context should also be checked
	if UserInputManager.match_tce_event_uuid(tce_event_uuid, _tmp_eventKeychain):
		if value is int:
			var _tmp_index : int = value-1
			self._actionItemList.unselect_all()
			self._actionItemList.select(_tmp_index)
			self._item_selected(_tmp_index)

	_tmp_eventKeychain = ["game", "creative", "UserInputManager", "requesting", "global", "execution", "change", "tile", "action", "mode", "index", "by"]
	if UserInputManager.match_tce_event_uuid(tce_event_uuid, _tmp_eventKeychain):
		if value is int:
			var _itemCount : int = self._actionItemList.get_item_count()
			var _currentIndex : int = (self._actionItemList.get_selected_items())[0]

			var _tmp_index : int = _currentIndex + value

			if _tmp_index > _itemCount - 1:
				_tmp_index = 0
			if _tmp_index < 0:
				_tmp_index = _itemCount - 1

			# REMARK: Has to be placed here, because placing it later in the chain would overwrite
			# the correct action mode
			if _tmp_index != 4:
				# Approach 2: Execute gui show directly via game class
				UserInputManager._logic._hide_gui_creative_mode(false)

			self._actionItemList.unselect_all()
			self._actionItemList.select(_tmp_index)
			self._item_selected(_tmp_index)

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready() -> void:
	# DESCRIPTION: Find the amount of already present items and delete them
	# REMARK: Required due to tool functionality to ensure that the same items 
	# are not instanciated multiple times when the game is started
	var _amount_of_items_present = self._actionItemList.get_item_count()
	if _amount_of_items_present != 0:
		self._actionItemList.clear()

	# DESCRIPTION: Add each item defined in the default dictionary to the list
	var _counter = 0
	for _entry in self.ACTION_ITEM_LIST_DEFAULT:
		var _iconTexture = load(_entry["icon"]["path"])
		self._actionItemList.add_item(_entry["text"], _iconTexture, _entry["selectable"])
		self._actionItemList.set_item_disabled(_counter, _entry["disabled"])
		self._actionItemList.set_item_metadata(_counter, _entry["metadata"])
		_counter += 1

	# DESCRIPTION: Allow reselection
	# REMARK: Should help with issues if user selects a Tile Definition in the 
	# Tile Definition Window while in Tile Action Mode "pick"
	self._actionItemList.set_allow_reselect(true)

	# DESCRIPTION: Set default and announce the setting, so that a global update
	# of all affected objects can occur
	# REMARK: Default currently hardcoded to "place"
	self.initialize_selection_to_default()

	# DESCRIPTION: Initialize internal signal handling
	self._error = self._actionItemList.connect("mouse_entered", self, "_on_mouse_entered")
	self._error = self._actionItemList.connect("mouse_exited", self, "_on_mouse_exited")
	self._error = self._actionItemList.connect("item_selected", self, "_on_item_selected")

	# DESCRIPTION: Initialize signaling from/to User Input Manager
	self._error = UserInputManager.connect("transmit_global_event", self, "_on_user_input_manager_global_command")
	self._error = self.connect("action_mode_changed", UserInputManager, "_on_special_user_input")
	self._error = self.connect("gui_mouse_context_changed", UserInputManager, "_on_gui_context_changed")
