tool

extends Control

class_name TCEUICluster

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _context : String 
var _cluster : Object

var _defaultObject
var _objectReferences : Array = []
var _focusReferences : Array = []

var _vSpacerHeight : int = 24

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
    _elementInstance.initialize(self._context, element)
    cluster.add_child(_elementInstance)
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
func initialize_ui_cluster(context : String, cluster : Object, _elementResource : Resource, elements : Array) -> void:
    self._context = context
    self.pause_mode = PAUSE_MODE_PROCESS
    self._cluster = cluster

    # DESCRIPTION: If there are already some children present, delete them
    # to prevent the issue that multiple instances of the same slider could be present
    # due to tool functionality
    self._remove_all_elements_in_cluster(cluster)

    for _i in elements.size():
        var _element = elements[_i]
        if self._is_element_creation_allowed(_element):
            self._create_element(cluster, _elementResource, _element)

            if _i < len(elements) - 1:
                self._create_spacer(cluster)

func get_focus_reference() -> Array:
    return self._focusReferences

func set_focus_neighbours(focusReference : Array) -> void:
	# DESCRIPTION: If more than one slider
	if len(focusReference) > 1:
		var _maxIndex : int = len(focusReference)-1

		for i in focusReference.size():
			var _current : Button = focusReference[i]

			var _neighboursTopObject : Button
			var _neighboursBottomObject : Button

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

func set_focus_to_default() -> void:
    self._defaultObject.grab_focus()

func update_size() -> void:
	var _tmp_sizeX : float = max(self._cluster.rect_size.x, self._cluster.rect_min_size.x) + 2*48
	var _tmp_sizeY : float = max(self._cluster.rect_size.y, self._cluster.rect_min_size.y) + 2*self._vSpacerHeight + len(self.buttons)*self._vSpacerHeight
	self.rect_min_size = Vector2(_tmp_sizeX, _tmp_sizeY)