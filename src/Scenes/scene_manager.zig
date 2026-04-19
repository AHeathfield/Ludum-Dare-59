const std = @import("std");
const Scene = @import("scene.zig").Scene;

pub const SceneManager = struct {
    allocator: std.mem.Allocator,
    scenes: std.ArrayList(Scene),

    pub fn init(allocator: std.mem.Allocator) SceneManager {
        return .{
            .allocator = allocator,
            .scenes = std.ArrayList(Scene).empty,
        };
    }

    pub fn deinit(self: *SceneManager) void {
        for (self.scenes.items) |scn| {
            scn.deinit();
        }
        self.scenes.deinit(self.allocator);
    }

    pub fn update(self: *SceneManager, delta_time: f32) !void {
        for (self.scenes.items) |scn| {
            try scn.update(delta_time);
        }
    }

    pub fn addScene(self: *SceneManager, scene: Scene) !void {
        try self.scenes.append(self.allocator, scene);
        try self.scenes.getLast().init();
    }
};
