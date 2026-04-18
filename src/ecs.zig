// This is a simple ECS
const std = @import("std");
const comps = @import("Components/components.zig");
const ComponentType = comps.ComponentType;
const expect = std.testing.expect;

var entity_count: u32 = 0;

const Components = struct {
    position_2d: ?*comps.Position2D = null,
};

// has an entity id and contains components
pub const Entity = struct {
    eid: u32,
    components: Components = .{},
};

pub fn addComponent(entity: *Entity, component: anytype) bool {
    const current_comps: Components = entity.*.components;
    // std.debug.print("component type: {}\n", .{@TypeOf(&component)});
    var new_component = @constCast(&component);
    _ = &new_component;

    inline for (std.meta.fields(@TypeOf(current_comps))) |f| {
        // std.debug.print(f.name ++ "\n", .{});
        // std.debug.print(@typeName(f.type) ++ "\n", .{});
        // std.debug.print("{}\n", .{@TypeOf(@constCast(&component))});
        if (std.meta.eql(f.type, ?@TypeOf(new_component))) {
            // var field = @field(current_comps, f.name);
            // var field = @field(entity.*.components, f.name);
            // std.debug.print("{}\n", .{@TypeOf(field)});
            std.debug.print("{}\n", .{@TypeOf(new_component)});
            @field(entity.*.components, f.name) = new_component;
            if (entity.*.components.position_2d == null) {
                std.debug.print("BADDDDD\n", .{});
            }
            std.debug.print("The component should be added!\n", .{});
            return true;
        }
    }

    return false;
}

pub fn createEntity() Entity {
    const ent: Entity = .{
        .eid = entity_count,
    };
    entity_count += 1;
    return ent;
}

test "adding component" {
    const pos: comps.Position2D = .{
        .x = 10.0,
        .y = 0.0,
    };

    var ent: Entity = createEntity();
    try expect(addComponent(&ent, pos));
    try expect(ent.components.position_2d != null);
    std.debug.print("{}\n", .{ent.components.position_2d.?.*.x});
}
