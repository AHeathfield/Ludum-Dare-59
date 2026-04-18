// This is a simple ECS
const std = @import("std");
const comps = @import("Components/components.zig");
const expect = std.testing.expect;

// This stores all the entities and has methods to create and get them and add components
pub const ECS = struct {
    allocator: std.mem.Allocator,
    entity_count: u32 = 0,
    entities: std.AutoHashMap(u32, Entity),
    systems: std.ArrayList(System),

    pub fn init(allocator: std.mem.Allocator) ECS {
        return .{
            .allocator = allocator,
            .entities = std.AutoHashMap(u32, Entity).init(allocator),
            .systems = std.ArrayList(System).empty,
        };
    }

    pub fn deinit(self: *ECS) void {
        self.entities.deinit();
        self.systems.deinit(self.allocator);
    }

    pub fn createEntity(self: *ECS) !Entity {
        const ent: Entity = .{
            .eid = self.entity_count,
        };

        try self.entities.put(ent.eid, ent);
        self.entity_count += 1;
        return ent;
    }

    pub fn destroyEntity(self: *ECS, eid: u32) bool {
        return self.entities.remove(eid);
    }

    pub fn getEntity(self: *ECS, eid: u32) ?*Entity {
        return self.entities.getPtr(eid);
    }

    pub fn addComponent(self: *ECS, entity: *Entity, component: anytype) bool {
        _ = self;
        const current_comps: Components = entity.*.components;
        var new_component = @constCast(&component);
        _ = &new_component;

        inline for (std.meta.fields(@TypeOf(current_comps))) |f| {
            if (std.meta.eql(f.type, ?@TypeOf(new_component))) {
                @field(entity.*.components, f.name) = new_component;
                // std.debug.print("The component should be added!\n", .{});
                return true;
            }
        }

        return false;
    }
};

const Components = struct {
    position_2d: ?*comps.Position2D = null,
};

pub const Entity = struct {
    eid: u32,
    components: Components = .{},
};

// System interface
pub const System = struct {
    ptr: *anyopaque,
    impl: *const Interface,

    // ctx = context :)
    pub const Interface = struct {
        update: *const fn (ctx: *anyopaque, delta_time: f32) void,
        add_entity: *const fn (ctx: *anyopaque, eid: u32) void,
    };

    pub fn update(self: System, delta_time: f32) void {
        return self.impl.update(self.ptr, delta_time);
    }

    pub fn add_entity(self: System, eid: u32) void {
        return self.impl.add_entity(self.ptr, eid);
    }
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
    var ecs: ECS = ECS.init(std.testing.allocator);
    defer ecs.deinit();

    const pos: comps.Position2D = .{
        .x = 10.0,
        .y = 0.0,
    };

    var ent: Entity = try ecs.createEntity();
    try expect(ecs.addComponent(&ent, pos));
    try expect(ent.components.position_2d != null);
    try expect(ent.components.position_2d.?.x == 10.0);
}
