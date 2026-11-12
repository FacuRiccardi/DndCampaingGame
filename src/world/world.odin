package world

import "src:grid"

World :: struct {
	grid:           grid.Grid,
	entities:       [dynamic]Entity,
	next_entity_id: Entity_Id,
}

Virtual_Id :: enum {}

create :: proc(width, depth: i32) -> World {
	tiles := make([]grid.Tile, width * depth)
	for &tile in tiles {tile = grid.tile_default()}
	return {grid = {width, depth, tiles}}
}

destroy :: proc(w: ^World) {
	for e in w.entities {delete(e.movement.path)}
	delete(w.entities)
	delete(w.grid.tiles)
}
