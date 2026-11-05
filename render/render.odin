package render

import "../camera"
import "../controls"
import "../scene"
import rl "vendor:raylib"

render :: proc(
	s: scene.Scene,
	c: camera.Combat_Camera,
	hovered_entity, selected_entity: Maybe(scene.Entity_Id),
	hovered_tile: Maybe(scene.Tile_Coord),
	path_preview: []scene.Tile_Coord,
) {
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)
	rl.BeginMode3D(c.camera)

	scene_draw(s, hovered_tile)

	path_draw(s, path_preview)

	entities_draw(s, hovered_entity, selected_entity)

	rl.EndMode3D()

	rl.DrawFPS(10, 10)

	rl.EndDrawing()
}

scene_draw :: proc(s: scene.Scene, hovered_tile: Maybe(scene.Tile_Coord)) {
	for z in 0 ..< s.depth {
		for x in 0 ..< s.width {
			tile := s.tiles[z * s.width + x]

			// The scene is centered on the origin, so tile centers sit at half units.
			center := rl.Vector3 {
				f32(x) - f32(s.width) / 2 + scene.TILE_SIZE / 2,
				tile.height - tile.thickness / 2,
				f32(z) - f32(s.depth) / 2 + scene.TILE_SIZE / 2,
			}

			tile_color := tile.color
			if (scene.Tile_Coord{x, z} == hovered_tile) {
				tile_color = rl.GREEN
			}

			rl.DrawCube(center, scene.TILE_SIZE, tile.thickness, scene.TILE_SIZE, tile_color)
			rl.DrawCubeWires(
				center,
				scene.TILE_SIZE,
				tile.thickness,
				scene.TILE_SIZE,
				tile.border_color,
			)
		}
	}
}

entities_draw :: proc(s: scene.Scene, hovered_entity, selected_entity: Maybe(scene.Entity_Id)) {
	for e in s.entities {
		color := rl.MAROON
		if (e.id == selected_entity) {
			color = rl.GREEN
		} else if (e.id == hovered_entity) {
			color = rl.BLUE
		}

		rl.DrawCylinder(
			scene.tile_surface_center(s, e.position),
			e.size[0] / 2,
			e.size[0] / 2,
			e.size[1],
			scene.CYLINDER_SLICES,
			rl.RED,
		)
		rl.DrawCylinderWires(
			scene.tile_surface_center(s, e.position),
			e.size[0] / 2,
			e.size[0] / 2,
			e.size[1],
			scene.CYLINDER_SLICES,
			color,
		)
	}
}

path_draw :: proc(s: scene.Scene, path: []scene.Tile_Coord) {
	lift := rl.Vector3{0, 0.05, 0} // avoids z-fighting with the tile surface

	for i in 0 ..< len(path) - 1 {
		a := scene.tile_surface_center(s, path[i]) + lift
		b := scene.tile_surface_center(s, path[i + 1]) + lift
		rl.DrawLine3D(a, b, rl.ORANGE)
	}

	if len(path) > 0 {
		rl.DrawSphere(scene.tile_surface_center(s, path[len(path) - 1]) + lift, 0.1, rl.ORANGE)
	}
}
