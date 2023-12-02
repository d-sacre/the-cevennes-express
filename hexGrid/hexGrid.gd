tool
extends Spatial

var rng = RandomNumberGenerator.new()


const TILE_MATERIALS = [
	"blue",
	"green",
	"red",
	"yellow"
]

const TILE_SIZE := 1.0
const HEX_TILE = preload("res://hexGrid/hexTiles/hexTile.tscn")

export (int, 2, 200) var grid_size := 10 # good values: 10, 50

var tile_reference = []

func _ready() -> void:
	_generate_grid()


func _generate_grid():
	var tile_index : int = 0
	for x in range(grid_size):
		var tile_coordinates := Vector2.ZERO
		tile_coordinates.x = x * TILE_SIZE * cos(deg2rad(30))
		tile_coordinates.y = 0 if x % 2 == 0 else TILE_SIZE / 2

		for y in range(grid_size):
			var tile = HEX_TILE.instance()
			add_child(tile)
			tile_reference.append(tile)
			tile.translate(Vector3(tile_coordinates.x, 0, tile_coordinates.y))
			tile_coordinates.y += TILE_SIZE
			tile.material_id = get_tile_material(tile_index)
			tile.change_material = true
			tile.tile_index = tile_index
			tile_index += 1
			
			# add station
			var stationLOAD = load("res://assets/gare_medium.tscn")
			var station = stationLOAD.instance()
			tile.add_child(station)
			
			rng.randomize()
			var rotation_y = rng.randf_range(0.0, 180.0)
			station.rotation_degrees = Vector3(0,rotation_y,0)

func get_tile_material(tile_index: int):
	var index = tile_index % TILE_MATERIALS.size()
	return TILE_MATERIALS[index]


