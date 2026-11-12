package grid

import "core:math"

TILE_SIZE :: 1.0
TILE_THICKNESS :: 0.1

Tile :: struct {
	height:    f32, // y of the tile's top surface; 0 is floor level
	thickness: f32,
}

Tile_Coord :: struct {
	x, z: i32,
}

Grid :: struct {
	width, depth: i32,
	tiles:        []Tile,
}

Box :: struct {
	min, max: [3]f32,
}

tile_default :: proc() -> Tile {
	return Tile{0, TILE_THICKNESS}
}

tile_at :: proc(g: Grid, coord: Tile_Coord) -> Tile {
	return g.tiles[coord.z * g.width + coord.x]
}

tile_to_world :: proc(g: Grid, coord: Tile_Coord) -> [3]f32 {
	tile := tile_at(g, coord)
	half := f32(TILE_SIZE) / 2
	return {
		f32(coord.x) - f32(g.width) / 2 + half,
		tile.height,
		f32(coord.z) - f32(g.depth) / 2 + half,
	}
}

world_to_tile :: proc(g: Grid, world_coord: [3]f32) -> Tile_Coord {
	half := f32(TILE_SIZE) / 2
	return {
		i32(math.floor(world_coord.x + f32(g.width) / 2 - half)),
		i32(math.floor(world_coord.z + f32(g.depth) / 2 - half)),
	}
}

tile_bounds :: proc(g: Grid, coord: Tile_Coord) -> Box {
	tile := tile_at(g, coord)
	top := tile_to_world(g, coord)
	half := f32(TILE_SIZE) / 2
	return {
		min = {top.x - half, tile.height - tile.thickness, top.z - half},
		max = {top.x + half, tile.height, top.z + half},
	}
}
