extends Control

const TILE_LIST_ICON_SIZE_DEFAULT : Vector2 = Vector2(128,128)

onready var tileDefinitionManager : Object = $tileDefinitionManager # only in the testing setup; later has to be inherited from main.gd
var tileList : ItemList

var tileListIconSize : Vector2 = Vector2(128,128)

var _tileDatabase : Dictionary = {}

func initialize_tile_list():
	print("Initializing Tile List...")

	_tileDatabase = tileDefinitionManager.tile_definition_database
	var _keys = _tileDatabase.keys()

	var _counter = 1
	for _key in _keys:
		var _tileTexturePath = _tileDatabase[_key]["TEXTURE_RESOURCE_PATH"]

		# adapted from: https://forum.godotengine.org/t/load-texture-from-file-and-assign-to-texture/22655/2
		# load the original tile texture as image
		var _image : Image = Image.new()
		_image.load(_tileTexturePath)
		
		# create a new image with the correct size and format as well as a suiting crop rectangle
		# REMARK: MAGIC NUMBERS SHOULD NOT BE HARDCODED, BUT DEFINED AS CONSTANTS
		var _imageCropped : Image = Image.new()
		_imageCropped.create(512,1024-430, true, _image.get_format())
		var _imageCropRectangle = Rect2(Vector2(0,430),Vector2(512,1024-430))
		
		# crop the original tile texture to rectangle and copy clipped data to upper left corner of new image
		_imageCropped.blit_rect(_image, _imageCropRectangle, Vector2(0,0))

		# REMARK: GODOT 3 DOES NOT NATIVELY SUPPORT ROTATION OF IMAGES OR TEXTURES; HAS TO BE
		# HACKED INTO IT WITH A THUMBNAIL CREATION AT LOADTIME VIA SHADER AND IMAGE SAVING 

		_imageCropped.flip_x()
		_imageCropped.flip_y()

		# create an ImageTexture from the cropped image
		var _iconTexture = ImageTexture.new()
		_iconTexture.create_from_image(_imageCropped, 0)

		tileList.add_item("Tile "+str(_counter), _iconTexture, true)
		_counter += 1


# Called when the node enters the scene tree for the first time.
func _ready():
	tileList = $PanelContainer/GridContainer/tileList

	# set icon size accordingly to amount of columns
	var tileListWidth = tileList.get_size().x
	var tileListMaxColumns = tileList.get_max_columns()
	var tileListIconWidth = 0.925*(tileListWidth/tileListMaxColumns)

	tileListIconSize = Vector2(tileListIconWidth,tileListIconWidth)
	tileList.set_fixed_icon_size(tileListIconSize)
	# tileList.ensure_current_is_visible() # not working
	self.initialize_tile_list() # only in the testing setup; later has to be called from main.gd


