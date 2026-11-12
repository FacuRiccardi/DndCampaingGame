package app

import "src:camera"
import "src:input"
import "src:interaction"
import "src:render"
import "src:world"
import rl "vendor:raylib"

run :: proc() {
	window_open(window_default_config())
	defer rl.CloseWindow()

	cam := camera.init(camera.default_config())
	ui: interaction.Interaction

	w := world.create(20, 20)
	defer world.destroy(&w)
	setup_encounter(&w)

	r: render.Render
	defer render.destroy(&r)

	for !rl.WindowShouldClose() {
		inp := input.poll()
		for cmd in interaction.update(&ui, inp, w, cam) {
			world.apply(&w, cmd)
		}

		world.update(&w, rl.GetFrameTime())
		camera.update(&cam, inp.camera_move)
		render.animate(&r, w, rl.GetFrameTime())
		render.draw_frame(&r, w, cam, ui)
		free_all(context.temp_allocator)
	}
}

setup_encounter :: proc(w: ^world.World) {
	world.spawn_entity(w, {9, 9}, .Rogue_Hooded)
	world.spawn_entity(w, {11, 11}, .Knight)
}
