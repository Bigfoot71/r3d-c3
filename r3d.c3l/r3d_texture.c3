/* r3d_texture.c3 -- R3D Texture Module.
 *
 * Copyright (c) 2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
module r3d;

import raylib55;

// ========================================
// PUBLIC API
// ========================================

<*
 Loads a texture from the specified file path.

 If 'is_color' is true, the texture is loaded using the currently defined color space (sRGB by default).
 The wrap and filter modes are taken from the current global default state.

 @param file_name : `the path to the texture file`
 @param is_color : `whether the texture should be treated as color data`
 @return `the loaded texture`
*>
extern fn RLTexture2D load_texture(ZString file_name, bool is_color) @cname("R3D_LoadTexture");

<*
 Loads a texture from the specified file path.

 If 'is_color' is true, the texture is loaded using the currently defined color space (sRGB by default).

 @param file_name : `the path to the texture file`
 @param wrap : `the texture wrap mode`
 @param filter : `the texture filter mode`
 @param is_color : `whether the texture should be treated as color data`
 @return `the loaded texture`
*>
extern fn RLTexture2D load_texture_ex(ZString file_name, RLTextureWrap wrap, RLTextureFilter filter, bool is_color) @cname("R3D_LoadTextureEx");

<*
 Loads a texture from the specified image.

 If 'is_color' is true, the texture is loaded using the currently defined color space (sRGB by default).
 The wrap and filter modes are taken from the current global default state.

 @param image : `the source image`
 @param is_color : `whether the texture should be treated as color data`
 @return `the loaded texture`
*>
extern fn RLTexture2D load_texture_from_image(RLImage image, bool is_color) @cname("R3D_LoadTextureFromImage");

<*
 Loads a texture from the specified image.

 If 'is_color' is true, the texture is loaded using the currently defined color space (sRGB by default).

 @param image : `the source image`
 @param wrap : `the texture wrap mode`
 @param filter : `the texture filter mode`
 @param is_color : `whether the texture should be treated as color data`
 @return `the loaded texture`
*>
extern fn RLTexture2D load_texture_from_image_ex(RLImage image, RLTextureWrap wrap, RLTextureFilter filter, bool is_color) @cname("R3D_LoadTextureFromImageEx");

<*
 Loads a texture directly from memory.

 If 'is_color' is true, the texture is loaded using the currently defined color space (sRGB by default).
 The wrap and filter modes are taken from the current global default state.

 @param file_type : `the file type/extension used to interpret the data`
 @param file_data : `a pointer to the file data in memory`
 @param data_size : `the size of the file data in bytes`
 @param is_color : `whether the texture should be treated as color data`
 @return `the loaded texture`
*>
extern fn RLTexture2D load_texture_from_memory(ZString file_type, void* file_data, int data_size, bool is_color) @cname("R3D_LoadTextureFromMemory");

<*
 Loads a texture directly from memory.

 If 'is_color' is true, the texture is loaded using the currently defined color space (sRGB by default).

 @param file_type : `the file type/extension used to interpret the data`
 @param file_data : `a pointer to the file data in memory`
 @param data_size : `the size of the file data in bytes`
 @param wrap : `the texture wrap mode`
 @param filter : `the texture filter mode`
 @param is_color : `whether the texture should be treated as color data`
 @return `the loaded texture`
*>
extern fn RLTexture2D load_texture_from_memory_ex(ZString file_type, void* file_data, int data_size, RLTextureWrap wrap, RLTextureFilter filter, bool is_color) @cname("R3D_LoadTextureFromMemoryEx");

<*
 Unloads a texture.

 This function calls raylib's `unload_texture` internally, while ensuring that
 the provided texture is not an internal r3d texture.

 @param texture : `the texture to unload`
*>
extern fn void unload_texture(RLTexture2D texture) @cname("R3D_UnloadTexture");
