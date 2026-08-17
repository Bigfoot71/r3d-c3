/* r3d_lighting.c3 -- R3D Lighting Module.
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
 Types of lights supported by the rendering engine.

 Each light type has different behaviors and use cases.
*>
enum R3DLightType : int
{
    DIR,    // Directional light, affects the entire scene with parallel rays.
    SPOT,   // Spot light, emits light in a cone shape.
    OMNI,   // Omni light, emits light in all directions from a single point.
}

// ========================================
// STRUCTS TYPES
// ========================================

<*
 Describes a light source.
*>
struct R3DLight
{
    RLVector3 position;     // Light position (spot/omni)
    RLVector3 direction;    // Light direction (spot/dir)
    RLColor color;          // Light color
    float energy;           // Light intensity/brightness multiplier
    float specular;         // Specular reflection intensity multiplier
    float range;            // Maximum distance (spot/omni)
    float falloff;          // Distance falloff factor (spot/omni)
    float inner_cut_off;    // Spot light inner cutoff angle (degrees)
    float outer_cut_off;    // Spot light outer cutoff angle (degrees)
    float fog_energy;       // Volumetric fog energy multiplier
    R3DLightType type;      // Light type (directional/spot/omni)
}

<*
 Represents an allocated shadow map for a light.
*>
struct R3DShadowMap
{
    uint handle;            // Internal shadow map handle (don't touch)
    float softness;         // Softness factor for penumbra
    float opacity;          // Shadow opacity factor
    float depth_bias;       // Constant depth bias
    float slope_bias;       // Slope-scaled depth bias
    R3DLayer cull_mask;     // Layers considered when culling shadow casters for this map
    R3DLightType type;      // Light type this shadow map was allocated for
}

// ========================================
// PUBLIC API
// ========================================

// ----------------------------------------
// LIGHTING: Lights Functions
// ----------------------------------------

<*
 Creates a directional light.

 @param dir : `light direction`
 @param color : `light color`
 @param energy : `light intensity/brightness multiplier`
 @return `newly created directional light`
*>
extern fn R3DLight create_dir_light(RLVector3 dir, RLColor color, float energy) @cname("R3D_CreateDirLight");

<*
 Creates a spot light, with default inner/outer cutoff angles of 22.5/45 degrees.

 @param pos : `light position`
 @param dir : `light direction`
 @param range : `maximum distance`
 @param color : `light color`
 @param energy : `light intensity/brightness multiplier`
 @return `newly created spot light`
*>
extern fn R3DLight create_spot_light(RLVector3 pos, RLVector3 dir, float range, RLColor color, float energy) @cname("R3D_CreateSpotLight");

<*
 Creates an omnidirectional (point) light.

 @param pos : `light position`
 @param range : `maximum distance`
 @param color : `light color`
 @param energy : `light intensity/brightness multiplier`
 @return `newly created omni light`
*>
extern fn R3DLight create_omni_light(RLVector3 pos, float range, RLColor color, float energy) @cname("R3D_CreateOmniLight");

// ----------------------------------------
// LIGHTING: Shadow Functions
// ----------------------------------------

<*
 Allocates a shadow map layer for a given light type.

 The shadow map resolution is fixed per light type and configured via
 SHADOW_DIR_SIZE, SHADOW_SPOT_SIZE and SHADOW_OMNI_SIZE hints
 before R3D is initialized.

 @param type : `the light type this shadow map will be used with (must match the type of the light it is later passed to via push_light())`
 @return `newly allocated shadow map`
*>
extern fn R3DShadowMap load_shadow_map(R3DLightType type) @cname("R3D_LoadShadowMap");

<*
 Releases a shadow map, freeing its layer for reuse.

 @param shadow_map : `shadow map to unload`
*>
extern fn void unload_shadow_map(R3DShadowMap shadow_map) @cname("R3D_UnloadShadowMap");

<*
 Returns whether the shadow map has a valid allocated layer.

 @param shadow_map : `shadow map to check`
 @return `true if the shadow map has a valid allocated layer`
*>
extern fn bool is_shadow_map_valid(R3DShadowMap shadow_map) @cname("R3D_IsShadowMapValid");

// ----------------------------------------
// LIGHTING: Light Helper Functions
// ----------------------------------------

<*
 Draws the area of influence of the light in 3D space.

 This function visualizes the area affected by a light in 3D space.
 It draws the light's influence, such as the cone for spotlights or the volume for omni-lights.
 This function is only relevant for spotlights and omni-lights.

 This function should be called while using the default 3D rendering mode of raylib,
 not with r3d's rendering mode. It uses raylib's 3D drawing functions to render the light's shape.

 @param light : `the light to visualize (see R3DLight)`
*>
extern fn void draw_light_debug(R3DLight light) @cname("R3D_DrawLightDebug");
