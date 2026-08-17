/* r3d_shape.c3 -- R3D Shape Module.
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
 Alias for raylib's RLBoundingBox (min/max corner points).
*>
typedef R3DBoundingBox = RLBoundingBox;

<*
 Oriented bounding box (OBB).

 Defined by a center point, three orthogonal axes, and half-extents along each axis.
*>
struct R3DOrientedBox
{
    RLVector3 center;
    RLVector3 axis_x;
    RLVector3 axis_y;
    RLVector3 axis_z;
    RLVector3 half_extents;
}

<*
 Capsule shape defined by two endpoints and radius
*>
struct R3DCapsule
{
    RLVector3 start;    // Start point of capsule axis
    RLVector3 end;      // End point of capsule axis
    float radius;       // Capsule radius
}

<*
 Penetration information from an overlap test
*>
struct R3DPenetration
{
    bool collides;     // Whether shapes are overlapping
    float depth;       // Penetration depth
    RLVector3 normal;  // Collision normal (direction to resolve penetration)
    RLVector3 mtv;     // Minimum Translation Vector (normal * depth)
}

// ========================================
// PUBLIC API
// ========================================

<*
 Compute an axis-aligned bounding box from a center and half-extents.

 @param center : `center point`
 @param half_extents : `half-extents along each axis`
 @return `computed bounding box`
*>
extern fn R3DBoundingBox get_bounding_box(RLVector3 center, RLVector3 half_extents) @cname("R3D_GetBoundingBox");

<*
 Compute an oriented bounding box from an AABB and transform.

 @param aabb : `axis-aligned bounding box`
 @param transform : `transform to apply`
 @return `computed oriented bounding box`
*>
extern fn R3DOrientedBox get_oriented_box(R3DBoundingBox aabb, RLMatrix transform) @cname("R3D_GetOrientedBox");

<*
 Check if two axis-aligned bounding boxes intersect

 @param box1 : `first bounding box`
 @param box2 : `second bounding box`
 @return `true if collision detected`
*>
extern fn bool check_collision_bounding_boxes(R3DBoundingBox box1, R3DBoundingBox box2) @cname("R3D_CheckCollisionBoundingBoxes");

<*
 Check if an axis-aligned bounding box intersects a sphere

 @param box : `bounding box`
 @param center : `sphere center`
 @param radius : `sphere radius`
 @return `true if collision detected`
*>
extern fn bool check_collision_bounding_box_sphere(R3DBoundingBox box, RLVector3 center, float radius) @cname("R3D_CheckCollisionBoundingBoxSphere");

<*
 Check if two oriented bounding boxes intersect

 @param box1 : `first oriented box`
 @param box2 : `second oriented box`
 @return `true if collision detected`
*>
extern fn bool check_collision_oriented_boxes(R3DOrientedBox box1, R3DOrientedBox box2) @cname("R3D_CheckCollisionOrientedBoxes");

<*
 Check if an oriented bounding box intersects a sphere

 @param box : `oriented bounding box`
 @param center : `sphere center`
 @param radius : `sphere radius`
 @return `true if collision detected`
*>
extern fn bool check_collision_oriented_box_sphere(R3DOrientedBox box, RLVector3 center, float radius) @cname("R3D_CheckCollisionOrientedBoxSphere");

<*
 Check if two spheres intersect

 @param center1 : `first sphere center`
 @param radius1 : `first sphere radius`
 @param center2 : `second sphere center`
 @param radius2 : `second sphere radius`
 @return `true if collision detected`
*>
extern fn bool check_collision_spheres(RLVector3 center1, float radius1, RLVector3 center2, float radius2) @cname("R3D_CheckCollisionSpheres");

<*
 Check if capsule intersects with bounding box

 @param capsule : `capsule shape`
 @param box : `bounding box`
 @return `true if collision detected`
*>
extern fn bool check_collision_capsule_bounding_box(R3DCapsule capsule, R3DBoundingBox box) @cname("R3D_CheckCollisionCapsuleBoundingBox");

<*
 Check if capsule intersects with oriented box

 @param capsule : `capsule shape`
 @param box : `oriented box`
 @return `true if collision detected`
*>
extern fn bool check_collision_capsule_oriented_box(R3DCapsule capsule, R3DOrientedBox box) @cname("R3D_CheckCollisionCapsuleOrientedBox");

<*
 Check if capsule intersects with sphere

 @param capsule : `capsule shape`
 @param center : `sphere center`
 @param radius : `sphere radius`
 @return `true if collision detected`
*>
extern fn bool check_collision_capsule_sphere(R3DCapsule capsule, RLVector3 center, float radius) @cname("R3D_CheckCollisionCapsuleSphere");

<*
 Check if two capsules intersect

 @param a : `first capsule`
 @param b : `second capsule`
 @return `true if collision detected`
*>
extern fn bool check_collision_capsules(R3DCapsule a, R3DCapsule b) @cname("R3D_CheckCollisionCapsules");

<*
 Check if capsule intersects with mesh

 @param capsule : `capsule shape`
 @param mesh : `mesh data`
 @param transform : `mesh transform`
 @return `true if collision detected`
*>
extern fn bool check_collision_capsule_mesh(R3DCapsule capsule, R3DMeshData mesh, RLMatrix transform) @cname("R3D_CheckCollisionCapsuleMesh");

<*
 Check penetration between two axis-aligned bounding boxes

 @param box1 : `first bounding box`
 @param box2 : `second bounding box`
 @return `penetration information`
*>
extern fn R3DPenetration check_penetration_bounding_boxes(R3DBoundingBox box1, R3DBoundingBox box2) @cname("R3D_CheckPenetrationBoundingBoxes");

<*
 Check penetration between an axis-aligned bounding box and a sphere

 @param box : `bounding box`
 @param center : `sphere center`
 @param radius : `sphere radius`
 @return `penetration information`
*>
extern fn R3DPenetration check_penetration_bounding_box_sphere(R3DBoundingBox box, RLVector3 center, float radius) @cname("R3D_CheckPenetrationBoundingBoxSphere");

<*
 Check penetration between two oriented bounding boxes

 @param box1 : `first oriented box`
 @param box2 : `second oriented box`
 @return `penetration information`
*>
extern fn R3DPenetration check_penetration_oriented_boxes(R3DOrientedBox box1, R3DOrientedBox box2) @cname("R3D_CheckPenetrationOrientedBoxes");

<*
 Check penetration between an oriented bounding box and a sphere

 @param box : `oriented bounding box`
 @param center : `sphere center`
 @param radius : `sphere radius`
 @return `penetration information`
*>
extern fn R3DPenetration check_penetration_oriented_box_sphere(R3DOrientedBox box, RLVector3 center, float radius) @cname("R3D_CheckPenetrationOrientedBoxSphere");

<*
 Check penetration between two spheres

 @param center1 : `first sphere center`
 @param radius1 : `first sphere radius`
 @param center2 : `second sphere center`
 @param radius2 : `second sphere radius`
 @return `penetration information`
*>
extern fn R3DPenetration check_penetration_spheres(RLVector3 center1, float radius1, RLVector3 center2, float radius2) @cname("R3D_CheckPenetrationSpheres");

<*
 Check penetration between a capsule and a bounding box

 @param capsule : `capsule shape`
 @param box : `bounding box`
 @return `penetration information`
*>
extern fn R3DPenetration check_penetration_capsule_bounding_box(R3DCapsule capsule, R3DBoundingBox box) @cname("R3D_CheckPenetrationCapsuleBoundingBox");

<*
 Check penetration between a capsule and an oriented bounding box

 @param capsule : `capsule shape`
 @param box : `oriented bounding box`
 @return `penetration information`
*>
extern fn R3DPenetration check_penetration_capsule_oriented_box(R3DCapsule capsule, R3DOrientedBox box) @cname("R3D_CheckPenetrationCapsuleOrientedBox");

<*
 Check penetration between capsule and sphere

 @param capsule : `capsule shape`
 @param center : `sphere center`
 @param radius : `sphere radius`
 @return `penetration information`
*>
extern fn R3DPenetration check_penetration_capsule_sphere(R3DCapsule capsule, RLVector3 center, float radius) @cname("R3D_CheckPenetrationCapsuleSphere");

<*
 Check penetration between two capsules

 @param a : `first capsule`
 @param b : `second capsule`
 @return `penetration information`
*>
extern fn R3DPenetration check_penetration_capsules(R3DCapsule a, R3DCapsule b) @cname("R3D_CheckPenetrationCapsules");

<*
 Cast a ray against a triangle

 @param ray : `ray to cast`
 @param p1 : `first triangle vertex`
 @param p2 : `second triangle vertex`
 @param p3 : `third triangle vertex`
 @return `ray collision info (hit, distance, point, normal)`
*>
extern fn RLRayCollision raycast_triangle(RLRay ray, RLVector3 p1, RLVector3 p2, RLVector3 p3) @cname("R3D_RaycastTriangle");

<*
 Cast a ray against a quad

 The quad must be strictly planar and non-self-intersecting

 @param ray : `ray to cast`
 @param p1 : `first quad vertex`
 @param p2 : `second quad vertex`
 @param p3 : `third quad vertex`
 @param p4 : `fourth quad vertex`
 @return `ray collision info (hit, distance, point, normal)`
*>
extern fn RLRayCollision raycast_quad(RLRay ray, RLVector3 p1, RLVector3 p2, RLVector3 p3, RLVector3 p4) @cname("R3D_RaycastQuad");

<*
 Cast a ray against an axis-aligned bounding box

 @param ray : `ray to cast`
 @param box : `bounding box to test against`
 @return `ray collision info (hit, distance, point, normal)`
*>
extern fn RLRayCollision raycast_bounding_box(RLRay ray, R3DBoundingBox box) @cname("R3D_RaycastBoundingBox");

<*
 Cast a ray against an oriented bounding box

 @param ray : `ray to cast`
 @param box : `oriented bounding box to test against`
 @return `ray collision info (hit, distance, point, normal)`
*>
extern fn RLRayCollision raycast_oriented_box(RLRay ray, R3DOrientedBox box) @cname("R3D_RaycastOrientedBox");

<*
 Cast a ray against a sphere

 @param ray : `ray to cast`
 @param center : `sphere center`
 @param radius : `sphere radius`
 @return `ray collision info (hit, distance, point, normal)`
*>
extern fn RLRayCollision raycast_sphere(RLRay ray, RLVector3 center, float radius) @cname("R3D_RaycastSphere");

<*
 Cast a ray against a capsule

 @param ray : `ray to cast`
 @param capsule : `capsule shape to test against`
 @return `ray collision info (hit, distance, point, normal)`
*>
extern fn RLRayCollision raycast_capsule(RLRay ray, R3DCapsule capsule) @cname("R3D_RaycastCapsule");

<*
 Cast a ray against mesh geometry

 @param ray : `ray to cast`
 @param mesh : `mesh data to test against`
 @param transform : `mesh world transform`
 @return `ray collision info (hit, distance, point, normal)`
*>
extern fn RLRayCollision raycast_mesh(RLRay ray, R3DMeshData mesh, RLMatrix transform) @cname("R3D_RaycastMesh");

<*
 Cast a ray against a model (tests all meshes)

 @param ray : `ray to cast`
 @param model : `model to test against (must have valid mesh_data)`
 @param transform : `model world transform`
 @return `ray collision info for closest hit (hit=false if no mesh_data)`
*>
extern fn RLRayCollision raycast_model(RLRay ray, R3DModel model, RLMatrix transform) @cname("R3D_RaycastModel");

<*
 Find closest point on line segment to given point

 @param point : `query point`
 @param start : `segment start`
 @param end : `segment end`
 @return `closest point on segment [start, end]`
*>
extern fn RLVector3 closest_point_on_segment(RLVector3 point, RLVector3 start, RLVector3 end) @cname("R3D_ClosestPointOnSegment");

<*
 Find closest point on triangle to given point

 @param p : `query point`
 @param a : `triangle vertex A`
 @param b : `triangle vertex B`
 @param c : `triangle vertex C`
 @return `closest point on triangle surface`
*>
extern fn RLVector3 closest_point_on_triangle(RLVector3 p, RLVector3 a, RLVector3 b, RLVector3 c) @cname("R3D_ClosestPointOnTriangle");

<*
 Find closest point on box surface to given point

 @param point : `query point`
 @param box : `bounding box`
 @return `closest point on/in box (clamped to box bounds)`
*>
extern fn RLVector3 closest_point_on_box(RLVector3 point, R3DBoundingBox box) @cname("R3D_ClosestPointOnBox");
