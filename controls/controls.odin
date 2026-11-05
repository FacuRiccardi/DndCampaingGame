package controls

import "../camera"
import "../scene"
import rl "vendor:raylib"

Controls :: struct {
	camera_movement: rl.Vector3,
	hovered_entity:  Maybe(scene.Entity_Id),
	selected_entity: Maybe(scene.Entity_Id),
	hovered_tile:    Maybe(scene.Tile_Coord),
	path_preview:    []scene.Tile_Coord,
}

update :: proc(c: ^Controls, s: scene.Scene, cam: camera.Combat_Camera) -> []scene.Command {
	c.camera_movement = camera_movement()
	hover(c, s, cam)
	update_path_preview(c, s)
	left_click(c, s)

	commands := make([dynamic]scene.Command, context.temp_allocator)
	if cmd := right_click(c^); cmd != nil {
		append(&commands, cmd)
	}
	return commands[:]
}

camera_movement :: proc() -> rl.Vector3 {
	move: rl.Vector3

	if (rl.IsKeyDown(.W)) {
		move += {-1, 0, -1}
	}
	if (rl.IsKeyDown(.S)) {
		move += {1, 0, 1}
	}
	if (rl.IsKeyDown(.A)) {
		move += {-1, 0, 1}
	}
	if (rl.IsKeyDown(.D)) {
		move += {1, 0, -1}
	}

	return move
}

hover :: proc(c: ^Controls, s: scene.Scene, cam: camera.Combat_Camera) {
	ray := rl.GetScreenToWorldRay(rl.GetMousePosition(), cam.camera)

	id, entity_hit := scene.pick_entity(s, ray).?

	if (!entity_hit) {
		c.hovered_entity = nil
	} else {
		c.hovered_entity = id
	}

	if (c.selected_entity != nil) {
		coord, tile_hit := scene.pick_tile(s, ray).?

		if (!tile_hit) {
			c.hovered_tile = nil
		} else {
			c.hovered_tile = coord
		}
	}
}

left_click :: proc(c: ^Controls, s: scene.Scene) {
	if (rl.IsMouseButtonPressed(.LEFT)) {
		if id, ok := c.hovered_entity.?; ok {
			if e, found := scene.get_entity(s, id).?; found && e.selectable {
				c.selected_entity = c.hovered_entity
				return
			}
		}

		c.selected_entity = nil
		c.hovered_tile = nil
	}
}

update_path_preview :: proc(c: ^Controls, s: scene.Scene) {
	c.path_preview = nil

	id, has_selected := c.selected_entity.?
	if !has_selected {return}

	target, has_target := c.hovered_tile.?
	if !has_target {return}

	entity, found := scene.get_entity(s, id).?
	if !found {return}

	c.path_preview = scene.plan_path(entity.position, target)
}

right_click :: proc(c: Controls) -> scene.Command {
	if !rl.IsMouseButtonPressed(.RIGHT) {return nil}

	id, has_selected := c.selected_entity.?
	if !has_selected {return nil}

	if len(c.path_preview) == 0 {return nil}

	return scene.Cmd_Move{id, c.path_preview}
}
