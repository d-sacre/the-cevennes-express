extends Spatial

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
var rng = RandomNumberGenerator.new()

const TILE_BASE_TEXTURES = {
	"default": preload("res://assets/3D/tiles/base/textures/hexagon_tile_base-material_grass.png"),
	"variant": preload("res://assets/3D/tiles/base/textures/hexagon_tile_texture_track_straight_default.png")
}


################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
# public members
var tile_index : int 

# var material_id : String = "blue"
var change_material : bool = false

var highlight : bool = false

################################################################################
#### Private Member Variables ##################################################
################################################################################
# var _material : Resource 

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################

func _check_and_set_highlight() -> void:
	if self.change_material:
		# get_node("OutlineMesh").visible = self.highlight # outline mesh currently not used
		var base_material = get_node("hexMesh").get_active_material(0)

		if self.highlight: 
			# _material = TILE_MATERIALS_HIGHLIGHT[material_id]
			base_material.set_shader_param("highlight", true)
		else:
			base_material.set_shader_param("highlight", false)
			# _material = TILE_MATERIALS[material_id]
			# get_node("hexMesh")#.mesh.surface_get_material(0).set_shader_param("highlight",false)

		# get_node("hexMesh").material_override = _material
		self.change_material = false

func initial_tile_configuration(tile_id) -> void:
	var base_material = get_node("hexMesh").get_active_material(0)

	var base_albedo_texture = TILE_BASE_TEXTURES[tile_id]
	base_material.set_shader_param("texture_albedo_default", base_albedo_texture)
	base_material.set_shader_param("texture_albedo_highlight", base_albedo_texture)
	base_material.set_shader_param("texture_normal", load("res://assets/3D/tiles/base/textures/hexagon_tile_thick_normalmap_impasso.png"))
	base_material.set_shader_param("normal_scale",0.5) # has to be adjusted
	base_material.set_shader_param("texture_emission", load("res://assets/3D/tiles/base/textures/test-tile-texture_highlight-emission.png"))
	base_material.set_shader_param("emission_energy", 0.2)

	if tile_id == "default":
		# add station
		var stationLOAD = load("res://assets/gare_medium.tscn")
		var station = stationLOAD.instance()
		self.add_child(station)

		rng.randomize()
		var rotation_y = rng.randf_range(0.0, 180.0)
		station.rotation_degrees = Vector3(0,rotation_y,0)

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _process(delta) -> void:
	_check_and_set_highlight()

