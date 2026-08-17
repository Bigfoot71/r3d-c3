/* r3d_cubemap.c3 -- R3D Cubemap Module.
 *
 * Copyright (c) 2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
module r3d;

import raylib55;

// ========================================
// ENUM TYPES
// ========================================

<*
 Supported cubemap source layouts.

 Used when converting an image into a cubemap. AUTO_DETECT tries to guess
 the layout based on image dimensions.
*>
enum R3DCubemapLayout : int
{
    AUTO_DETECT,            // Automatically detect layout type
    LINE_VERTICAL,          // Layout is defined by a vertical line with faces
    LINE_HORIZONTAL,        // Layout is defined by a horizontal line with faces
    CROSS_THREE_BY_FOUR,    // Layout is defined by a 3x4 cross with cubemap faces
    CROSS_FOUR_BY_THREE,    // Layout is defined by a 4x3 cross with cubemap faces
    PANORAMA,               // Layout is defined by an equirectangular panorama
}

// ========================================
// STRUCT TYPES
// ========================================

<*
 GPU cubemap texture.

 Holds the OpenGL texture handle and its base resolution (per face).
*>
struct R3DCubemap
{
    uint texture;
    uint fbo;
    int size;
}

// ========================================
// PUBLIC API
// ========================================

<*
 Loads a cubemap from an image file.

 The layout parameter tells how faces are arranged inside the source image.

 @param file_name : `path to the source image file`
 @param layout : `how faces are arranged inside the source image`
 @return `a fully initialized cubemap`
*>
extern fn R3DCubemap load_cubemap(ZString file_name, R3DCubemapLayout layout) @cname("R3D_LoadCubemap");

<*
 Builds a cubemap from an existing Image.

 Same behavior as load_cubemap(), but without loading from disk.

 @param image : `source image`
 @param layout : `how faces are arranged inside the source image`
 @return `a fully initialized cubemap`
*>
extern fn R3DCubemap load_cubemap_from_image(RLImage image, R3DCubemapLayout layout) @cname("R3D_LoadCubemapFromImage");

<*
 Releases GPU resources associated with a cubemap.

 @param cubemap : `the cubemap to unload`
*>
extern fn void unload_cubemap(R3DCubemap cubemap) @cname("R3D_UnloadCubemap");
