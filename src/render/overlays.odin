package render

import "src:grid"
import rl "vendor:raylib"

draw_path :: proc(g: grid.Grid, path: []grid.Tile_Coord) {
	lift := rl.Vector3{0, 0.05, 0} // avoids z-fighting with the tile surface

	for i in 0 ..< len(path) - 1 {
		a := grid.tile_to_world(g, path[i]) + lift
		b := grid.tile_to_world(g, path[i + 1]) + lift
		rl.DrawLine3D(a, b, rl.ORANGE)
	}

	if len(path) > 0 {
		rl.DrawSphere(grid.tile_to_world(g, path[len(path) - 1]) + lift, 0.1, rl.ORANGE)
	}
}
