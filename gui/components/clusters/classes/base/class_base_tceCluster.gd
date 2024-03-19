tool

extends Control

class_name TCEClusterBase

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _context : String 
var _cluster : Object
var _elementResource : Object
var _clusterEntries : Array

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

func _create_category_title(parent : Object, title : String) -> void:
	var _title = Label.new()
	_title.text = title
	_title.align = Label.ALIGN_LEFT
	_title.size_flags_horizontal = SIZE_EXPAND_FILL

	# REMARK: Has to be adjusted when the paths will have changed
	_title.add_font_override("font", preload("res://themes/fonts/lmodern_bold_48px.tres")) 
	parent.add_child(_title)

	self._create_spacer(parent)

func _change_ui_focus_mode(methodName : String) -> void:
	for _child in self._cluster.get_children():
		if _child.has_method(methodName):
			_child.call(methodName)

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func enable_container_cleaning() -> void:
	self._clearContainerAllowed = true

func disable_container_cleaning() -> void:
	self._clearContainerAllowed = false

func enable_ui_focus_mode_all() -> void:
	self._change_ui_focus_mode("enable_ui_focus_mode_all")

func disable_ui_focus_mode_all() -> void:
	self._change_ui_focus_mode("disable_ui_focus_mode_all")

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
	
	# DESCRIPTION: To ensure that the cluster does not interfer with ui focus of other elements
	self.disable_ui_focus_mode_all()

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
	self.emit_signal("item_rect_changed") # Testing purposes to see whether size is updated; seems not to have any effect
	self.enable_ui_focus_mode_all()

	var _tmp_defaultObjectName : String = self._defaultObject.name
	print("Default Object: ", self._defaultObject, ", name: ", _tmp_defaultObjectName,", class: ", self._defaultObject.get_class())
	print("Viewport Size: ", get_viewport_rect())
	
	# DESCRIPTION: Detect TCE Custom Types to be able to set focus to the correct Godot default element
	# REMARK: Currently very crude/unflexible/hardcoded and only working for HSliders
	# FUTURE: Needs to be generalized and expanded to other types
	if _tmp_defaultObjectName.match("TCE*") or _tmp_defaultObjectName.match("tce*"):
		var _tmp_defaultObject = self._defaultObject

		if _tmp_defaultObjectName.match("*HSlider*"):
			_tmp_defaultObject = self._defaultObject.get_node("GridContainer/HSlider")
		
		self._defaultObject = _tmp_defaultObject

	self._defaultObject.grab_focus()
	print("Mouse Position (before): global, local:", get_global_mouse_position(), ", ", get_local_mouse_position())
	# if not UserInputManager.is_device_responsible_for_current_input_mouse():
	var _center : Vector2 =  0.5 * self._defaultObject.rect_size
	print("Calculated Coordinate: ", _center)
	self._defaultObject.warp_mouse(_center)
	# get_viewport().warp_mouse(_center)
	# Input.warp_mouse_position(self.get_global_transform_with_canvas().origin+_center)
	print("Mouse Position (after): global, local:", get_global_mouse_position(), ", ", get_local_mouse_position(), "\n")

func update_size() -> void:
	var _tmp_sizeX : float = max(self._cluster.rect_size.x, self._cluster.rect_min_size.x) + 2*48
	var _tmp_sizeY : float = max(self._cluster.rect_size.y, self._cluster.rect_min_size.y) + self._vCorrection
	self.rect_min_size = Vector2(_tmp_sizeX, _tmp_sizeY)
