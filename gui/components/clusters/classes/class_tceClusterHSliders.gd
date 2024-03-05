tool

extends TCEUICluster

class_name TCEHSliderCluster

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
const _sliderResource : Resource = preload("res://gui/components/slider/tce_hslider.tscn")

func initialize_slider_cluster(context : String, cluster : Object, elements : Array) -> void:
	.initialize_ui_cluster(context, cluster, self._sliderResource, elements)
