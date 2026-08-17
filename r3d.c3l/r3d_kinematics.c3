/* r3d_kinematics.c3 -- R3D Kinematics Module.
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
 Collision information from a sweep test
*>
struct R3DSweepCollision
{
    RLVector3 point;   // World space collision point
    RLVector3 normal;  // Surface normal at collision point
    float time;        // Time of impact [0-1], fraction along velocity vector
    bool hit;          // Whether a collision occurred
}

// ========================================
// PUBLIC API
// ========================================

<*
 Remove the normal component from a velocity vector (project onto a plane)

 @param velocity : `incoming velocity`
 @param normal : `surface normal (must be normalized)`
 @return `velocity with the component along normal removed`
*>
extern fn RLVector3 clip_velocity(RLVector3 velocity, RLVector3 normal) @cname("R3D_ClipVelocity");

<*
 Reflect a velocity vector off a surface

 @param velocity : `incoming velocity`
 @param normal : `surface normal (must be normalized)`
 @param bounciness : `coefficient of restitution (0=no bounce, 1=perfect bounce)`
 @return `reflected velocity scaled by bounciness`
*>
extern fn RLVector3 reflect_velocity(RLVector3 velocity, RLVector3 normal, float bounciness) @cname("R3D_ReflectVelocity");

<*
 Resolve a velocity vector against a sweep collision, sliding along the hit surface

 @param velocity : `desired movement vector`
 @param collision : `sweep collision result to resolve against`
 @param out_normal : `optional: receives the collision normal if a hit occurred`
 @return `resolved velocity (safe movement + clipped remainder)`
*>
extern fn RLVector3 slide_velocity(RLVector3 velocity, R3DSweepCollision collision, RLVector3* out_normal) @cname("R3D_SlideVelocity");

<*
 Slide sphere along bounding box surface, resolving collisions

 @param center : `sphere center position`
 @param radius : `sphere radius`
 @param velocity : `desired movement vector`
 @param box : `obstacle bounding box`
 @param out_normal : `optional: receives collision normal if collision occurred`
 @return `actual movement applied (may be reduced/redirected by collision)`
*>
extern fn RLVector3 slide_sphere_bounding_box(RLVector3 center, float radius, RLVector3 velocity, R3DBoundingBox box, RLVector3* out_normal) @cname("R3D_SlideSphereBoundingBox");

<*
 Slide sphere along mesh surface, resolving collisions

 @param center : `sphere center position`
 @param radius : `sphere radius`
 @param velocity : `desired movement vector`
 @param mesh : `mesh data to collide against`
 @param transform : `mesh world transform`
 @param out_normal : `optional: receives collision normal if collision occurred`
 @return `actual movement applied (may be reduced/redirected by collision)`
*>
extern fn RLVector3 slide_sphere_mesh(RLVector3 center, float radius, RLVector3 velocity, R3DMeshData mesh, RLMatrix transform, RLVector3* out_normal) @cname("R3D_SlideSphereMesh");

<*
 Slide capsule along bounding box surface, resolving collisions

 @param capsule : `capsule shape`
 @param velocity : `desired movement vector`
 @param box : `obstacle bounding box`
 @param out_normal : `optional: receives collision normal if collision occurred`
 @return `actual movement applied (may be reduced/redirected by collision)`
*>
extern fn RLVector3 slide_capsule_bounding_box(R3DCapsule capsule, RLVector3 velocity, R3DBoundingBox box, RLVector3* out_normal) @cname("R3D_SlideCapsuleBoundingBox");

<*
 Slide capsule along mesh surface, resolving collisions

 @param capsule : `capsule shape`
 @param velocity : `desired movement vector`
 @param mesh : `mesh data to collide against`
 @param transform : `mesh world transform`
 @param out_normal : `optional: receives collision normal if collision occurred`
 @return `actual movement applied (may be reduced/redirected by collision)`
*>
extern fn RLVector3 slide_capsule_mesh(R3DCapsule capsule, RLVector3 velocity, R3DMeshData mesh, RLMatrix transform, RLVector3* out_normal) @cname("R3D_SlideCapsuleMesh");

<*
 Push sphere out of bounding box if penetrating

 @param center : `sphere center (modified in place if penetrating)`
 @param radius : `sphere radius`
 @param box : `obstacle box`
 @param out_penetration : `optional: receives penetration depth`
 @return `true if depenetration occurred`
*>
extern fn bool depenetrate_sphere_bounding_box(RLVector3* center, float radius, R3DBoundingBox box, float* out_penetration) @cname("R3D_DepenetrateSphereBoundingBox");

<*
 Push capsule out of bounding box if penetrating

 @param capsule : `capsule shape (modified in place if penetrating)`
 @param box : `obstacle box`
 @param out_penetration : `optional: receives penetration depth`
 @return `true if depenetration occurred`
*>
extern fn bool depenetrate_capsule_bounding_box(R3DCapsule* capsule, R3DBoundingBox box, float* out_penetration) @cname("R3D_DepenetrateCapsuleBoundingBox");

<*
 Check if a sphere is supported by a bounding box in a given direction

 @param center : `sphere center`
 @param radius : `sphere radius`
 @param direction : `ray direction to probe (must be normalized)`
 @param distance : `maximum probe distance beyond the sphere surface`
 @param box : `bounding box to test against`
 @param out_hit : `optional: receives raycast hit info`
 @return `true if a surface is within reach in the given direction`
*>
extern fn bool check_sphere_support_bounding_box(RLVector3 center, float radius, RLVector3 direction, float distance, R3DBoundingBox box, RLRayCollision* out_hit) @cname("R3D_CheckSphereSupportBoundingBox");

<*
 Check if a sphere is supported by mesh geometry in a given direction

 @param center : `sphere center`
 @param radius : `sphere radius`
 @param direction : `ray direction to probe (must be normalized)`
 @param distance : `maximum probe distance beyond the sphere surface`
 @param mesh : `mesh data to test against`
 @param transform : `mesh world transform`
 @param out_hit : `optional: receives raycast hit info`
 @return `true if a surface is within reach in the given direction`
*>
extern fn bool check_sphere_support_mesh(RLVector3 center, float radius, RLVector3 direction, float distance, R3DMeshData mesh, RLMatrix transform, RLRayCollision* out_hit) @cname("R3D_CheckSphereSupportMesh");

<*
 Check if a capsule is supported by a bounding box in a given direction

 @param capsule : `capsule shape`
 @param direction : `ray direction to probe (must be normalized)`
 @param distance : `maximum probe distance beyond the capsule surface`
 @param box : `bounding box to test against`
 @param out_hit : `optional: receives raycast hit info`
 @return `true if a surface is within reach in the given direction`
*>
extern fn bool check_capsule_support_bounding_box(R3DCapsule capsule, RLVector3 direction, float distance, R3DBoundingBox box, RLRayCollision* out_hit) @cname("R3D_CheckCapsuleSupportBoundingBox");

<*
 Check if a capsule is supported by mesh geometry in a given direction

 @param capsule : `capsule shape`
 @param direction : `ray direction to probe (must be normalized)`
 @param distance : `maximum probe distance beyond the capsule surface`
 @param mesh : `mesh data to test against`
 @param transform : `mesh world transform`
 @param out_hit : `optional: receives raycast hit info`
 @return `true if a surface is within reach in the given direction`
*>
extern fn bool check_capsule_support_mesh(R3DCapsule capsule, RLVector3 direction, float distance, R3DMeshData mesh, RLMatrix transform, RLRayCollision* out_hit) @cname("R3D_CheckCapsuleSupportMesh");

<*
 Sweep sphere against single point

 @param center : `sphere center position`
 @param radius : `sphere radius`
 @param velocity : `movement vector (direction and magnitude)`
 @param point : `point to test against`
 @return `sweep collision info (hit, time, point, normal)`
*>
extern fn R3DSweepCollision sweep_sphere_point(RLVector3 center, float radius, RLVector3 velocity, RLVector3 point) @cname("R3D_SweepSpherePoint");

<*
 Sweep sphere against line segment

 @param center : `sphere center position`
 @param radius : `sphere radius`
 @param velocity : `movement vector (direction and magnitude)`
 @param a : `segment start point`
 @param b : `segment end point`
 @return `sweep collision info (hit, time, point, normal)`
*>
extern fn R3DSweepCollision sweep_sphere_segment(RLVector3 center, float radius, RLVector3 velocity, RLVector3 a, RLVector3 b) @cname("R3D_SweepSphereSegment");

<*
 Sweep sphere against triangle plane (no edge/vertex clipping)

 @param center : `sphere center position`
 @param radius : `sphere radius`
 @param velocity : `movement vector (direction and magnitude)`
 @param a : `triangle vertex A`
 @param b : `triangle vertex B`
 @param c : `triangle vertex C`
 @return `sweep collision info (hit, time, point, normal)`
*>
extern fn R3DSweepCollision sweep_sphere_triangle_plane(RLVector3 center, float radius, RLVector3 velocity, RLVector3 a, RLVector3 b, RLVector3 c) @cname("R3D_SweepSphereTrianglePlane");

<*
 Sweep sphere against triangle with edge/vertex handling

 @param center : `sphere center position`
 @param radius : `sphere radius`
 @param velocity : `movement vector (direction and magnitude)`
 @param a : `triangle vertex A`
 @param b : `triangle vertex B`
 @param c : `triangle vertex C`
 @return `sweep collision info (hit, time, point, normal)`
*>
extern fn R3DSweepCollision sweep_sphere_triangle(RLVector3 center, float radius, RLVector3 velocity, RLVector3 a, RLVector3 b, RLVector3 c) @cname("R3D_SweepSphereTriangle");

<*
 Sweep sphere along velocity vector

 @param center : `sphere center position`
 @param radius : `sphere radius`
 @param velocity : `movement vector (direction and magnitude)`
 @param box : `obstacle bounding box`
 @return `sweep collision info (hit, distance, point, normal)`
*>
extern fn R3DSweepCollision sweep_sphere_bounding_box(RLVector3 center, float radius, RLVector3 velocity, R3DBoundingBox box) @cname("R3D_SweepSphereBoundingBox");

<*
 Sweep sphere along velocity vector against mesh geometry

 @param center : `sphere center position`
 @param radius : `sphere radius`
 @param velocity : `movement vector (direction and magnitude)`
 @param mesh : `mesh data to test against`
 @param transform : `mesh world transform`
 @return `sweep collision info (hit, time, point, normal)`
*>
extern fn R3DSweepCollision sweep_sphere_mesh(RLVector3 center, float radius, RLVector3 velocity, R3DMeshData mesh, RLMatrix transform) @cname("R3D_SweepSphereMesh");

<*
 Sweep capsule along velocity vector

 @param capsule : `capsule shape to sweep`
 @param velocity : `movement vector (direction and magnitude)`
 @param box : `obstacle bounding box`
 @return `sweep collision info (hit, distance, point, normal)`
*>
extern fn R3DSweepCollision sweep_capsule_bounding_box(R3DCapsule capsule, RLVector3 velocity, R3DBoundingBox box) @cname("R3D_SweepCapsuleBoundingBox");

<*
 Sweep capsule along velocity vector against mesh geometry

 @param capsule : `capsule shape to sweep`
 @param velocity : `movement vector (direction and magnitude)`
 @param mesh : `mesh data to test against`
 @param transform : `mesh world transform`
 @return `sweep collision info (hit, time, point, normal)`
*>
extern fn R3DSweepCollision sweep_capsule_mesh(R3DCapsule capsule, RLVector3 velocity, R3DMeshData mesh, RLMatrix transform) @cname("R3D_SweepCapsuleMesh");
