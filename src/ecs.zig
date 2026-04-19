// This is a simple ECS
const std = @import("std");
const Entity = @import("entity.zig").Entity;
const System = @import("Systems/system.zig").System;
const Components = @import("Components/components.zig").Components;
const expect = std.testing.expect;

pub const ECS = struct {
    arena: std.heap.ArenaAllocator,
    entity_count: u32 = 0,
    entities: std.AutoHashMap(u32, Entity),
    systems: std.ArrayList(System),

    // Allows me to choose the specific allocator
    pub fn init(allocator: std.mem.Allocator) ECS {
        const arena = std.heap.ArenaAllocator.init(allocator);

        return .{
            .arena = arena,
            .entities = std.AutoHashMap(u32, Entity).init(allocator),
            .systems = std.ArrayList(System).empty,
        };
    }

    pub fn initSystems(self: *ECS) void {
        for (self.systems.items) |sys| {
            sys.init();
        }
    }

    pub fn deinit(self: *ECS) void {
        for (self.systems.items) |sys| {
            sys.deinit();
        }
        self.entities.deinit();
        self.systems.deinit(self.arena.allocator());
        self.arena.deinit();
    }

    pub fn update(self: *ECS, delta_time: f32) !void {
        for (self.systems.items) |system| {
            try system.update(delta_time);
        }
    }

    pub fn addSystem(self: *ECS, system: System) !void {
        try self.systems.append(self.getAllocator(), system);
    }

    pub fn createEntity(self: *ECS) !*Entity {
        const ent: Entity = .{
            .eid = self.entity_count,
        };

        try self.entities.put(ent.eid, ent);
        self.entity_count += 1;
        return self.entities.getPtr(ent.eid).?;
    }

    pub fn destroyEntity(self: *ECS, eid: u32) bool {
        return self.entities.remove(eid);
    }

    pub fn getEntity(self: *ECS, eid: u32) ?*Entity {
        return self.entities.getPtr(eid);
    }

    pub fn getAllocator(self: *ECS) std.mem.Allocator {
        return self.arena.allocator();
    }

    pub fn addComponent(self: *ECS, entity: *Entity, component: anytype) !bool {
        const component_type = @TypeOf(component);
        inline for (std.meta.fields(Components)) |f| {
            if (@typeInfo(f.type) == .optional) {
                const current_component_type = @typeInfo(f.type).optional.child;
                if (current_component_type == component_type) {
                    @field(entity.components, f.name) = component;

                    // This notifies systems of a change in an entity
                    for (self.systems.items) |system| {
                        try system.addEntity(entity.eid);
                    }
                    return true;
                }
            }
        }
        return false;
    }
    // This is how I would with optional pointers, I'm just going to use values
    // const component_ptr = @constCast(component);
    // const component_type = @TypeOf(component_ptr);
    // std.debug.print("Component type: {}\n", .{component_type});
    //
    // inline for (std.meta.fields(Components)) |f| {
    //     const field_type = f.type;
    //     std.debug.print("Field: {s}, type: {}\n", .{ f.name, field_type });
    //
    //     // If field is optional and its child matches the component type
    //     if (@typeInfo(field_type) == .optional) {
    //         const child_type = @typeInfo(field_type).optional.child;
    //         std.debug.print("Optional Child type: {}\n", .{child_type});
    //
    //         if (child_type == component_type) {
    //             // Assign directly - Zig handles the optional wrapping
    //             @field(entity.*.components, f.name) = component_ptr;
    //             for (self.systems.items) |system| {
    //                 try system.addEntity(entity.*);
    //             }
    //         }
    //         return true;
    //     }
    // }
    // return false;
};

// =================== TESTS ===================

test "create entity" {
    var ecs: ECS = ECS.init(std.testing.allocator);
    defer ecs.deinit();

    const ent: Entity = try ecs.createEntity();
    try expect(ent.eid == 0);
}

test "delete entity" {
    var ecs: ECS = ECS.init(std.testing.allocator);
    defer ecs.deinit();

    const ent: Entity = try ecs.createEntity();
    try expect(ecs.destroyEntity(ent.eid));
    try expect(ecs.getEntity(ent.eid) == null);
}

test "get entity by id" {
    var ecs: ECS = ECS.init(std.testing.allocator);
    defer ecs.deinit();

    const ent: Entity = try ecs.createEntity();
    const retrieved: ?*Entity = ecs.getEntity(ent.eid);
    try expect(retrieved != null);
    try expect(retrieved.?.eid == 0);

    const non_existent = ecs.getEntity(999);
    try expect(non_existent == null);
}

test "adding component" {
    const Transform2 = @import("Components/transform2.zig").Transform2;
    var ecs: ECS = ECS.init(std.testing.allocator);
    defer ecs.deinit();

    const transform_2d: Transform2 = .{
        .pos = .{ .x = 10.0, .y = 0.0 },
    };

    var ent: Entity = try ecs.createEntity();
    try expect(try ecs.addComponent(&ent, transform_2d));
    try expect(ent.components.transform_2d != null);
    try expect(ent.components.transform_2d.?.pos.x == 10.0);
}
