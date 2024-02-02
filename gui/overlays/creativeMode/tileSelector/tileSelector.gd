extends Control

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal new_selection(tile_definition_uuid)
signal gui_mouse_context(context, status)

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const TILE_LIST_ICON_SIZE_DEFAULT : Vector2 = Vector2(128,128)

################################################################################
#### PUBLIC MEMBER VARIABLES ###################################################
################################################################################
var selectedTile : String = ""
var tileListIconSize : Vector2 = TILE_LIST_ICON_SIZE_DEFAULT

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
# var tileDefinitionManager : Object  # only in the testing setup; later has to be inherited from main.gd
var _tileList : ItemList
var _tileDatabase : Dictionary = {}

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

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize_tile_list(_tileDefinitionManager : Object) -> void:
	print("Initializing Tile List...")

	self._tileDatabase = _tileDefinitionManager.get_tile_definition_database()
	var _keys = _tileDatabase.keys()

	var _counter = 0
	for _key in _keys:
		var _tileTexturePath = _tileDatabase[_key]["TEXTURE_RESOURCE_PATH"]
		var _tileDefinitionUUID = _key

		var _iconTexture = _create_icon_texture(_tileTexturePath)
		self._tileList.add_item("Tile "+str(_counter), _iconTexture, true)
		self._tileList.set_item_metadata(_counter, _tileDefinitionUUID)
		_counter += 1
	
	self._tileList.select(0,true)
	self.selectedTile = _tileList.get_item_metadata(0)

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_item_selected(index : int) -> void:
	self.selectedTile = self._tileList.get_item_metadata(index)
	emit_signal("new_selection", self.selectedTile)

func _on_mouse_entered() -> void:
	emit_signal("gui_mouse_context", "tileSelector", "entered")

func _on_mouse_exited() -> void:
	emit_signal("gui_mouse_context", "tileSelector", "exited")

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready() -> void:
	self._tileList = $PanelContainer/GridContainer/tileList

	# initialize signal handling
	self._tileList.connect("item_selected", self, "_on_item_selected")
	self._tileList.connect("mouse_entered", self, "_on_mouse_entered")
	self._tileList.connect("mouse_exited", self, "_on_mouse_exited")

	# set icon size accordingly to amount of columns
	var _tileListWidth = _tileList.get_size().x
	var _tileListMaxColumns = _tileList.get_max_columns()
	var _tileListIconWidth = 0.925*(_tileListWidth/_tileListMaxColumns)

	self.tileListIconSize = Vector2(_tileListIconWidth,_tileListIconWidth)
	self._tileList.set_fixed_icon_size(self.tileListIconSize)
	


