package world

import "src:grid"

Entity_Id :: distinct u32

Entity :: struct {
	id:         Entity_Id,
	position:   [3]f32,
	size:       [2]f32, // radius, height
	selectable: bool,
	visual:     Visual_Id,
	facing:     f32,
	movement:   Entity_Movement,
	speed:      f32, // Units per second
}

Visual_Id :: enum {
	Rogue_Hooded,
	Mage,
	Knight,
}

entity_bounds :: proc(e: Entity) -> grid.Box {
	r := e.size[0] / 2
	return {
		min = {e.position[0] - r, e.position[1], e.position[2] - r},
		max = {e.position[0] + r, e.position[1] + e.size[1], e.position[2] + r},
	}
}

spawn_entity :: proc(w: ^World, at: grid.Tile_Coord, visual: Visual_Id) -> Entity_Id {
	w.next_entity_id += 1
	append(
		&w.entities,
		Entity {
			id = w.next_entity_id,
			position = grid.tile_to_world(w.grid, at),
			size = {1, 1},
			selectable = true,
			visual = visual,
			speed = 2,
		},
	)
	return w.next_entity_id
}

entity_get :: proc(w: World, id: Entity_Id) -> Maybe(Entity) {
	for e in w.entities {
		if (e.id == id) {
			return e
		}
	}

	return nil
}

entity_get_ptr :: proc(w: ^World, id: Entity_Id) -> Maybe(^Entity) {
	for &e in w.entities {
		if (e.id == id) {
			return &e
		}
	}

	return nil
}
