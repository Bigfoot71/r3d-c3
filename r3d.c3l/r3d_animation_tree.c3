/* r3d_animation_tree.c3 -- R3D Animation Tree Module.
 *
 * Copyright (c) 2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
module r3d;

import raylib55;

// ========================================
// OPAQUE TYPES
// ========================================

typedef R3DAnimationTreeNode = void;

alias R3DAnimationStmIndex = int;

// ========================================
// CALLBACKS TYPES
// ========================================

<*
 Callback type for manipulating the animation before it is used by the animation tree.

 @param animation : `pointer to the processed animation`
 @param state : `current animation state`
 @param bone_index : `index of the processed bone`
 @param out : `transformation of the processed bone`
 @param user_data : `optional user-defined data passed when the callback was registered`
*>
alias R3DAnimationNodeCallback = fn void(R3DAnimation* animation, R3DAnimationState state, int bone_index, RLTransform* out, void* user_data);

<*
 Callback type for manipulating the final animation.

 @param player : `pointer to the animation player used by the animation tree`
 @param bone_index : `index of the processed bone`
 @param out : `transformation of the processed bone`
 @param user_data : `optional user-defined data passed when the callback was registered`
*>
alias R3DAnimationTreeCallback = fn void(R3DAnimationPlayer* player, int bone_index, RLTransform* out, void* user_data);

// ========================================
// ENUM TYPES
// ========================================

<*
 Types of operation modes for state machine edge.
*>
enum R3DStmEdgeMode : int
{
    INSTANT,    // Switch to next state instantly, with respecting cross fade time.
    ONDONE,     // Switch to next state when associated animation is done or looped with looper parameter set true.
}

<*
 Types of travel status for state machine edge.
*>
enum R3DStmEdgeStatus : int
{
    ON,     // Edge is traversable by travel function.
    AUTO,   // Edge is traversable automatically and by travel function.
    ONCE,   // Edge is traversable automatically and by travel function, but only once; edge status changes to nextStatus when traversed.
    OFF,    // Edge is not traversable.
}

// ========================================
// STRUCTS TYPES
// ========================================

<*
 Bone mask for Blend2 and Add2 animation nodes.

 Bone mask structure, can by created by compute_bone_mask.
*>
struct R3DBoneMask
{
    int[8] mask;        // Bit mask buffer for maximum of 256 bones (32bits * 8).
    int bone_count;     // Actual bones count.
}

<*
 Parameters for animation tree node Animation.

 Animation is a leaf node, holding the R3DAnimation structure.
*>
struct R3DAnimationNodeParams
{
    char[32] name;                              // Animation name (null-terminated string).
    R3DAnimationState state;                    // Animation state.
    bool looper;                                // Flag to control whether the animation is considered done when looped; yes when true.

    R3DAnimationNodeCallback eval_callback;     // Callback function to receive and modify animation transformation before been used.
    void* eval_user_data;                       // Optional user data pointer passed to the callback.
}

<*
 Parameters for animation tree node Blend2.

 Blend2 node blends channels of any two animation nodes together, with respecting optional bone mask.
*>
struct R3DBlend2NodeParams
{
    R3DBoneMask* bone_mask;     // Pointer to bone mask structure, can be NULL; calculated by compute_bone_mask().
    float blend;                // Blend weight value, can be in interval from 0.0 to 1.0.
}

<*
 Parameters for animation tree node Add2.

 Add2 node adds channels of any two animation nodes together, with respecting optional bone mask.
*>
struct R3DAdd2NodeParams
{
    R3DBoneMask* bone_mask;     // Pointer to bone mask structure, can be NULL; calculated by compute_bone_mask().
    float weight;               // Add weight value, can be in interval from 0.0 to 1.0.
}

<*
 Parameters for animation tree node Switch.

 Switch node allows instant or blended/faded transition between any animation nodes connected to inputs.
*>
struct R3DSwitchNodeParams
{
    bool synced;         // Flag to control input animation nodes synchronization; activated input is reset when false.
    int active_input;    // Active input zero-based index.
    float x_fade_time;   // Animation nodes cross fade blending time, in seconds.
}

<*
 Parameters for animation state machine edge.
*>
struct R3DStmEdgeParams
{
    R3DStmEdgeMode mode;          // Operation mode.
    R3DStmEdgeStatus status;      // Current travel status.
    R3DStmEdgeStatus next_status; // Travel status used after machine traversed through this edge with status set to ONCE.
    float x_fade_time;            // Cross fade blending time between connected animation nodes, in seconds.
}

<*
 Manages a tree structure of animation nodes.

 Animation tree allows to define complex logic for switching and blending animations of
 associated animation player. It supports 5 different animation node types: Animation, Blend2, Add2,
 Switch and State Machine. It also fully supports root motion and bone masking in Blend2/Add2.
*>
struct R3DAnimationTree
{
    R3DAnimationPlayer player;              // Animation player and skeleton used by all animation nodes.
    R3DAnimationTreeNode* root_node;        // Pointer to root animation node of the tree.
    R3DAnimationTreeNode* node_pool;        // Animation node pool of size node_pool_max_size.
    int node_pool_size;                     // Current animation node pool size.
    int node_pool_max_size;                 // Maximum number of animation nodes, defined during load.
    int root_bone;                          // Optional root bone index, -1 if not defined.

    R3DAnimationTreeCallback update_callback;   // Callback function to receive and modify final animation transformation.
    void* update_user_data;                     // Optional user data pointer passed to the callback.
}

// ========================================
// PUBLIC API
// ========================================

<*
 Creates an animation tree using given animation player.

 Allocates memory for animation nodes pool.

 @param player : `animation player used by the animation tree`
 @param max_size : `size of the animation nodes pool; maximum number of animation nodes in the tree`
 @return `newly created animation tree, or a zeroed struct on failure`
*>
extern fn R3DAnimationTree load_animation_tree(R3DAnimationPlayer player, int max_size) @cname("R3D_LoadAnimationTree");

<*
 Creates an animation tree using given animation player, with optional root motion support.

 Allocates memory for animation nodes pool and sets root bone index for root motion.

 @param player : `animation player used by the animation tree`
 @param max_size : `size of the animation nodes pool; maximum number of animation nodes in the tree`
 @param root_bone : `root bone index; set -1 to disable root motion`
 @return `newly created animation tree, or a zeroed struct on failure`
*>
extern fn R3DAnimationTree load_animation_tree_ex(R3DAnimationPlayer player, int max_size, int root_bone) @cname("R3D_LoadAnimationTreeEx");

<*
 Creates an animation tree using given animation player, with optional root motion support and callback.

 Allocates memory for animation nodes pool, sets root bone index and update callback.

 @param player : `animation player used by the animation tree`
 @param max_size : `size of the animation nodes pool; maximum number of animation nodes in the tree`
 @param root_bone : `root bone index; set -1 to disable root motion`
 @param update_callback : `callback function pointer to receive and modify final animation transformation, can be NULL`
 @param update_user_data : `user data pointer passed to the callback, can be NULL`
 @return `newly created animation tree, or a zeroed struct on failure`
*>
extern fn R3DAnimationTree load_animation_tree_pro(R3DAnimationPlayer player, int max_size, int root_bone, R3DAnimationTreeCallback update_callback, void* update_user_data) @cname("R3D_LoadAnimationTreePro");

<*
 Releases all resources used by an animation tree, including all animation nodes.

 @param tree : `animation tree to unload`
*>
extern fn void unload_animation_tree(R3DAnimationTree tree) @cname("R3D_UnloadAnimationTree");

<*
 Updates the animation tree: calculates blended pose, sets and uploads the pose through associated animation player.

 @param tree : `animation tree`
 @param dt : `delta time in seconds`
*>
extern fn void update_animation_tree(R3DAnimationTree* tree, float dt) @cname("R3D_UpdateAnimationTree");

<*
 Updates the animation tree: calculates blended pose, sets and uploads the pose through associated animation player.

 Set the root_motion and/or root_distance pointers to get root motion information.
 Divide root_motion translation vector by dt to get root bone speed.

 @param tree : `animation tree`
 @param dt : `delta time in seconds`
 @param root_motion : `pointer to root bone motion transformation`
 @param root_distance : `pointer to transformation containing root bone distance from rest pose`
*>
extern fn void update_animation_tree_ex(R3DAnimationTree* tree, float dt, RLTransform* root_motion, RLTransform* root_distance) @cname("R3D_UpdateAnimationTreeEx");

<*
 Sets root animation node of the animation tree.

 @param tree : `animation tree`
 @param node : `root animation node`
*>
extern fn void add_root_animation_node(R3DAnimationTree* tree, R3DAnimationTreeNode* node) @cname("R3D_AddRootAnimationNode");

<*
 Connects two animation nodes of animation tree hierarchy.

 @param parent : `parent animation node`
 @param node : `child animation node`
 @param input_index : `index of the parent node input used for connection`
 @return `true on success; false if parent node or input_index is invalid`
*>
extern fn bool add_animation_node(R3DAnimationTreeNode* parent, R3DAnimationTreeNode* node, int input_index) @cname("R3D_AddAnimationNode");

<*
 Creates animation node of type Animation.

 Animation is a leaf node, holding the R3DAnimation structure.

 @param tree : `animation tree`
 @param params : `animation node initial parameters`
 @return `pointer to created animation node; NULL if maximum number of nodes was exceeded or animation name is not found`
*>
extern fn R3DAnimationTreeNode* create_animation_node(R3DAnimationTree* tree, R3DAnimationNodeParams params) @cname("R3D_CreateAnimationNode");

<*
 Creates animation node of type Animation, optionally sets animation current_time.

 Animation is a leaf node, holding the R3DAnimation structure.

 @param tree : `animation tree`
 @param params : `animation node initial parameters`
 @param set_time : `flag to set current_time value based on animation speed; useful for animations with negative speed in State Machine`
 @return `pointer to created animation node; NULL if maximum number of nodes was exceeded or animation name is not found`
*>
extern fn R3DAnimationTreeNode* create_animation_node_ex(R3DAnimationTree* tree, R3DAnimationNodeParams params, bool set_time) @cname("R3D_CreateAnimationNodeEx");

<*
 Creates animation node of type Blend2.

 Blend2 node blends channels of any two animation nodes together, with respecting optional bone mask.

 @param tree : `animation tree`
 @param params : `blend2 node initial parameters`
 @return `pointer to created animation node; NULL if maximum number of nodes was exceeded`
*>
extern fn R3DAnimationTreeNode* create_blend2_node(R3DAnimationTree* tree, R3DBlend2NodeParams params) @cname("R3D_CreateBlend2Node");

<*
 Creates animation node of type Add2.

 Add2 node adds channels of any two animation nodes together, with respecting optional bone mask.

 @param tree : `animation tree`
 @param params : `add2 node initial parameters`
 @return `pointer to created animation node; NULL if maximum number of nodes was exceeded`
*>
extern fn R3DAnimationTreeNode* create_add2_node(R3DAnimationTree* tree, R3DAdd2NodeParams params) @cname("R3D_CreateAdd2Node");

<*
 Creates animation node of type Switch.

 Switch node allows instant or blended/faded transition between any animation nodes connected to inputs.

 @param tree : `animation tree`
 @param input_count : `number of available inputs`
 @param params : `switch node initial parameters`
 @return `pointer to created animation node; NULL if maximum number of nodes was exceeded`
*>
extern fn R3DAnimationTreeNode* create_switch_node(R3DAnimationTree* tree, int input_count, R3DSwitchNodeParams params) @cname("R3D_CreateSwitchNode");

<*
 Creates animation node of type State Machine (Stm).

 Stm node allows to create a state machine graph of any animation nodes.

 @param tree : `animation tree`
 @param states_count : `maximum number of states in the state machine`
 @param edges_count : `maximum number of edges in the state machine`
 @return `pointer to created animation node; NULL if maximum number of nodes was exceeded`
*>
extern fn R3DAnimationTreeNode* create_stm_node(R3DAnimationTree* tree, int states_count, int edges_count) @cname("R3D_CreateStmNode");

<*
 Creates animation node of type State Machine (Stm), with option to disable travel feature (enabled by default).

 @param tree : `animation tree`
 @param states_count : `maximum number of states in the state machine`
 @param edges_count : `maximum number of edges in the state machine`
 @param enable_travel : `flag to enable or disable travel feature; enabled when set true`
 @return `pointer to created animation node; NULL if maximum number of nodes was exceeded`
*>
extern fn R3DAnimationTreeNode* create_stm_node_ex(R3DAnimationTree* tree, int states_count, int edges_count, bool enable_travel) @cname("R3D_CreateStmNodeEx");

<*
 Creates animation node of type State Machine Stop/Done (StmX).

 StmX is a helper animation node, that allows stopping state machine evaluation in the current update.
 Sets animation node done status of the state machine to true.

 @param tree : `animation tree`
 @param nested_node : `actual animation node with animation channels`
 @return `pointer to created animation node; NULL if maximum number of nodes was exceeded`
*>
extern fn R3DAnimationTreeNode* create_stm_x_node(R3DAnimationTree* tree, R3DAnimationTreeNode* nested_node) @cname("R3D_CreateStmXNode");

<*
 Creates state in a State Machine animation node.

 @param stm_node : `animation node of type State Machine`
 @param state_node : `associated animation node of the state`
 @param out_edges_count : `number of output edges of the state`
 @return `index of created state; -1 if maximum number of states was exceeded`
*>
extern fn R3DAnimationStmIndex create_stm_node_state(R3DAnimationTreeNode* stm_node, R3DAnimationTreeNode* state_node, int out_edges_count) @cname("R3D_CreateStmNodeState");

<*
 Creates edge in a State Machine animation node.

 @param stm_node : `animation node of type State Machine`
 @param begin_state_index : `index of state connected to the edge beginning`
 @param end_state_index : `index of state connected to the edge end`
 @param params : `edge initial parameters`
 @return `index of created edge; -1 if maximum number of edges was exceeded`
*>
extern fn R3DAnimationStmIndex create_stm_node_edge(R3DAnimationTreeNode* stm_node, R3DAnimationStmIndex begin_state_index, R3DAnimationStmIndex end_state_index, R3DStmEdgeParams params) @cname("R3D_CreateStmNodeEdge");

<*
 Sets parameters of animation node Animation.

 @param node : `animation node of type Animation`
 @param params : `new parameters`
*>
extern fn void set_animation_node_params(R3DAnimationTreeNode* node, R3DAnimationNodeParams params) @cname("R3D_SetAnimationNodeParams");

<*
 Gets parameters of animation node Animation.

 @param node : `animation node of type Animation`
 @return `current parameters`
*>
extern fn R3DAnimationNodeParams get_animation_node_params(R3DAnimationTreeNode* node) @cname("R3D_GetAnimationNodeParams");

<*
 Sets parameters of animation node Blend2.

 @param node : `animation node of type Blend2`
 @param params : `new parameters`
*>
extern fn void set_blend2_node_params(R3DAnimationTreeNode* node, R3DBlend2NodeParams params) @cname("R3D_SetBlend2NodeParams");

<*
 Gets parameters of animation node Blend2.

 @param node : `animation node of type Blend2`
 @return `current parameters`
*>
extern fn R3DBlend2NodeParams get_blend2_node_params(R3DAnimationTreeNode* node) @cname("R3D_GetBlend2NodeParams");

<*
 Sets parameters of animation node Add2.

 @param node : `animation node of type Add2`
 @param params : `new parameters`
*>
extern fn void set_add2_node_params(R3DAnimationTreeNode* node, R3DAdd2NodeParams params) @cname("R3D_SetAdd2NodeParams");

<*
 Gets parameters of animation node Add2.

 @param node : `animation node of type Add2`
 @return `current parameters`
*>
extern fn R3DAdd2NodeParams get_add2_node_params(R3DAnimationTreeNode* node) @cname("R3D_GetAdd2NodeParams");

<*
 Sets parameters of animation node Switch.

 @param node : `animation node of type Switch`
 @param params : `new parameters`
*>
extern fn void set_switch_node_params(R3DAnimationTreeNode* node, R3DSwitchNodeParams params) @cname("R3D_SetSwitchNodeParams");

<*
 Gets parameters of animation node Switch.

 @param node : `animation node of type Switch`
 @return `current parameters`
*>
extern fn R3DSwitchNodeParams get_switch_node_params(R3DAnimationTreeNode* node) @cname("R3D_GetSwitchNodeParams");

<*
 Sets parameters of State Machine edge.

 @param node : `animation node of type State Machine (Stm)`
 @param edge_index : `index of the State Machine edge`
 @param params : `new parameters of the edge`
*>
extern fn void set_stm_node_edge_params(R3DAnimationTreeNode* node, R3DAnimationStmIndex edge_index, R3DStmEdgeParams params) @cname("R3D_SetStmNodeEdgeParams");

<*
 Gets parameters of State Machine edge.

 @param node : `animation node of type State Machine`
 @param edge_index : `index of the State Machine edge`
 @return `current parameters of the edge`
*>
extern fn R3DStmEdgeParams get_stm_node_edge_params(R3DAnimationTreeNode* node, R3DAnimationStmIndex edge_index) @cname("R3D_GetStmNodeEdgeParams");

<*
 Gets active state index of State Machine.

 @param node : `animation node of type State Machine`
 @return `index of current active state`
*>
extern fn R3DAnimationStmIndex get_stm_state_active_index(R3DAnimationTreeNode* node) @cname("R3D_GetStmStateActiveIndex");

<*
 Sets travel path inside State Machine, from current state to target.

 If travel path is not found, target is set as current state instantly (teleport).

 @param node : `animation node of type State Machine`
 @param target_state_index : `index of the targeted state`
*>
extern fn void travel_to_stm_state(R3DAnimationTreeNode* node, R3DAnimationStmIndex target_state_index) @cname("R3D_TravelToStmState");

<*
 Computes bone mask from list of bone names.

 Only listed bones will be included in evaluation of animation node with this bone mask.
 Can be used in Blend2 and Add2 animation nodes.

 @param skeleton : `skeleton of associated animation player`
 @param bone_names : `array of pointers to null-terminated strings with bone names`
 @param bone_name_count : `count of strings in bone_names array`
 @return `calculated bone mask, or zeroed structure on failure`
*>
extern fn R3DBoneMask compute_bone_mask(R3DSkeleton* skeleton, ZString* bone_names, int bone_name_count) @cname("R3D_ComputeBoneMask");
