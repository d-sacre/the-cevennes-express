extends Spatial

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
var rng = RandomNumberGenerator.new()

const PLACEHOLDER_BASE_TEXTURES = {
	"default": preload("res://assets/3D/tiles/placeholder/textures/hexagon_tile_placeholder_texture_default.png"),
	"placement_possible": preload("res://assets/3D/tiles/placeholder/textures/hexagon_tile_placeholder_texture_placement-possible.png"),
	"placement_impossible": preload("res://assets/3D/tiles/placeholder/textures/hexagon_tile_placeholder_texture_placement-impossible.png")
}


################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
# public members
var tile_index : int 

# var material_id : String = "blue"
var change_material : bool = false

var highlight : bool = false
var placement_possible : bool = false
var placement_impossible : bool = false

################################################################################
#### Private Member Variables ##################################################
################################################################################
var _albedo_texture : Resource 

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################

func _check_and_set_highlight() -> void:
	if self.change_material:
		var base_material = get_node("hexMesh").get_active_material(0)

		print("BEFORE: placement: (possible/impossible): ", placement_possible, "/", placement_impossible)
		if placement_possible:
			_albedo_texture = PLACEHOLDER_BASE_TEXTURES["placement_possible"]
			placement_impossible = false # as a safety measure to ensure no other logic is called afterwards

		if placement_impossible:
			_albedo_texture = PLACEHOLDER_BASE_TEXTURES["placement_impossible"]
			placement_possible = false # as a safety measure to ensure no other logic is called afterwards

		if not placement_possible:
			if not placement_impossible:
				_albedo_texture = PLACEHOLDER_BASE_TEXTURES["default"]

		base_material.set_shader_param("texture_albedo_default", _albedo_texture)

		if self.highlight: 
			base_material.set_shader_param("highlight", true)
		else:
			base_material.set_shader_param("highlight", false)

		self.change_material = false
		print("AFTER: placement: (possible/impossible): ", placement_possible, "/", placement_impossible)

func initial_placeholder_configuration() -> void:
	var base_material = get_node("hexMesh").get_active_material(0)

	var base_albedo_texture = PLACEHOLDER_BASE_TEXTURES["default"]
	base_material.set_shader_param("texture_albedo_default", base_albedo_texture)

	base_material.set_shader_param("texture_emission", load("res://assets/3D/tiles/base/textures/test-tile-texture_highlight-emission.png"))
	base_material.set_shader_param("emission_energy", 0.2)

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _process(delta) -> void:
	_check_and_set_highlight()

