const std = @import("std");
const rl = @import("raylib");
const Scene = @import("scene.zig").Scene;
const Entity = @import("../entity.zig").Entity;
const Transform2 = @import("../Components/transform2.zig").Transform2;
const Texture = @import("../Components/texture.zig").Texture;
const ECS = @import("../ecs.zig").ECS;

pub const PlayerScene = struct {
    ecs: *ECS,
    ents: std.AutoHashMap(u32, void),
    player: u32 = 0,

    // confusing naming convention lol
    pub fn setup(ecs: *ECS, allocator: std.mem.Allocator) PlayerScene {
        return .{
            .ecs = ecs,
            .ents = std.AutoHashMap(u32, void).init(allocator),
        };
    }

    // ========== Implementations =========
    pub fn init(ctx: *anyopaque) !void {
        const self: *PlayerScene = @ptrCast(@alignCast(ctx));

        const ent: *Entity = try self.ecs.createEntity();
        _ = try self.ecs.addComponent(ent, Texture{
            .img_path = "resources/test.png",
        });
        _ = try self.ecs.addComponent(ent, Transform2{
            .pos = rl.Vector2{ .x = 50.0, .y = 50.0 },
            .rot = 45.0,
        });

        self.player = ent.eid;
        try self.ents.put(ent.eid, {});
    }

    pub fn deinit(ctx: *anyopaque) void {
        const self: *PlayerScene = @ptrCast(@alignCast(ctx));
        self.ents.deinit();
    }

    pub fn update(ctx: *anyopaque, delta_time: f32) !void {
        const self: *PlayerScene = @ptrCast(@alignCast(ctx));

        const ent: ?*Entity = self.ecs.getEntity(self.player);
        if (ent == null) return;

        var pos = &ent.?.components.transform_2d.?.pos;
        pos.x += delta_time * 5.0;
    }

    pub fn create(self: *PlayerScene) Scene {
        return Scene{ .ptr = self, .impl = &.{
            .init = init,
            .deinit = deinit,
            .update = update,
        } };
    }
};
