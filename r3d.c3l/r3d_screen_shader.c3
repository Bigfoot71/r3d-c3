/* r3d_screen_shader.c3 -- R3D Screen Shader Module.
 *
 * Copyright (c) 2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
module r3d;

import raylib55;

// ========================================
// OPAQUE TYPES
// ========================================

typedef R3DScreenShader = void;

// ========================================
// ENUM TYPES
// ========================================

<*
 Screen shader execution stage.

 Screen shaders are custom fullscreen post-processing passes inserted at
 specific points of the frame.

 The SCENE stage runs before built-in post-processing and receives
 scene-referred HDR linear color. It is an advanced stage: effects
 may affect bloom, auto exposure, and all later passes.

 The POST stage runs after built-in HDR post-processing, but before output
 conversion. It still receives scene-referred HDR linear color.

 The OUTPUT stage runs after tonemapping/output conversion, but before
 anti-aliasing. It receives display-referred LDR color and is suitable for
 most artistic image effects.

 The FINAL stage runs after anti-aliasing, before the final blit. It receives
 the final display-referred image and is suitable for overlays, grain,
 scanlines, sharpening, fades, and debug visualization.
*>
enum R3DScreenShaderStage : int
{
    SCENE,  // Before built-in post-processing; advanced HDR scene stage.
    POST,   // After built-in HDR post-processing, before output conversion.
    OUTPUT, // After output conversion, before anti-aliasing.
    FINAL,  // After anti-aliasing, before final blit.
    COUNT,  // Number of screen shader stages.
}

// ========================================
// PUBLIC API
// ========================================

<*
 Loads a screen shader from a file.

 The shader must define a single entry point:
 `void fragment()`. Any other entry point, such as `vertex()`,
 or any varyings will be ignored.

 @param file_path : `path to the shader source file`
 @return `pointer to the loaded screen shader, or NULL on failure`
*>
extern fn R3DScreenShader* load_screen_shader(ZString file_path) @cname("R3D_LoadScreenShader");

<*
 Loads a screen shader from a source code string in memory.

 The shader must define a single entry point:
 `void fragment()`. Any other entry point, such as `vertex()`,
 or any varyings will be ignored.

 @param code : `null-terminated shader source code`
 @return `pointer to the loaded screen shader, or NULL on failure`
*>
extern fn R3DScreenShader* load_screen_shader_from_memory(ZString code) @cname("R3D_LoadScreenShaderFromMemory");

<*
 Creates an alias of an existing screen shader.

 The alias shares the same compiled program as the original but holds its own
 independent uniform and sampler state. Typical use cases include pre-configuring
 aliases for distinct effects (e.g. different convolution kernels), or running
 the same shader multiple times in a post-process chain with different parameters
 at each pass.

 Uniform and sampler state is copied from the original at the moment this
 function is called, not from the shader source defaults. Any values set
 on the original after compilation but before this call will be reflected
 in the alias; values set afterward will not.

 The alias does not own the program. Always unload all aliases before
 unloading the original, or the alias program references become dangling.

 @param shader : `the original screen shader to alias`
 @return `pointer to the alias, or NULL on failure`
*>
extern fn R3DScreenShader* load_screen_shader_alias(R3DScreenShader* shader) @cname("R3D_LoadScreenShaderAlias");

<*
 Unloads and destroys a screen shader.

 If the shader owns its program shaders (i.e. it was created with load_screen_shader
 or load_screen_shader_from_memory), they are deleted. Aliases created from this
 shader via load_screen_shader_alias must be unloaded beforehand, as they
 share the same programs and will be left with dangling references.

 @param shader : `screen shader to unload`
*>
extern fn void unload_screen_shader(R3DScreenShader* shader) @cname("R3D_UnloadScreenShader");

<*
 Sets a uniform value for the current frame.

 Once a uniform is set, it remains valid for the all frames.
 If an uniform is set multiple times during the same frame,
 the last value defined before end() is used.

 Supported types:
 bool, int, float,
 ivec2, ivec3, ivec4,
 vec2, vec3, vec4,
 mat2, mat3, mat4

 Boolean values are read as 4 bytes.

 @param shader : `target screen shader. May be NULL. In that case, the call is ignored and a warning is logged`
 @param name : `name of the uniform; must not be NULL`
 @param value : `pointer to the uniform value; must not be NULL`
*>
extern fn void set_screen_shader_uniform(R3DScreenShader* shader, ZString name, void* value) @cname("R3D_SetScreenShaderUniform");

<*
 Sets a texture sampler for the current frame.

 Once a sampler is set, it remains valid for all frames.
 If a sampler is set multiple times during the same frame,
 the last value defined before end() is used.

 Supported samplers:
 sampler1D, sampler2D, sampler3D, samplerCube

 @param shader : `target screen shader. May be NULL. In that case, the call is ignored and a warning is logged`
 @param name : `name of the sampler uniform; must not be NULL`
 @param texture : `texture to bind to the sampler`
*>
extern fn void set_screen_shader_sampler(R3DScreenShader* shader, ZString name, RLTexture texture) @cname("R3D_SetScreenShaderSampler");

<*
 Sets the screen shader chain for a given stage.

 Screen shaders are executed in the order provided. The maximum number of
 shaders per stage is `MAX_SCREEN_SHADERS`; extra entries are ignored
 and a warning is emitted.

 Shader pointers are copied internally, so the original array may be modified
 or freed after the call. NULL entries are allowed and skipped safely.

 Calling this function replaces the previous chain for the selected stage.
 To clear a stage, pass `shaders = NULL` or `count = 0`.

 @param stage : `screen shader stage to configure`
 @param shaders : `array of pointers to R3DScreenShader objects`
 @param count : `number of shaders in the array`
*>
extern fn void set_screen_shader_chain(R3DScreenShaderStage stage, R3DScreenShader** shaders, int count) @cname("R3D_SetScreenShaderChain");
