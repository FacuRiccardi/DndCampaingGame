package assets

import "core:strings"
import rl "vendor:raylib"

bone_name :: proc(b: ^rl.BoneInfo) -> string {
	return strings.truncate_to_byte(string(b.name[:]), 0)
}

// raylib applies animation poses by bone index, but KayKit character and animation
// files list the same bones in a different order. Reorder each keyframe pose so that
// index i matches model.skeleton bone i, looking bones up by name.
// Only the in-memory animation data is changed; the .glb files are untouched.
anims_remap_to_model :: proc(
	model: rl.Model,
	anims: [^]rl.ModelAnimation,
	anim_count: i32,
	anim_skeleton: rl.ModelSkeleton,
) {
	bone_count := int(model.skeleton.boneCount)

	// remap[model_bone] = index of the same bone in the animation file, or -1.
	remap := make([]int, bone_count, context.temp_allocator)
	for i in 0 ..< bone_count {
		remap[i] = -1
		name := bone_name(&model.skeleton.bones[i])
		for j in 0 ..< int(anim_skeleton.boneCount) {
			if bone_name(&anim_skeleton.bones[j]) == name {
				remap[i] = j
				break
			}
		}
	}

	reordered := make([]rl.Transform, bone_count, context.temp_allocator)
	for a in 0 ..< int(anim_count) {
		anim := anims[a]
		for k in 0 ..< int(anim.keyframeCount) {
			pose := anim.keyframePoses[k]
			for i in 0 ..< bone_count {
				// Bones missing from the animation keep their bind pose.
				reordered[i] = remap[i] >= 0 ? pose[remap[i]] : model.skeleton.bindPose[i]
			}
			copy(pose[:bone_count], reordered)
		}
	}
}

// Loads the animations in path and remaps them to the bone order of model.
load_model_animations_remapped :: proc(
	model: rl.Model,
	path: cstring,
) -> (
	anims: [^]rl.ModelAnimation,
	anim_count: i32,
) {
	anims = rl.LoadModelAnimations(path, &anim_count)

	// Loaded only to read the bone order used by the animation file.
	anim_source := rl.LoadModel(path)
	defer rl.UnloadModel(anim_source)

	anims_remap_to_model(model, anims, anim_count, anim_source.skeleton)
	return
}

// Returns the index of the animation with the given name, or nil if not found.
anim_find :: proc(anims: [^]rl.ModelAnimation, anim_count: i32, name: string) -> Maybe(i32) {
	for i in 0 ..< anim_count {
		if strings.truncate_to_byte(string(anims[i].name[:]), 0) == name {
			return i
		}
	}
	return nil
}
