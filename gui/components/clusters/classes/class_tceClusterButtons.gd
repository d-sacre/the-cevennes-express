tool

extends TCEClusterBase

class_name TCEButtonCluster

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
const _buttonResource : Resource = preload("res://gui/components/buttons/menuButton.tscn")

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize_button_cluster(context : String, cluster : Object, elements : Array) -> void:
	.set_element_resource(self._buttonResource)
	.initialize_ui_cluster(context, cluster, elements)

func update_size() -> void:
	self._vCorrection = len(self.buttons) * self._vSpacerHeight
	.update_size()
