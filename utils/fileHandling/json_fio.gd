extends Node

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script is autoloaded as "JsonFio".

func _init():
	print("=> AutoLoading Scripts...")
	print("\t-> Initialize JSON File Input/Output Utility...")

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
# json loading
func load_json(fp) -> Dictionary:
	var file = File.new()
	file.open(fp, File.READ)
	var data = parse_json(file.get_as_text())
	file.close()

	return data

# json saving
func save_json(fp,file_data) -> void:
	var file = File.new()
	file.open(fp, File.WRITE)
	file.store_line(to_json(file_data))
	file.close()
