package scene

import rl "vendor:raylib"

CYLINDER_SLICES :: 64

Entity_Id :: distinct u32

Entity :: struct {
	id:         Entity_Id,
	position:   Tile_Coord,
	size:       [2]f32,
	selectable: bool,
}

entity_bounding_box :: proc(e: Entity, coord: rl.Vector3) -> rl.BoundingBox {
	bounding_box: rl.BoundingBox = {
		min = {coord[0] - e.size[0] / 2, coord[1], coord[2] - e.size[0] / 2},
		max = {coord[0] + e.size[0] / 2, coord[1] + e.size[1], coord[2] + e.size[0] / 2},
	}

	return bounding_box
}
