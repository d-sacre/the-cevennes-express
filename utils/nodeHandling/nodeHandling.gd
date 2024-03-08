extends Node

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
# source: https://forum.godotengine.org/t/how-do-you-get-all-nodes-of-a-certain-class/9143
func find_all_nodes_of_class(node: Node, className : String, result : Array) -> void:
	if node.is_class(className):
		result.push_back(node)

	for child in node.get_children():
		self.find_all_nodes_of_class(child, className, result)

func find_all_hslider_nodes(node: Node, result: Array) -> void:
	self.find_all_nodes_of_class(node, "HSlider", result)

func find_all_check_button_nodes(node: Node, result: Array) -> void:
	self.find_all_nodes_of_class(node, "CheckButton", result)

func remove_stylebox_override(node : Control, override : String) -> void:
	if node.has_stylebox_override(override):
			node.remove_stylebox_override(override)

func override_stylebox(node : Control, override : String, styleboxPath : String) -> void:
	self.remove_stylebox_override(node, override)
	node.add_stylebox_override(override, load(styleboxPath))

func override_styleboxes(node : Control, data : Array) -> void:
	for _stylebox in data:
		self.override_stylebox(node, _stylebox["override"], _stylebox["stylebox_path"])

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _init() -> void:
	print("\t-> Load Node Handling Utility...")