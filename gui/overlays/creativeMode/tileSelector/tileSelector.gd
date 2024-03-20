extends Control

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal new_tile_definition_selected(tce_event_uuid, tile_definition_uuid)
signal gui_mouse_context_changed(context, status)

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const TILE_LIST_ICON_SIZE_DEFAULT : Vector2 = Vector2(128,128)

################################################################################
#### PUBLIC MEMBER VARIABLES ###################################################
################################################################################
var selectedTile : String = ""
var tileListIconSize : Vector2 = TILE_LIST_ICON_SIZE_DEFAULT

var tce_event_and_gui_uuid_lut : Dictionary = {
	"gui": {
		"list": ["gui", "sidepanel", "right", "selector", "tile", "definition"],
		"string": ""
	},
	"actions" : {
		"new_tile_definition_selected": {
			"list": ["user", "selected", "tile", "definition"],
			"string": ""
		}
	}
}

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
# var tileDefinitionManager : Object  # only in the testing setup; later has to be inherited from main.gd
var _tileList : ItemList
var _tileDatabase : Dictionary = {}
var _tile_tduuid_to_list_index_lut : Dictionary = {}

var _context : String 

var _lastSelectionAsmr : Vector2 = Vector2(0,0)
var _asmrRepetitionAllowed : bool = false
var _asmr_repetition_delay : float = 0.75

var _visible : bool = true

var _error : int 

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var _asmrRepetitionDelayTimer : Timer = $asmrRepetitionDelayTimer

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _create_icon_texture(fp : String) -> ImageTexture:
	# adapted from: https://forum.godotengine.org/t/load-texture-from-file-and-assign-to-texture/22655/2
	# REMARK: In theory, one could load an image directly
	# var _image : Image = Image.new()
	# _image.load(_tileTexturePath)
	# However, there occurs the warning message
	# load: Loaded resource as image file, this will not work on export: <FILENAME>. 
	# Instead, import the image file as an Image resource and load it normally as a resource.
	# The result is a black image in the exported game
	# Workaround required for Godot 3: Load as texture and than copy to image
	# However, this simple approach breaks the clipping to the content logic, because the tile base texture
	# will be imported without alpha channel, so that the cropping to content via alpha clipping will result
	# in a black border instead of transparency. To fix this, one needs to convert the image to contain alpha
	# information; the easiest way to do so is to copy the format of the mask
	var texture = load(fp)
	var _image = Image.new()
	_image = texture.get_data()

	# loading the content mask as a texture and converting it to an image
	var mask = load("res://gui/overlays/creativeMode/tileSelector/hexagonTile_mask.png")
	var _imageIconContentMask : Image = Image.new()
	_imageIconContentMask = mask.get_data()
	var _contentMaskFormat = _imageIconContentMask.get_format()

	# create image that only contains the top side of the hexagon texture
	# REMARK: MAGIC NUMBERS SHOULD NOT BE HARDCODED, BUT DEFINED AS CONSTANTS
	var _imageIconContentOnly: Image = Image.new()
	_imageIconContentOnly.create(1024,1024,true, _contentMaskFormat)
	_image.convert(_contentMaskFormat) # convert tile texture to format with transparency
	_imageIconContentOnly.blit_rect_mask(_image, _imageIconContentMask, Rect2(Vector2(0,0), Vector2(1024,1024)), Vector2(0,0))
	
	# create a new image with the correct size and format as well as a suiting crop rectangle
	# REMARK: MAGIC NUMBERS SHOULD NOT BE HARDCODED, BUT DEFINED AS CONSTANTS
	var _imageCropped : Image = Image.new()
	_imageCropped.create(512,1024-430, true, _image.get_format())
	var _imageCropRectangle = Rect2(Vector2(0,430),Vector2(512,1024-430))
	
	# crop the original tile texture to rectangle and copy clipped data to upper left corner of new image
	_imageCropped.blit_rect(_imageIconContentOnly, _imageCropRectangle, Vector2(0,0))

	# REMARK: GODOT 3 DOES NOT NATIVELY SUPPORT ROTATION OF IMAGES OR TEXTURES; HAS TO BE
	# HACKED INTO IT WITH A THUMBNAIL CREATION AT LOADTIME VIA SHADER AND IMAGE SAVING 
	_imageCropped.flip_x()
	_imageCropped.flip_y()

	# create an ImageTexture from the cropped image
	var _iconTexture = ImageTexture.new()
	_iconTexture.create_from_image(_imageCropped, 0)

	return _iconTexture

func _select_item(index : int) -> void:
	self.selectedTile = self._tileList.get_item_metadata(index)
	emit_signal("new_tile_definition_selected", self.tce_event_and_gui_uuid_lut["actions"]["new_tile_definition_selected"]["string"], self.selectedTile)


func _select_tile_definition_by_asmr(asmr : Vector2) -> void:
	if self._lastSelectionAsmr != asmr:
		self._lastSelectionAsmr = asmr

		if self._lastSelectionAsmr != Vector2(0,0):
			self._asmrRepetitionAllowed = true

			if self._asmrRepetitionDelayTimer.is_stopped():
				self._asmrRepetitionDelayTimer.start(self._asmr_repetition_delay)
		else:
			self._asmrRepetitionAllowed = false

			if not self._asmrRepetitionDelayTimer.is_stopped():
				self._asmrRepetitionDelayTimer.stop()
			

	if self._lastSelectionAsmr != Vector2(0,0):
		var _maxColumns : int = self._tileList.get_max_columns()
		var _itemCount : int = self._tileList.get_item_count()
		var _currentIndex : int = (self._tileList.get_selected_items())[0]
		var ci : Object = convert_indices.new(_maxColumns)

		var _tmp_index2D : Vector2 = ci.from_1D_to_2D(_currentIndex)
		_tmp_index2D += asmr * Vector2(-1,-1)
		var _tmp_index1D : int = ci.from_2D_to_1D(_tmp_index2D)

		# DESCRIPTION: Manage out of bounds at beginning/end of list
		if _tmp_index1D <= _itemCount - 1:
			if _tmp_index1D >= 0:
				pass
			else:
				_tmp_index1D = _itemCount - 1
		else:
			_tmp_index1D = 0

		self._select_item(_tmp_index1D)

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize_tile_list(_tileDefinitionManager : Object) -> void:
	print("\t\t\t-> Initializing Tile Definition Selection List...")
	print("\t\t\t\t-> Creating Tile Thumbnails...")

	self._tileDatabase = _tileDefinitionManager.get_tile_definition_database()
	var _keys = _tileDatabase.keys()

	var _counter = 0
	for _key in _keys:
		var _tileTexturePath = _tileDatabase[_key]["TEXTURE_RESOURCE_PATH"]
		var _tileDefinitionUUID = _key

		var _iconTexture = _create_icon_texture(_tileTexturePath)
		self._tileList.add_item("Tile "+str(_counter), _iconTexture, true)
		self._tileList.set_item_metadata(_counter, _tileDefinitionUUID)
		self._tile_tduuid_to_list_index_lut[_tileDefinitionUUID] = _counter
		_counter += 1
	
	print("\t\t\t\t-> Setting Defaults...")
	self._tileList.select(0,true)
	self.selectedTile = _tileList.get_item_metadata(0)

func initialize(context : String, tdm : Object) -> void:
	self.initialize_tile_list(tdm)
	self._context = context
	self.tce_event_and_gui_uuid_lut["gui"]["string"] = UserInputManager.create_tce_event_uuid(self._context, self.tce_event_and_gui_uuid_lut["gui"]["list"])
	self.tce_event_and_gui_uuid_lut["actions"]["new_tile_definition_selected"]["string"] = UserInputManager.create_tce_event_uuid(self._context, self.tce_event_and_gui_uuid_lut["actions"]["new_tile_definition_selected"]["list"])

	# DESCRIPTION: Required to set proper initialization value of _curentTileDefinitionUUID
	# REMARK: Hopefully a temporary solution? Perhaps use UserInputManager command bus?
	var _index : int = (self._tileList.get_selected_items())[0]
	var _tmp_uuid : String = self._tileList.get_item_metadata(_index)
	UserInputManager._curentTileDefinitionUUID = _tmp_uuid

func is_visible() -> bool:
	return self._visible

func deactivate_and_hide() -> void:
	# FUTURE: Deactivate tile selection for additional safety and perhaps play hiding animation
	# self.visible = false
	# print_debug("Slide ")
	TransitionManager.slide_element_out_to_right_center(self)
	self._visible = false

func reactivate_and_unhide() -> void:
	# if not self.visible:
	# 	# FUTURE: Activate tile selection for additional safety and perhaps play unhiding animation
	# 	self.visible = true
	if not self.is_visible():
		TransitionManager.slide_element_in_from_right_center(self)
		self._visible = true



################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_item_selected(index : int) -> void:
	self._select_item(index)

func _on_mouse_entered() -> void:
	emit_signal("gui_mouse_context_changed", self.tce_event_and_gui_uuid_lut["gui"]["string"], "entered")

func _on_mouse_exited() -> void:
	emit_signal("gui_mouse_context_changed", self.tce_event_and_gui_uuid_lut["gui"]["string"], "exited")

func _on_asmr_repetition_timeout() -> void:
	if self._asmrRepetitionAllowed:
		self._select_tile_definition_by_asmr(self._lastSelectionAsmr)

func _on_user_input_manager_global_command(tce_event_uuid : String, value) -> void:
	var _tmp_eventKeychain : Array = ["game", "creative", "UserInputManager", "requesting", "global", "update", "tile", "definition", "uuid"]
	if UserInputManager.match_tce_event_uuid(tce_event_uuid, _tmp_eventKeychain):
		if value is String:
			var _tmp_list_index : int = self._tile_tduuid_to_list_index_lut[value]
			self._tileList.unselect_all()
			self._tileList.select(_tmp_list_index)
			self._tileList.ensure_current_is_visible()

	_tmp_eventKeychain = ["game", "creative", "UserInputManager", "requesting", "global", "update", "tile", "definition", "selector", "position"]
	if UserInputManager.match_tce_event_uuid(tce_event_uuid, _tmp_eventKeychain):
		if value is Vector2:
			self._select_tile_definition_by_asmr(value)

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready() -> void:
	self._tileList = $PanelContainer/MarginContainer/GridContainer/tileList

	# initialize internal signal handling
	self._tileList.connect("item_selected", self, "_on_item_selected")
	self._tileList.connect("mouse_entered", self, "_on_mouse_entered")
	self._tileList.connect("mouse_exited", self, "_on_mouse_exited")

	# internal for asmr repetition
	self._asmrRepetitionDelayTimer.set_wait_time(self._asmr_repetition_delay)
	self._error = self._asmrRepetitionDelayTimer.connect("timeout", self, "_on_asmr_repetition_timeout")

	# initialize signaling from/to User Input Manager
	UserInputManager.connect("transmit_global_event", self, "_on_user_input_manager_global_command")
	self.connect("new_tile_definition_selected", UserInputManager, "_on_special_user_input")
	self.connect("gui_mouse_context_changed", UserInputManager, "_on_gui_context_changed")

	# set icon size accordingly to amount of columns
	var _tileListWidth = _tileList.get_size().x
	var _tileListMaxColumns = _tileList.get_max_columns()
	var _tileListIconWidth = 0.925*(_tileListWidth/_tileListMaxColumns)

	self.tileListIconSize = Vector2(_tileListIconWidth,_tileListIconWidth)
	self._tileList.set_fixed_icon_size(self.tileListIconSize)
	self._tileList.set_allow_reselect(true)
	


