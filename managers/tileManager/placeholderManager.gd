extends Spatial

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
const PLACEHOLDER_TEXTURES : Dictionary = {
	"default": preload("res://assets/3D/tiles/placeholder/textures/hexagonTile_placeholder_texture_default.png"),
	"highlight": preload("res://assets/3D/tiles/placeholder/textures/hexagonTile_placeholder_texture_highlight_emission.png"),
	"placement_possible": preload("res://assets/3D/tiles/placeholder/textures/hexagonTile_placeholder_texture_placement-possible.png"),
	"placement_impossible": preload("res://assets/3D/tiles/placeholder/textures/hexagonTile_placeholder_texture_placement-impossible.png")
}

################################################################################
#### PUBLIC MEMBER VARIABLES ###################################################
################################################################################
var tile_index : int 

var change_material : bool = false
var highlight : bool = false
var placement_possible : bool = false
var placement_impossible : bool = false

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _albedo_texture : Resource 

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _check_and_set_highlight() -> void:
	if self.change_material:
		var _base_material = get_node("hexMesh").get_active_material(0)

		if self.placement_possible:
			_albedo_texture = PLACEHOLDER_TEXTURES["placement_possible"]
			self.placement_impossible = false # as a safety measure to ensure no other logic is called afterwards

		if self.placement_impossible:
			_albedo_texture = PLACEHOLDER_TEXTURES["placement_impossible"]
			self.placement_possible = false # as a safety measure to ensure no other logic is called afterwards

		if not self.placement_possible:
			if not self.placement_impossible:
				_albedo_texture = PLACEHOLDER_TEXTURES["default"]

		_base_material.set_shader_param("texture_albedo_default", _albedo_texture)

		if self.highlight: 
			_base_material.set_shader_param("highlight", true)
		else:
			_base_material.set_shader_param("highlight", false)

		# Reset placement bools so that if the cursor moves away, no placement information
		# will be displayed
		self.placement_impossible = false
		self.placement_possible = false

		self.change_material = false # prevent that the material is changed again

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################		
func initial_placeholder_configuration() -> void:
	var _base_material = get_node("hexMesh").get_active_material(0)

	var _base_albedo_texture = PLACEHOLDER_TEXTURES["default"]
	_base_material.set_shader_param("texture_albedo_default", _base_albedo_texture)

	_base_material.set_shader_param("texture_emission", PLACEHOLDER_TEXTURES["highlight"])
	_base_material.set_shader_param("emission_energy", 0.2)

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _process(_delta : float) -> void:
	_check_and_set_highlight()

