package app

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
		fullscreen = false,
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
