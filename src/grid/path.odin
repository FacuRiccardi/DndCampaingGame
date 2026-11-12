package grid

find_path :: proc(from, to: Tile_Coord) -> []Tile_Coord {
	step :: proc(a, b: i32) -> i32 {
		if b > a {return 1}
		if b < a {return -1}
		return 0
	}

	path := make([dynamic]Tile_Coord, context.temp_allocator)
	current := from
	append(&path, current)
	for current != to {
		current.x += step(current.x, to.x)
		current.z += step(current.z, to.z)
		append(&path, current)
	}
	return path[:]
}
