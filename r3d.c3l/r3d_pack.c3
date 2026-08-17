/* r3d_pack.c3 -- R3D Pack Module.
 *
 * Copyright (c) 2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
module r3d;

// ========================================
// PUBLIC API
// ========================================

<*
 Packs a 32-bit float into a 16-bit floating-point value.

 @param x : `value to pack`
 @return `IEEE 754 half-precision representation`
*>
extern fn ushort pack_float16(float x) @cname("R3D_PackFloat16");

<*
 Packs a float into a 16-bit unsigned normalized value.

 The input value is clamped to the [0, 1] range before packing.

 @param x : `value to pack`
 @return `16-bit UNORM representation`
*>
extern fn ushort pack_unorm16(float x) @cname("R3D_PackUnorm16");

<*
 Packs a float into a 16-bit signed normalized value.

 The input value is clamped to the [-1, 1] range before packing.

 @param x : `value to pack`
 @return `16-bit SNORM representation`
*>
extern fn short pack_snorm16(float x) @cname("R3D_PackSnorm16");

<*
 Packs a float into an 8-bit unsigned normalized value.

 The input value is clamped to the [0, 1] range before packing.

 @param x : `value to pack`
 @return `8-bit UNORM representation`
*>
extern fn char pack_unorm8(float x) @cname("R3D_PackUnorm8");

<*
 Packs a float into an 8-bit signed normalized value.

 The input value is clamped to the [-1, 1] range before packing.

 @param x : `value to pack`
 @return `8-bit SNORM representation`
*>
extern fn ichar pack_snorm8(float x) @cname("R3D_PackSnorm8");

<*
 Unpacks a 16-bit floating-point value into a 32-bit float.

 @param x : `IEEE 754 half-precision representation`
 @return `unpacked float value`
*>
extern fn float unpack_float16(ushort x) @cname("R3D_UnpackFloat16");

<*
 Unpacks a 16-bit unsigned normalized value.

 The returned value is in the [0, 1] range.

 @param x : `16-bit UNORM representation`
 @return `unpacked float value`
*>
extern fn float unpack_unorm16(ushort x) @cname("R3D_UnpackUnorm16");

<*
 Unpacks a 16-bit signed normalized value.

 The returned value is clamped to the [-1, 1] range.

 @param x : `16-bit SNORM representation`
 @return `unpacked float value`
*>
extern fn float unpack_snorm16(short x) @cname("R3D_UnpackSnorm16");

<*
 Unpacks an 8-bit unsigned normalized value.

 The returned value is in the [0, 1] range.

 @param x : `8-bit UNORM representation`
 @return `unpacked float value`
*>
extern fn float unpack_unorm8(char x) @cname("R3D_UnpackUnorm8");

<*
 Unpacks an 8-bit signed normalized value.

 The returned value is clamped to the [-1, 1] range.

 @param x : `8-bit SNORM representation`
 @return `unpacked float value`
*>
extern fn float unpack_snorm8(ichar x) @cname("R3D_UnpackSnorm8");
