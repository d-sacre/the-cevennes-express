tool

extends TCEUICluster

class_name TCEButtonCluster

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
const _buttonResource : Resource = preload("res://gui/components/buttons/menuButton.tscn")

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize_button_cluster(context : String, cluster : Object, elements : Array) -> void:
	.initialize_ui_cluster(context, cluster, self._buttonResource, elements)
