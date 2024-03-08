tool

extends TCEClusterBase

class_name TCEClusterButtonToggle

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
const _buttonResource : Resource = preload("res://gui/components/buttons/variants/toggle/tceButtonToggle.tscn")

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize_toggle_button_cluster(context : String, cluster : Object, elements : Array) -> void:
	.set_element_resource(self._buttonResource)
	.initialize_ui_cluster(context, cluster, elements)

func update_size() -> void:
	# self._vCorrection = len(self.buttons) * self._vSpacerHeight
	.update_size()
