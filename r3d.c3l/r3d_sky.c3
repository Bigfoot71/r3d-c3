/* r3d_sky.c3 -- R3D Sky Module.
 *
 * Copyright (c) 2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
module r3d;

import raylib55;

// ========================================
// STRUCT TYPES
// ========================================

<*
 Parameters for procedural sky generation.

 Curves control gradient falloff (lower = sharper transition at horizon).
*>
struct R3DProceduralSky
{
    RLColor sky_top_color;          // Sky color at zenith
    RLColor sky_horizon_color;      // Sky color at horizon
    float sky_horizon_curve;         // Gradient curve exponent (0.01 - 1.0, typical: 0.15)
    float sky_energy;                // Sky brightness multiplier

    RLColor ground_bottom_color;    // Ground color at nadir
    RLColor ground_horizon_color;   // Ground color at horizon
    float ground_horizon_curve;      // Gradient curve exponent (typical: 0.02)
    float ground_energy;             // Ground brightness multiplier

    RLVector3 sun_direction;        // Direction from which light comes (can take not normalized)
    RLColor sun_color;               // Sun disk color
    float sun_size;                  // Sun angular size in radians (real sun: ~0.0087 rad = 0.5°)
    float sun_curve;                 // Sun edge softness exponent (typical: 0.15)
    float sun_energy;                // Sun brightness multiplier
}

// ========================================
// CONSTANTS
// ========================================

const R3DProceduralSky PROCEDURAL_SKY_BASE = {
    .sky_top_color = { 98, 116, 140, 255 },
    .sky_horizon_color = { 165, 167, 171, 255 },
    .sky_horizon_curve = 0.15f,
    .sky_energy = 1.0f,
    .ground_bottom_color = { 51, 43, 34, 255 },
    .ground_horizon_color = { 165, 167, 171, 255 },
    .ground_horizon_curve = 0.02f,
    .ground_energy = 1.0f,
    .sun_direction = { -1.0f, -1.0f, -1.0f },
    .sun_color = { 255, 255, 255, 255 },
    .sun_size = 1.0f * rl::DEG2RAD,
    .sun_curve = 0.15f,
    .sun_energy = 1.0f,
};

// ========================================
// PUBLIC API
// ========================================

<*
 Generates a procedural sky cubemap.

 Creates a GPU cubemap with procedural gradient sky and sun rendering.
 The cubemap is ready for use as environment map or IBL source.

 @param size : `cubemap face resolution`
 @param params : `procedural sky parameters`
 @return `generated cubemap`
*>
extern fn R3DCubemap gen_procedural_sky(int size, R3DProceduralSky params) @cname("R3D_GenProceduralSky");

<*
 Generates a custom sky cubemap.

 Creates a GPU cubemap rendered using the provided sky shader.
 The cubemap is ready for use as environment map or IBL source.

 @param size : `cubemap face resolution`
 @param shader : `sky shader used to render the cubemap`
 @return `generated cubemap`
*>
extern fn R3DCubemap gen_custom_sky(int size, R3DSkyShader* shader) @cname("R3D_GenCustomSky");

<*
 Updates an existing procedural sky cubemap.

 Re-renders the cubemap with new parameters. Faster than unload + generate
 when animating sky conditions (time of day, weather, etc.).

 @param cubemap : `cubemap to update`
 @param params : `procedural sky parameters`
*>
extern fn void update_procedural_sky(R3DCubemap* cubemap, R3DProceduralSky params) @cname("R3D_UpdateProceduralSky");

<*
 Updates an existing custom sky cubemap.

 Re-renders the cubemap using the provided sky shader. Faster than unload + generate
 when animating sky conditions or updating shader uniforms (time, clouds, stars, etc.).

 @param cubemap : `cubemap to update`
 @param shader : `sky shader used to render the cubemap`
*>
extern fn void update_custom_sky(R3DCubemap* cubemap, R3DSkyShader* shader) @cname("R3D_UpdateCustomSky");
