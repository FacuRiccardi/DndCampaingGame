package render

import "src:assets"
import "src:camera"
import "src:interaction"
import "src:world"
import rl "vendor:raylib"

@(rodata)
VISUAL_PATHS := [world.Visual_Id]cstring {
	.Rogue_Hooded = "assets/models/characters/Rogue_Hooded.glb",
	.Mage         = "assets/models/characters/Mage.glb",
	.Knight       = "assets/models/characters/Knight.glb",
}

Model_Instance :: struct {
	entity_id:  world.Entity_Id,
	anim_frame: f32,
}

Render :: struct {
	models:    [world.Visual_Id]Maybe(assets.Model_Asset),
	instances: [dynamic]Model_Instance,
}

draw_frame :: proc(
	r: ^Render,
	w: world.World,
	c: camera.Combat_Camera,
	ui: interaction.Interaction,
) {
	sync_instances(r, w)

	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)
	rl.BeginMode3D(c.camera)

	draw_tiles(w.grid, ui.hovered_tile)

	draw_path(w.grid, ui.path_preview)

	draw_entities(r^, w, ui.hovered_entity, ui.selected_entity)

	rl.EndMode3D()

	rl.DrawFPS(10, 10)

	rl.EndDrawing()
}

sync_instances :: proc(r: ^Render, w: world.World) {
	for e in w.entities {
		if has_instance(r^, e.id) do continue
		if r.models[e.visual] == nil {
			r.models[e.visual] = assets.model_load(VISUAL_PATHS[e.visual])
		}

		append(&r.instances, Model_Instance{entity_id = e.id})
	}

	#reverse for inst, i in r.instances {
		if world.entity_get(w, inst.entity_id) == nil {
			unordered_remove(&r.instances, i)
		}
	}
}

has_instance :: proc(r: Render, id: world.Entity_Id) -> bool {
	for inst in r.instances {
		if inst.entity_id == id do return true
	}
	return false
}

destroy :: proc(r: ^Render) {
	for m in r.models {
		if asset, ok := m.?; ok {assets.model_unload(asset)}
	}
	r.models = {}
	delete(r.instances)
	r.instances = nil
}
