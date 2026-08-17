/* r3d_utils.c3 -- R3D Utility Module.
 *
 * Copyright (c) 2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
module r3d;

import raylib55;

// ----------------------------------------
// UTILS: Default Texture Retrieval Functions
// ----------------------------------------

<*
 Retrieves a default white texture.

 This texture is fully white (1,1,1,1), useful for default material properties.

 @return `a white texture`
*>
extern fn RLTexture2D get_white_texture() @cname("R3D_GetWhiteTexture");

<*
 Retrieves a default black texture.

 This texture is fully black (0,0,0,1), useful for masking or default values.

 @return `a black texture`
*>
extern fn RLTexture2D get_black_texture() @cname("R3D_GetBlackTexture");

<*
 Retrieves a default normal map texture.

 This texture represents a neutral normal map (0.5, 0.5, 1.0), which applies no normal variation.

 @return `a neutral normal texture`
*>
extern fn RLTexture2D get_normal_texture() @cname("R3D_GetNormalTexture");

// ----------------------------------------
// UTILS: Render Texture Retrieval Functions
// ----------------------------------------

<*
 Retrieves the buffer containing the scene's normal data.

 This texture stores octahedral-compressed normals using two 16-bit per-channel RG components.

 You can find the decoding functions in 'shaders/include/math.glsl'.

 @return `the normal buffer texture`
*>
extern fn RLTexture2D get_buffer_normal() @cname("R3D_GetBufferNormal");

<*
 Retrieves the final depth buffer.

 This texture is an R16 texture containing a linear depth value
 normalized between the near and far clipping planes.

 The texture is intended for post-processing effects outside of R3D
 that require access to linear depth information.

 @return `the final depth buffer texture (R16, linear depth)`
*>
extern fn RLTexture2D get_buffer_depth() @cname("R3D_GetBufferDepth");

// ----------------------------------------
// UTILS: Camera Matrices Retrieval Functions
// ----------------------------------------

<*
 Retrieves the view matrix.

 This matrix represents the camera's transformation from world space to view space.
 It is updated at the last call to begin().

 @return `the current view matrix`
*>
extern fn RLMatrix get_matrix_view() @cname("R3D_GetMatrixView");

<*
 Retrieves the inverse view matrix.

 This matrix transforms coordinates from view space back to world space.
 It is updated at the last call to begin().

 @return `the current inverse view matrix`
*>
extern fn RLMatrix get_matrix_inv_view() @cname("R3D_GetMatrixInvView");

<*
 Retrieves the projection matrix.

 This matrix defines the transformation from view space to clip space.
 It is updated at the last call to begin().

 @return `the current projection matrix`
*>
extern fn RLMatrix get_matrix_projection() @cname("R3D_GetMatrixProjection");

<*
 Retrieves the inverse projection matrix.

 This matrix transforms coordinates from clip space back to view space.
 It is updated at the last call to begin().

 @return `the current inverse projection matrix`
*>
extern fn RLMatrix get_matrix_inv_projection() @cname("R3D_GetMatrixInvProjection");

<*
 Retrieves the view-projection matrix.

 This matrix represents the transformation from world space to clip space.
 It is updated at the last call to begin().

 @return `the current view-projection matrix`
*>
extern fn RLMatrix get_matrix_view_projection() @cname("R3D_GetMatrixViewProjection");
