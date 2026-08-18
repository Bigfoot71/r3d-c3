/* r3d_mesh_data.c3 -- R3D Mesh Data Module.
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
 Defines the geometric primitive type.
*>
enum R3DPrimitiveType : int
{
    POINTS,             // Each vertex represents a single point.
    LINES,              // Each pair of vertices forms an independent line segment.
    LINE_STRIP,         // Connected series of line segments sharing vertices.
    LINE_LOOP,          // Closed loop of connected line segments.
    TRIANGLES,          // Each set of three vertices forms an independent triangle.
    TRIANGLE_STRIP,     // Connected strip of triangles sharing vertices.
    TRIANGLE_FAN,       // Fan of triangles sharing the first vertex.
}

// ========================================
// STRUCTS TYPES
// ========================================

<*
 Represents a mesh stored in CPU memory.

 R3DMeshData is the CPU-side container of a mesh. It stores vertex and index data,
 and provides utility functions to generate, transform, and process geometry before
 uploading it to the GPU as an R3DMesh.

 Think of it as a toolbox for procedural or dynamic mesh generation on the CPU.
*>
struct R3DMeshData
{
    R3DVertex* vertices;    // Pointer to vertex data in CPU memory.
    uint* indices;          // Pointer to index data in CPU memory.
    int vertex_capacity;    // Capacity of vertices.
    int index_capacity;     // Capacity of indices.
    int vertex_count;       // Number of vertices.
    int index_count;        // Number of indices.
}

// ========================================
// PUBLIC API
// ========================================

<*
 Allocates a mesh data container with the given capacity.

 This function allocates CPU-side buffers for vertices and indices, but does NOT
 initialize the mesh with any actual data. The returned R3DMeshData has:

 - vertex_capacity and index_capacity set to the requested sizes
 - vertex_count and index_count set to 0

 You must manually set vertex_count/index_count after filling the buffers,
 or use helper functions like append_mesh_data() to populate the mesh.

 All allocated memory is zero-initialized.

 @param vertex_capacity : `number of vertices to allocate; must be > 0`
 @param index_capacity : `number of indices to allocate; may be 0. If 0, no index buffer is allocated`
 @return `a new R3DMeshData with allocated buffers and zero element counts`
*>
extern fn R3DMeshData load_mesh_data(int vertex_capacity, int index_capacity) @cname("R3D_LoadMeshData");

<*
 Releases memory used by a mesh data container.

 @param mesh_data : `R3DMeshData to destroy`
*>
extern fn void unload_mesh_data(R3DMeshData mesh_data) @cname("R3D_UnloadMeshData");

<*
 Check if mesh data is valid.

 Returns true if the mesh data contains at least one vertex buffer
 with a positive number of vertices.

 @param mesh_data : `mesh data to check`
 @return `true if valid, false otherwise`
*>
extern fn bool is_mesh_data_valid(R3DMeshData mesh_data) @cname("R3D_IsMeshDataValid");

<*
 Generate a quad mesh with specified dimensions, resolution, and orientation.

 Creates a flat rectangular quad mesh with customizable facing direction.
 The mesh can be subdivided for higher resolution or displacement mapping.
 The quad is centered at the origin and oriented according to the front_dir parameter,
 which defines both the face direction and the surface normal.

 @param width : `width of the quad along its local X axis`
 @param length : `length of the quad along its local Z axis`
 @param res_x : `number of subdivisions along the width`
 @param res_z : `number of subdivisions along the length`
 @param front_dir : `direction vector defining the quad's front face and normal; this vector will be normalized internally`
 @return `generated quad mesh structure with proper normals, tangents, and UVs`
*>
extern fn R3DMeshData gen_mesh_data_quad(float width, float length, int res_x, int res_z, RLVector3 front_dir) @cname("R3D_GenMeshDataQuad");

<*
 Generate a plane mesh with specified dimensions and resolution.

 Creates a flat plane mesh in the XZ plane, centered at the origin.
 The mesh can be subdivided for higher resolution or displacement mapping.

 @param width : `width of the plane along the X axis`
 @param length : `length of the plane along the Z axis`
 @param res_x : `number of subdivisions along the X axis`
 @param res_z : `number of subdivisions along the Z axis`
 @return `generated plane mesh structure`
*>
extern fn R3DMeshData gen_mesh_data_plane(float width, float length, int res_x, int res_z) @cname("R3D_GenMeshDataPlane");

<*
 Generate a polygon mesh with specified number of sides.

 Creates a regular polygon mesh centered at the origin in the XY plane.
 The polygon is generated with vertices evenly distributed around a circle.

 @param sides : `number of sides for the polygon (minimum 3)`
 @param radius : `radius of the circumscribed circle`
 @param front_dir : `direction vector defining the polygon's front face and normal; this vector will be normalized internally`
 @return `generated polygon mesh structure`
*>
extern fn R3DMeshData gen_mesh_data_poly(int sides, float radius, RLVector3 front_dir) @cname("R3D_GenMeshDataPoly");

<*
 Generate a cube mesh with specified dimensions.

 Creates a cube mesh centered at the origin with the specified width, height, and length.
 Each face consists of two triangles with proper normals and texture coordinates.

 @param width : `width of the cube along the X axis`
 @param height : `height of the cube along the Y axis`
 @param length : `length of the cube along the Z axis`
 @return `generated cube mesh structure`
*>
extern fn R3DMeshData gen_mesh_data_cube(float width, float height, float length) @cname("R3D_GenMeshDataCube");

<*
 Generate a subdivided cube mesh with specified dimensions.

 Extension of gen_mesh_data_cube() allowing per-axis subdivision.
 Each face can be tessellated along the X, Y, and Z axes according
 to the provided resolutions.

 @param width : `width of the cube along the X axis`
 @param height : `height of the cube along the Y axis`
 @param length : `length of the cube along the Z axis`
 @param res_x : `number of subdivisions along the X axis`
 @param res_y : `number of subdivisions along the Y axis`
 @param res_z : `number of subdivisions along the Z axis`
 @return `generated cube mesh structure`
*>
extern fn R3DMeshData gen_mesh_data_cube_ex(float width, float height, float length, int res_x, int res_y, int res_z) @cname("R3D_GenMeshDataCubeEx");

<*
 Generate a slope mesh by cutting a cube with a plane.

 Creates a slope mesh by slicing a cube with a plane that passes through the origin.
 The plane is defined by its normal vector, and the portion of the cube on the side
 opposite to the normal direction is kept. This allows creating ramps, wedges, and
 angled surfaces with arbitrary orientations.

 The normal vector will be automatically normalized internally.
 The cutting plane always passes through the center of the cube (origin).

 @param width : `width of the base cube along the X axis`
 @param height : `height of the base cube along the Y axis`
 @param length : `length of the base cube along the Z axis`
 @param slope_normal : `normal vector of the cutting plane. The mesh keeps the portion of the cube in the direction opposite to this normal. Example: {-1, 0, 0} creates a ramp rising towards +X. {0, 1, 0} creates a wedge with the slope facing up. {-1.0, 1.0, 0} creates a 45° diagonal slope`
 @return `generated slope mesh structure`
*>
extern fn R3DMeshData gen_mesh_data_slope(float width, float height, float length, RLVector3 slope_normal) @cname("R3D_GenMeshDataSlope");

<*
 Generate a sphere mesh with specified parameters.

 Creates a UV sphere mesh centered at the origin using latitude-longitude subdivision.
 Higher ring and slice counts produce smoother spheres but with more vertices.

 @param radius : `radius of the sphere`
 @param rings : `number of horizontal rings (latitude divisions)`
 @param slices : `number of vertical slices (longitude divisions)`
 @return `generated sphere mesh structure`
*>
extern fn R3DMeshData gen_mesh_data_sphere(float radius, int rings, int slices) @cname("R3D_GenMeshDataSphere");

<*
 Generate a hemisphere mesh with specified parameters.

 Creates a half-sphere mesh (dome) centered at the origin, extending upward in the Y axis.
 Uses the same UV sphere generation technique as gen_mesh_data_sphere but only the upper half.

 @param radius : `radius of the hemisphere`
 @param rings : `number of horizontal rings (latitude divisions)`
 @param slices : `number of vertical slices (longitude divisions)`
 @return `generated hemisphere mesh structure`
*>
extern fn R3DMeshData gen_mesh_data_hemi_sphere(float radius, int rings, int slices) @cname("R3D_GenMeshDataHemiSphere");

<*
 Generates a cylinder mesh centered at the origin along the Y axis.

 Both caps are included. For a cone or truncated cone, use gen_mesh_data_cylinder_ex.

 @param radius : `radius of the cylinder; must be > 0`
 @param height : `total height along the Y axis; must be > 0`
 @param slices : `radial subdivisions around the circumference; must be >= 3`
 @return `the generated mesh data, or an empty mesh on invalid input`
*>
extern fn R3DMeshData gen_mesh_data_cylinder(float radius, float height, int slices) @cname("R3D_GenMeshDataCylinder");

<*
 Generates a cylinder, cone, or truncated cone mesh centered at the origin along the Y axis.

 The bottom cap sits at Y = -height/2 and the top cap at Y = +height/2.
 Setting one radius to 0 produces a cone; caps can be toggled independently.

 @param bottom_radius : `radius of the bottom end; must be >= 0. Cannot both be 0`
 @param top_radius : `radius of the top end; must be >= 0. Cannot both be 0`
 @param height : `total height along the Y axis; must be > 0`
 @param slices : `radial subdivisions around the circumference; must be >= 3`
 @param stacks : `vertical subdivisions along the height; must be >= 1. Higher values reduce faceting, especially on cones`
 @param bottom_cap : `whether to generate the bottom cap`
 @param top_cap : `whether to generate the top cap`
 @return `the generated mesh data, or an empty mesh on invalid input`
*>
extern fn R3DMeshData gen_mesh_data_cylinder_ex(float bottom_radius, float top_radius, float height, int slices, int stacks, bool bottom_cap, bool top_cap) @cname("R3D_GenMeshDataCylinderEx");

<*
 Generate a capsule mesh with specified parameters.

 Creates a capsule mesh centered at the origin, extending along the Y axis.
 The capsule consists of a cylindrical body with hemispherical caps on both ends.
 The total height of the capsule is height + 2 * radius.

 @param radius : `radius of the capsule (both cylindrical body and hemispherical caps)`
 @param height : `height of the cylindrical portion along the Y axis`
 @param rings : `total number of latitudinal subdivisions for both hemispheres combined`
 @param slices : `number of radial subdivisions around the shape`
 @return `generated mesh structure`
*>
extern fn R3DMeshData gen_mesh_data_capsule(float radius, float height, int rings, int slices) @cname("R3D_GenMeshDataCapsule");

<*
 Generate a torus mesh with specified parameters.

 Creates a torus (donut shape) mesh centered at the origin in the XZ plane.
 The torus is defined by a major radius (distance from center to tube center)
 and a minor radius (tube thickness).

 @param radius : `major radius of the torus (distance from center to tube center)`
 @param size : `minor radius of the torus (tube thickness/radius)`
 @param rad_seg : `number of segments around the major radius`
 @param sides : `number of sides around the tube cross-section`
 @return `generated torus mesh structure`
*>
extern fn R3DMeshData gen_mesh_data_torus(float radius, float size, int rad_seg, int sides) @cname("R3D_GenMeshDataTorus");

<*
 Generate a trefoil knot mesh with specified parameters.

 Creates a trefoil knot mesh, which is a mathematical knot shape.
 Similar to a torus but with a twisted, knotted topology.

 @param radius : `major radius of the knot`
 @param size : `minor radius (tube thickness) of the knot`
 @param rad_seg : `number of segments around the major radius`
 @param sides : `number of sides around the tube cross-section`
 @return `generated trefoil knot mesh structure`
*>
extern fn R3DMeshData gen_mesh_data_knot(float radius, float size, int rad_seg, int sides) @cname("R3D_GenMeshDataKnot");

<*
 Generate a terrain mesh from a heightmap image.

 Creates a terrain mesh by interpreting the brightness values of a heightmap image
 as height values. The resulting mesh represents a 3D terrain surface.

 @param heightmap : `image containing height data (grayscale values represent elevation)`
 @param size : `3D vector defining the terrain dimensions (width, max height, depth)`
 @return `generated heightmap terrain mesh structure`
*>
extern fn R3DMeshData gen_mesh_data_heightmap(RLImage heightmap, RLVector3 size) @cname("R3D_GenMeshDataHeightmap");

<*
 Generate a voxel-style mesh from a cubicmap image.

 Creates a mesh composed of cubes based on a cubicmap image, where each pixel
 represents the presence or absence of a cube at that position. Useful for
 creating voxel-based or block-based geometry.

 @param cubicmap : `image where pixel values determine cube placement`
 @param cube_size : `3D vector defining the size of each individual cube`
 @return `generated cubicmap mesh structure`
*>
extern fn R3DMeshData gen_mesh_data_cubicmap(RLImage cubicmap, RLVector3 cube_size) @cname("R3D_GenMeshDataCubicmap");

<*
 Reserves memory for the specified number of vertices and indices.

 @param mesh_data : `target mesh data container`
 @param vertex_count : `number of vertices to reserve space for`
 @param index_count : `number of indices to reserve space for`
*>
extern fn void reserve_mesh_data(R3DMeshData* mesh_data, int vertex_count, int index_count) @cname("R3D_ReserveMeshData");

<*
 Shrinks allocated memory to fit the current vertex and index counts.

 @param mesh_data : `target mesh data container to shrink`
*>
extern fn void shrink_mesh_data(R3DMeshData* mesh_data) @cname("R3D_ShrinkMeshData");

<*
 Clears all vertices and indices without releasing allocated memory.

 @param mesh_data : `target mesh data container to reset`
*>
extern fn void reset_mesh_data(R3DMeshData* mesh_data) @cname("R3D_ResetMeshData");

<*
 Creates a deep copy of an existing mesh data container.

 @param mesh_data : `source mesh data to duplicate`
 @return `a new R3DMeshData containing a copy of the source data`
*>
extern fn R3DMeshData copy_mesh_data(R3DMeshData mesh_data) @cname("R3D_CopyMeshData");

<*
 Merges two mesh data containers into a single one.

 @param a : `first mesh data`
 @param b : `second mesh data`
 @return `a new R3DMeshData containing the merged geometry`
*>
extern fn R3DMeshData merge_mesh_data(R3DMeshData a, R3DMeshData b) @cname("R3D_MergeMeshData");

<*
 Appends vertices and indices to the mesh data container.

 @param mesh_data : `target mesh data container`
 @param vertices : `array of vertices to append`
 @param vertex_count : `number of vertices to append`
 @param indices : `array of indices to append`
 @param index_count : `number of indices to append`
*>
extern fn void append_mesh_data(R3DMeshData* mesh_data, R3DVertex* vertices, int vertex_count, uint* indices, int index_count) @cname("R3D_AppendMeshData");

<*
 Applies a transformation matrix to all vertices in the mesh data.

 @param mesh_data : `target mesh data container`
 @param transform : `transformation matrix to apply`
*>
extern fn void transform_mesh_data(R3DMeshData* mesh_data, RLMatrix transform) @cname("R3D_TransformMeshData");

<*
 Translates all vertices by a given offset.

 @param mesh_data : `mesh data to modify`
 @param translation : `offset to apply to all vertex positions`
*>
extern fn void translate_mesh_data(R3DMeshData* mesh_data, RLVector3 translation) @cname("R3D_TranslateMeshData");

<*
 Rotates all vertices using a quaternion.

 @param mesh_data : `mesh data to modify`
 @param rotation : `quaternion representing the rotation`
*>
extern fn void rotate_mesh_data(R3DMeshData* mesh_data, RLQuaternion rotation) @cname("R3D_RotateMeshData");

<*
 Scales all vertices by given factors.

 @param mesh_data : `mesh data to modify`
 @param scale : `scaling factors for each axis`
*>
extern fn void scale_mesh_data(R3DMeshData* mesh_data, RLVector3 scale) @cname("R3D_ScaleMeshData");

<*
 Generates planar UV coordinates.

 @param mesh_data : `mesh data to modify`
 @param uv_scale : `scaling factors for UV coordinates`
 @param axis : `axis along which to project the planar mapping`
*>
extern fn void gen_mesh_data_uvs_planar(R3DMeshData* mesh_data, RLVector2 uv_scale, RLVector3 axis) @cname("R3D_GenMeshDataUVsPlanar");

<*
 Generates spherical UV coordinates.

 @param mesh_data : `mesh data to modify`
*>
extern fn void gen_mesh_data_uvs_spherical(R3DMeshData* mesh_data) @cname("R3D_GenMeshDataUVsSpherical");

<*
 Generates cylindrical UV coordinates.

 @param mesh_data : `mesh data to modify`
*>
extern fn void gen_mesh_data_uvs_cylindrical(R3DMeshData* mesh_data) @cname("R3D_GenMeshDataUVsCylindrical");

<*
 Computes vertex normals from triangle geometry.

 Not thread-safe: uses the shared global scratch stack.

 @param mesh_data : `mesh data to modify`
 @param type : `primitive type of the mesh. Points and line primitives are not supported and will default to a front-facing normal (0, 0, 1)`
*>
extern fn void gen_mesh_data_normals(R3DMeshData* mesh_data, R3DPrimitiveType type) @cname("R3D_GenMeshDataNormals");

<*
 Computes vertex tangents based on existing normals and UVs.

 Not thread-safe: uses the shared global scratch stack.

 @param mesh_data : `mesh data to modify`
 @param type : `primitive type of the mesh. Points and line primitives are not supported and will default to a front-facing tangent (1, 0, 0, 1)`
*>
extern fn void gen_mesh_data_tangents(R3DMeshData* mesh_data, R3DPrimitiveType type) @cname("R3D_GenMeshDataTangents");

<*
 Calculates the axis-aligned bounding box of the mesh.

 @param mesh_data : `mesh data to analyze`
 @return `the computed bounding box`
*>
extern fn RLBoundingBox calculate_mesh_data_bounding_box(R3DMeshData mesh_data) @cname("R3D_CalculateMeshDataBoundingBox");
