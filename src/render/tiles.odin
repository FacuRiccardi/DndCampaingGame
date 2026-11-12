package render

import "src:grid"
import rl "vendor:raylib"

TILE_COLOR :: rl.Color{200, 230, 255, 255}
HOVERED_TILE_COLOR :: rl.GREEN
TILE_BORDER_COLOR :: rl.Color{120, 160, 200, 255}

draw_tiles :: proc(g: grid.Grid, hovered_tile: Maybe(grid.Tile_Coord)) {
	for z in 0 ..< g.depth {
		for x in 0 ..< g.width {
			tile := g.tiles[z * g.width + x]

			center := grid.tile_to_world(g, {x, z}) - {0, tile.thickness / 2, 0}

			tile_color := hovered_tile == {x, z} ? HOVERED_TILE_COLOR : TILE_COLOR

			rl.DrawCube(center, grid.TILE_SIZE, tile.thickness, grid.TILE_SIZE, tile_color)
			rl.DrawCubeWires(
				center,
				grid.TILE_SIZE,
				tile.thickness,
				grid.TILE_SIZE,
				TILE_BORDER_COLOR,
			)
		}
	}
}
