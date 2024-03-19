tool

extends TCEClusterBase

class_name TCEClusterMixed

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _parse_elements_into_categories() -> Array:
	var _tmp_categoryCluster : Array = []

	for _h in self._clusterEntries.size():
		var _category : Dictionary = self._clusterEntries[_h]
		var _lastType : String = ""

		var _tmp_clusterOfClusters : Array = []
		var _tmp_helper : Dictionary = {}

		if _category.has("members"):
			if len(_category["members"]) != 0:
				for _i in _category["members"].size():
					var _element : Dictionary = _category["members"][_i]

					if _element["type"] != _lastType:
						if len(_tmp_helper) != 0:
							_tmp_clusterOfClusters.append(_tmp_helper)
							_tmp_helper = {}
						else:
							_lastType = _element["type"]
							_tmp_helper = {_lastType : [{"category": _h, "element": _i}]}
					else:
						if _tmp_helper != {}:
							if _tmp_helper.has(_lastType):
								_tmp_helper[_lastType].append({"category": _h, "element": _i})
						else:
							_tmp_helper = {_lastType : [{"category": _h, "element": _i}]}

					if _i == len(_category["members"])-1:
						if len(_tmp_helper) != 0:
							_tmp_clusterOfClusters.append(_tmp_helper)
							_tmp_helper = {}

		_tmp_categoryCluster.append(_tmp_clusterOfClusters)

	return _tmp_categoryCluster

func _load_type_specific_routines(type : String) -> Dictionary:
	var _tmp_elementCluster : Object 
	var _tmp_initMethodName : String

	match type:
		"TCEHSlider":
			_tmp_elementCluster = TCEClusterHSlider.new()
			_tmp_initMethodName = "initialize_slider_cluster"
		"TCEButtonToggle":
			_tmp_elementCluster = TCEClusterButtonToggle.new()
			_tmp_initMethodName = "initialize_toggle_button_cluster"

	return {"class_instance": _tmp_elementCluster, "init_method": _tmp_initMethodName}

func _update_cluster_width(value : int) -> void:
	self._cluster.rect_min_size.x = value

func _process_category_element_by_type(elementData : Array, type : String, neighbourReference : Array) -> void:
	var _tmp_elementData : Array = []

	for _entry in elementData:
		_tmp_elementData.append(self._clusterEntries[_entry["category"]]["members"][_entry["element"]])

	var _tmp_typeSpecificRoutines : Dictionary = self._load_type_specific_routines(type)

	_tmp_typeSpecificRoutines.class_instance.disable_container_cleaning()

	_tmp_typeSpecificRoutines.class_instance.call(_tmp_typeSpecificRoutines.init_method, self._context, self._cluster, _tmp_elementData)
	_tmp_typeSpecificRoutines.class_instance.update_size()
	# REMARK: Required to prevent memory leaks
	_tmp_typeSpecificRoutines.class_instance.queue_free() 

	# REMARK: Currently hardcoded, as all progamatical approaches have failed so far
	# FUTURE: Make it progamatic
	self._update_cluster_width(self._cluster.rect_size.x-24)

	neighbourReference.push_back(_tmp_typeSpecificRoutines.class_instance.get_focus_reference()[0])

func _process_category_elements_according_to_type(category : Array, neighbourReference : Array) -> void:
	if category != []:
		for _element in category:
			for _key in _element.keys():
				self._process_category_element_by_type(_element[_key], _key, neighbourReference)

func _process_categories(categoryCluster : Array) -> Array:
	var _neighbourReferences : Array = []

	for  _i in range(len(categoryCluster)):
		var _category = categoryCluster[_i]

		var _categoryTitle : String = self._clusterEntries[_i]["heading"]
		self._create_category_title(self._cluster, _categoryTitle)

		self._process_category_elements_according_to_type(_category, _neighbourReferences)

		self._create_spacer(self._cluster)
		self._create_spacer(self._cluster)

	return _neighbourReferences

func _initialize(context : String, cluster : Object = $CenterContainer/GridContainer) -> void:
	self.initialize_ui_cluster_parameters(context, cluster)

	var _tmp_categoryCluster : Array = self._parse_elements_into_categories()
	self._focusReferences = self._process_categories(_tmp_categoryCluster)
	
	self.set_focus_neighbours(self._focusReferences)
	# self.set_focus_to_default()

func _set_all_nodes_of_type_to_default(type : String) -> void:
	var _references : Array = []

	var _class : String
	var _method : String

	# TO-DO: Include TCEButtonOption
	match type:
		"TCEHSlider":
			_class = "HSlider"
			_method = "set_slider_to_default_value"
		"TCEButtonToggle":
			_class = "CheckButton"
			_method = "set_toggle_button_to_default_value"

	NodeHandling.find_all_nodes_of_class(self, _class, _references)

	for _node in _references:
		var _parent = _node.get_parent()

		if _parent.has_method(_method):
			_parent.call(_method)
		else:
			var _grandParent = _parent.get_parent()

			if _grandParent.has_method(_method):
				_grandParent.call(_method)
