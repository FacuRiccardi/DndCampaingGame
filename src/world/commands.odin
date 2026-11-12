package world

import "core:slice"
import "src:grid"

Command :: union {
	Cmd_Move,
}

Cmd_Move :: struct {
	id:   Entity_Id,
	path: []grid.Tile_Coord,
}

apply :: proc(w: ^World, cmd: Command) {
	switch c in cmd {
	case Cmd_Move:
		start_movement(w, c.id, slice.clone(c.path))
	case nil:
	}
}
