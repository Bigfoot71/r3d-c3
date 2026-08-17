/* r3d_decal.c3 -- R3D Decal Module.
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
 Represents a decal and its properties.

 This structure defines a decal that can be projected onto geometry that has already been rendered.

 Decals are drawn using deferred screen space rendering and do not interact with any
 forward rendered or non-opaque objects.
*>
struct R3DDecal
{
    R3DAlbedoMap albedo;         // Albedo map (if the texture is undefined, implicitly treat `apply_color` as false, with alpha = 1.0)
    R3DEmissionMap emission;     // Emission map
    R3DNormalMap normal;         // Normal map
    R3DOrmMap orm;                // Occlusion-Roughness-Metalness map
    RLVector2 uv_offset;          // UV offset (default: {0.0f, 0.0f})
    RLVector2 uv_scale;           // UV scale (default: {1.0f, 1.0f})
    float alpha_cutoff;           // Alpha cutoff threshold (default: 0.01f)
    float normal_threshold;       // Maximum angle against the surface normal to draw decal. 0.0f disables threshold. (default: 0.0f)
    float fade_width;             // The width of fading along the normal threshold (default: 0.0f)
    bool apply_color;             // Indicates that the albedo color will not be rendered, only the alpha component of the albedo will be used as a mask. (default: true)
    R3DSurfaceShader* shader;    // Custom shader applied to the decal (default: NULL)
}

// ========================================
// CONSTANTS
// ========================================

<*
 Default decal configuration.

 Contains a R3DDecal structure with sensible default values for all rendering parameters.
*>
const R3DDecal DECAL_BASE = {
    .albedo = {
        .texture = {},
        .color = {255, 255, 255, 255},
    },
    .emission = {
        .texture = {},
        .color = {255, 255, 255, 255},
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
    },
    .uv_offset = {0.0f, 0.0f},
    .uv_scale = {1.0f, 1.0f},
    .alpha_cutoff = 0.01f,
    .normal_threshold = 0,
    .fade_width = 0,
    .apply_color = true,
    .shader = null,
};

// ========================================
// PUBLIC API
// ========================================

<*
 Unload all map textures assigned to a R3DDecal.

 Frees all underlying textures in a R3DDecal that are not a default texture.

 @param decal : `decal to unload maps from`
*>
extern fn void unload_decal_maps(R3DDecal decal) @cname("R3D_UnloadDecalMaps");
