/* r3d_probe.c3 -- R3D Probe Module.
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
 Type of data captured by a probe.
*>
enum R3DProbeType : int
{
    ILLUMINATION,     // Captures indirect diffuse lighting.
    REFLECTION,       // Captures environment reflections.
}

// ========================================
// STRUCT TYPES
// ========================================

<*
 Describes a probe used for indirect lighting or reflections.
*>
struct R3DProbe
{
    R3DProbeType type;     // Type of data captured by the probe
    uint handle;           // Internal probe handle (don't touch)
    RLVector3 position;    // World-space probe position
    float falloff;         // Distance falloff factor
    float range;           // Maximum influence distance
    bool interior;         // Whether the probe is captured as an interior
    bool shadows;          // Whether shadows are included in the capture
}

// ========================================
// PUBLIC API
// ========================================

<*
 Allocates a probe of the given type.

 @param type : `whether this probe contributes indirect lighting or reflections`
 @param interior : `whether the skybox is taken into account when capturing this probe`
 @param shadow : `whether shadow casters are taken into account when capturing this probe`
 @return `newly allocated probe`
*>
extern fn R3DProbe load_probe(R3DProbeType type, bool interior, bool shadow) @cname("R3D_LoadProbe");

<*
 Releases a probe, freeing its layer for reuse.

 @param probe : `probe to unload`
*>
extern fn void unload_probe(R3DProbe probe) @cname("R3D_UnloadProbe");

<*
 Returns whether the probe has a valid allocated layer.

 @param probe : `probe to check`
 @return `true if the probe has a valid allocated layer`
*>
extern fn bool is_probe_valid(R3DProbe probe) @cname("R3D_IsProbeValid");
