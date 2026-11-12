package input

import rl "vendor:raylib"

Input :: struct {
	camera_move:     rl.Vector3,
	mouse:           rl.Vector2,
	select_pressed:  bool,
	command_pressed: bool,
}

poll :: proc() -> Input {
	return {
		camera_move = camera_movement(),
		mouse = rl.GetMousePosition(),
		select_pressed = rl.IsMouseButtonPressed(.LEFT),
		command_pressed = rl.IsMouseButtonPressed(.RIGHT),
	}
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

// left_click :: proc(c: ^Controls, s: scene.Scene) {
// 	if (rl.IsMouseButtonPressed(.LEFT)) {
// 		if id, ok := c.hovered_entity.?; ok {
// 			if e, found := scene.get_entity(s, id).?; found && e.selectable {
// 				c.selected_entity = c.hovered_entity
// 				return
// 			}
// 		}

// 		c.selected_entity = nil
// 		c.hovered_tile = nil
// 	}
// }

// right_click :: proc(c: Controls) -> scene.Command {
// 	if !rl.IsMouseButtonPressed(.RIGHT) {return nil}

// 	id, has_selected := c.selected_entity.?
// 	if !has_selected {return nil}

// 	if len(c.path_preview) == 0 {return nil}

// 	return scene.Cmd_Move{id, c.path_preview}
// }
