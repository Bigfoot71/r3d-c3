/* r3d_material.c3 -- R3D Material Module.
 *
 * Copyright (c) 2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
module r3d;

import raylib55;

// ========================================
// ENUMS TYPES
// ========================================

<*
 Material transparency handling modes.

 Defines how material opacity and blending are processed during rendering.
*>
enum R3DTransparencyMode : int
{
    OPAQUE,     // Fully opaque in G-Buffer (supports hard alpha cutoff/masking). Ignores blend mode.
    HYBRID,     // Two-pass rendering: opaque cutoff in G-Buffer + forward blending.
    BLEND,      // Blended only (forward pass, no depth write / shadow casting).
}

<*
 Billboard modes.

 This enumeration defines how a 3D object aligns itself relative to the camera.
 It provides options to disable billboarding or to enable specific modes of alignment.
*>
enum R3DBillboardMode : int
{
    DISABLED,   // Billboarding is disabled; the object retains its original orientation.
    FRONT,      // Full billboarding; the object fully faces the camera, rotating on all axes.
    Y_AXIS,     // Y-axis constrained billboarding; the object rotates only around the Y-axis, keeping its "up" orientation fixed. This is suitable for upright objects like characters or signs.
}

<*
 Blend modes.

 Defines common blending modes to combine source and destination colors.
 NOTE: Ignored when R3DTransparencyMode.OPAQUE is selected.
*>
enum R3DBlendMode : int
{
    ALPHA,                  // Standard alpha blending: source color is blended using its alpha channel.
    ADDITIVE,               // Pure additive blending: source color is added directly to destination (ignores alpha).
    ADD_ALPHA,              // Alpha-modulated additive blending: source color scaled by alpha before adding to destination.
	MULTIPLY,               // Multiply blending: source color is multiplied with destination, darkening the image.
    PREMULTIPLIED_ALPHA,    // Premultiplied alpha blending: assumes source color is already multiplied by its alpha.
}

<*
 Comparison modes.

 Defines how fragments are tested against the depth/stencil buffer during rendering.

 The depth/stencil comparison mode affects both forward and deferred rendering passes.
*>
enum R3DCompareMode : int
{
    LESS,       // Passes if 'value' <  'buffer' (default)
    LEQUAL,     // Passes if 'value' <= 'buffer'
    EQUAL,      // Passes if 'value' == 'buffer'
    GREATER,    // Passes if 'value' >  'buffer'
    GEQUAL,     // Passes if 'value' >= 'buffer'
    NOTEQUAL,   // Passes if 'value' != 'buffer'
    ALWAYS,     // Always passes
    NEVER,      // Never passes
}

<*
 Stencil buffer operations.

 Defines how the stencil buffer value is modified based on test results.
*>
enum R3DStencilOp : int
{
    KEEP,       // Keep the current stencil value
    ZERO,       // Set stencil value to 0
    REPLACE,    // Replace with reference value
    INCR,       // Increment stencil value (clamped)
    DECR,       // Decrement stencil value (clamped)
}

<*
 Face culling modes.

 Specifies which faces of a geometry are discarded during rendering based on their winding order.
*>
enum R3DCullMode : int
{
    NONE,   // No culling; all faces are rendered.
    BACK,   // Cull back-facing polygons (faces with clockwise winding order).
    FRONT,  // Cull front-facing polygons (faces with counter-clockwise winding order).
}

// ========================================
// STRUCTS TYPES
// ========================================

<*
 Albedo (base color) map.

 Provides the base color texture and a color multiplier.
*>
struct R3DAlbedoMap
{
    RLTexture2D texture;    // Base color texture (default: WHITE)
    RLColor color;          // Color multiplier (default: WHITE)
}

<*
 Emission map.

 Provides emission texture, color, and energy multiplier.
*>
struct R3DEmissionMap
{
    RLTexture2D texture;    // Emission texture (default: WHITE)
    RLColor color;          // Emission color (default: WHITE)
    float energy;           // Emission strength (default: 0.0f)
}

<*
 Normal map.

 Provides normal map texture and scale factor.
*>
struct R3DNormalMap
{
    RLTexture2D texture;    // Normal map texture (default: Front Facing)
    float scale;            // Normal scale (default: 1.0f)
}

<*
 Combined Occlusion-Roughness-Metalness (ORM) map.

 Provides texture and individual multipliers for occlusion, roughness, and metalness.
*>
struct R3DOrmMap
{
    RLTexture2D texture;    // ORM texture (default: WHITE)
    float occlusion;        // Occlusion multiplier (default: 1.0f)
    float roughness;        // Roughness multiplier (default: 1.0f)
    float metalness;        // Metalness multiplier (default: 0.0f)
    float specular;         // Controls how reflective non-metal materials appear (default: 0.5f)
}

<*
 Depth buffer state configuration.

 Controls how fragments interact with the depth buffer during rendering.

 This structure does not directly control depth buffer writes for technical reasons.
 To render objects without writing to the depth buffer, use alpha blending mode instead.
*>
struct R3DDepthState
{
    R3DCompareMode mode;    // Comparison function for depth test (default: LESS)
    float offset_factor;    // Scales the maximum depth slope for polygon offset (default: 0.0f)
    float offset_units;     // Constant depth offset value (default: 0.0f)
    float range_near;       // Near clipping plane for depth range mapping (default: 0.0f)
    float range_far;        // Far clipping plane for depth range mapping (default: 1.0f)
}

<*
 Stencil buffer state configuration.

 Controls how fragments interact with the stencil buffer during rendering.
 The stencil buffer can be used for effects like x-ray vision, outlines,
 portals, and masking.
*>
struct R3DStencilState
{
    R3DCompareMode mode;     // Comparison function for stencil test (default: ALWAYS)
    char ref;                // Reference value (0-255) for comparison and replace operations (default: 0x00)
    char mask;               // Bit mask applied to both reference and stencil values during comparison (default: 0xFF)
    R3DStencilOp op_fail;    // Operation when stencil test fails (default: KEEP)
    R3DStencilOp op_z_fail;  // Operation when stencil test passes but depth test fails (default: KEEP)
    R3DStencilOp op_pass;    // Operation when both stencil and depth tests pass (default: REPLACE)
}

<*
 Material definition.

 Combines multiple texture maps and rendering parameters for shading.
*>
struct R3DMaterial
{
    R3DAlbedoMap albedo;                     // Albedo map
    R3DEmissionMap emission;                 // Emission map
    R3DNormalMap normal;                     // Normal map
    R3DOrmMap orm;                           // Occlusion-Roughness-Metalness map

    RLVector2 uv_offset;                     // UV offset (default: {0.0f, 0.0f})
    RLVector2 uv_scale;                      // UV scale (default: {1.0f, 1.0f})
    float alpha_cutoff;                      // Alpha cutoff threshold (default: 0.01f)

    R3DDepthState depth;                     // Depth test configuration (default: standard)
    R3DStencilState stencil;                 // Stencil test configuration (default: disabled)

    R3DTransparencyMode transparency_mode;   // Transparency mode (default: DISABLED)
    R3DBillboardMode billboard_mode;         // Billboard mode (default: DISABLED)
    R3DBlendMode blend_mode;                 // Blend mode (default: MIX)
    R3DCullMode cull_mode;                   // Face culling mode (default: BACK)
    bool unlit;                              // If true, material does not participate in lighting (default: false)

    int priority;                            // Render order priority; lower values are drawn first (default: 0)
    R3DSurfaceShader* shader;                // Custom shader applied to the material (default: NULL)
}

// ========================================
// CONSTANTS
// ========================================

<*
 Default material configuration.

 Initializes an R3DMaterial structure with sensible default values for all
 rendering parameters. Use this as a starting point for custom configurations.
*>
const R3DMaterial MATERIAL_BASE = {
    .albedo = {
        .texture = {},
        .color = { 255, 255, 255, 255 },
    },
    .emission = {
        .texture = {},
        .color = { 255, 255, 255, 255 },
        .energy = 0.0f,
    },
    .normal = {
        .texture = {},
        .scale = 1.0f,
    },
    .orm = {
        .texture = {},
        .occlusion = 1.0f,
        .roughness = 1.0f,
        .metalness = 0.0f,
        .specular  = 0.5f,
    },
    .uv_offset = { 0.0f, 0.0f },
    .uv_scale = { 1.0f, 1.0f },
    .alpha_cutoff = 0.5f,
    .depth = {
        .mode = LESS,
        .offset_factor = 0.0f,
        .offset_units = 0.0f,
        .range_near = 0.0f,
        .range_far = 1.0f,
    },
    .stencil = {
        .mode = ALWAYS,
        .ref = 0x00,
        .mask = 0xFF,
        .op_fail = KEEP,
        .op_z_fail = KEEP,
        .op_pass = REPLACE,
    },
    .transparency_mode = OPAQUE,
    .billboard_mode = DISABLED,
    .blend_mode = ALPHA,
    .cull_mode = BACK,
    .unlit = false,
    .priority = 0,
    .shader = null,
};

// ========================================
// PUBLIC API
// ========================================

<*
 Get the default material configuration.

 Returns `MATERIAL_BASE` by default,
 or the material defined via `set_default_material()`.

 @return `default material structure with standard properties`
*>
extern fn R3DMaterial get_default_material() @cname("R3D_GetDefaultMaterial");

<*
 Set the default material configuration.

 Allows you to override the default material.
 The default material will be used as the basis for loading 3D models.

 @param material : `default material to define`
*>
extern fn void set_default_material(R3DMaterial material) @cname("R3D_SetDefaultMaterial");

<*
 Load materials from a file.

 Parses a 3D model file and loads its associated materials.

 @param file_path : `path to the 3D model file`
 @param material_count : `pointer to an integer to store the number of loaded materials`
 @return `pointer to an array of loaded R3DMaterial, or NULL on failure`
*>
extern fn R3DMaterial* load_materials(ZString file_path, int* material_count) @cname("R3D_LoadMaterials");

<*
 Load materials from memory.

 Loads materials directly from a memory buffer containing 3D model data.

 @param data : `pointer to the memory buffer containing the model data`
 @param size : `size of the data buffer in bytes`
 @param hint : `hint on the model format (can be NULL)`
 @param material_count : `pointer to an integer to store the number of loaded materials`
 @return `pointer to an array of loaded R3DMaterial, or NULL on failure`
*>
extern fn R3DMaterial* load_materials_from_memory(void* data, uint size, ZString hint, int* material_count) @cname("R3D_LoadMaterialsFromMemory");

<*
 Load materials from an importer.

 Loads materials that were previously imported via an R3DImporter instance.

 @param importer : `pointer to a valid R3DImporter`
 @param material_count : `pointer to an integer to store the number of loaded materials`
 @return `pointer to an array of loaded R3DMaterial, or NULL on failure`
*>
extern fn R3DMaterial* load_materials_from_importer(R3DImporter* importer, int* material_count) @cname("R3D_LoadMaterialsFromImporter");

<*
 Unload a material and its associated textures.

 Frees all memory associated with a material, including its textures.
 This function will unload all textures that are not default textures.

 Only call this function if you are certain that the textures
 are not shared with other materials or objects, as this will permanently
 free the texture data.

 @param material : `pointer to the material structure to be unloaded`
*>
extern fn void unload_material(R3DMaterial material) @cname("R3D_UnloadMaterial");

<*
 Load an albedo (base color) map from file.

 Loads an image, uploads it as an sRGB texture (if enabled),
 and applies the provided tint color.

 @param file_name : `path to the texture file`
 @param color : `multiplicative tint applied in the shader`
 @return `albedo map structure; returns an empty map on failure`
*>
extern fn R3DAlbedoMap load_albedo_map(ZString file_name, RLColor color) @cname("R3D_LoadAlbedoMap");

<*
 Load an albedo (base color) map from memory.

 Same behavior as load_albedo_map(), but reads from memory instead of disk.

 @param file_type : `image format hint (e.g. ".png", ".jpg")`
 @param file_data : `pointer to image data`
 @param data_size : `size of image data in bytes`
 @param color : `multiplicative tint applied in the shader`
 @return `albedo map structure; returns an empty map on failure`
*>
extern fn R3DAlbedoMap load_albedo_map_from_memory(ZString file_type, void* file_data, int data_size, RLColor color) @cname("R3D_LoadAlbedoMapFromMemory");

<*
 Unload an albedo map texture.

 Frees the underlying texture unless it is a default texture.

 @param map : `albedo map to unload`
*>
extern fn void unload_albedo_map(R3DAlbedoMap map) @cname("R3D_UnloadAlbedoMap");

<*
 Load an emission map from file.

 Loads an emissive texture (sRGB if enabled) and sets color + energy.

 @param file_name : `path to the texture file`
 @param color : `emission color`
 @param energy : `emission intensity multiplier`
 @return `emission map; returns an empty map on failure`
*>
extern fn R3DEmissionMap load_emission_map(ZString file_name, RLColor color, float energy) @cname("R3D_LoadEmissionMap");

<*
 Load an emission map from memory.

 Same behavior as load_emission_map(), but reads from memory.

 @param file_type : `image format hint (e.g. ".png", ".jpg")`
 @param file_data : `pointer to image data`
 @param data_size : `size of image data in bytes`
 @param color : `emission color`
 @param energy : `emission intensity multiplier`
 @return `emission map; returns an empty map on failure`
*>
extern fn R3DEmissionMap load_emission_map_from_memory(ZString file_type, void* file_data, int data_size, RLColor color, float energy) @cname("R3D_LoadEmissionMapFromMemory");

<*
 Unload an emission map texture.

 Frees the texture unless it is a default texture.

 @param map : `emission map to unload`
*>
extern fn void unload_emission_map(R3DEmissionMap map) @cname("R3D_UnloadEmissionMap");

<*
 Load a normal map from file.

 Uploads the texture in linear space and stores the normal scale factor.

 @param file_name : `path to the texture file`
 @param scale : `normal intensity multiplier`
 @return `normal map; returns an empty map on failure`
*>
extern fn R3DNormalMap load_normal_map(ZString file_name, float scale) @cname("R3D_LoadNormalMap");

<*
 Load a normal map from memory.

 Same behavior as load_normal_map(), but reads from memory.

 @param file_type : `image format hint (e.g. ".png", ".jpg")`
 @param file_data : `pointer to image data`
 @param data_size : `size of image data in bytes`
 @param scale : `normal intensity multiplier`
 @return `normal map; returns an empty map on failure`
*>
extern fn R3DNormalMap load_normal_map_from_memory(ZString file_type, void* file_data, int data_size, float scale) @cname("R3D_LoadNormalMapFromMemory");

<*
 Unload a normal map texture.

 Frees the texture unless it is a default texture.

 @param map : `normal map to unload`
*>
extern fn void unload_normal_map(R3DNormalMap map) @cname("R3D_UnloadNormalMap");

<*
 Load a combined ORM (Occlusion-Roughness-Metalness) map from file.

 Uploads the texture in linear space and applies the provided multipliers.

 @param file_name : `path to the ORM texture`
 @param occlusion : `occlusion multiplier`
 @param roughness : `roughness multiplier`
 @param metalness : `metalness multiplier`
 @param specular : `base reflectivity multiplier for non-metal materials`
 @return `ORM map; returns an empty map on failure`
*>
extern fn R3DOrmMap load_orm_map(ZString file_name, float occlusion, float roughness, float metalness, float specular) @cname("R3D_LoadOrmMap");

<*
 Load a combined ORM (Occlusion-Roughness-Metalness) map from memory.

 Same behavior as load_orm_map(), but reads from memory.

 @param file_type : `image format hint (e.g. ".png", ".jpg")`
 @param file_data : `pointer to image data`
 @param data_size : `size of image data in bytes`
 @param occlusion : `occlusion multiplier`
 @param roughness : `roughness multiplier`
 @param metalness : `metalness multiplier`
 @param specular : `base reflectivity multiplier for non-metal materials`
 @return `ORM map; returns an empty map on failure`
*>
extern fn R3DOrmMap load_orm_map_from_memory(ZString file_type, void* file_data, int data_size, float occlusion, float roughness, float metalness, float specular) @cname("R3D_LoadOrmMapFromMemory");

<*
 Unload an ORM map texture.

 Frees the texture unless it is a default texture.

 @param map : `ORM map to unload`
*>
extern fn void unload_orm_map(R3DOrmMap map) @cname("R3D_UnloadOrmMap");
