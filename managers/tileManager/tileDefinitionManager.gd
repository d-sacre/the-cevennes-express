extends Node

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
var FIO : Resource = load("res://managers/tileManager/utils/tileManager_json_fio_handling.gd")
var fio = FIO.new()

const TILE_DEFINITION_DATABASE_INDEX_RESOURCE_PATH = "res://assets/3D/tiles/definitions/tile_database_index.json"

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
# public members
var tile_definition_database : Dictionary = {}

################################################################################
#### Private Member Variables ##################################################
################################################################################

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################

func _initialize_tile_definition_database(db_index_fp) -> Dictionary:
	var _tile_definition_database_index : Dictionary = fio.load_json(db_index_fp)
	var _tile_definition_db_file_list : Array = _tile_definition_database_index["TILE_DEFINITION_RESOURCE_PATHS"]

	var _tmp_tile_definition_db : Dictionary = {}

	# load all the tile definition files specified in the database index 
	# and store the information in the tile definition database
	for fp in _tile_definition_db_file_list:
		var _tmp_file_content = fio.load_json(fp)
		var _tmp_tddb_entry : Dictionary = {}
		var _keys = _tmp_file_content.keys()

		for _key in _keys:
			if _key != "TILE_DEFINITION_UUID":
				# for all dictionary entries except "TILE_DEFINITION_UUID"
				# copy the data into the new temporary db entry dictionary
				_tmp_tddb_entry[_key] = _tmp_file_content[_key]

		# obtain the "TILE_DEFINITION_UUID" and use it as key to add temporary
		# db entry dictionary to output db dictionary
		var _tile_definition_uuid = _tmp_file_content["TILE_DEFINITION_UUID"]
		_tmp_tile_definition_db[_tile_definition_uuid] = _tmp_tddb_entry

	return _tmp_tile_definition_db

func get_tile_definition_database_entry(tile_definition_uuid) -> Dictionary:
    var _tmp_tddb_entry = self.tile_definition_database[tile_definition_uuid]
    _tmp_tddb_entry["TILE_DEFINITION_UUID"] = tile_definition_uuid

    return _tmp_tddb_entry

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready() -> void:
	tile_definition_database = _initialize_tile_definition_database(TILE_DEFINITION_DATABASE_INDEX_RESOURCE_PATH)
