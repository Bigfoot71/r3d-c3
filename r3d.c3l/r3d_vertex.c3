/* r3d_vertex.c3 -- R3D Vertex Module.
 *
 * Copyright (c) 2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
module r3d;

import raylib55;

// ========================================
// STRUCTS TYPES
// ========================================

<*
 Compact vertex format used by R3D meshes.

 Texture coordinates are stored as float16 values.
 Normals and tangents are stored as signed normalized 8-bit values.
 Bone weights are stored as unsigned 8-bit values and should sum to 255.
*>
struct R3DVertex
{
    RLVector3 position;       // Vertex position in object space.
    ushort[2] texcoord;       // Texture coordinates stored as float16.
    ichar[4] normal;          // Normal vector stored as SNORM8. XYZ are used, W is unused.
    ichar[4] tangent;         // Tangent vector stored as SNORM8. XYZ are tangent, W stores handedness.
    RLColor color;            // Vertex color in RGBA8.
    char[4] bone_indices;     // Indices of up to 4 bones influencing this vertex.
    char[4] bone_weights;     // Bone weights in UNORM8. Values should sum to 255.
}

// ========================================
// PUBLIC API
// ========================================

<*
 Constructs a packed R3D vertex from unpacked attribute data.

 Texture coordinates are packed to float16.
 Normals and tangents are packed to SNORM8.

 @param position : `vertex position in object space`
 @param texcoord : `texture coordinates in float32; any range is supported`
 @param normal : `normal vector; components are clamped to the [-1, 1] range`
 @param tangent : `tangent vector; XYZ components are clamped to [-1, 1], W stores handedness`
 @param color : `vertex color in RGBA8`
 @return `packed vertex ready for GPU upload`
*>
extern fn R3DVertex make_vertex(RLVector3 position, RLVector2 texcoord, RLVector3 normal, RLVector4 tangent, RLColor color) @cname("R3D_MakeVertex");

<*
 Packs texture coordinates from float32 to float16.

 @param dst : `output buffer of 2 ushort values; must not be NULL`
 @param src : `texture coordinates in float32; any range is supported`
*>
extern fn void pack_tex_coord(ushort* dst, RLVector2 src) @cname("R3D_PackTexCoord");

<*
 Unpacks texture coordinates from float16 to float32.

 @param src : `input buffer of 2 ushort values; must not be NULL`
 @return `unpacked texture coordinates in float32`
*>
extern fn RLVector2 unpack_tex_coord(ushort* src) @cname("R3D_UnpackTexCoord");

<*
 Packs a normal vector from float32 to SNORM8.

 XYZ components are clamped to the [-1, 1] range before packing.
 The fourth component is set to 0.

 @param dst : `output buffer of 4 ichar values; must not be NULL`
 @param src : `normal vector to pack`
*>
extern fn void pack_normal(ichar* dst, RLVector3 src) @cname("R3D_PackNormal");

<*
 Unpacks a normal vector from SNORM8 to float32.

 Only XYZ components are read.

 @param src : `input buffer of 4 ichar values; must not be NULL`
 @return `unpacked normal vector; not guaranteed to be unit length`
*>
extern fn RLVector3 unpack_normal(ichar* src) @cname("R3D_UnpackNormal");

<*
 Packs a tangent vector from float32 to SNORM8.

 XYZ components are clamped to the [-1, 1] range before packing.
 W stores tangent handedness and is packed as either +1 or -1.

 @param dst : `output buffer of 4 ichar values; must not be NULL`
 @param src : `tangent vector to pack; W is interpreted as handedness`
*>
extern fn void pack_tangent(ichar* dst, RLVector4 src) @cname("R3D_PackTangent");

<*
 Unpacks a tangent vector from SNORM8 to float32.

 XYZ components are unpacked from SNORM8.
 W is returned as exactly +1.0f or -1.0f.

 @param src : `input buffer of 4 ichar values; must not be NULL`
 @return `unpacked tangent vector`
*>
extern fn RLVector4 unpack_tangent(ichar* src) @cname("R3D_UnpackTangent");
