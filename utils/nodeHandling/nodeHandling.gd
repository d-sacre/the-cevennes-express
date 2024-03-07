extends Node

# source: https://forum.godotengine.org/t/how-do-you-get-all-nodes-of-a-certain-class/9143
func find_all_nodes_of_class(node: Node, className : String, result : Array) -> void:
	if node.is_class(className):
		result.push_back(node)

	for child in node.get_children():
		self.find_all_nodes_of_class(child, className, result)

func find_all_hslider_nodes(node: Node, result: Array) -> void:
	self.find_all_nodes_of_class(node, "HSlider", result)