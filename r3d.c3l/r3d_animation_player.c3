/* r3d_animation_player.c3 -- R3D Animation Player Module.
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
 Types of events that an animation player can emit.
*>
enum R3DAnimationEvent : int
{
    FINISHED,   // Animation has finished playing (non-looping).
    LOOPED,     // Animation has completed a loop.
}

// ========================================
// CALLBACKS TYPES
// ========================================

<*
 Callback type for receiving animation events.

 @param player : `pointer to the animation player emitting the event`
 @param event_type : `type of the event (finished, looped)`
 @param anim_index : `index of the animation triggering the event`
 @param user_data : `optional user-defined data passed when the callback was registered`
*>
alias R3DAnimationEventCallback = fn void(R3DAnimationPlayer* player, R3DAnimationEvent event_type, int anim_index, void* user_data);

// ========================================
// STRUCTS TYPES
// ========================================

<*
 Describes the playback state of a single animation within a player.

 Tracks the current time, speed, play/pause state, and looping behavior.
*>
struct R3DAnimationState
{
    float current_time; // Current playback time in animation ticks.
    float speed;        // Playback speed; can be negative for reverse playback.
    bool play;          // Whether the animation is currently playing.
    bool loop;          // True to enable looping playback.
}

<*
 Manages playback of multiple animations for a skeleton.

 The animation player updates animation states, interpolates keyframes,
 blends animations according to their weights, and stores the resulting
 local and global bone transforms. It also supports GPU skinning by uploading
 the global pose into a texture.
*>
struct R3DAnimationPlayer
{
    R3DAnimationLib anim_lib;      // Animation library providing the available animations.
    R3DSkeleton skeleton;          // Skeleton to animate.

    R3DAnimationState* states;     // Array of animation states, one per animation.
    int active_anim_index;         // Index of the current animation.

    RLMatrix* local_pose;          // Array of bone transforms representing the blended local pose.
    RLMatrix* model_pose;          // Array of bone transforms in model space, obtained by hierarchical accumulation.
    RLMatrix* skin_buffer;         // Array of final skinning matrices (invBind * modelPose), sent to the GPU.
    uint skin_texture;             // GPU texture ID storing the skinning matrices as a 1D RGBA16F texture.

    R3DAnimationEventCallback event_callback;  // Callback function to receive animation events.
    void* event_user_data;                     // Optional user data pointer passed to the callback.
}

// ========================================
// PUBLIC API
// ========================================

<*
 Creates an animation player for a skeleton and animation library.

 Allocates memory for animation states and pose buffers.

 @param skeleton : `skeleton to animate`
 @param anim_lib : `animation library providing animations`
 @return `newly created animation player, or a zeroed struct on failure`
*>
extern fn R3DAnimationPlayer load_animation_player(R3DSkeleton skeleton, R3DAnimationLib anim_lib) @cname("R3D_LoadAnimationPlayer");

<*
 Releases all resources used by an animation player.

 @param player : `animation player to unload`
*>
extern fn void unload_animation_player(R3DAnimationPlayer player) @cname("R3D_UnloadAnimationPlayer");

<*
 Checks whether an animation player is valid.

 @param player : `animation player to check`
 @return `true if valid, false otherwise`
*>
extern fn bool is_animation_player_valid(R3DAnimationPlayer player) @cname("R3D_IsAnimationPlayerValid");

<*
 Returns whether an animation is currently playing.

 @param player : `animation player`
 @return `true if playing, false otherwise`
*>
extern fn bool is_animation_playing(R3DAnimationPlayer player) @cname("R3D_IsAnimationPlaying");

<*
 Starts playback of the specified animation.

 @param player : `animation player`
 @param anim_index : `index of the animation to play`
*>
extern fn void play_animation(R3DAnimationPlayer* player, int anim_index) @cname("R3D_PlayAnimation");

<*
 Pauses the current animation.

 @param player : `animation player`
*>
extern fn void pause_animation(R3DAnimationPlayer* player) @cname("R3D_PauseAnimation");

<*
 Stops the current animation and clamps its time.

 @param player : `animation player`
*>
extern fn void stop_animation(R3DAnimationPlayer* player) @cname("R3D_StopAnimation");

<*
 Rewinds the animation to the start or end depending on playback direction.

 @param player : `animation player`
*>
extern fn void rewind_animation(R3DAnimationPlayer* player) @cname("R3D_RewindAnimation");

<*
 Gets the current playback time of an animation.

 @param player : `animation player`
 @param anim_index : `index of the animation`
 @return `current time in animation ticks`
*>
extern fn float get_animation_time(R3DAnimationPlayer player, int anim_index) @cname("R3D_GetAnimationTime");

<*
 Sets the current playback time of an animation.

 @param player : `animation player`
 @param anim_index : `index of the animation`
 @param time : `time in animation ticks`
*>
extern fn void set_animation_time(R3DAnimationPlayer* player, int anim_index, float time) @cname("R3D_SetAnimationTime");

<*
 Gets the playback speed of an animation.

 @param player : `animation player`
 @param anim_index : `index of the animation`
 @return `current speed (may be negative for reverse playback)`
*>
extern fn float get_animation_speed(R3DAnimationPlayer player, int anim_index) @cname("R3D_GetAnimationSpeed");

<*
 Sets the playback speed of an animation.

 Negative values play the animation backwards. If setting a negative speed
 on a stopped animation, consider calling rewind_animation() to start at the end.

 @param player : `animation player`
 @param anim_index : `index of the animation`
 @param speed : `playback speed`
*>
extern fn void set_animation_speed(R3DAnimationPlayer* player, int anim_index, float speed) @cname("R3D_SetAnimationSpeed");

<*
 Gets whether the animation is set to loop.

 @param player : `animation player`
 @param anim_index : `index of the animation`
 @return `true if looping is enabled`
*>
extern fn bool get_animation_loop(R3DAnimationPlayer player, int anim_index) @cname("R3D_GetAnimationLoop");

<*
 Enables or disables looping for the animation.

 @param player : `animation player`
 @param anim_index : `index of the animation`
 @param loop : `true to enable looping`
*>
extern fn void set_animation_loop(R3DAnimationPlayer* player, int anim_index, bool loop) @cname("R3D_SetAnimationLoop");

<*
 Advances the time of the current animation.

 Updates animation timer based on speed and delta time.
 Does NOT recalculate the skeleton pose.

 @param player : `animation player`
 @param dt : `delta time in seconds`
*>
extern fn void advance_animation_time(R3DAnimationPlayer* player, float dt) @cname("R3D_AdvanceAnimationTime");

<*
 Computes the local-space transform of each bone for the current animation.

 Samples and interpolates the current animation keyframes at the current playback time,
 and stores the resulting bone transforms in local space into `player.local_pose`.
 Does NOT advance animation time, and does NOT compute model-space transforms.

 @param player : `animation player whose local pose will be updated`
*>
extern fn void compute_animation_local_pose(R3DAnimationPlayer* player) @cname("R3D_ComputeAnimationLocalPose");

<*
 Computes the model-space transform of each bone from the current local pose.

 Traverses the bone hierarchy and accumulates local transforms into model-space matrices,
 stored into `player.model_pose`. This assumes `player.local_pose` is already up-to-date.
 Does NOT sample animation keyframes, and does NOT advance animation time.

 @param player : `animation player whose model pose will be updated`
*>
extern fn void compute_animation_model_pose(R3DAnimationPlayer* player) @cname("R3D_ComputeAnimationModelPose");

<*
 Computes both the local and model-space transforms for the current animation.

 Equivalent to calling compute_animation_local_pose() followed by compute_animation_model_pose().
 Does NOT advance animation time.

 @param player : `animation player whose local and model poses will be updated`
*>
extern fn void compute_animation_pose(R3DAnimationPlayer* player) @cname("R3D_ComputeAnimationPose");

<*
 Computes the final skinning matrices and uploads them to the GPU.

 Multiplies each bone's model-space transform by its inverse bind matrix to produce
 the skinning matrices, then uploads them to the GPU skin texture.
 This assumes `player.model_pose` is already up-to-date.

 @param player : `animation player whose skinning matrices will be uploaded`
*>
extern fn void upload_animation_pose(R3DAnimationPlayer* player) @cname("R3D_UploadAnimationPose");

<*
 Updates the animation player: calculates and upload the current pose, then advances time.

 Equivalent to calling compute_animation_local_pose() followed by
 compute_animation_model_pose() and advance_animation_time().

 @param player : `animation player`
 @param dt : `delta time in seconds`
*>
extern fn void update_animation_player(R3DAnimationPlayer* player, float dt) @cname("R3D_UpdateAnimationPlayer");
