extends Spatial

const TILE_MATERIALS = {
	"blue": preload("res://assets/3D/tiles/base_materials/blue.tres"),
	"green": preload("res://assets/3D/tiles/base_materials/green.tres"),
	"red": preload("res://assets/3D/tiles/base_materials/red.tres"),
	"yellow": preload("res://assets/3D/tiles/base_materials/yellow.tres"),
}

const TILE_MATERIALS_HIGHLIGHT = {
	"blue": preload("res://assets/3D/tiles/base_materials/blue_highlight.tres"),
	"green": preload("res://assets/3D/tiles/base_materials/green_highlight.tres"),
	"red": preload("res://assets/3D/tiles/base_materials/red_highlight.tres"),
	"yellow": preload("res://assets/3D/tiles/base_materials/yellow_highlight.tres"),
}

# public variables
var tile_index : int 

var material_id : String = "blue"
var change_material : bool = false

var highlight : bool = false

# private variables
var _material : Resource 

func _on_selector_entered(area_rid, area, area_shape_index, local_shape_index) -> void:
	print("rid: ", area_rid, ", ", area)

	get_node("OutlineMesh").visible = true
	print("Tile ", self.tile_index, " is highlighted")
	self.highlight = true
	self.change_material = true
	
func _on_selector_exited(area_rid, area, area_shape_index, local_shape_index) -> void:
	get_node("OutlineMesh").visible = false
	self.highlight = false
	self.change_material = true

func _ready() -> void:
	pass
	
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

