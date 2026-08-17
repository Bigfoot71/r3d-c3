/* r3d_instance.c3 -- R3D Instance Module.
 *
 * Copyright (c) 2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
module r3d;

import raylib55;

// ========================================
// CONSTANTS
// ========================================

const int INSTANCE_ATTRIBUTE_COUNT = 5;

// ========================================
// ENUM / FLAGS
// ========================================

<*
 Bitmask defining which instance attributes are present.

 Each bit enables one per-instance attribute stream. Attribute data is stored
 in separate GPU buffers, one buffer per enabled attribute.

 The memory format of each enabled attribute is defined by `R3DInstanceLayout`.
 In shaders, these attributes are exposed as floating-point vectors, including
 normalized integer formats such as UNORM/SNORM.
*>
bitstruct R3DInstanceFlags : uint
{
    bool position;  // Position attribute: 3 components
    bool rotation;  // Rotation attribute: 4 components (quaternion)
    bool scale;     // Scale attribute: 3 components
    bool color;     // Color attribute: 4 components
    bool custom;    // Custom attribute: 4 components
}

<*
 Storage format used by an instance attribute.

 The selected format controls how the attribute is stored in GPU memory.
 All formats are read by the shader as floating-point values.

 UNORM formats are converted to the [0, 1] range.
 SNORM formats are converted to the [-1, 1] range.
*>
enum R3DInstanceFormat : int
{
    FLOAT32,    // 32-bit floating-point component.
    FLOAT16,    // 16-bit floating-point component.
    UNORM16,    // 16-bit unsigned normalized component.
    SNORM16,    // 16-bit signed normalized component.
    UNORM8,     // 8-bit unsigned normalized component.
    SNORM8,     // 8-bit signed normalized component.

    COUNT,      // Number of available instance formats.
}

// ========================================
// STRUCT TYPES
// ========================================

<*
 Describes the layout of an instance buffer.

 `flags` defines which instance attributes are allocated.
 `formats` defines the storage format used by each attribute.

 The `formats` array is indexed in the same order as the instance attribute
 flags:

 - index 0: position
 - index 1: rotation
 - index 2: scale
 - index 3: color
 - index 4: custom

 Data uploaded or mapped for an attribute must match the format selected for
 that attribute.
*>
struct R3DInstanceLayout
{
    R3DInstanceFormat[5] formats;    // Storage format for each instance attribute.
    R3DInstanceFlags flags;          // Enabled instance attribute mask.
}

<*
 GPU buffers storing instance attribute streams.

 Each enabled attribute owns one GPU buffer. The enabled attributes and their
 storage formats are described by `layout`.
*>
struct R3DInstanceBuffer
{
    uint[5] buffers;          // One GPU buffer per attribute, indexed by attribute order.
    R3DInstanceLayout layout;  // Instance buffer layout.
    int capacity;              // Maximum number of instances.
}

// ========================================
// PUBLIC API
// ========================================

<*
 Creates instance buffers on the GPU using the default layout.

 This is the simple entry point. It allocates one GPU buffer for each enabled
 attribute in `flags`.

 Default formats:

 - position: FLOAT32
 - rotation: FLOAT32
 - scale:    FLOAT32
 - color:    UNORM8
 - custom:   FLOAT32

 @param capacity : `maximum number of instances`
 @param flags : `attribute mask to allocate`
 @return `initialized instance buffer, or an empty buffer on failure`
*>
extern fn R3DInstanceBuffer load_instance_buffer(int capacity, R3DInstanceFlags flags) @cname("R3D_LoadInstanceBuffer");

<*
 Creates instance buffers on the GPU using a custom layout.

 This is the advanced entry point. It allocates one GPU buffer for each
 enabled attribute in `layout.flags`, using the corresponding storage format
 from `layout.formats`.

 Data uploaded or mapped for each attribute must match the format selected in
 the layout.

 @param capacity : `maximum number of instances`
 @param layout : `instance layout describing enabled attributes and formats`
 @return `initialized instance buffer, or an empty buffer on failure`
*>
extern fn R3DInstanceBuffer load_instance_buffer_ex(int capacity, R3DInstanceLayout layout) @cname("R3D_LoadInstanceBufferEx");

<*
 Destroy all GPU buffers owned by this instance buffer.

 @param buffer : `instance buffer to unload`
*>
extern fn void unload_instance_buffer(R3DInstanceBuffer buffer) @cname("R3D_UnloadInstanceBuffer");

<*
 Grow the GPU buffers of an instance buffer to a new capacity.

 Only expands; if new_capacity <= buffer.capacity the call is a no-op.
 All attribute buffers present in buffer.flags are reallocated and
 if keep_data is true, their existing content is copied to the new
 buffers before the old ones are deleted.

 @param buffer : `instance buffer to resize (updated in place)`
 @param new_capacity : `desired minimum capacity in number of instances`
 @param keep_data : `if true, preserves existing instance data`
*>
extern fn void resize_instance_buffer(R3DInstanceBuffer* buffer, int new_capacity, bool keep_data) @cname("R3D_ResizeInstanceBuffer");

<*
 Upload a contiguous range of instance data to a GPU buffer.

 @param buffer : `instance buffer containing the target GPU buffer`
 @param flag : `attribute to update (single bit)`
 @param offset : `first instance index`
 @param count : `number of instances to upload`
 @param data : `source data pointer`
 @param discard : `if true, the entire GPU buffer is orphaned before upload, avoiding a GPU/CPU sync at the cost of discarding existing data. Safe to use when rewriting the full buffer each frame`
*>
extern fn void upload_instances(R3DInstanceBuffer buffer, R3DInstanceFlags flag, int offset, int count, void* data, bool discard) @cname("R3D_UploadInstances");

<*
 Map an entire attribute buffer for CPU write access.

 Call unmap_instances when done writing.

 @param buffer : `instance buffer containing the target GPU buffer`
 @param flag : `attribute to map (single bit)`
 @param discard : `if true, existing buffer contents are invalidated, allowing the driver to return a fresh memory region without stalling on in-flight GPU reads`
 @return `writable pointer to the full buffer, or NULL on error`
*>
extern fn void* map_instances(R3DInstanceBuffer buffer, R3DInstanceFlags flag, bool discard) @cname("R3D_MapInstances");

<*
 Map a sub-range of an attribute buffer for CPU write access.

 Prefer this over map_instances for partial updates to avoid
 touching unrelated data. Call unmap_instances when done writing.

 @param buffer : `instance buffer containing the target GPU buffer`
 @param flag : `attribute to map (single bit)`
 @param offset : `first instance index of the mapped range`
 @param count : `number of instances to map`
 @param discard : `if true, the mapped range is invalidated, allowing the driver to skip syncing that region with in-flight GPU reads`
 @return `writable pointer to the mapped range, or NULL on error`
*>
extern fn void* map_instances_ex(R3DInstanceBuffer buffer, R3DInstanceFlags flag, int offset, int count, bool discard) @cname("R3D_MapInstancesEx");

<*
 Unmap one or more previously mapped attribute buffers.

 @param buffer : `instance buffer containing the target GPU buffers`
 @param flags : `bitmask of attributes to unmap`
*>
extern fn void unmap_instances(R3DInstanceBuffer buffer, R3DInstanceFlags flags) @cname("R3D_UnmapInstances");

<*
 Sets the storage format of an instance attribute in a layout.

 `attribute` must be a single instance attribute flag, such as
 `position`, not a combination of multiple flags.

 This function only changes the format stored in the layout. It does not
 enable the attribute in `layout.flags`.

 @param layout : `layout to modify`
 @param attribute : `single attribute flag to modify`
 @param format : `new storage format`
*>
extern fn void set_instance_format(R3DInstanceLayout* layout, R3DInstanceFlags attribute, R3DInstanceFormat format) @cname("R3D_SetInstanceFormat");

<*
 Gets the storage format of an instance attribute from a layout.

 `attribute` must be a single instance attribute flag, such as
 `position`, not a combination of multiple flags.

 @param layout : `layout to read from`
 @param attribute : `single attribute flag to query`
 @return `storage format of the requested attribute, or FLOAT32 if the attribute flag is invalid`
*>
extern fn R3DInstanceFormat get_instance_format(R3DInstanceLayout layout, R3DInstanceFlags attribute) @cname("R3D_GetInstanceFormat");
