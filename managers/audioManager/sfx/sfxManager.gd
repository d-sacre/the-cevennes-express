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
#### VARIABLE DEFINITIONS ######################################################
################################################################################
var sfx : Dictionary = {}

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################
func play_sound(keyChain):
	var tmp_keyChain = keyChain
	tmp_keyChain.append("nodePath")
	var tmp_node_path = DictionaryParsing.get_dict_element_via_keychain(sfx, keyChain)
	# print("Playing ", keyChain, ", Bus: ", get_node(tmp_node_path).get_bus())
	get_node(tmp_node_path).play()

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready():
	print("=> AutoLoading Managers...")
	print("\t-> Initialize sfxManager...")
	# loading all the sounds from the json file
	sfx = JsonFio.load_json("res://managers/audioManager/sfx/sfx.json")
	var sfx_objects = sfx.keys()
	
	for object in sfx_objects:
		var sfx_subobject_key_list = sfx[object].keys()

		if not sfx[object].has("fp"): # if the entry is not a data entry but a true category
			if self.has_node(object): # category already exists
				pass
			else: # category does not already exist
				AudioManagerNodeHandling.add_category_node(self, "SELF", object)

		for subobject in sfx_subobject_key_list:
			if sfx[object][subobject].has("fp"): # if it is not a sub subobject, but settings data
				pass
			else: # object contains a subcategory

				var sfx_subsubobject_key_list = sfx[object][subobject].keys()

				if not sfx[object][subobject].has("fp"): # if the entry is not a data entry but a true subcategory
					if self.has_node(subobject): # subcategory already exists
						pass
					else: # subcategory does not already exist
						AudioManagerNodeHandling.add_category_node(self, object, subobject)

				for subsubobject in sfx_subsubobject_key_list:
					if sfx[object][subobject][subsubobject].has("fp"): # if it is not a subsub subobject, but settings data
						var sfx_object_name = subsubobject # create the subobject name ; old: subobject + "_" +
						var sfx_object_node_path = object + "/" + subobject + "/" + sfx_object_name # create the node path
						sfx[object][subobject][subsubobject]["nodePath"] = sfx_object_node_path # add the node path to the dictionary entry

						AudioManagerNodeHandling.add_and_configure_AudioStreamPlayer(self,sfx[object][subobject][subsubobject], object+"/"+subobject, sfx_object_name)
					else:
						pass



