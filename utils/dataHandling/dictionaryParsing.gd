extends Node

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script is autoloaded as "DictionaryParsing".

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################
func _init():
	print("\t-> Initialize Dictionary Parsing Utility...")

func get_dict_element_via_keychain(dict,keychain):
	var _dict_element = dict

	for key in keychain:
		_dict_element = _dict_element[key]

	return _dict_element

# print_stray_nodes()

