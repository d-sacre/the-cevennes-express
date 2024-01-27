extends Spatial

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
var rng = RandomNumberGenerator.new()

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
# public members
var tile_index : int 
var tile_definition_uuid : String

var change_material : bool = false
var highlight : bool = false

################################################################################
#### Private Member Variables ##################################################
################################################################################

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################
func _check_and_set_highlight() -> void:
	if self.change_material:
		# get_node("OutlineMesh").visible = self.highlight # outline mesh currently not used
		var base_material = get_node("hexMesh").get_active_material(0)

		if self.highlight: 
			base_material.set_shader_param("highlight", true)
		else:
			base_material.set_shader_param("highlight", false)
			
		self.change_material = false

func initial_tile_configuration(tile_definition) -> void:
	self.tile_definition_uuid = tile_definition["TILE_DEFINITION_UUID"]
	var base_albedo_texture = load(tile_definition["TEXTURE_RESOURCE_PATH"]) #load("res://assets/3D/tiles/base/textures/hexagon_tile_base-material_grass.png")

	var base_material = get_node("hexMesh").get_active_material(0)

	base_material.set_shader_param("texture_albedo_default", base_albedo_texture)
	base_material.set_shader_param("texture_albedo_highlight", base_albedo_texture)
	base_material.set_shader_param("texture_normal", load("res://assets/3D/tiles/base/textures/hexagon_tile_thick_normalmap_impasso.png"))
	base_material.set_shader_param("normal_scale",0.5) # has to be adjusted
	base_material.set_shader_param("texture_emission", load("res://assets/3D/tiles/base/textures/test-tile-texture_highlight-emission.png"))
	base_material.set_shader_param("emission_energy", 0.2)

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _process(delta) -> void:
	_check_and_set_highlight()

