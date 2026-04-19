const Components = @import("Components/components.zig").Components;

pub const Entity = struct {
    eid: u32,
    components: Components = .{},
};
