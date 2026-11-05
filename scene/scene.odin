package scene

import rl "vendor:raylib"

TILE_SIZE :: 1.0
TILE_THICKNESS :: 0.1
TILE_COLOR :: rl.Color{200, 230, 255, 255}
TILE_BORDER_COLOR :: rl.Color{120, 160, 200, 255}

Tile_Coord :: struct {
	x, z: int,
}

Tile :: struct {
	height:       f32, // y of the tile's top surface; 0 is floor level
	thickness:    f32,
	color:        rl.Color,
	border_color: rl.Color,
}

tile_default :: proc() -> Tile {
	return Tile{0, TILE_THICKNESS, TILE_COLOR, TILE_BORDER_COLOR}
}

// Tiles are stored row by row: index = z * width + x.
Scene :: struct {
	width:          int,
	depth:          int,
	tiles:          []Tile,
	entities:       [dynamic]Entity,
	next_entity_id: Entity_Id,
}

Command :: union {
	Cmd_Move,
}

Cmd_Move :: struct {
	id:   Entity_Id,
	path: []Tile_Coord,
}

// Builds a flat scene of width x depth tiles, centered on the world origin.
generate :: proc(width, depth: int) -> Scene {
	tiles := make([]Tile, width * depth)
	for &tile in tiles {
		tile = tile_default()
	}
	return Scene{width = width, depth = depth, tiles = tiles}
}

spawn_entity :: proc(s: ^Scene, position: Tile_Coord) -> Entity_Id {
	s.next_entity_id += 1
	entity: Entity = {s.next_entity_id, position, {1, 1}, true}
	append(&s.entities, entity)
	return entity.id
}

destroy :: proc(s: ^Scene) {
	delete(s.tiles)
	delete(s.entities)
}

pick_entity :: proc(s: Scene, ray: rl.Ray) -> Maybe(Entity_Id) {
	closest_distance := max(f32)
	id: Maybe(Entity_Id)
	for e in s.entities {
		collision := rl.GetRayCollisionBox(
			ray,
			entity_bounding_box(e, tile_surface_center(s, e.position)),
		)
		if collision.hit && collision.distance < closest_distance {
			closest_distance = collision.distance
			id = e.id
		}
	}

	if (id != nil) {
		return id
	}

	return nil
}

get_entity :: proc(s: Scene, id: Entity_Id) -> Maybe(Entity) {
	for e in s.entities {
		if (e.id == id) {
			return e
		}
	}

	return nil
}

get_entity_reference :: proc(s: ^Scene, id: Entity_Id) -> Maybe(^Entity) {
	for &e in s.entities {
		if (e.id == id) {
			return &e
		}
	}

	return nil
}

tile_bounding_box :: proc(s: Scene, coord: Tile_Coord) -> rl.BoundingBox {
	tile := s.tiles[coord.z * s.width + coord.x]
	cx := f32(coord.x) - f32(s.width) / 2 + TILE_SIZE / 2
	cz := f32(coord.z) - f32(s.depth) / 2 + TILE_SIZE / 2
	return {
		min = {cx - TILE_SIZE / 2, tile.height - tile.thickness, cz - TILE_SIZE / 2},
		max = {cx + TILE_SIZE / 2, tile.height, cz + TILE_SIZE / 2},
	}
}

pick_tile :: proc(s: Scene, ray: rl.Ray) -> Maybe(Tile_Coord) {
	closest_distance := max(f32)
	coord: Maybe(Tile_Coord)

	for z in 0 ..< s.depth {
		for x in 0 ..< s.width {
			collision := rl.GetRayCollisionBox(ray, tile_bounding_box(s, Tile_Coord{x, z}))

			if collision.hit && collision.distance < closest_distance {
				closest_distance = collision.distance
				coord = Tile_Coord{x, z}
			}
		}
	}

	if (coord != nil) {
		return coord
	}

	return nil
}

tile_surface_center :: proc(s: Scene, coord: Tile_Coord) -> rl.Vector3 {
	tile := s.tiles[coord.z * s.width + coord.x]
	return {
		f32(coord.x) - f32(s.width) / 2 + TILE_SIZE / 2,
		tile.height,
		f32(coord.z) - f32(s.depth) / 2 + TILE_SIZE / 2,
	}
}

plan_path :: proc(from, to: Tile_Coord) -> []Tile_Coord {
	step :: proc(a, b: int) -> int {
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

apply :: proc(s: ^Scene, cmd: Command) {
	switch c in cmd {
	case Cmd_Move:
		move_entity(s, c.id, c.path)
	case nil:
	}
}

move_entity :: proc(s: ^Scene, id: Entity_Id, path: []Tile_Coord) {
	e, ok := get_entity_reference(s, id).?
	e.position = path[len(path) - 1]
}
