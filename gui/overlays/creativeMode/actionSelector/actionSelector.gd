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
	{"text": "Replace", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/replace_icon.png"},"default": false, "selectable": true, "disabled": false, "metadata": "user::selected::tile::action::replace"},
	{"text": "Pick", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/pick_icon.png"},"default": false, "selectable": true, "disabled": false, "metadata": "user::selected::tile::action::pick"},
	{"text": "Delete", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/delete_icon.png"},"default": false, "selectable": true, "disabled": false, "metadata": "user::selected::tile::action::delete"},
	{"text": "Hide GUI", "icon": {"path": "res://gui/overlays/creativeMode/actionSelector/icons/hide-gui_icon.png"},"default": false, "selectable": true, "disabled": false, "metadata": "user::selected::gui::hide"}
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
		emit_signal("action_mode", self.tce_signaling_uuid_lut["actions"]["prefix"]+_actionMode, "NONE")

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize(context : String) -> void:
	self._context = context
	self.tce_signaling_uuid_lut["gui"]["string"] = UserInputManager.create_tce_signaling_uuid(self._context, self.tce_signaling_uuid_lut["gui"]["list"])
	self.tce_signaling_uuid_lut["actions"]["prefix"] = UserInputManager.create_tce_signaling_uuid(self._context, [])

func initialize_selection_to_default() -> void:
	var _index = 0 # TO-DO: Add logic to find the default
	self._actionItemList.select(_index, true)
	self._item_selected(_index)

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_mouse_entered() -> void:
	emit_signal("gui_mouse_context", self.tce_signaling_uuid_lut["gui"]["string"], "entered")

func _on_mouse_exited() -> void:
	emit_signal("gui_mouse_context", self.tce_signaling_uuid_lut["gui"]["string"], "exited")

func _on_item_selected(index : int) -> void:
	self._item_selected(index)

func _on_user_input_manager_is_requesting(tce_signaling_uuid : String, value) -> void:
	var _tmp_signaling_keychain : Array  = ["game", "creative", "UserInputManager", "requesting", "global", "execution", "option*"]

	# REMARK: Currently hardcoded to assume that the actionSelector.tscn will only 
	# be used in the game::creative context. To make it more flexible/less 
	# susceptible to errors, the context should also be checked
	if UserInputManager.match_tce_signaling_uuid(tce_signaling_uuid, _tmp_signaling_keychain):
		if value is int:
			var _tmp_index : int = value-1
			self._actionItemList.unselect_all()
			self._actionItemList.select(_tmp_index)
			self._item_selected(_tmp_index)

	_tmp_signaling_keychain = ["game", "creative", "UserInputManager", "requesting", "global", "execution", "change", "tile", "action", "mode", "index", "by"]
	if UserInputManager.match_tce_signaling_uuid(tce_signaling_uuid, _tmp_signaling_keychain):
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

			# # REMARK: DOES NOT WORK
			# if _tmp_index != 4:
			# 	## Approach 1: Execute gui show via UserInputManager (does not work)
			# 	# _tmp_signaling_keychain = ["user", "selected", "gui", "show"]
			# 	# var _tmp_signaling_string : String = UserInputManager.create_tce_signaling_uuid(self._context, _tmp_signaling_keychain)
			# 	# UserInputManager._logic.general_processing_pipeline(tce_signaling_uuid, "actionSelector")

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

	self._actionItemList.set_allow_reselect(true)

	self._actionItemList.select(0,true)
	var _defaultMetadata : String = self._actionItemList.get_item_metadata(0) 
	emit_signal("action_mode", _defaultMetadata)
	self.mode = _defaultMetadata

	# initialize internal signal handling
	self._actionItemList.connect("mouse_entered", self, "_on_mouse_entered")
	self._actionItemList.connect("mouse_exited", self, "_on_mouse_exited")
	self._actionItemList.connect("item_selected", self, "_on_item_selected")

	# initialize signaling from/to User Input Manager
	UserInputManager.connect("user_input_manager_send_public_command", self, "_on_user_input_manager_is_requesting")
	self.connect("action_mode", UserInputManager, "_on_special_user_input")
	self.connect("gui_mouse_context", UserInputManager, "_on_gui_selector_context_changed")
