tool

extends TCEClusterBase

class_name TCEClusterHSlider

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
const _sliderResource : Resource = preload("res://gui/components/slider/tce_hslider.tscn")

func initialize_slider_cluster(context : String, cluster : Object, elements : Array) -> void:
	self._vSpacerHeight = 42
	.set_element_resource(self._sliderResource)
	.initialize_ui_cluster(context, cluster, elements, false)

func update_size() -> void:
	.update_size()
