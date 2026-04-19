const std = @import("std");
const Entity = @import("../entity.zig").Entity;
const ECS = @import("../ecs.zig").ECS;

// System interface
pub const System = struct {
    ptr: *anyopaque,
    impl: *const Interface,

    // ctx = context :)
    pub const Interface = struct {
        init: *const fn (ctx: *anyopaque) void,
        deinit: *const fn (ctx: *anyopaque) void,
        update: *const fn (ctx: *anyopaque, delta_time: f32) anyerror!void,
        addEntity: *const fn (ctx: *anyopaque, eid: u32) anyerror!void,
        removeEntity: *const fn (ctx: *anyopaque, eid: u32) void,
    };

    // This is for anything the system needs to initalize
    pub fn init(self: System) void {
        self.impl.init(self.ptr);
    }

    pub fn deinit(self: System) void {
        return self.impl.deinit(self.ptr);
    }

    pub fn update(self: System, delta_time: f32) !void {
        return self.impl.update(self.ptr, delta_time);
    }

    pub fn addEntity(self: System, eid: u32) !void {
        return self.impl.addEntity(self.ptr, eid);
    }

    pub fn removeEntity(self: System, eid: u32) void {
        return self.impl.removeEntity(self.ptr, eid);
    }
};
