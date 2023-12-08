tool
extends Node

var DICTUTILS = load("res://managers/audioManager/utils/audioManager_dict_utils.gd")
var dictutils = DICTUTILS.new()

var JSONUTILS = load("res://managers/audioManager/utils/audioManager_json_fio_handling.gd")
var jsonutils = JSONUTILS.new()

var NODEUTILS = load("res://managers/audioManager/utils/audioManager_node-handling.gd")
var nodeutils = NODEUTILS.new()

var sfx : Dictionary = {}
	
func play_sound(keyChain):
	var tmp_keyChain = keyChain
	tmp_keyChain.append("nodePath")
	var tmp_node_path = dictutils.get_dict_element_via_keychain(sfx, keyChain)
	get_node(tmp_node_path).play()


# Called when the node enters the scene tree for the first time.
func _ready():
	# loading all the sounds from the json file
	sfx = jsonutils.load_json("res://managers/audioManager/sfx/sfx.json")
	var sfx_objects = sfx.keys()
	
	for object in sfx_objects:
		var sfx_subobject_key_list = sfx[object].keys()

		if not sfx[object].has("fp"): # if the entry is not a data entry but a true category
			if self.has_node(object): # category already exists
				pass
			else: # category does not already exist
				nodeutils.add_category_node(self, "SELF", object)

		for subobject in sfx_subobject_key_list:
			if sfx[object][subobject].has("fp"): # if it is not a sub subobject, but settings data
				pass
			else: # object contains a subcategory

				var sfx_subsubobject_key_list = sfx[object][subobject].keys()

				if not sfx[object][subobject].has("fp"): # if the entry is not a data entry but a true subcategory
					if self.has_node(subobject): # subcategory already exists
						pass
					else: # subcategory does not already exist
						nodeutils.add_category_node(self, object, subobject)

				for subsubobject in sfx_subsubobject_key_list:
					if sfx[object][subobject][subsubobject].has("fp"): # if it is not a subsub subobject, but settings data
						var sfx_object_name = subsubobject # create the subobject name ; old: subobject + "_" +
						var sfx_object_node_path = object + "/" + subobject + "/" + sfx_object_name # create the node path
						sfx[object][subobject][subsubobject]["nodePath"] = sfx_object_node_path # add the node path to the dictionary entry

						nodeutils.add_and_configure_AudioStreamPlayer(self,sfx[object][subobject][subsubobject], object+"/"+subobject, sfx_object_name)
					else:
						pass



