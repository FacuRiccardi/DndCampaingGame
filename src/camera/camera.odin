package camera

import rl "vendor:raylib"

Config :: struct {
	start_target: rl.Vector3, // ground point the camera looks at on start
	offset:       rl.Vector3, // from target to camera; defines the isometric angle
	fovy:         f32, // in orthographic mode, vertical size of the view
	max_speed:    f32,
	acceleration: f32,
	deceleration: f32,
	map_limit:    f32, // limit on the target's X and Z
}

// Config + state that changes every frame.
Combat_Camera :: struct {
	camera:   rl.Camera3D,
	velocity: rl.Vector3,
	config:   Config,
}

default_config :: proc() -> Config {
	return Config {
		start_target = {0.0, 0.0, 0.0},
		offset = {10.0, 8.165, 10.0},
		fovy = 10.0,
		max_speed = 10.0,
		acceleration = 40.0,
		deceleration = 60.0,
		map_limit = 10.0,
	}
}

init :: proc(config: Config) -> Combat_Camera {
	c: Combat_Camera
	c.config = config
	c.camera.target = config.start_target
	c.camera.position = config.start_target + config.offset
	c.camera.up = {0.0, 1.0, 0.0}
	c.camera.fovy = config.fovy
	c.camera.projection = .ORTHOGRAPHIC
	return c
}

update :: proc(c: ^Combat_Camera, move: rl.Vector3) {
	dt := rl.GetFrameTime()

	if (move != {0, 0, 0}) {
		c.velocity += rl.Vector3Normalize(move) * c.config.acceleration * dt
	} else {
		speed := rl.Vector3Length(c.velocity)
		drop := c.config.deceleration * dt
		if (speed <= drop) {
			c.velocity = {}
		} else {
			c.velocity *= (speed - drop) / speed
		}
	}

	if (rl.Vector3Length(c.velocity) > c.config.max_speed) {
		c.velocity = rl.Vector3Normalize(c.velocity) * c.config.max_speed
	}

	c.camera.position += c.velocity * dt
	c.camera.target += c.velocity * dt

	clamped := c.camera.target
	clamped.x = clamp(clamped.x, -c.config.map_limit, c.config.map_limit)
	clamped.z = clamp(clamped.z, -c.config.map_limit, c.config.map_limit)
	correction := clamped - c.camera.target
	c.camera.position += correction
	c.camera.target = clamped
	if (correction.x != 0) {c.velocity.x = 0}
	if (correction.z != 0) {c.velocity.z = 0}
}
