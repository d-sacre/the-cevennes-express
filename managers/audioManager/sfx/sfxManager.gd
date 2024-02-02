#tool
extends Node

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# The scene this script is attached to is autoloaded as "sfxManager".
# The scene and this script require the following other scenes/scripts to be 
# autoloaded in the following order before this scene can be autoloaded:
# "JsonFio": res://utils/fileHandling/json_fio.gd
# "DictionaryParsing": res://utils/dataHandling/dictionaryParsing.gd
# "AudioManagerNodeHandling": res://managers/audioManager/utils/audioManager_node-handling.gd
# "sfxManager": res://managers/audioManager/sfx/sfxManager.tscn

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _sfx : Dictionary = {}

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func play_sound(keyChain : Array) -> void:
	var _tmp_keyChain = keyChain
	_tmp_keyChain.append("nodePath")
	var _tmp_node_path = DictionaryParsing.get_dict_element_via_keychain(self._sfx, keyChain)
	get_node(_tmp_node_path).play()

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready() -> void:
	print("=> AutoLoading Managers...")
	print("\t-> Initialize sfxManager...")
	# loading all the sounds from the json file
	print("\t\t-> Loading SFX Database...\n\t\t-> Creating SFX Categories and AudioStreamPlayers...")
	self._sfx = JsonFio.load_json("res://managers/audioManager/sfx/sfx.json")
	var _sfx_objects : Array = self._sfx.keys()
	
	# TO-DO: Has to be refined to cover more general cases! Currently hardcoded for a very specific tree structure
	for _object in _sfx_objects:
		var _sfx_subobject_key_list : Array = self._sfx[_object].keys()

		# create categories
		if not self._sfx[_object].has("fp"): # if the entry is not a data entry but a true category
			if self.has_node(_object): # category already exists
				pass
			else: # category does not already exist
				AudioManagerNodeHandling.add_category_node(self, sfxManager, _object)

		for _subobject in _sfx_subobject_key_list:
			if self._sfx[_object][_subobject].has("fp"): # if it is not a sub subobject, but settings data
				pass
			else: # object contains a subcategory

				var _sfx_subsubobject_key_list : Array = self._sfx[_object][_subobject].keys()

				# Create subcategories
				if not self._sfx[_object][_subobject].has("fp"): # if the entry is not a data entry but a true subcategory
					if self.has_node(_subobject): # subcategory already exists
						pass
					else: # subcategory does not already exist
						AudioManagerNodeHandling.add_category_node(self, _object, _subobject)

				for _subsubobject in _sfx_subsubobject_key_list:
					if self._sfx[_object][_subobject][_subsubobject].has("fp"): # if it is not a subsub subobject, but settings data
						var _sfx_object_name = _subsubobject # create the subobject name ; old: subobject + "_" +
						var _sfx_object_node_path = _object + "/" + _subobject + "/" + _sfx_object_name # create the node path
						self._sfx[_object][_subobject][_subsubobject]["nodePath"] = _sfx_object_node_path # add the node path to the dictionary entry
						AudioManagerNodeHandling.add_and_configure_AudioStreamPlayer(self,self._sfx[_object][_subobject][_subsubobject], _object+"/"+_subobject, _sfx_object_name)
					else:
						if self.has_node(_subsubobject): # subcategory already exists
							pass
						else: # subcategory does not already exist
							AudioManagerNodeHandling.add_category_node(self, _subobject, _subsubobject)



