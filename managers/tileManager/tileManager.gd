extends Spatial

################################################################################
#### RESOURCE AND CLASS LOADING ################################################
################################################################################
var rng = RandomNumberGenerator.new()

const TILE_MATERIALS = {
	"blue": preload("res://assets/3D/tiles/base/materials/blue.tres"),
	"green": preload("res://assets/3D/tiles/base/materials/green.tres"),
	"red": preload("res://assets/3D/tiles/base/materials/red.tres"),
	"yellow": preload("res://assets/3D/tiles/base/materials/yellow.tres"),
}

const TILE_MATERIALS_HIGHLIGHT = {
	"blue": preload("res://assets/3D/tiles/base/materials/blue_highlight.tres"),
	"green": preload("res://assets/3D/tiles/base/materials/green_highlight.tres"),
	"red": preload("res://assets/3D/tiles/base/materials/red_highlight.tres"),
	"yellow": preload("res://assets/3D/tiles/base/materials/yellow_highlight.tres"),
}

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
# public members
var tile_index : int 

var material_id : String = "blue"
var change_material : bool = false

var highlight : bool = false

################################################################################
#### Private Member Variables ##################################################
################################################################################
var _material : Resource 

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################

func _check_and_set_highlight() -> void:
	if self.change_material:
		get_node("OutlineMesh").visible = self.highlight

		if self.highlight: 
			_material = TILE_MATERIALS_HIGHLIGHT[material_id]
		else:
			_material = TILE_MATERIALS[material_id]

		get_node("hexMesh").material_override = _material
		self.change_material = false

func initial_tile_configuration() -> void:
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

