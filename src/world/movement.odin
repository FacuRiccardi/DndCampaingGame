package world

import "core:math"
import "core:math/linalg"
import "src:grid"

Entity_Movement :: struct {
	moving:   bool,
	path:     []grid.Tile_Coord,
	step:     int,
	progress: f32,
}

start_movement :: proc(w: ^World, id: Entity_Id, path: []grid.Tile_Coord) {
	e, ok := entity_get_ptr(w, id).?

	if !ok || e.movement.moving || len(path) < 2 {
		delete(path)
		return
	}

	e.movement = {
		moving = true,
		path   = path,
	}
}

update :: proc(w: ^World, dt: f32) {
	for &e in w.entities {
		m := &e.movement
		if !m.moving do continue

		from := grid.tile_to_world(w.grid, m.path[m.step])
		to := grid.tile_to_world(w.grid, m.path[m.step + 1])
		e.facing = facing_towards(from, to)

		m.progress += dt * e.speed / linalg.length(to - from)

		if m.progress < 1 {
			e.position = linalg.lerp(from, to, m.progress)
			continue
		}

		e.position = to
		m.step += 1
		m.progress = 0
		if m.step == len(m.path) - 1 {
			delete(m.path)
			m^ = {}
		}
	}
}

facing_towards :: proc(from, to: [3]f32) -> f32 {
	d := to - from
	return math.to_degrees(math.atan2(d.x, d.z))
}
