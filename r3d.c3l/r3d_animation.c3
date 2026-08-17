/* r3d_animation.c3 -- R3D Animation Module.
 *
 * Copyright (c) 2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
module r3d;

import raylib55;

// ========================================
// STRUCTS TYPES
// ========================================

<*
 Animation track storing keyframe times and values.

 Represents a single animated property (translation, rotation or scale).
 Keys are sampled by time and interpolated at runtime.
*>
struct R3DAnimationTrack
{
    float* times;    // Keyframe times (sorted, in animation ticks).
    void* values;    // Keyframe values (RLVector3 or RLQuaternion).
    int count;       // Number of keyframes.
}

<*
 Animation channel controlling a single bone.

 Contains animation tracks for translation, rotation and scale.
 The sampled tracks are combined to produce the bone local transform.
*>
struct R3DAnimationChannel
{
    R3DAnimationTrack translation;  // Translation track (RLVector3).
    R3DAnimationTrack rotation;     // Rotation track (RLQuaternion).
    R3DAnimationTrack scale;        // Scale track (RLVector3).
    int bone_index;                 // Index of the affected bone.
}

<*
 Represents a skeletal animation for a model.

 Contains all animation channels required to animate a skeleton.
 Each channel corresponds to one bone and defines its transformation
 (translation, rotation, scale) over time.
*>
struct R3DAnimation
{
    R3DAnimationChannel* channels;   // Array of animation channels, one per animated bone.
    int channel_count;               // Total number of channels in this animation.
    float ticks_per_second;          // Playback rate; number of animation ticks per second.
    float duration;                  // Total length of the animation, in ticks.
    int bone_count;                  // Number of bones in the target skeleton.
    char[32] name;                   // Animation name (null-terminated string).
}

<*
 Represents a collection of skeletal animations sharing the same skeleton.

 Holds multiple animations that can be applied to compatible models or skeletons.
 Typically loaded together from a single 3D model file (e.g., GLTF, FBX) containing several animation clips.
*>
struct R3DAnimationLib
{
    R3DAnimation* animations;    // Array of animations included in this library.
    int count;                   // Number of animations contained in the library.
}

// ========================================
// PUBLIC API
// ========================================

<*
 Loads animations from a model file.

 @param file_path : `path to the model file containing animations`
 @return `an animation library, or a zeroed struct on failure`
*>
extern fn R3DAnimationLib load_animation_lib(ZString file_path) @cname("R3D_LoadAnimationLib");

<*
 Loads animations from memory data.

 @param data : `pointer to memory buffer containing model animation data`
 @param size : `size of the buffer in bytes`
 @param hint : `hint on the model format (can be NULL)`
 @return `an animation library, or a zeroed struct on failure`
*>
extern fn R3DAnimationLib load_animation_lib_from_memory(void* data, uint size, ZString hint) @cname("R3D_LoadAnimationLibFromMemory");

<*
 Loads animations from an existing importer.

 @param importer : `importer instance containing animation data`
 @return `an animation library, or a zeroed struct on failure`
*>
extern fn R3DAnimationLib load_animation_lib_from_importer(R3DImporter* importer) @cname("R3D_LoadAnimationLibFromImporter");

<*
 Releases all resources associated with an animation library.

 @param anim_lib : `animation library to unload`
*>
extern fn void unload_animation_lib(R3DAnimationLib anim_lib) @cname("R3D_UnloadAnimationLib");

<*
 Returns the index of an animation by name.

 @param anim_lib : `animation library to search`
 @param name : `name of the animation (case-sensitive)`
 @return `zero-based index if found, or -1 if not found`
*>
extern fn int get_animation_index(R3DAnimationLib anim_lib, ZString name) @cname("R3D_GetAnimationIndex");

<*
 Retrieves an animation by name.

 @param anim_lib : `animation library to search`
 @param name : `name of the animation (case-sensitive)`
 @return `pointer to the animation, or NULL if not found`
*>
extern fn R3DAnimation* get_animation(R3DAnimationLib anim_lib, ZString name) @cname("R3D_GetAnimation");
