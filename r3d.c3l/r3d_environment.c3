/* r3d_environment.c3 -- R3D Environment Module.
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
 Bloom effect modes.

 Different blending methods for the bloom glow effect.
*>
enum R3DBloom : int
{
    DISABLED,   // No bloom effect applied
    MIX,        // Linear interpolation blend between scene and bloom
    ADDITIVE,   // Additive blending, intensifying bright regions
    SCREEN,     // Screen blending for softer highlight enhancement
}

<*
 Fog effect modes.

 Distance-based fog density distribution methods.
*>
enum R3DFog : int
{
    DISABLED,   // No fog effect
    LINEAR,     // Linear density increase between start and end distances
    EXP2,       // Exponential squared density (exp2), more realistic
    EXP,        // Simple exponential density increase
}

<*
 Depth of field modes.
*>
enum R3DDoF : int
{
    DISABLED,   // No depth of field effect
    ENABLED,    // Depth of field enabled with focus point and blur
}

<*
 Tone mapping algorithms.

 HDR to LDR color compression methods.
*>
enum R3DTonemap : int
{
    LINEAR,     // Direct linear mapping (no compression)
    REINHARD,   // Reinhard operator, balanced HDR compression
    FILMIC,     // Film-like response curve
    ACES,       // Academy Color Encoding System (cinematic standard)
    AGX,        // Modern algorithm preserving highlights and shadows
    COUNT,      // Internal: number of tonemap modes
}

// ========================================
// STRUCT TYPES
// ========================================

<*
 Background and skybox configuration.

 NOTE: A transparent or semi-transparent background color is supported,
 but effects that blur/spread geometry (like bloom or DoF) will bleed
 or fade at silhouettes instead of blending with real content behind.
*>
struct R3DEnvBackground
{
    RLColor color;           // Background color when there is no skybox
    float energy;            // Energy multiplier applied to background (skybox or color)
    float sky_blur;          // Sky blur factor [0,1], based on mipmaps, very fast
    R3DCubemap sky;          // Skybox asset (used if ID is non-zero)
    RLQuaternion rotation;   // Skybox rotation (pitch, yaw, roll as quaternion)
}

<*
 Ambient lighting configuration.
*>
struct R3DEnvAmbient
{
    RLColor color;           // Ambient light color when there is no ambient map
    float energy;            // Energy multiplier for ambient light (map or color)
    R3DAmbientMap map;       // IBL environment map, can be generated from skybox
}

<*
 Screen Space Ambient Occlusion (SSAO) settings.

 Darkens areas where surfaces are close together, such as corners and crevices.
*>
struct R3DEnvSSAO
{
    int sample_count;     // Number of samples to compute SSAO (default: 16)
    float intensity;      // Base occlusion strength multiplier (default: 1.0)
    float power;          // Exponential falloff for sharper darkening (default: 1.0)
    float radius;         // Sampling radius in world space (default: 1.0)
    float bias;           // Depth bias to prevent self-occlusion artifacts, in world-space units (default: 0.03)
    bool enabled;         // Enable/disable SSAO effect (default: false)
}

<*
 Screen Space Indirect Lighting (SSIL) settings.

 Extends the SSAO algorithm with a global illumination component: occluding
 surfaces not only darken the fragment (ambient occlusion) but also transfer
 their color to it (indirect light bounce). A larger radius than SSAO is
 generally preferable to capture meaningful indirect lighting contributions.
*>
struct R3DEnvSSIL
{
    int sample_count;     // Number of samples to compute SSIL (default: 16)
    float gi_intensity;   // Indirect light strength multiplier (default: 1.0)
    float ao_intensity;   // Ambient occlusion strength multiplier (default: 1.0)
    float ao_power;       // Exponential falloff for sharper occlusion darkening (default: 1.0)
    float radius;         // Sampling radius in world space (default: 4.0)
    float bias;           // Depth bias to prevent self-occlusion artifacts, in world-space units (default: 0.03)
    bool enabled;         // Enable/disable SSIL effect (default: false)
}

<*
 Screen Space Global Illumination (SSGI) settings.

 Computes indirect lighting from the scene's visible surfaces in real time.
*>
struct R3DEnvSSGI
{
    int slice_count;          // Number of directions sampled per pixel. Higher = fewer noise streaks, higher cost. (default: 4)
    float edge_fade;          // Fades out GI near screen edges to hide emissive objects partially off-screen. (default: 0.1)
    float distance_falloff;   // How quickly indirect light fades with distance. Higher = shorter reach, darker result. (default: 1.0)
    float normal_rejection;   // Prevents surfaces from receiving light through their own backside. 0 = off, 1 = physically correct. May look inconsistent with non-directional emissives. (default: 0.0)
    float intensity;          // Brightness of the indirect lighting. Dimly lit scenes may require significantly higher values to show probable contribution. (default: 1.0)
    int denoise_steps;        // Number of denoiser passes. Higher = smoother result, slightly higher cost. (default: 4)
    bool enabled;             // Enable or disable SSGI entirely. (default: false)
}

<*
 Screen Space Reflections (SSR) settings.

 Real-time reflections calculated in screen space.
*>
struct R3DEnvSSR
{
    int max_iterations;   // Maximum ray marching iterations (default: 64)
    float thickness;      // Depth tolerance for valid hits (default: 0.5)
    float edge_fade;      // Screen edge fade start [0,1] (default: 0.25)
    bool enabled;         // Enable/disable SSR (default: false)
}

<*
 Atmospheric fog effect settings.
*>
struct R3DEnvFog
{
    R3DFog mode;          // Fog distribution mode (default: DISABLED)
    RLColor color;        // Fog tint color (default: white)
    float start;          // Linear mode: distance where fog begins (default: 1.0)
    float end;            // Linear mode: distance of full fog density (default: 50.0)
    float density;        // Exponential modes: fog thickness factor (default: 0.05)
    float sky_affect;     // Fog influence on skybox [0-1] (default: 0.5)
}

<*
 Volumetric fog effect settings.
*>
struct R3DVolumetricFog
{
    float scattering_density;   // Light scattering thickness; higher = more visible light rays (default: 0.01)
    float absortion_density;    // Light absorption thickness; higher = darker scene (default: 0.03)
    RLColor scattering_color;   // Tint color of scattered light rays (default: WHITE)
    float anisotropy;           // Scattering direction: 0 = uniform, >0 = forward (haze), <0 = backward (default: 0.5)
    RLColor emission_color;     // Color emitted by the fog regardless of lighting (default: WHITE)
    float emission_energy;      // Emission brightness; 0 disables emission (default: 0.0)
    float sky_affect;           // Fog influence on the skybox [0-1] (default: 0.5)
    float length;               // Maximum fog render distance in world units (default: 50.0)
    float step_size;            // Ray-march step size; smaller = higher quality, lower performance (default: 1.0)
    bool enabled;               // Enables or disables the volumetric fog (default: false)
}

<*
 Depth of Field (DoF) camera focus settings.

 Blurs objects outside the focal plane.
*>
struct R3DEnvDoF
{
    R3DDoF mode;           // Enable/disable state (default: DISABLED)
    float focus_point;     // Focus distance in meters from camera (default: 10.0)
    float focus_scale;     // Depth of field depth: lower = shallower (default: 1.0)
    float near_scale;      // Near blur intensity: 0.0 = disabled, 1.0 = symmetric to far (default: 1.0)
    float max_blur_size;   // Maximum blur radius, similar to aperture (default: 20.0)
}

<*
 Bloom post-processing settings.

 Glow effect around bright areas in the scene.
*>
struct R3DEnvBloom
{
    R3DBloom mode;          // Bloom blending mode (default: DISABLED)
    float levels;           // Mipmap spread factor [0-1]: higher = wider glow (default: 0.5)
    float intensity;        // Bloom strength multiplier (default: 0.05)
    float threshold;        // Minimum brightness to trigger bloom (default: 0.0)
    float soft_threshold;   // Softness of brightness cutoff transition (default: 0.5)
    float filter_radius;    // Blur filter radius during upscaling (default: 1.0)
}

<*
 Auto exposure post-processing settings.

 Automatically adjusts scene exposure from average luminance,
 simulating eye adaptation. Adaptation should physically be
 faster toward bright scenes than toward dark scenes,
 as dark adaptation is slower.

 Current implementation keeps a single temporal history. Enabling
 auto exposure for multiple scene passes in the same frame, or across
 different scenes, may produce incorrect adaptation. For now, use it only on
 one continuous begin/end scene render path.
*>
struct R3DEnvAutoExposure
{
    float min_ev;                   // Minimum measured luminance in EV stops, relative to middle gray (default: -1.0)
    float max_ev;                   // Maximum measured luminance in EV stops, relative to middle gray (default:  1.0)
    float exposure_compensation;    // Artistic exposure bias in EV stops: +1 = one stop brighter (default: 0.0)
    float adaptation_to_bright;     // Time constant in seconds when scene luminance increases; lower = faster (default: 0.5)
    float adaptation_to_dark;       // Time constant in seconds when scene luminance decreases; lower = faster (default: 1.0)
    bool enabled;                   // Enable auto exposure (default: false)
}

<*
 Tone mapping and exposure settings.

 Converts HDR colors to displayable LDR range.
*>
struct R3DEnvTonemap
{
    R3DTonemap mode;    // Tone mapping algorithm (default: LINEAR)
    float exposure;     // Scene brightness multiplier (default: 1.0)
    float white;        // Reference white point (not used for AGX) (default: 1.0)
}

<*
 Color grading adjustments.

 Final color correction applied after all other effects.
*>
struct R3DEnvColor
{
    float brightness;    // Overall brightness multiplier (default: 1.0)
    float contrast;      // Contrast between dark and bright areas (default: 1.0)
    float saturation;    // Color intensity (default: 1.0)
}

<*
 Complete environment configuration structure.

 Contains all rendering environment parameters: background, lighting, and post-processing effects.
 Initialize with ENVIRONMENT_BASE for default values.
*>
struct R3DEnvironment
{
    R3DEnvBackground   background;      // Background and skybox settings
    R3DEnvAmbient      ambient;         // Ambient lighting configuration
    R3DEnvSSAO         ssao;            // Screen space ambient occlusion
    R3DEnvSSIL         ssil;            // Screen space indirect lighting
    R3DEnvSSGI         ssgi;            // Screen space global illumination
    R3DEnvSSR          ssr;             // Screen space reflections
    R3DEnvFog          fog;             // Atmospheric fog
    R3DVolumetricFog   volumetric_fog;  // Volumetric fog
    R3DEnvDoF          dof;             // Depth of field focus effect
    R3DEnvBloom        bloom;           // Bloom glow effect
    R3DEnvAutoExposure auto_exposure;   // Auto exposure effect
    R3DEnvTonemap      tonemap;         // HDR tone mapping
    R3DEnvColor        color;           // Color grading adjustments
}

// ========================================
// CONSTANTS
// ========================================

<*
 Default environment configuration.

 Initializes an R3DEnvironment structure with sensible default values for all
 rendering parameters. Use this as a starting point for custom configurations.
*>
const R3DEnvironment ENVIRONMENT_BASE = {
    .background = {
        .color    = rl::GRAY,
        .energy   = 1.0f,
        .sky_blur = 0.0f,
        .sky      = {},
        .rotation = { 0.0f, 0.0f, 0.0f, 1.0f },
    },
    .ambient = {
        .color  = rl::BLACK,
        .energy = 1.0f,
        .map    = {},
    },
    .ssao = {
        .sample_count = 16,
        .intensity    = 1.0f,
        .power        = 1.0f,
        .radius       = 1.0f,
        .bias         = 0.03f,
        .enabled      = false,
    },
    .ssil = {
        .sample_count = 16,
        .gi_intensity = 1.0f,
        .ao_intensity = 1.0f,
        .ao_power     = 1.0f,
        .radius       = 4.0f,
        .bias         = 0.03f,
        .enabled      = false,
    },
    .ssgi = {
        .slice_count      = 4,
        .edge_fade        = 0.1f,
        .distance_falloff = 1.0f,
        .normal_rejection = 0.0f,
        .intensity        = 1.0f,
        .denoise_steps    = 4,
        .enabled          = false,
    },
    .ssr = {
        .max_iterations = 64,
        .thickness      = 0.5f,
        .edge_fade      = 0.25f,
        .enabled        = false,
    },
    .fog = {
        .mode       = DISABLED,
        .color      = rl::WHITE,
        .start      = 1.0f,
        .end        = 50.0f,
        .density    = 0.05f,
        .sky_affect = 0.5f,
    },
    .volumetric_fog = {
        .scattering_density = 0.01f,
        .absortion_density  = 0.03f,
        .scattering_color   = rl::WHITE,
        .anisotropy         = 0.5f,
        .emission_color     = rl::WHITE,
        .emission_energy    = 0.0f,
        .sky_affect         = 0.5f,
        .length             = 50.0f,
        .step_size          = 1.0f,
        .enabled            = false,
    },
    .dof = {
        .mode          = DISABLED,
        .focus_point   = 10.0f,
        .focus_scale   = 1.0f,
        .near_scale    = 1.0f,
        .max_blur_size = 20.0f,
    },
    .bloom = {
        .mode           = DISABLED,
        .levels         = 0.5f,
        .intensity      = 0.05f,
        .threshold      = 0.0f,
        .soft_threshold = 0.5f,
        .filter_radius  = 1.0f,
    },
    .auto_exposure = {
        .min_ev                 = -1.0f,
        .max_ev                 =  1.0f,
        .exposure_compensation  = 0.0f,
        .adaptation_to_bright   = 0.5f,
        .adaptation_to_dark     = 1.0f,
    },
    .tonemap = {
        .mode     = LINEAR,
        .exposure = 1.0f,
        .white    = 1.0f,
    },
    .color = {
        .brightness = 1.0f,
        .contrast   = 1.0f,
        .saturation = 1.0f,
    },
};

// ========================================
// PUBLIC API
// ========================================

<*
 Retrieves a pointer to the current environment configuration.

 Provides direct read/write access to environment settings.
 Modifications take effect immediately.

 @return `pointer to the active R3DEnvironment structure`
*>
extern fn R3DEnvironment* get_environment() @cname("R3D_GetEnvironment");

<*
 Replaces the entire environment configuration.

 Copies all settings from the provided structure to the active environment.
 Useful for switching between presets or restoring saved states.

 @param env : `pointer to the R3DEnvironment structure to copy from`
*>
extern fn void set_environment(R3DEnvironment* env) @cname("R3D_SetEnvironment");
