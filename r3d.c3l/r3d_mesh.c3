/* r3d_mesh.c3 -- R3D Mesh Module.
 *
 * Copyright (c) 2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
module r3d;

import raylib55;

// ========================================
// ENUMS TYPES
// ========================================

<*
 Shadow casting modes for objects.

 Controls how an object interacts with the shadow mapping system.
 These modes determine whether the object contributes to shadows,
 and if so, whether it is also rendered in the main pass.
*>
enum R3DShadowCastMode : int
{
    ON_AUTO,               // The object casts shadows; the faces used are determined by the material's culling mode.
    ON_DOUBLE_SIDED,       // The object casts shadows with both front and back faces, ignoring face culling.
    ON_FRONT_SIDE,         // The object casts shadows with only front faces, culling back faces.
    ON_BACK_SIDE,          // The object casts shadows with only back faces, culling front faces.
    ONLY_AUTO,             // The object only casts shadows; the faces used are determined by the material's culling mode.
    ONLY_DOUBLE_SIDED,     // The object only casts shadows with both front and back faces, ignoring face culling.
    ONLY_FRONT_SIDE,       // The object only casts shadows with only front faces, culling back faces.
    ONLY_BACK_SIDE,        // The object only casts shadows with only back faces, culling front faces.
    DISABLED,              // The object does not cast shadows at all.
}

// ========================================
// STRUCTS TYPES
// ========================================

<*
 Represents a 3D mesh.

 Stores vertex and index data, shadow casting settings, bounding box, and layer information.
 Can represent a static or skinned mesh.
*>
struct R3DMesh
{
    int vertex_offset;                  // Offset in the internal VBO.
    int vertex_capacity;                // Number of vertices allocated in the internal VBO.
    int vertex_count;                   // Number of vertices currently in use.

    int index_offset;                   // Offset in the internal EBO.
    int index_capacity;                 // Number of indices allocated in the internal EBO.
    int index_count;                    // Number of indices currently in use.

    R3DShadowCastMode shadow_cast_mode; // Shadow casting mode for the mesh.
    R3DPrimitiveType primitive_type;    // Type of primitive that constitutes the vertices.
    R3DLayer layer_mask;                // Bitfield indicating the rendering layer(s) of this mesh.
    RLBoundingBox aabb;                 // Axis-Aligned Bounding Box in local space.
}

// ========================================
// PUBLIC API
// ========================================

<*
 Creates a 3D mesh from CPU-side mesh data.

 The function copies all vertex and index data into GPU buffers.

 @param type : `primitive type used to interpret vertex data`
 @param data : `R3DMeshData containing vertices and indices (can be zero initialized)`
 @param aabb : `optional pointer to a bounding box; if NULL, it will be computed automatically`
 @return `created R3DMesh`
*>
extern fn R3DMesh load_mesh(R3DPrimitiveType type, R3DMeshData data, RLBoundingBox* aabb) @cname("R3D_LoadMesh");

<*
 Destroys a 3D mesh and frees its resources.

 @param mesh : `R3DMesh to destroy`
*>
extern fn void unload_mesh(R3DMesh mesh) @cname("R3D_UnloadMesh");

<*
 Check if a mesh is valid for rendering.

 Returns true if the mesh has a valid VAO and VBO.

 @param mesh : `the mesh to check`
 @return `true if valid, false otherwise`
*>
extern fn bool is_mesh_valid(R3DMesh mesh) @cname("R3D_IsMeshValid");

<*
 Generate a quad mesh with orientation.

 @param width : `width along local X axis`
 @param length : `length along local Z axis`
 @param res_x : `subdivisions along width`
 @param res_z : `subdivisions along length`
 @param front_dir : `direction vector for the quad's front face`
 @return `mesh ready for rendering`
*>
extern fn R3DMesh gen_mesh_quad(float width, float length, int res_x, int res_z, RLVector3 front_dir) @cname("R3D_GenMeshQuad");

<*
 Generate a plane mesh.

 @param width : `width along X axis`
 @param length : `length along Z axis`
 @param res_x : `subdivisions along X axis`
 @param res_z : `subdivisions along Z axis`
 @return `mesh ready for rendering`
*>
extern fn R3DMesh gen_mesh_plane(float width, float length, int res_x, int res_z) @cname("R3D_GenMeshPlane");

<*
 Generate a polygon mesh.

 @param sides : `number of sides (min 3)`
 @param radius : `radius of the polygon`
 @param front_dir : `direction vector for the polygon's front face`
 @return `mesh ready for rendering`
*>
extern fn R3DMesh gen_mesh_poly(int sides, float radius, RLVector3 front_dir) @cname("R3D_GenMeshPoly");

<*
 Generate a cube mesh.

 @param width : `width along X axis`
 @param height : `height along Y axis`
 @param length : `length along Z axis`
 @return `mesh ready for rendering`
*>
extern fn R3DMesh gen_mesh_cube(float width, float height, float length) @cname("R3D_GenMeshCube");

<*
 Generate a subdivided cube mesh.

 @param width : `width along X axis`
 @param height : `height along Y axis`
 @param length : `length along Z axis`
 @param res_x : `subdivisions along X axis`
 @param res_y : `subdivisions along Y axis`
 @param res_z : `subdivisions along Z axis`
 @return `mesh ready for rendering`
*>
extern fn R3DMesh gen_mesh_cube_ex(float width, float height, float length, int res_x, int res_y, int res_z) @cname("R3D_GenMeshCubeEx");

<*
 Generate a slope mesh.

 @param width : `width along X axis`
 @param height : `height along Y axis`
 @param length : `length along Z axis`
 @param slope_normal : `direction of the slope`
 @return `mesh ready for rendering`
*>
extern fn R3DMesh gen_mesh_slope(float width, float height, float length, RLVector3 slope_normal) @cname("R3D_GenMeshSlope");

<*
 Generate a sphere mesh.

 @param radius : `sphere radius`
 @param rings : `number of latitude divisions`
 @param slices : `number of longitude divisions`
 @return `mesh ready for rendering`
*>
extern fn R3DMesh gen_mesh_sphere(float radius, int rings, int slices) @cname("R3D_GenMeshSphere");

<*
 Generate a hemisphere mesh.

 @param radius : `hemisphere radius`
 @param rings : `number of latitude divisions`
 @param slices : `number of longitude divisions`
 @return `mesh ready for rendering`
*>
extern fn R3DMesh gen_mesh_hemi_sphere(float radius, int rings, int slices) @cname("R3D_GenMeshHemiSphere");

<*
 Generate a cylinder mesh.

 @param radius : `radius of the cylinder`
 @param height : `height along Y axis`
 @param slices : `radial subdivisions`
 @return `mesh ready for rendering`
*>
extern fn R3DMesh gen_mesh_cylinder(float radius, float height, int slices) @cname("R3D_GenMeshCylinder");

<*
 Generate a cylinder, cone or truncated cone mesh.

 @param bottom_radius : `bottom radius`
 @param top_radius : `top radius`
 @param height : `height along Y axis`
 @param slices : `radial subdivisions`
 @param stacks : `vertical subdivisions`
 @param bottom_cap : `generate bottom cap`
 @param top_cap : `generate top cap`
 @return `mesh ready for rendering`
*>
extern fn R3DMesh gen_mesh_cylinder_ex(float bottom_radius, float top_radius, float height, int slices, int stacks, bool bottom_cap, bool top_cap) @cname("R3D_GenMeshCylinderEx");

<*
 Generate a capsule mesh.

 @param radius : `capsule radius`
 @param height : `height along Y axis`
 @param rings : `number of latitude divisions`
 @param slices : `number of longitude divisions`
 @return `mesh ready for rendering`
*>
extern fn R3DMesh gen_mesh_capsule(float radius, float height, int rings, int slices) @cname("R3D_GenMeshCapsule");

<*
 Generate a torus mesh.

 @param radius : `major radius (center to tube)`
 @param size : `minor radius (tube thickness)`
 @param rad_seg : `segments around major radius`
 @param sides : `sides around tube cross-section`
 @return `mesh ready for rendering`
*>
extern fn R3DMesh gen_mesh_torus(float radius, float size, int rad_seg, int sides) @cname("R3D_GenMeshTorus");

<*
 Generate a trefoil knot mesh.

 @param radius : `major radius`
 @param size : `minor radius`
 @param rad_seg : `segments around major radius`
 @param sides : `sides around tube cross-section`
 @return `mesh ready for rendering`
*>
extern fn R3DMesh gen_mesh_knot(float radius, float size, int rad_seg, int sides) @cname("R3D_GenMeshKnot");

<*
 Generate a heightmap terrain mesh.

 @param heightmap : `heightmap image`
 @param size : `3D dimensions of terrain`
 @return `mesh ready for rendering`
*>
extern fn R3DMesh gen_mesh_heightmap(RLImage heightmap, RLVector3 size) @cname("R3D_GenMeshHeightmap");

<*
 Generate a cubicmap voxel mesh.

 @param cubicmap : `cubicmap image`
 @param cube_size : `size of each cube`
 @return `mesh ready for rendering`
*>
extern fn R3DMesh gen_mesh_cubicmap(RLImage cubicmap, RLVector3 cube_size) @cname("R3D_GenMeshCubicmap");

<*
 Upload a mesh data on the GPU.

 This function uploads a mesh's vertex and optional index data to the GPU.

 If `aabb` is provided, it will be used as the mesh's bounding box; if null,
 the bounding box is automatically recalculated from the vertex data.

 @param mesh : `pointer to the mesh structure to update`
 @param data : `mesh data (vertices and indices) to upload`
 @param aabb : `optional bounding box; if null, it is recalculated automatically`
 @return `true if the update is successful, false otherwise`
*>
extern fn bool update_mesh(R3DMesh* mesh, R3DMeshData data, RLBoundingBox* aabb) @cname("R3D_UpdateMesh");
