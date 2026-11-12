package interaction

import "src:grid"
import "src:world"
import rl "vendor:raylib"

to_rl_box :: proc(b: grid.Box) -> rl.BoundingBox {
	return {b.min, b.max}
}

pick_entity :: proc(w: world.World, ray: rl.Ray) -> Maybe(world.Entity_Id) {
	closest_distance := max(f32)
	id: Maybe(world.Entity_Id)
	for e in w.entities {
		collision := rl.GetRayCollisionBox(ray, to_rl_box(world.entity_bounds(e)))
		if collision.hit && collision.distance < closest_distance {
			closest_distance = collision.distance
			id = e.id
		}
	}

	return id
}

pick_tile :: proc(w: world.World, ray: rl.Ray) -> Maybe(grid.Tile_Coord) {
	closest_distance := max(f32)
	coord: Maybe(grid.Tile_Coord)

	for z in 0 ..< w.grid.depth {
		for x in 0 ..< w.grid.width {
			collision := rl.GetRayCollisionBox(
				ray,
				to_rl_box(grid.tile_bounds(w.grid, grid.Tile_Coord{x, z})),
			)

			if collision.hit && collision.distance < closest_distance {
				closest_distance = collision.distance
				coord = grid.Tile_Coord{x, z}
			}
		}
	}

	return coord
}
