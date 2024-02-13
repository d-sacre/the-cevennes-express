extends Node

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const TILE_DEFINITION_DATABASE_INDEX_RESOURCE_PATH = "res://assets/3D/tiles/placeable/definitions/tile_database_index.json"

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _tile_definition_database : Dictionary = {}

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _initialize_tile_definition_database(db_index_fp) -> Dictionary:
	var _tile_definition_database_index : Dictionary = JsonFio.load_json(db_index_fp)
	var _tile_definition_db_file_list : Array = _tile_definition_database_index["TILE_DEFINITION_RESOURCE_PATHS"]

	var _tmp_tile_definition_db : Dictionary = {}

	# load all the tile definition files specified in the database index 
	# and store the information in the tile definition database
	for fp in _tile_definition_db_file_list:
		var _tmp_file_content = JsonFio.load_json(fp)
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

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func get_tile_definition_database_entry(tile_definition_uuid : String) -> Dictionary:
	var _tmp_tddb_entry = self._tile_definition_database[tile_definition_uuid]
	_tmp_tddb_entry["TILE_DEFINITION_UUID"] = tile_definition_uuid

	return _tmp_tddb_entry

func get_tile_definition_database() -> Dictionary:
	return _tile_definition_database

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready() -> void:
	_tile_definition_database = _initialize_tile_definition_database(TILE_DEFINITION_DATABASE_INDEX_RESOURCE_PATH)