package render

import "core:math"
import "src:assets"
import "src:world"
import rl "vendor:raylib"

ANIM_FPS :: 120.0

current_clip :: proc(asset: assets.Model_Asset, e: world.Entity) -> Maybe(rl.ModelAnimation) {
	set, name := asset.general, "Idle_B"
	if e.movement.moving {
		set, name = asset.movement, "Walking_A"
	}
	i, found := assets.anim_find(set.anims, set.count, name).?
	if !found {return nil}
	return set.anims[i]
}

animate :: proc(r: ^Render, w: world.World, dt: f32) {
	for &inst in r.instances {
		e, ok := world.entity_get(w, inst.entity_id).?
		if !ok {continue}
		asset, loaded := r.models[e.visual].?
		if !loaded {continue}
		clip, found := current_clip(asset, e).?
		if !found {continue}
		inst.anim_frame = math.mod(inst.anim_frame + ANIM_FPS * dt, f32(clip.keyframeCount))
	}
}
