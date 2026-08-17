/* r3d_draw.c3 -- R3D Draw Module.
 *
 * Copyright (c) 2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
module r3d;

import raylib55;

// ========================================
// STRUCT TYPES
// ========================================

<*
 Describes an R3D rendering view.

 A view defines the camera and output area used for a single rendering
 session. It combines an R3D camera, an optional render target and an optional
 viewport inside that target.

 If `target` is zero-initialized, rendering is directed to the default
 framebuffer. If `viewport.width` or `viewport.height` is less than or equal
 to zero, the full target size is used.
*>
struct R3DView
{
    R3DCamera camera;          // Camera used for this view.
    RLRenderTexture target;    // Render target. Zero-initialized means screen/backbuffer.
    RLRectangle viewport;      // Viewport inside the target. If width or height <= 0, the full target is used.
}

// ========================================
// C3 MACROS
// ========================================

<*
 Begins a rendering session using the given raylib camera, then calls [block].
 Rendering will end after [block] has finished.

 The camera is converted internally to an R3DCamera.
*>
macro void @rendering(RLCamera3D camera ;@body)
{
	begin(camera);
	defer end();
	@body();
}

<*
 Begins a rendering session using the given R3D camera, then calls [block].
 Rendering will end after [block] has finished.

 This entry point provides access to R3D-specific camera features such as
 layer masks, custom near/far clipping planes and quaternion-based orientation.
*>
macro void @rendering_ex(R3DCamera camera ;@body)
{
	begin_ex(camera);
	defer end();
	@body();
}

<*
 Begins an advanced rendering session using the given R3D view descriptor,
 then calls [block].

 Rendering will end after [block] has finished.

 The view descriptor specifies the camera, render target and viewport, allowing
 render-to-texture workflows, custom viewports, multipass rendering, editor
 views, minimaps, probes and other advanced use cases.
*>
macro void @rendering_pro(R3DView view ;@body)
{
	begin_pro(view);
	defer end();
	@body();
}

// ========================================
// PUBLIC API
// ========================================

<*
 Begins a rendering session using the given raylib camera.

 Rendering output is directed to the default framebuffer.

 The given Camera3D is converted internally to an R3DCamera. Since raylib
 cameras do not store near/far clipping planes, the converted camera uses the
 current rlgl culling distances for those values.

 @param camera : `camera used to render the scene`
*>
extern fn void begin(RLCamera3D camera) @cname("R3D_Begin");

<*
 Begins a rendering session using an R3D camera.

 Rendering output is directed to the default framebuffer.

 This entry point provides access to R3D-specific camera features such as
 layer masks, custom near/far clipping planes and quaternion-based orientation.

 @param camera : `camera used to render the scene`
*>
extern fn void begin_ex(R3DCamera camera) @cname("R3D_BeginEx");

<*
 Begins a rendering session using a complete R3D view descriptor.

 This is the advanced entry point. It allows the caller to specify the camera,
 render target and viewport used for the rendering session.

 The view camera is used as-is, including its near/far clipping planes and
 layer mask. If the camera was created from a raylib Camera3D using
 `camera_from_rl()`, its near/far planes come from the current rlgl culling
 distances because raylib cameras do not store those values directly.

 Use this function for render-to-texture workflows, custom viewports,
 multipass rendering, editor views, minimaps, probes or any case where the
 default framebuffer is not enough.

 @param view : `view descriptor used to render the scene`
*>
extern fn void begin_pro(R3DView view) @cname("R3D_BeginPro");

<*
 Ends the current rendering session.

 This function is the one that actually performs the full
 rendering of the described scene. It carries out culling,
 sorting, shadow rendering, scene rendering, and screen /
 post-processing effects.
*>
extern fn void end() @cname("R3D_End");

<*
 Begins a clustered draw pass.

 All draw calls submitted in this pass are first tested against the
 cluster AABB. If the cluster fails the scene/shadow frustum test,
 none of the contained objects are tested or drawn.

 @param aabb : `bounding box used as the cluster-level frustum test`
*>
extern fn void begin_cluster(RLBoundingBox aabb) @cname("R3D_BeginCluster");

<*
 Ends the current clustered draw pass.

 Stops submitting draw calls to the active cluster.
*>
extern fn void end_cluster() @cname("R3D_EndCluster");

<*
 Queues a light to be rendered for the current frame, without shadows.

 The light is submitted for rendering during end(), and must be pushed
 again on every frame between begin() and end() to remain visible.

 @param light : `the light data to submit (see R3DLight)`
*>
extern fn void push_light(R3DLight light) @cname("R3D_PushLight");

<*
 Queues a light to be rendered for the current frame, with an associated shadow map.

 The light is submitted for rendering during end(), and must be pushed
 again on every frame between begin() and end() to remain visible.

 The shadow map is re-rendered whenever update_shadow is true, or when it has never
 been rendered before (so static lights can safely pass false from the start and
 still get valid shadows). This happens even if the light is currently off-screen,
 so you can safely ignore visibility when driving update_shadow, or factor it in
 yourself if you want to defer updates for off-screen lights.

 @param light : `the light data to submit (see R3DLight)`
 @param map : `the shadow map to associate with this light for this frame`
 @param update_shadow : `whether the shadow map should be re-rendered this frame. If false, the previously rendered content is reused instead`
*>
extern fn void push_light_ex(R3DLight light, R3DShadowMap map, bool update_shadow) @cname("R3D_PushLightEx");

<*
 Queues a probe to be rendered for the current frame.

 The probe is submitted for rendering during end(), and must be pushed
 again on every frame between begin() and end() to remain active.

 The probe is re-captured whenever update_probe is true, or when it has never been
 captured before (so static probes can safely pass false from the start and still
 get valid data). This happens even if the probe is currently off-screen, so you
 can safely ignore visibility when driving update_probe, or factor it in yourself
 if you want to defer updates for off-screen probes.

 @param probe : `the probe data to submit (see R3DProbe)`
 @param update_probe : `whether the probe's capture should be re-rendered this frame. If false, the previously captured content is reused instead`
*>
extern fn void push_probe(R3DProbe probe, bool update_probe) @cname("R3D_PushProbe");

<*
 Queues a mesh draw command with position and uniform scale.

 The command is executed during end().

 @param mesh : `mesh to draw`
 @param material : `material to apply`
 @param position : `world-space position`
 @param scale : `uniform scale`
*>
extern fn void draw_mesh(R3DMesh mesh, R3DMaterial material, RLVector3 position, float scale) @cname("R3D_DrawMesh");

<*
 Queues a mesh draw command with position, rotation and non-uniform scale.

 The command is executed during end().

 @param mesh : `mesh to draw`
 @param material : `material to apply`
 @param position : `world-space position`
 @param rotation : `orientation`
 @param scale : `non-uniform scale`
*>
extern fn void draw_mesh_ex(R3DMesh mesh, R3DMaterial material, RLVector3 position, RLQuaternion rotation, RLVector3 scale) @cname("R3D_DrawMeshEx");

<*
 Queues a mesh draw command using a full transform matrix.

 The command is executed during end().

 @param mesh : `mesh to draw`
 @param material : `material to apply`
 @param transform : `full transform matrix`
*>
extern fn void draw_mesh_pro(R3DMesh mesh, R3DMaterial material, RLMatrix transform) @cname("R3D_DrawMeshPro");

<*
 Queues an instanced mesh draw command.

 Draws multiple instances using the provided instance buffer.
 Does nothing if the number of instances is <= 0.

 The command is executed during end().

 @param mesh : `mesh to draw`
 @param material : `material to apply`
 @param instances : `instance buffer`
 @param count : `number of instances to draw`
*>
extern fn void draw_mesh_instanced(R3DMesh mesh, R3DMaterial material, R3DInstanceBuffer instances, int count) @cname("R3D_DrawMeshInstanced");

<*
 Queues an instanced mesh draw command with an instance range.

 Draws 'count' instances starting at 'offset' in the instance buffer.
 Both 'offset' and 'count' are clamped to stay within [0, instances.capacity]:
   - offset is clamped to [0, capacity]
   - count is clamped to [0, capacity - offset]
 Does nothing if the resulting count is <= 0.

 The command is executed during end().

 @param mesh : `mesh to draw`
 @param material : `material to apply`
 @param instances : `instance buffer`
 @param offset : `starting offset in the instance buffer`
 @param count : `number of instances to draw`
*>
extern fn void draw_mesh_instanced_ex(R3DMesh mesh, R3DMaterial material, R3DInstanceBuffer instances, int offset, int count) @cname("R3D_DrawMeshInstancedEx");

<*
 Queues an instanced mesh draw command with an instance range and an additional transform.

 Draws 'count' instances starting at 'offset' in the instance buffer.
 Both 'offset' and 'count' are clamped to stay within [0, instances.capacity]:
   - offset is clamped to [0, capacity]
   - count is clamped to [0, capacity - offset]
 Does nothing if the resulting count is <= 0.
 The transform is applied to all instances.

 The command is executed during end().

 @param mesh : `mesh to draw`
 @param material : `material to apply`
 @param instances : `instance buffer`
 @param offset : `starting offset in the instance buffer`
 @param count : `number of instances to draw`
 @param transform : `transform applied to all instances`
*>
extern fn void draw_mesh_instanced_pro(R3DMesh mesh, R3DMaterial material, R3DInstanceBuffer instances, int offset, int count, RLMatrix transform) @cname("R3D_DrawMeshInstancedPro");

<*
 Queues a model draw command with position and uniform scale.

 The command is executed during end().

 @param model : `model to draw`
 @param position : `world-space position`
 @param scale : `uniform scale`
*>
extern fn void draw_model(R3DModel model, RLVector3 position, float scale) @cname("R3D_DrawModel");

<*
 Queues a model draw command with position, rotation and non-uniform scale.

 The command is executed during end().

 @param model : `model to draw`
 @param position : `world-space position`
 @param rotation : `orientation`
 @param scale : `non-uniform scale`
*>
extern fn void draw_model_ex(R3DModel model, RLVector3 position, RLQuaternion rotation, RLVector3 scale) @cname("R3D_DrawModelEx");

<*
 Queues a model draw command using a full transform matrix.

 The command is executed during end().

 @param model : `model to draw`
 @param transform : `full transform matrix`
*>
extern fn void draw_model_pro(R3DModel model, RLMatrix transform) @cname("R3D_DrawModelPro");

<*
 Queues an instanced model draw command.

 Draws multiple instances using the provided instance buffer.
 Does nothing if the number of instances is <= 0.

 The command is executed during end().

 @param model : `model to draw`
 @param instances : `instance buffer`
 @param count : `number of instances to draw`
*>
extern fn void draw_model_instanced(R3DModel model, R3DInstanceBuffer instances, int count) @cname("R3D_DrawModelInstanced");

<*
 Queues an instanced model draw command with an instance range.

 Draws 'count' instances starting at 'offset' in the instance buffer.
 Both 'offset' and 'count' are clamped to stay within [0, instances.capacity]:
   - offset is clamped to [0, capacity]
   - count is clamped to [0, capacity - offset]
 Does nothing if the resulting count is <= 0.

 The command is executed during end().

 @param model : `model to draw`
 @param instances : `instance buffer`
 @param offset : `starting offset in the instance buffer`
 @param count : `number of instances to draw`
*>
extern fn void draw_model_instanced_ex(R3DModel model, R3DInstanceBuffer instances, int offset, int count) @cname("R3D_DrawModelInstancedEx");

<*
 Queues an instanced model draw command with an instance range and an additional transform.

 Draws 'count' instances starting at 'offset' in the instance buffer.
 Both 'offset' and 'count' are clamped to stay within [0, instances.capacity]:
   - offset is clamped to [0, capacity]
   - count is clamped to [0, capacity - offset]
 Does nothing if the resulting count is <= 0.
 The transform is applied to all instances.

 The command is executed during end().

 @param model : `model to draw`
 @param instances : `instance buffer`
 @param offset : `starting offset in the instance buffer`
 @param count : `number of instances to draw`
 @param transform : `transform applied to all instances`
*>
extern fn void draw_model_instanced_pro(R3DModel model, R3DInstanceBuffer instances, int offset, int count, RLMatrix transform) @cname("R3D_DrawModelInstancedPro");

<*
 Queues an animated model draw command.

 Uses the provided animation player to compute the pose.

 The command is executed during end().

 @param model : `model to draw`
 @param player : `animation player providing the pose`
 @param position : `world-space position`
 @param scale : `uniform scale`
*>
extern fn void draw_animated_model(R3DModel model, R3DAnimationPlayer player, RLVector3 position, float scale) @cname("R3D_DrawAnimatedModel");

<*
 Queues an animated model draw command with position, rotation and non-uniform scale.

 Uses the provided animation player to compute the pose.

 The command is executed during end().

 @param model : `model to draw`
 @param player : `animation player providing the pose`
 @param position : `world-space position`
 @param rotation : `orientation`
 @param scale : `non-uniform scale`
*>
extern fn void draw_animated_model_ex(R3DModel model, R3DAnimationPlayer player, RLVector3 position, RLQuaternion rotation, RLVector3 scale) @cname("R3D_DrawAnimatedModelEx");

<*
 Queues an animated model draw command using a full transform matrix.

 The command is executed during end().

 @param model : `model to draw`
 @param player : `animation player providing the pose`
 @param transform : `full transform matrix`
*>
extern fn void draw_animated_model_pro(R3DModel model, R3DAnimationPlayer player, RLMatrix transform) @cname("R3D_DrawAnimatedModelPro");

<*
 Queues an instanced animated model draw command.

 Draws multiple animated instances using the provided instance buffer.
 Does nothing if the number of instances is <= 0.

 The command is executed during end().

 @param model : `model to draw`
 @param player : `animation player providing the pose`
 @param instances : `instance buffer`
 @param count : `number of instances to draw`
*>
extern fn void draw_animated_model_instanced(R3DModel model, R3DAnimationPlayer player, R3DInstanceBuffer instances, int count) @cname("R3D_DrawAnimatedModelInstanced");

<*
 Queues an instanced animated model draw command with an instance range.

 Draws 'count' animated instances starting at 'offset' in the instance buffer.
 Both 'offset' and 'count' are clamped to stay within [0, instances.capacity]:
   - offset is clamped to [0, capacity]
   - count is clamped to [0, capacity - offset]
 Does nothing if the resulting count is <= 0.

 The command is executed during end().

 @param model : `model to draw`
 @param player : `animation player providing the pose`
 @param instances : `instance buffer`
 @param offset : `starting offset in the instance buffer`
 @param count : `number of instances to draw`
*>
extern fn void draw_animated_model_instanced_ex(R3DModel model, R3DAnimationPlayer player, R3DInstanceBuffer instances, int offset, int count) @cname("R3D_DrawAnimatedModelInstancedEx");

<*
 Queues an instanced animated model draw command with an instance range and an additional transform.

 Draws 'count' animated instances starting at 'offset' in the instance buffer.
 Both 'offset' and 'count' are clamped to stay within [0, instances.capacity]:
   - offset is clamped to [0, capacity]
   - count is clamped to [0, capacity - offset]
 Does nothing if the resulting count is <= 0.
 The transform is applied to all instances.

 The command is executed during end().

 @param model : `model to draw`
 @param player : `animation player providing the pose`
 @param instances : `instance buffer`
 @param offset : `starting offset in the instance buffer`
 @param count : `number of instances to draw`
 @param transform : `transform applied to all instances`
*>
extern fn void draw_animated_model_instanced_pro(R3DModel model, R3DAnimationPlayer player, R3DInstanceBuffer instances, int offset, int count, RLMatrix transform) @cname("R3D_DrawAnimatedModelInstancedPro");

<*
 Queues a decal draw command with position and uniform scale.

 The command is executed during end().

 @param decal : `decal to draw`
 @param position : `world-space position`
 @param scale : `uniform scale`
*>
extern fn void draw_decal(R3DDecal decal, RLVector3 position, float scale) @cname("R3D_DrawDecal");

<*
 Queues a decal draw command with position, rotation and non-uniform scale.

 The command is executed during end().

 @param decal : `decal to draw`
 @param position : `world-space position`
 @param rotation : `orientation`
 @param scale : `non-uniform scale`
*>
extern fn void draw_decal_ex(R3DDecal decal, RLVector3 position, RLQuaternion rotation, RLVector3 scale) @cname("R3D_DrawDecalEx");

<*
 Queues a decal draw command using a full transform matrix.

 The command is executed during end().

 @param decal : `decal to draw`
 @param transform : `full transform matrix`
*>
extern fn void draw_decal_pro(R3DDecal decal, RLMatrix transform) @cname("R3D_DrawDecalPro");

<*
 Queues an instanced decal draw command.

 Draws multiple instances using the provided instance buffer.
 Does nothing if the number of instances is <= 0.

 The command is executed during end().

 @param decal : `decal to draw`
 @param instances : `instance buffer`
 @param count : `number of instances to draw`
*>
extern fn void draw_decal_instanced(R3DDecal decal, R3DInstanceBuffer instances, int count) @cname("R3D_DrawDecalInstanced");

<*
 Queues an instanced decal draw command with an instance range.

 Draws 'count' instances starting at 'offset' in the instance buffer.
 Both 'offset' and 'count' are clamped to stay within [0, instances.capacity]:
   - offset is clamped to [0, capacity]
   - count is clamped to [0, capacity - offset]
 Does nothing if the resulting count is <= 0.

 The command is executed during end().

 @param decal : `decal to draw`
 @param instances : `instance buffer`
 @param offset : `starting offset in the instance buffer`
 @param count : `number of instances to draw`
*>
extern fn void draw_decal_instanced_ex(R3DDecal decal, R3DInstanceBuffer instances, int offset, int count) @cname("R3D_DrawDecalInstancedEx");

<*
 Queues an instanced decal draw command with an instance range and an additional transform.

 Draws 'count' instances starting at 'offset' in the instance buffer.
 Both 'offset' and 'count' are clamped to stay within [0, instances.capacity]:
   - offset is clamped to [0, capacity]
   - count is clamped to [0, capacity - offset]
 Does nothing if the resulting count is <= 0.
 The transform is applied to all instances.

 The command is executed during end().

 @param decal : `decal to draw`
 @param instances : `instance buffer`
 @param offset : `starting offset in the instance buffer`
 @param count : `number of instances to draw`
 @param transform : `transform applied to all instances`
*>
extern fn void draw_decal_instanced_pro(R3DDecal decal, R3DInstanceBuffer instances, int offset, int count, RLMatrix transform) @cname("R3D_DrawDecalInstancedPro");
