/* r3d_core.c3 -- R3D Core Module.
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
 Configuration hints used to customize R3D before initialization.

 Hints must be set via set_hint() before calling init().
 Any hint not explicitly set falls back to its default value.

 Some hints may be clamped internally, accordingly to hardware limits.
*>
enum R3DHint : int
{
    MESH_VERTEX_BUFFER_CAPACITY,    // Initial vertex capacity of the global VBO. Default: 65'536
    MESH_INDEX_BUFFER_CAPACITY,     // Initial index capacity of the global EBO. Default: 131'072
    MESH_STREAMING_CAPACITY,        // Initial capacity for tracking freed mesh slots, relevant only for meshes loaded/unloaded at runtime. Default: 128
    DRAW_CALL_CAPACITY,             // Initial capacity of the CPU-side draw call list. Default: 1024
    FORWARD_LIGHT_PER_MESH,         // Max lights per mesh in forward pass. Default: 16
    PROBE_ILLUMINATION_MAX_ACTIVE,  // Max illumination probes rendered simultaneously. Default: 32
    PROBE_REFLECTION_MAX_ACTIVE,    // Max reflection probes rendered simultaneously. Default: 8
    SHADOW_DIR_SIZE,                // Directional light shadow map size (px). Default: 4096
    SHADOW_SPOT_SIZE,               // Spot light shadow map size (px). Default: 2048
    SHADOW_OMNI_SIZE,               // Omni light shadow map size (px). Default: 2048
    IBL_IRRADIANCE_SIZE,            // Irradiance cubemap face size, shared by ambient IBL and probes (px). Default: 32
    IBL_PREFILTER_SIZE,             // Prefiltered cubemap face size, shared by ambient IBL and probes (px). Default: 128
    COUNT,                          // Sentinel, not a valid hint
}

<*
 Anti-aliasing modes used during rendering.

 Anti-aliasing reduces visible jagged edges (aliasing artifacts)
 in the final rendered image.
*>
enum R3DAntiAliasingMode : int
{
    NONE,   // No anti-aliasing. Best performance, visible jagged edges.
    FXAA,   // Fast Approximate AA. Smooths edges efficiently but may appear blurry.
    SMAA,   // Subpixel Morphological AA. Sharper than FXAA, moderate performance cost.
}

<*
 Quality presets for anti-aliasing.

 Presets adjust internal algorithm parameters (e.g. edge detection,
 search steps, thresholds). Higher presets increase quality and GPU cost.
*>
enum R3DAntiAliasingPreset : int
{
    LOW,      // Performance-oriented preset with reduced quality.
    MEDIUM,   // Balanced quality/performance preset.
    HIGH,     // High quality preset with increased GPU cost.
    ULTRA,    // Maximum quality preset, highest performance cost.
    COUNT,    // Number of presets (not a valid preset value).
}

<*
 Aspect ratio handling modes for rendering.
*>
enum R3DAspectMode : int
{
    EXPAND, // Expands the rendered output to fully fill the target (render texture or window).
    KEEP,   // Preserves the target's aspect ratio without distortion, adding empty gaps if necessary.
}

<*
 Upscaling/filtering methods for rendering output.

 Upscale mode to apply when the output window is larger than the internal render resolution.
*>
enum R3DUpscaleMode : int
{
    NEAREST,    // Nearest-neighbor upscaling: very fast, but produces blocky pixels.
    LINEAR,     // Bilinear upscaling: very fast, smoother than nearest, but can appear blurry.
    BICUBIC,    // Bicubic upscaling: slower, smoother, and less blurry than linear.
    LANCZOS,    // Lanczos-2 upscaling: preserves more fine details, but is the most expensive.
}

<*
 Downscaling/filtering methods for rendering output.

 Downscale mode to apply when the output window is smaller than the internal render resolution.
*>
enum R3DDownscaleMode : int
{
    NEAREST,    // Nearest-neighbor downscaling: very fast, but produces aliasing.
    LINEAR,     // Bilinear filtering. Fast, may show moire on high-frequency content.
    RGSS,       // 4-sample supersampling. Reduces aliasing and moire, low cost. Recommended default.
    PDSS,       // 16-sample supersampling. Better color accuracy than RGSS, higher cost.
}

<*
 Defines the buffer to output (render texture or window).

 Nothing will be output if the requested target has not been created / used.
*>
enum R3DOutputMode : int
{
    SCENE,
    ALBEDO,
    NORMAL,
    ORM,
    DIFFUSE,
    SPECULAR,
    SSAO,
    SSIL,
    SSGI,
    SSR,
    BLOOM,
    DOF,
}

// ========================================
// PUBLIC API
// ========================================

<*
 Sets a configuration hint.

 Must be called before init().

 @param hint : `the hint to configure`
 @param value : `the value to assign to the hint`
*>
extern fn void set_hint(R3DHint hint, int value) @cname("R3D_SetHint");

<*
 Returns the effective value of a hint.

 @param hint : `the hint to query`
 @return `the effective value of the hint`
*>
extern fn int get_hint(R3DHint hint) @cname("R3D_GetHint");

<*
 Initializes the rendering engine.

 This function sets up the internal rendering system with the provided resolution.

 @param res_width : `width of the internal resolution`
 @param res_height : `height of the internal resolution`
 @return `true if the initialization is successful`
*>
extern fn bool init(int res_width, int res_height) @cname("R3D_Init");

<*
 Closes the rendering engine and deallocates all resources.

 This function shuts down the rendering system and frees all allocated memory,
 including the resources associated with the created lights.
*>
extern fn void close() @cname("R3D_Close");

<*
 Gets the current internal resolution.

 This function retrieves the current internal resolution being used by the
 rendering engine.

 @param width : `pointer to store the width of the internal resolution`
 @param height : `pointer to store the height of the internal resolution`
*>
extern fn void get_resolution(int* width, int* height) @cname("R3D_GetResolution");

<*
 Sets the internal rendering resolution.

 Reallocates all internal render targets to the new resolution.
 This operation may cause a stall, this is acceptable when called
 infrequently (like window resize events), but should never be called per-frame.

 @param width : `new internal width in pixels`
 @param height : `new internal height in pixels`
*>
extern fn void set_resolution(int width, int height) @cname("R3D_SetResolution");

<*
 Retrieves the current anti-aliasing mode used for rendering.

 @return `the currently active R3DAntiAliasingMode`
*>
extern fn R3DAntiAliasingMode get_anti_aliasing_mode() @cname("R3D_GetAntiAliasingMode");

<*
 Sets the anti-aliasing mode for rendering.

 The new mode takes effect on subsequent frames.

 If the mode is invalid, no AA will be applied.

 @param mode : `the desired R3DAntiAliasingMode`
*>
extern fn void set_anti_aliasing_mode(R3DAntiAliasingMode mode) @cname("R3D_SetAntiAliasingMode");

<*
 Retrieves the current anti-aliasing quality preset.

 @return `the currently active R3DAntiAliasingPreset`
*>
extern fn R3DAntiAliasingPreset get_anti_aliasing_preset() @cname("R3D_GetAntiAliasingPreset");

<*
 Sets the anti-aliasing quality preset.

 Changing the preset triggers an internal shader recompilation.
 Compiled variants are cached and reused if the preset is set again.

 The preset will be a clamp between low and ultra.

 @param preset : `the desired R3DAntiAliasingPreset`
*>
extern fn void set_anti_aliasing_preset(R3DAntiAliasingPreset preset) @cname("R3D_SetAntiAliasingPreset");

<*
 Retrieves the current aspect ratio handling mode.

 @return `the currently active R3DAspectMode`
*>
extern fn R3DAspectMode get_aspect_mode() @cname("R3D_GetAspectMode");

<*
 Sets the aspect ratio handling mode for rendering.

 @param mode : `the desired R3DAspectMode`
*>
extern fn void set_aspect_mode(R3DAspectMode mode) @cname("R3D_SetAspectMode");

<*
 Retrieves the current upscaling/filtering method.

 @return `the currently active R3DUpscaleMode`
*>
extern fn R3DUpscaleMode get_upscale_mode() @cname("R3D_GetUpscaleMode");

<*
 Sets the upscaling/filtering method for rendering output.

 @param mode : `the desired R3DUpscaleMode`
*>
extern fn void set_upscale_mode(R3DUpscaleMode mode) @cname("R3D_SetUpscaleMode");

<*
 Retrieves the current downscaling mode used for rendering.

 @return `the currently active R3DDownscaleMode`
*>
extern fn R3DDownscaleMode get_downscale_mode() @cname("R3D_GetDownscaleMode");

<*
 Sets the downscaling mode for rendering output.

 @param mode : `the desired R3DDownscaleMode`
*>
extern fn void set_downscale_mode(R3DDownscaleMode mode) @cname("R3D_SetDownscaleMode");

<*
 Gets the current output mode.

 @return `the currently active R3DOutputMode`
*>
extern fn R3DOutputMode get_output_mode() @cname("R3D_GetOutputMode");

<*
 Sets the output mode for rendering.

 Nothing will be output if the requested target has not been created / used.

 @param mode : `the R3DOutputMode to use`
*>
extern fn void set_output_mode(R3DOutputMode mode) @cname("R3D_SetOutputMode");

<*
 Sets the default texture filtering mode.

 This function defines the default texture filter that will be applied to all subsequently
 loaded textures, including those used in materials, sprites, and other resources.

 If a trilinear or anisotropic filter is selected, mipmaps will be automatically generated
 for the textures, but they will not be generated when using nearest or bilinear filtering.

 The default texture filter mode is `RLTextureFilter.TRILINEAR`.

 @param filter : `the texture filtering mode to be applied by default`
*>
extern fn void set_texture_filter(RLTextureFilter filter) @cname("R3D_SetTextureFilter");

<*
 Sets the default texture wrap mode.

 This function only affects textures that are loaded manually for material maps.
 Textures loaded automatically during model import will use the wrap mode
 defined in the model file itself.

 The default texture wrap mode is `RLTextureWrap.CLAMP`.

 @param wrap : `the texture wrap mode to apply by default`
*>
extern fn void set_texture_wrap(RLTextureWrap wrap) @cname("R3D_SetTextureWrap");
