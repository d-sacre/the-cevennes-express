extends Node

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script is autoloaded as "DictionaryParsing".

func _init():
	print("\t-> Load Dictionary Parsing Utility...")

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func get_dict_element_via_keychain(dict,keychain):
	var _dict_element = dict

	for key in keychain:
		_dict_element = _dict_element[key]

	return _dict_element


