extends Spatial

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

# public members
var tile_index : int 

var material_id : String = "blue"
var change_material : bool = false

var highlight : bool = false

# private members
var _material : Resource 
	
func _process(delta) -> void:
	if self.change_material:
		if self.highlight:
			_material = TILE_MATERIALS_HIGHLIGHT[material_id]
			get_node("OutlineMesh").visible = true
		else:
			_material = TILE_MATERIALS[material_id]
			get_node("OutlineMesh").visible = false
			
		get_node("hexMesh").material_override = _material
		self.change_material = false

