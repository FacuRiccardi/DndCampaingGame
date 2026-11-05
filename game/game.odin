package game

import "../camera"
import "../controls"
import "../render"
import "../scene"
import rl "vendor:raylib"

Window_Config :: struct {
	width, height: i32,
	title:         cstring,
	fullscreen:    bool,
	target_fps:    i32,
	msaa:          bool,
}

window_default_config :: proc() -> Window_Config {
	return {
		width = 1200,
		height = 800,
		title = "RPGGame",
		target_fps = 120,
		msaa = true,
		fullscreen = true,
	}
}

window_open :: proc(c: Window_Config) {
	flags: rl.ConfigFlags
	if c.msaa {flags += {.MSAA_4X_HINT}}
	if c.fullscreen {flags += {.FULLSCREEN_MODE}}
	rl.SetConfigFlags(flags)
	rl.InitWindow(c.width, c.height, c.title)
	rl.SetTargetFPS(c.target_fps)
}

loop :: proc() {

	window_open(window_default_config())

	cam := camera.init(camera.default_config())
	cls: controls.Controls

	sc := scene.generate(20, 20)
	defer scene.destroy(&sc)

	scene.spawn_entity(&sc, {1, 1})
	scene.spawn_entity(&sc, {19, 19})

	for !rl.WindowShouldClose() {
		for cmd in controls.update(&cls, sc, cam) {
			scene.apply(&sc, cmd)
		}

		camera.update(&cam, cls.camera_movement)

		render.render(
			sc,
			cam,
			cls.hovered_entity,
			cls.selected_entity,
			cls.hovered_tile,
			cls.path_preview,
		)

		free_all(context.temp_allocator)
	}

	rl.CloseWindow()
}
