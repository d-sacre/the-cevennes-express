extends Spatial

func _on_cursor_over_tile(current_tile_index,last_tile_index):
	print("current tile: ", current_tile_index, ", last tile: ", last_tile_index)
	if current_tile_index != -1:
		var current_tile = $HexGrid.tile_reference[current_tile_index]
		current_tile.highlight=true
		current_tile.change_material = true
		
	if last_tile_index != -1:
		var last_tile = $HexGrid.tile_reference[last_tile_index]
		last_tile.highlight = false
		last_tile.change_material = true

func _ready():
	$cameraContainer/cameraRotator/Camera.connect("cursor_over_tile",self,"_on_cursor_over_tile")
	

