/* r3d_frustum.c3 -- R3D Frustum Module.
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
 Frustum plane indices.
*>
enum R3DFrustumPlane : int
{
    BACK,
    FRONT,
    BOTTOM,
    TOP,
    RIGHT,
    LEFT,
    COUNT,
}

// ========================================
// STRUCT TYPES
// ========================================

<*
 View frustum defined by its clipping planes.

 Planes are stored as RLVector4 (xyz = normal, w = distance).
*>
struct R3DFrustum
{
    RLVector4[6] planes;
}

// ========================================
// PUBLIC API
// ========================================

<*
 Get the current frustum.

 Returns the frustum computed during the last call to begin().

 @return `the current frustum`
*>
extern fn R3DFrustum get_frustum() @cname("R3D_GetFrustum");

<*
 Compute a frustum from a view-projection matrix.

 @param view_proj : `view-projection matrix`
 @return `computed frustum`
*>
extern fn R3DFrustum compute_frustum(RLMatrix view_proj) @cname("R3D_ComputeFrustum");

<*
 Compute the axis-aligned bounding box of a frustum.

 @param inv_view_proj : `inverse view-projection matrix`
 @return `axis-aligned bounding box of the frustum`
*>
extern fn RLBoundingBox compute_frustum_bounding_box(RLMatrix inv_view_proj) @cname("R3D_ComputeFrustumBoundingBox");

<*
 Compute the eight corner points of a frustum.

 @param inv_view_proj : `inverse view-projection matrix`
 @param corners : `output array of 8 points`
*>
extern fn void compute_frustum_corners(RLMatrix inv_view_proj, RLVector3[8]* corners) @cname("R3D_ComputeFrustumCorners");

<*
 Check if a point is inside the frustum.

 @param frustum : `frustum to test against; must not be NULL`
 @param position : `point to test`
 @return `true if the point is inside the frustum`
*>
extern fn bool frustum_contains_point(R3DFrustum* frustum, RLVector3 position) @cname("R3D_FrustumContainsPoint");

<*
 Check if any point from a set is inside the frustum.

 @param frustum : `frustum to test against; must not be NULL`
 @param positions : `array of points to test`
 @param count : `number of points in the array`
 @return `true if at least one point is inside the frustum`
*>
extern fn bool frustum_contains_any_point(R3DFrustum* frustum, RLVector3* positions, int count) @cname("R3D_FrustumContainsAnyPoint");

<*
 Check if a sphere intersects the frustum.

 @param frustum : `frustum to test against; must not be NULL`
 @param position : `sphere center`
 @param radius : `sphere radius`
 @return `true if the sphere intersects the frustum`
*>
extern fn bool frustum_intersects_sphere(R3DFrustum* frustum, RLVector3 position, float radius) @cname("R3D_FrustumIntersectsSphere");

<*
 Check if a bounding box intersects the frustum.

 @param frustum : `frustum to test against; must not be NULL`
 @param aabb : `axis-aligned bounding box to test`
 @return `true if the bounding box intersects the frustum`
*>
extern fn bool frustum_intersects_bounding_box(R3DFrustum* frustum, RLBoundingBox aabb) @cname("R3D_FrustumIntersectsBoundingBox");

<*
 Check if an oriented box intersects the frustum.

 @param frustum : `frustum to test against; must not be NULL`
 @param obb : `oriented box to test`
 @return `true if the oriented box intersects the frustum`
*>
extern fn bool frustum_intersects_oriented_box(R3DFrustum* frustum, R3DOrientedBox obb) @cname("R3D_FrustumIntersectsOrientedBox");
