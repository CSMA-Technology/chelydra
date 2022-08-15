extends NavigationPolygonInstance

const TILE_SIZE = 64
func _ready():
	for tower in $"../Towers".get_children():
		cut_hole(tower.global_position)

func cut_hole(pos:Vector2):
	navpoly.add_outline(PoolVector2Array([
		pos, Vector2(pos.x + TILE_SIZE, pos.y),
		Vector2(pos.x + TILE_SIZE, pos.y + TILE_SIZE),
		Vector2(pos.x, pos.y+TILE_SIZE)
	]))
	navpoly.make_polygons_from_outlines()
