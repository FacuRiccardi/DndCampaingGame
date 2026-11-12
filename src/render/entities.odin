package render

import "src:world"
import rl "vendor:raylib"

CYLINDER_SLICES :: 64
MODEL_SCALE :: 0.5

draw_entities :: proc(
	r: Render,
	w: world.World,
	hovered_entity, selected_entity: Maybe(world.Entity_Id),
) {
	for inst in r.instances {
		e, ok := world.entity_get(w, inst.entity_id).?
		if !ok do continue

		asset, loaded := r.models[e.visual].?
		if !loaded do continue

		if clip, found := current_clip(asset, e).?; found {
			rl.UpdateModelAnimation(asset.model, clip, inst.anim_frame)
		}


		rl.DrawModelEx(asset.model, e.position, {0, 1, 0}, e.facing, MODEL_SCALE, rl.WHITE)

		// color := rl.MAROON
		// if (e.id == selected_entity) {
		// 	color = rl.GREEN
		// } else if (e.id == hovered_entity) {
		// 	color = rl.BLUE
		// }

		// rl.DrawCylinderWires(
		// 	e.position,
		// 	e.size[0] / 2,
		// 	e.size[0] / 2,
		// 	e.size[1],
		// 	CYLINDER_SLICES,
		// 	color,
		// )
	}
}
