package assets

import rl "vendor:raylib"

RIG_GENERAL :: "assets/animations/rig_medium/Rig_Medium_General.glb"
RIG_MOVEMENT :: "assets/animations/rig_medium/Rig_Medium_MovementBasic.glb"

Anim_Set :: struct {
	anims: [^]rl.ModelAnimation,
	count: i32,
}

Model_Asset :: struct {
	model:    rl.Model,
	general:  Anim_Set,
	movement: Anim_Set,
}

model_load :: proc(path: cstring) -> Model_Asset {
	a: Model_Asset
	a.model = rl.LoadModel(path)
	a.general.anims, a.general.count = load_model_animations_remapped(a.model, RIG_GENERAL)
	a.movement.anims, a.movement.count = load_model_animations_remapped(a.model, RIG_MOVEMENT)
	return a
}

model_unload :: proc(a: Model_Asset) {
	rl.UnloadModelAnimations(a.general.anims, a.general.count)
	rl.UnloadModelAnimations(a.movement.anims, a.movement.count)
	rl.UnloadModel(a.model)
}
