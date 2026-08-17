/* r3d_camera.c3 -- R3D Camera Module.
 *
 * Copyright (c) 2026 Le Juez Victor
 *
 * This software is provided "as-is", without any express or implied warranty.
 * For conditions of distribution and use, see the accompanying LICENSE file.
 */
module r3d;

import raylib55;

// ========================================
// ENUM TYPES
// ========================================

<*
 Projection mode used by an R3D camera.
*>
enum R3DProjection : int
{
    PERSPECTIVE,    // Perspective projection.
    ORTHOGRAPHIC,   // Orthographic projection.
}

// ========================================
// BITFIELD TYPES
// ========================================

<*
 Bitfield type used to specify rendering layers.

 This type is used by cameras and renderable objects to control visibility.
 A renderable object is visible to a camera when at least one bit is shared
 between the object's layer mask and the camera's layer mask.

 For convenience, 16 predefined layers are provided here, but the underlying
 type supports up to 32 layers.
*>
typedef R3DLayer = uint;

const R3DLayer LAYER_01 = (R3DLayer)(1u << 0);
const R3DLayer LAYER_02 = (R3DLayer)(1u << 1);
const R3DLayer LAYER_03 = (R3DLayer)(1u << 2);
const R3DLayer LAYER_04 = (R3DLayer)(1u << 3);
const R3DLayer LAYER_05 = (R3DLayer)(1u << 4);
const R3DLayer LAYER_06 = (R3DLayer)(1u << 5);
const R3DLayer LAYER_07 = (R3DLayer)(1u << 6);
const R3DLayer LAYER_08 = (R3DLayer)(1u << 7);
const R3DLayer LAYER_09 = (R3DLayer)(1u << 8);
const R3DLayer LAYER_10 = (R3DLayer)(1u << 9);
const R3DLayer LAYER_11 = (R3DLayer)(1u << 10);
const R3DLayer LAYER_12 = (R3DLayer)(1u << 11);
const R3DLayer LAYER_13 = (R3DLayer)(1u << 12);
const R3DLayer LAYER_14 = (R3DLayer)(1u << 13);
const R3DLayer LAYER_15 = (R3DLayer)(1u << 14);
const R3DLayer LAYER_16 = (R3DLayer)(1u << 15);

const R3DLayer LAYER_ALL = (R3DLayer)0xFFFFFFFF;

// ========================================
// STRUCT TYPES
// ========================================

<*
 Quaternion-based 3D camera used by R3D.

 Unlike raylib's Camera3D, this camera stores its orientation directly as a
 quaternion instead of using a target/up pair. It also stores near/far clipping
 planes and a layer mask used to filter visible renderables.
*>
struct R3DCamera
{
    RLVector3 position;          // Camera world-space position.
    RLQuaternion rotation;       // Camera world-space orientation.
    double fovy;                 // Vertical field of view in degrees for perspective projection; vertical size for orthographic projection.
    double near_plane;           // Distance to the near clipping plane.
    double far_plane;            // Distance to the far clipping plane.
    R3DLayer cull_mask;          // Camera visibility layer mask.
    R3DProjection projection;    // Camera projection mode.
}

// ========================================
// CONSTANTS
// ========================================

const R3DCamera CAMERA_BASE = {
    .position   = { 0, 0, 0 },
    .rotation   = { 0, 0, 0, 1 },
    .fovy       = 60.0,
    .near_plane = 0.05,
    .far_plane  = 4000.0,
    .cull_mask  = LAYER_ALL,
    .projection = PERSPECTIVE,
};

// ========================================
// PUBLIC API
// ========================================

<*
 Creates an R3D camera from a raylib camera.

 The camera position, orientation, field of view and projection mode are
 derived from the given raylib camera.

 Since raylib's Camera3D does not store near/far clipping planes or layer
 masks, the near/far planes are initialized from the current rlgl culling
 distances, while the layer mask is set to the default R3D camera layer mask.

 @param camera : `raylib camera to convert`
 @return `converted R3D camera`
*>
extern fn R3DCamera camera_from_rl(RLCamera3D camera) @cname("R3D_CameraFromRL");

<*
 Converts an R3D camera to a raylib camera.

 The raylib target/up vectors are derived from the camera quaternion.
 Near/far clipping planes and layer masks are not represented by Camera3D.

 @param camera : `R3D camera to convert`
 @return `converted raylib camera`
*>
extern fn RLCamera3D camera_to_rl(R3DCamera camera) @cname("R3D_CameraToRL");

<*
 Sets the camera orientation so it looks at a target point.

 @param camera : `camera to orient`
 @param target : `point to look at`
 @param up : `up vector reference`
*>
extern fn void camera_look_at(R3DCamera* camera, RLVector3 target, RLVector3 up) @cname("R3D_CameraLookAt");

<*
 Returns the camera forward direction in world space.

 @param camera : `camera`
 @return `forward direction vector`
*>
extern fn RLVector3 get_camera_forward(R3DCamera camera) @cname("R3D_GetCameraForward");

<*
 Returns the camera right direction in world space.

 @param camera : `camera`
 @return `right direction vector`
*>
extern fn RLVector3 get_camera_right(R3DCamera camera) @cname("R3D_GetCameraRight");

<*
 Returns the camera up direction in world space.

 @param camera : `camera`
 @return `up direction vector`
*>
extern fn RLVector3 get_camera_up(R3DCamera camera) @cname("R3D_GetCameraUp");

<*
 Returns the camera view matrix.

 @param camera : `camera`
 @return `view matrix`
*>
extern fn RLMatrix get_camera_view(R3DCamera camera) @cname("R3D_GetCameraView");

<*
 Returns the camera projection matrix.

 @param camera : `camera`
 @param aspect : `viewport aspect ratio`
 @return `projection matrix`
*>
extern fn RLMatrix get_camera_proj(R3DCamera camera, double aspect) @cname("R3D_GetCameraProj");

<*
 Returns the combined view-projection matrix.

 @param camera : `camera`
 @param aspect : `viewport aspect ratio`
 @return `view-projection matrix`
*>
extern fn RLMatrix get_camera_view_proj(R3DCamera camera, double aspect) @cname("R3D_GetCameraViewProj");

<*
 Moves the camera in world space.

 @param camera : `camera to move`
 @param delta : `displacement in world space`
*>
extern fn void move_camera(R3DCamera* camera, RLVector3 delta) @cname("R3D_MoveCamera");

<*
 Moves the camera in local space.

 @param camera : `camera to move`
 @param delta : `displacement in local space`
*>
extern fn void move_camera_local(R3DCamera* camera, RLVector3 delta) @cname("R3D_MoveCameraLocal");

<*
 Rotates the camera using a quaternion.

 @param camera : `camera to rotate`
 @param rotation : `rotation to apply`
*>
extern fn void camera_rotate(R3DCamera* camera, RLQuaternion rotation) @cname("R3D_CameraRotate");

<*
 Rotates the camera around its local X axis.

 @param camera : `camera to rotate`
 @param angle : `rotation angle`
*>
extern fn void camera_pitch(R3DCamera* camera, float angle) @cname("R3D_CameraPitch");

<*
 Rotates the camera around its local Y axis.

 @param camera : `camera to rotate`
 @param angle : `rotation angle`
*>
extern fn void camera_yaw(R3DCamera* camera, float angle) @cname("R3D_CameraYaw");

<*
 Rotates the camera around its local Z axis.

 @param camera : `camera to rotate`
 @param angle : `rotation angle`
*>
extern fn void camera_roll(R3DCamera* camera, float angle) @cname("R3D_CameraRoll");

<*
 Replaces the camera culling mask.

 @param camera : `camera to update`
 @param cull_mask : `new culling mask`
*>
extern fn void set_camera_cull_mask(R3DCamera* camera, R3DLayer cull_mask) @cname("R3D_SetCameraCullMask");

<*
 Enables one or more layers in the camera culling mask.

 @param camera : `camera to update`
 @param layer_mask : `layers to enable`
*>
extern fn void enable_camera_cull_layers(R3DCamera* camera, R3DLayer layer_mask) @cname("R3D_EnableCameraCullLayers");

<*
 Disables one or more layers from the camera culling mask.

 @param camera : `camera to update`
 @param layer_mask : `layers to disable`
*>
extern fn void disable_camera_cull_layers(R3DCamera* camera, R3DLayer layer_mask) @cname("R3D_DisableCameraCullLayers");

<*
 Toggles one or more layers in the camera culling mask.

 @param camera : `camera to update`
 @param layer_mask : `layers to toggle`
*>
extern fn void toggle_camera_cull_layers(R3DCamera* camera, R3DLayer layer_mask) @cname("R3D_ToggleCameraCullLayers");

<*
 Checks whether at least one object layer is visible to the camera.

 @param camera : `camera`
 @param layer_mask : `layers to test`
 @return `true if at least one layer is visible`
*>
extern fn bool is_camera_layer_visible(R3DCamera camera, R3DLayer layer_mask) @cname("R3D_IsCameraLayerVisible");
