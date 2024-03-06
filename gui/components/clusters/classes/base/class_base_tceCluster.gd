tool

extends Control

class_name TCEClusterBase

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _context : String 
var _cluster : Object
var _elementResource : Object

var _clearContainerAllowed : bool = true

var _defaultObject
var _objectReferences : Array = []
var _focusReferences : Array = []

var _vSpacerHeight : int = 24
var _vCorrection : int   = 2*self._vSpacerHeight

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _remove_all_elements_in_cluster(cluster : Object) -> void:
	if cluster.get_child_count() != 0: 
		for _n in cluster.get_children():
			cluster.remove_child(_n)
			_n.queue_free()

func _is_element_creation_allowed(_element : Dictionary) -> bool:
	var _placeable : bool = true

	return _placeable

func _create_element(cluster : Object, elementResource : Resource, element : Dictionary) -> void:
	var _elementInstance  = elementResource.instance()
	cluster.add_child(_elementInstance)

	# REMARK: It is important to initialize the element only AFTER it was added
	# to the scene tree; otherwise, the TCEHSlider with several children of their
	# own will fail to initialize properly!
	_elementInstance.initialize(self._context, element)
	self._objectReferences.append(_elementInstance)

	if element["default"]:
		self._defaultObject = _elementInstance

	if not element["disabled"]:
		self._focusReferences.append(_elementInstance)

func _create_spacer(cluster : Object) -> void:
	var _spacer = Control.new()
	_spacer.rect_min_size = Vector2(self._vSpacerHeight, self._vSpacerHeight)
	cluster.add_child(_spacer)

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func enable_container_cleaning() -> void:
	self._clearContainerAllowed = true

func disable_container_cleaning() -> void:
	self._clearContainerAllowed = false

func get_element_size() -> Vector2:
	var _tmp_element : Object = self._elementResource.instance()
	var _size : Vector2 = _tmp_element.rect_size
	_tmp_element.queue_free()

	return _size

func set_element_resource(element : Resource) -> void:
	self._elementResource = element

func initialize_ui_cluster_parameters(context : String, cluster : Object) -> void:
	self._context = context
	self._cluster = cluster

func initialize_ui_cluster(context : String, cluster : Object, elements : Array) -> void:
	self.initialize_ui_cluster_parameters(context, cluster)
	self.pause_mode = PAUSE_MODE_PROCESS

	# DESCRIPTION: If there are already some children present, delete them
	# to prevent the issue that multiple instances of the same slider could be present
	# due to tool functionality
	if self._clearContainerAllowed:
		self._remove_all_elements_in_cluster(self._cluster)

	for _i in elements.size():
		var _element = elements[_i]
		if self._is_element_creation_allowed(_element):
			self._create_element(self._cluster, self._elementResource, _element)

			if _i < len(elements) - 1:
				self._create_spacer(self._cluster)

func get_focus_reference() -> Array:
	return self._focusReferences

func set_focus_neighbours(focusReference : Array) -> void:
	# DESCRIPTION: If more than one element
	if len(focusReference) > 1:
		var _maxIndex : int = len(focusReference)-1

		for i in focusReference.size():
			var _current : Object = focusReference[i]

			var _neighboursTopObject : Object
			var _neighboursBottomObject : Object

			match i:
				0:
					_neighboursTopObject = focusReference[-1]
					_neighboursBottomObject = focusReference[i+1]
				_maxIndex:
					_neighboursTopObject = focusReference[i-1]
					_neighboursBottomObject = focusReference[0]
				_:
					_neighboursTopObject = focusReference[i-1]
					_neighboursBottomObject = focusReference[i+1]

			var _neighboursTopPath : NodePath = _neighboursTopObject.get_path()
			var _neighboursBottomPath : NodePath = _neighboursBottomObject.get_path()
			_current.set_focus_neighbour(MARGIN_TOP, _neighboursTopPath)
			_current.set_focus_neighbour(MARGIN_BOTTOM, _neighboursBottomPath)
			_current.focus_previous = _neighboursTopPath
			_current.focus_next = _neighboursBottomPath

func set_focus_to_default() -> void:
	self._defaultObject.grab_focus()

func update_size() -> void:
	var _tmp_sizeX : float = max(self._cluster.rect_size.x, self._cluster.rect_min_size.x) + 2*48
	var _tmp_sizeY : float = max(self._cluster.rect_size.y, self._cluster.rect_min_size.y) + self._vCorrection
	self.rect_min_size = Vector2(_tmp_sizeX, _tmp_sizeY)
