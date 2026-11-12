package interaction

import "src:camera"
import "src:grid"
import "src:input"
import "src:world"
import rl "vendor:raylib"

Interaction :: struct {
	hovered_entity:  Maybe(world.Entity_Id),
	selected_entity: Maybe(world.Entity_Id),
	hovered_tile:    Maybe(grid.Tile_Coord),
	path_preview:    []grid.Tile_Coord,
}

update :: proc(
	ui: ^Interaction,
	inp: input.Input,
	w: world.World,
	cam: camera.Combat_Camera,
) -> []world.Command {
	hover(ui, inp, w, cam)
	select(ui, inp, w)
	update_path_preview(ui, w)

	commands := make([dynamic]world.Command, context.temp_allocator)
	if cmd := command(ui^, inp); cmd != nil {
		append(&commands, cmd)
	}
	return commands[:]
}

hover :: proc(ui: ^Interaction, inp: input.Input, w: world.World, cam: camera.Combat_Camera) {
	ray := rl.GetScreenToWorldRay(inp.mouse, cam.camera)

	ui.hovered_entity = pick_entity(w, ray)

	ui.hovered_tile = nil
	if ui.selected_entity != nil {
		ui.hovered_tile = pick_tile(w, ray)
	}
}

select :: proc(ui: ^Interaction, inp: input.Input, w: world.World) {
	if !inp.select_pressed {return}

	if id, ok := ui.hovered_entity.?; ok {
		if e, found := world.entity_get(w, id).?; found && e.selectable {
			ui.selected_entity = ui.hovered_entity
			return
		}
	}

	ui.selected_entity = nil
	ui.hovered_tile = nil
}

update_path_preview :: proc(ui: ^Interaction, w: world.World) {
	ui.path_preview = nil

	id, has_selected := ui.selected_entity.?
	if !has_selected {return}

	target, has_target := ui.hovered_tile.?
	if !has_target {return}

	entity, found := world.entity_get(w, id).?
	if !found {return}

	ui.path_preview = grid.find_path(grid.world_to_tile(w.grid, entity.position), target)
}

command :: proc(ui: Interaction, inp: input.Input) -> world.Command {
	if !inp.command_pressed {return nil}

	id, has_selected := ui.selected_entity.?
	if !has_selected || len(ui.path_preview) == 0 {return nil}

	return world.Cmd_Move{id, ui.path_preview}
}
