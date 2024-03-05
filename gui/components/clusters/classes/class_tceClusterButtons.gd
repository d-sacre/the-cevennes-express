tool

# extends Control
extends TCEUICluster

class_name TCEButtonCluster

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
const _buttonResource : Resource = preload("res://gui/components/buttons/menuButton.tscn")

# ################################################################################
# #### PRIVATE MEMBER VARIABLES ##################################################
# ################################################################################
# var _context : String 
# var _defaultButton : Button 
# var _buttonReferences : Array = []
# var _buttonFocusReferences : Array = []

# var _vSpacerHeight : int = 24

# ################################################################################
# #### ONREADY MEMBER VARIABLES ##################################################
# ################################################################################
# onready var _buttonContainer : Object #GridContainer

# ################################################################################
# #### PRIVATE MEMBER FUNCTIONS ##################################################
# ################################################################################
# func _remove_all_buttons() -> void:
# 	if _buttonContainer.get_child_count() != 0: 
# 		for _n in _buttonContainer.get_children():
# 			_buttonContainer.remove_child(_n)
# 			_n.queue_free()

# func _is_button_creation_allowed(button : Dictionary) -> bool:
# 	var _placeable : bool = false

# 	if OS.has_feature("JavaScript"):
# 		_placeable = button["export"]["javascript"]
# 	else:
# 		_placeable = true

# 	return _placeable

# func _create_button(button : Dictionary) -> void:
# 	var _buttonInstance  = _buttonResource.instance()
# 	_buttonInstance.initialize(self._context, button)
# 	self._buttonContainer.add_child(_buttonInstance)
# 	self._buttonReferences.append(_buttonInstance)

# 	if button["default"]:
# 		self._defaultButton = _buttonInstance

# 	if not button["disabled"]:
# 		self._buttonFocusReferences.append(_buttonInstance)

# func _create_spacer() -> void:
# 	var _spacer = Control.new()
# 	_spacer.rect_min_size = Vector2(self._vSpacerHeight, self._vSpacerHeight)
# 	self._buttonContainer.add_child(_spacer)

# func _set_focus_neighbours() -> void:
# 	# DESCRIPTION: If more than one button
# 	if len(self._buttonFocusReferences) > 1:
# 		var _maxIndex : int = len(self._buttonFocusReferences)-1

# 		for i in self._buttonFocusReferences.size():
# 			var _current : Button = self._buttonFocusReferences[i]

# 			var _neighboursTopObject : Button
# 			var _neighboursBottomObject : Button

# 			match i:
# 				0:
# 					_neighboursTopObject = self._buttonFocusReferences[-1]
# 					_neighboursBottomObject = self._buttonFocusReferences[i+1]
# 				_maxIndex:
# 					_neighboursTopObject = self._buttonFocusReferences[i-1]
# 					_neighboursBottomObject = self._buttonFocusReferences[0]
# 				_:
# 					_neighboursTopObject = self._buttonFocusReferences[i-1]
# 					_neighboursBottomObject = self._buttonFocusReferences[i+1]

# 			var _neighboursTopPath : NodePath = _neighboursTopObject.get_path()
# 			var _neighboursBottomPath : NodePath = _neighboursBottomObject.get_path()
# 			_current.set_focus_neighbour(MARGIN_TOP, _neighboursTopPath)
# 			_current.set_focus_neighbour(MARGIN_BOTTOM, _neighboursBottomPath)

# ################################################################################
# #### PUBLIC MEMBER FUNCTIONS ###################################################
# ################################################################################
# func set_focus_to_default() -> void:
# 	if len(self._buttonReferences) > 0:
# 		self._defaultButton.grab_focus()

# func initialize(context : String) -> void:
# 	self._context = context
# 	self.pause_mode = PAUSE_MODE_PROCESS

# 	# DESCRIPTION: If there are already some children present, delete them
# 	# to prevent the issue that multiple instances of the same button could be present
# 	# due to tool functionality
# 	self._remove_all_buttons()

# 	for _i in self.buttons.size():
# 		var _button = self.buttons[_i]
# 		if self._is_button_creation_allowed(_button):
# 			self._create_button(_button)

# 			if _i < len(self.buttons) - 1:
# 				self._create_spacer()
	
# 	# self._set_focus_neighbours() # currently producing errors
# 	# self.set_focus_to_default() # deactivated to prevent soundplayback during loading of game

func initialize_button_cluster(context : String, cluster : Object, elements : Array) -> void:
	.initialize_ui_cluster(context, cluster, self._buttonResource, elements)

# func update_size() -> void:
# 	var _tmp_sizeX : float = max(self._buttonContainer.rect_size.x, self._buttonContainer.rect_min_size.x) + 2*48
# 	var _tmp_sizeY : float = max(self._buttonContainer.rect_size.y, self._buttonContainer.rect_min_size.y) + 2*self._vSpacerHeight + len(self.buttons)*self._vSpacerHeight
# 	self.rect_min_size = Vector2(_tmp_sizeX, _tmp_sizeY)

