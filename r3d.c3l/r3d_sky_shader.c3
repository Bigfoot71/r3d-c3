/* r3d_sky_shader.c3 -- R3D Sky Shader Module.
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

typedef R3DSkyShader = void;

// ========================================
// PUBLIC API
// ========================================

<*
 Loads a sky shader from a file.

 The shader must define a single entry point:
 `void fragment()`. Any other entry point, such as `vertex()`,
 or any varyings will be ignored.

 @param file_path : `path to the shader source file`
 @return `pointer to the loaded sky shader, or NULL on failure`
*>
extern fn R3DSkyShader* load_sky_shader(ZString file_path) @cname("R3D_LoadSkyShader");

<*
 Loads a sky shader from a source code string in memory.

 The shader must define a single entry point:
 `void fragment()`. Any other entry point, such as `vertex()`,
 or any varyings will be ignored.

 @param code : `null-terminated shader source code`
 @return `pointer to the loaded sky shader, or NULL on failure`
*>
extern fn R3DSkyShader* load_sky_shader_from_memory(ZString code) @cname("R3D_LoadSkyShaderFromMemory");

<*
 Creates an alias of an existing sky shader.

 The alias shares the same compiled program as the original but holds its own
 independent uniform and sampler state. A typical use case is to pre-configure
 several aliases with different uniforms or textures, avoiding the need to
 reconfigure the shader on every skybox switch.

 Uniform and sampler state is copied from the original at the moment this
 function is called, not from the shader source defaults. Any values set
 on the original after compilation but before this call will be reflected
 in the alias; values set afterward will not.

 The alias does not own the program. Always unload all aliases before
 unloading the original, or the alias program references become dangling.

 @param shader : `the original sky shader to alias`
 @return `pointer to the alias, or NULL on failure`
*>
extern fn R3DSkyShader* load_sky_shader_alias(R3DSkyShader* shader) @cname("R3D_LoadSkyShaderAlias");

<*
 Unloads and destroys a sky shader.

 If the shader owns its program shaders (i.e. it was created with load_sky_shader
 or load_sky_shader_from_memory), they are deleted. Aliases created from this
 shader via load_sky_shader_alias must be unloaded beforehand, as they
 share the same programs and will be left with dangling references.

 @param shader : `sky shader to unload`
*>
extern fn void unload_sky_shader(R3DSkyShader* shader) @cname("R3D_UnloadSkyShader");

<*
 Sets a uniform value for all subsequent sky generations.

 Supported types:
 bool, int, float,
 ivec2, ivec3, ivec4,
 vec2, vec3, vec4,
 mat2, mat3, mat4

 Boolean values are read as 4 bytes.

 @param shader : `target sky shader. May be NULL. In that case, the call is ignored and a warning is logged`
 @param name : `name of the uniform; must not be NULL`
 @param value : `pointer to the uniform value; must not be NULL`
*>
extern fn void set_sky_shader_uniform(R3DSkyShader* shader, ZString name, void* value) @cname("R3D_SetSkyShaderUniform");

<*
 Sets a uniform value for all subsequent sky generations.

 Supported samplers:
 sampler1D, sampler2D, sampler3D, samplerCube

 @param shader : `target sky shader. May be NULL. In that case, the call is ignored and a warning is logged`
 @param name : `name of the sampler uniform; must not be NULL`
 @param texture : `texture to bind to the sampler`
*>
extern fn void set_sky_shader_sampler(R3DSkyShader* shader, ZString name, RLTexture texture) @cname("R3D_SetSkyShaderSampler");
