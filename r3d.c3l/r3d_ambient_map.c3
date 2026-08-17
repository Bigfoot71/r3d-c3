/* r3d_ambient_map.c3 -- R3D Ambient Map Module.
 *
 * Copyright (c) 2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
module r3d;

import raylib55;

// ========================================
// FLAG TYPES
// ========================================

<*
 Bit-flags controlling what components are generated.
*>
bitstruct R3DAmbientFlags : uint
{
	bool illumination;  // Generate diffuse irradiance
	bool reflection;    // Generate specular prefiltered map
}

// ========================================
// STRUCT TYPES
// ========================================

<*
 Global environment lighting data.

 An ambient map is built from a cubemap (like a skybox)
 and preprocessed into two specialized textures:

  - irradiance:
      Low-frequency lighting used for diffuse IBL.
      Captures soft ambient light from all directions.

  - prefilter:
      Mipmapped environment used for specular reflections.
      Higher mip levels simulate rougher surfaces.

 Both textures are derived from the same source cubemap,
 but serve different shading purposes.
*>
struct R3DAmbientMap
{
    R3DAmbientFlags flags; // Components generated for this map
    uint irradiance;       // Diffuse IBL cubemap (may be 0 if not generated)
    uint prefilter;        // Specular prefiltered cubemap (may be 0 if not generated)
}

// ========================================
// PUBLIC API
// ========================================

<*
 Loads a ambient map from an image file.

 The layout parameter tells how faces are arranged inside the source image.

 @param file_name : `path to the source image file`
 @param layout : `how faces are arranged inside the source image`
 @param flags : `which components to generate`
 @return `a fully initialized ambient map`
*>
extern fn R3DAmbientMap load_ambient_map(ZString file_name, R3DCubemapLayout layout, R3DAmbientFlags flags) @cname("R3D_LoadAmbientMap");

<*
 Builds a ambient map from an existing RLImage.

 Same behavior as load_ambient_map(), but without loading from disk.

 @param image : `source image`
 @param layout : `how faces are arranged inside the source image`
 @param flags : `which components to generate`
 @return `a fully initialized ambient map`
*>
extern fn R3DAmbientMap load_ambient_map_from_image(RLImage image, R3DCubemapLayout layout, R3DAmbientFlags flags) @cname("R3D_LoadAmbientMapFromImage");

<*
 Generates an ambient map from a cubemap.

 The source cubemap should usually be an HDR sky/environment.

 Depending on the provided flags, this function:
  - convolves the cubemap into diffuse irradiance
  - builds a mipmapped prefiltered cubemap for reflections

 @param cubemap : `source cubemap (environment / sky)`
 @param flags : `which components to generate (irradiance, reflection, or both)`
 @return `a fully initialized ambient map`
*>
extern fn R3DAmbientMap gen_ambient_map(R3DCubemap cubemap, R3DAmbientFlags flags) @cname("R3D_GenAmbientMap");

<*
 Frees the textures used by an ambient map.

 After this call, the ambient map is no longer valid.

 @param ambient_map : `the ambient map to unload`
*>
extern fn void unload_ambient_map(R3DAmbientMap ambient_map) @cname("R3D_UnloadAmbientMap");

<*
 Rebuilds an existing ambient map from a new cubemap.

 Use this when the environment changes dynamically (time of day,
 weather, interior/exterior transitions, etc).

 Only the components enabled in `ambient_map.flags` are regenerated.

 @param ambient_map : `existing ambient map to update`
 @param cubemap : `new cubemap source`
*>
extern fn void update_ambient_map(R3DAmbientMap ambient_map, R3DCubemap cubemap) @cname("R3D_UpdateAmbientMap");
