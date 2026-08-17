/* r3d_surface_shader.c3 -- R3D Surface Shader Module.
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

typedef R3DSurfaceShader = void;

// ========================================
// PUBLIC API
// ========================================

<*
 Loads a surface shader from a file.

 The shader must define at least one entry point: `void vertex()` or `void fragment()`.
 It can define either one or both.

 @param file_path : `path to the shader source file`
 @return `pointer to the loaded surface shader, or NULL on failure`
*>
extern fn R3DSurfaceShader* load_surface_shader(ZString file_path) @cname("R3D_LoadSurfaceShader");

<*
 Loads a surface shader from a source code string in memory.

 The shader must define at least one entry point: `void vertex()` or `void fragment()`.
 It can define either one or both.

 @param code : `null-terminated shader source code`
 @return `pointer to the loaded surface shader, or NULL on failure`
*>
extern fn R3DSurfaceShader* load_surface_shader_from_memory(ZString code) @cname("R3D_LoadSurfaceShaderFromMemory");

<*
 Creates an alias of an existing surface shader.

 The alias shares the same compiled program as the original but holds its own
 independent uniform and sampler state, allowing the same shader to be used
 multiple times within a single frame with different values.

 Uniform and sampler state is copied from the original at the moment this
 function is called, not from the shader source defaults. Any values set
 on the original after compilation but before this call will be reflected
 in the alias; values set afterward will not.

 The alias does not own the program. Always unload all aliases before
 unloading the original, or the alias program references become dangling.

 @param shader : `the original surface shader to alias`
 @return `pointer to the alias, or NULL on failure`
*>
extern fn R3DSurfaceShader* load_surface_shader_alias(R3DSurfaceShader* shader) @cname("R3D_LoadSurfaceShaderAlias");

<*
 Unloads and destroys a surface shader.

 If the shader owns its program shaders (i.e. it was created with load_surface_shader
 or load_surface_shader_from_memory), they are deleted. Aliases created from this
 shader via load_surface_shader_alias must be unloaded beforehand, as they
 share the same programs and will be left with dangling references.

 @param shader : `surface shader to unload`
*>
extern fn void unload_surface_shader(R3DSurfaceShader* shader) @cname("R3D_UnloadSurfaceShader");

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

 @param shader : `target surface shader. May be NULL. In that case, the call is ignored and a warning is logged`
 @param name : `name of the uniform; must not be NULL`
 @param value : `pointer to the uniform value; must not be NULL`
*>
extern fn void set_surface_shader_uniform(R3DSurfaceShader* shader, ZString name, void* value) @cname("R3D_SetSurfaceShaderUniform");

<*
 Sets a texture sampler for the current frame.

 Once a sampler is set, it remains valid for all frames.
 If a sampler is set multiple times during the same frame,
 the last value defined before end() is used.

 Supported samplers:
 sampler1D, sampler2D, sampler3D, samplerCube

 @param shader : `target surface shader. May be NULL. In that case, the call is ignored and a warning is logged`
 @param name : `name of the sampler uniform; must not be NULL`
 @param texture : `texture to bind to the sampler`
*>
extern fn void set_surface_shader_sampler(R3DSurfaceShader* shader, ZString name, RLTexture texture) @cname("R3D_SetSurfaceShaderSampler");
