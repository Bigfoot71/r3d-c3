/* r3d_model.c3 -- R3D Model Module.
 *
 * Copyright (c) 2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
module r3d;

import raylib55;

// ========================================
// ALIASES TYPES
// ========================================

<*
 Fixed-length string type for mesh names.

 The size can be freely adjusted before compilation.
*>
typedef R3DMeshName = char[32];

// ========================================
// STRUCTS TYPES
// ========================================

<*
 Represents a complete 3D model with meshes and materials.

 Contains multiple meshes and their associated materials, along with animation and bounding information.
*>
struct R3DModel
{
    R3DMesh* meshes;            // Array of meshes composing the model.
    R3DMeshData* mesh_data;     // Array of meshes data in RAM (optional, can be NULL).
    R3DMeshName* mesh_names;    // Array of meshes names (optional, can be NULL).

    R3DMaterial* materials;     // Array of materials used by the model.
    int* mesh_materials;        // Array of material indices, one per mesh.

    int mesh_count;             // Number of meshes.
    int material_count;         // Number of materials.

    RLBoundingBox aabb;         // Axis-Aligned Bounding Box encompassing the whole model.
    R3DSkeleton skeleton;       // Skeleton hierarchy and bind pose used for skinning (NULL if non-skinned).
}

// ========================================
// PUBLIC API
// ========================================

<*
 Load a 3D model from a file.

 Loads a 3D model from the specified file path. Supports various 3D file formats
 and automatically parses meshes, materials, and texture references.

 @param file_path : `path to the 3D model file to load`
 @return `loaded model structure containing meshes and materials`
*>
extern fn R3DModel load_model(ZString file_path) @cname("R3D_LoadModel");

<*
 Load a 3D model from a file with import flags.

 Extended version of load_model() allowing control over the import
 process through additional flags.

 @param file_path : `path to the 3D model file to load`
 @param flags : `importer behavior flags`
 @return `loaded model structure containing meshes and materials`
*>
extern fn R3DModel load_model_ex(ZString file_path, R3DImportFlags flags) @cname("R3D_LoadModelEx");

<*
 Load a 3D model from memory buffer.

 Loads a 3D model from a memory buffer containing the file data.
 Useful for loading models from embedded resources or network streams.

 External dependencies (e.g., textures or linked resources) are not supported.
 The model data must be fully self-contained. Use embedded formats like .glb to ensure compatibility.

 @param data : `pointer to the memory buffer containing the model data`
 @param size : `size of the data buffer in bytes`
 @param hint : `hint on the model format (can be NULL)`
 @return `loaded model structure containing meshes and materials`
*>
extern fn R3DModel load_model_from_memory(void* data, uint size, ZString hint) @cname("R3D_LoadModelFromMemory");

<*
 Load a 3D model from a memory buffer with import flags.

 Extended version of load_model_from_memory() allowing control over
 the import process through additional flags.

 External dependencies (e.g., textures or linked resources) are not supported.
 The model data must be fully self-contained.

 @param data : `pointer to the memory buffer containing the model data`
 @param size : `size of the data buffer in bytes`
 @param hint : `hint on the model format (can be NULL)`
 @param flags : `importer behavior flags`
 @return `loaded model structure containing meshes and materials`
*>
extern fn R3DModel load_model_from_memory_ex(void* data, uint size, ZString hint, R3DImportFlags flags) @cname("R3D_LoadModelFromMemoryEx");

<*
 Load a 3D model from an existing importer.

 Creates a model from a previously loaded importer instance.
 This avoids re-importing the source file.

 @param importer : `importer instance to extract the model from`
 @return `loaded model structure containing meshes and materials`
*>
extern fn R3DModel load_model_from_importer(R3DImporter* importer) @cname("R3D_LoadModelFromImporter");

<*
 Unload a model and optionally its materials.

 Frees all memory associated with a model, including its meshes.
 Materials can be optionally unloaded as well.

 @param model : `the model to be unloaded`
 @param unload_materials : `if true, also unloads all materials associated with the model. Set to false if textures are still being used elsewhere to avoid freeing shared resources`
*>
extern fn void unload_model(R3DModel model, bool unload_materials) @cname("R3D_UnloadModel");

<*
 Returns the index of the mesh with the given name.

 @param model : `the model to search in`
 @param mesh_name : `the name of the mesh to look up`
 @return `the mesh index, or -1 if not found or if mesh_names is NULL`
*>
extern fn int get_model_mesh_index(R3DModel model, ZString mesh_name) @cname("R3D_GetModelMeshIndex");

<*
 Returns a pointer to the mesh with the given name.

 @param model : `the model to search in`
 @param mesh_name : `the name of the mesh to look up`
 @return `a pointer to the mesh, or NULL if not found or if mesh_names is NULL`
*>
extern fn R3DMesh* get_model_mesh(R3DModel model, ZString mesh_name) @cname("R3D_GetModelMesh");

<*
 Returns a pointer to the mesh data with the given name.

 @param model : `the model to search in`
 @param mesh_name : `the name of the mesh to look up`
 @return `a pointer to the mesh data, or NULL if not found or if mesh_names or mesh_data is NULL`
*>
extern fn R3DMeshData* get_model_mesh_data(R3DModel model, ZString mesh_name) @cname("R3D_GetModelMeshData");
