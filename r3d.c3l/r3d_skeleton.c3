/* r3d_skeleton.c3 -- R3D Skeleton Module.
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
 Stores bone information for skeletal animation.

 Contains the bone name and the index of its parent bone.
*>
struct R3DBoneInfo
{
    char[32] name;   // Bone name (max 31 characters + null terminator).
    int parent;      // Index of the parent bone (-1 if root).
}

<*
 Represents a skeletal hierarchy used for skinning.

 Defines the bone structure, reference poses, and inverse bind matrices
 required for skeletal animation. The skeleton provides both local and
 global bind poses used during skinning and animation playback.
*>
struct R3DSkeleton
{
    R3DBoneInfo* bones;      // Array of bone descriptors defining the hierarchy and names.
    int bone_count;          // Total number of bones in the skeleton.

    RLMatrix* local_bind;    // Bind pose matrices relative to parent
    RLMatrix* model_bind;    // Bind pose matrices in model/global space
    RLMatrix* inv_bind;      // Inverse bind matrices (model space) for skinning
    RLMatrix root_bind;      // Root correction if local bind is not identity

    uint skin_texture;       // Texture ID that contains the bind pose for GPU skinning. This is a 1D Texture RGBA16F 4*bone_count.
}

// ========================================
// PUBLIC API
// ========================================

<*
 Loads a skeleton hierarchy from a 3D model file.

 Skeletons are automatically loaded when importing a model,
 but can be loaded manually for advanced use cases.

 @param file_path : `path to the model file containing the skeleton data`
 @return `the loaded R3DSkeleton`
*>
extern fn R3DSkeleton load_skeleton(ZString file_path) @cname("R3D_LoadSkeleton");

<*
 Loads a skeleton hierarchy from memory data.

 Allows manual loading of skeletons directly from a memory buffer.
 Typically used for advanced or custom asset loading workflows.

 @param data : `pointer to the memory buffer containing skeleton data`
 @param size : `size of the memory buffer in bytes`
 @param hint : `optional format hint (can be NULL)`
 @return `the loaded R3DSkeleton`
*>
extern fn R3DSkeleton load_skeleton_from_memory(void* data, uint size, ZString hint) @cname("R3D_LoadSkeletonFromMemory");

<*
 Loads a skeleton hierarchy from an existing importer.

 Extracts the skeleton data from a previously loaded importer instance.

 @param importer : `importer instance to extract the skeleton from`
 @return `the loaded R3DSkeleton`
*>
extern fn R3DSkeleton load_skeleton_from_importer(R3DImporter* importer) @cname("R3D_LoadSkeletonFromImporter");

<*
 Frees the memory allocated for a skeleton.

 @param skeleton : `R3DSkeleton to destroy`
*>
extern fn void unload_skeleton(R3DSkeleton skeleton) @cname("R3D_UnloadSkeleton");

<*
 Check if a skeleton is valid.

 Returns true if atleast the tex_bind_pose is greater than zero.

 @param skeleton : `the skeleton to check`
 @return `true if valid, false otherwise`
*>
extern fn bool is_skeleton_valid(R3DSkeleton skeleton) @cname("R3D_IsSkeletonValid");

<*
 Returns the index of the bone with the given name.

 @param skeleton : `skeleton to search in`
 @param bone_name : `name of the bone to find`
 @return `index of the bone, or a negative value if not found`
*>
extern fn int get_skeleton_bone_index(R3DSkeleton skeleton, ZString bone_name) @cname("R3D_GetSkeletonBoneIndex");

<*
 Returns a pointer to the bone with the given name.

 @param skeleton : `skeleton to search in`
 @param bone_name : `name of the bone to find`
 @return `pointer to the bone, or NULL if not found`
*>
extern fn R3DBoneInfo* get_skeleton_bone(R3DSkeleton skeleton, ZString bone_name) @cname("R3D_GetSkeletonBone");
