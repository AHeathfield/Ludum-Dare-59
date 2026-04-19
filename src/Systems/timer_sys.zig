const std = @import("std");
const System = @import("system.zig").System;
const Entity = @import("../entity.zig").Entity;
const ECS = @import("../ecs.zig").ECS;

pub const TimerSystem = struct {
    ecs: *ECS,
    ents: std.AutoHashMap(u32, void),

    // ======== Implementations =======
    pub fn init(ctx: *anyopaque) void {
        _ = ctx;
    }

    pub fn deinit(ctx: *anyopaque) void {
        const self: *TimerSystem = @ptrCast(@alignCast(ctx));
        self.ents.deinit();
    }

    pub fn update(ctx: *anyopaque, delta_time: f32) !void {
        const self: *TimerSystem = @ptrCast(@alignCast(ctx));

        var iterator = self.ents.iterator();
        while (iterator.next()) |entry| {
            const ent: ?*Entity = self.ecs.getEntity(entry.key_ptr.*);
            if (ent == null) continue;

            var timer_comp = &ent.?.components.timer.?;

            // Resetting looping timer
            if (timer_comp.is_finished and timer_comp.is_looping) {
                timer_comp.play();
            }

            // Increment timers
            if (!timer_comp.is_finished and !timer_comp.is_paused) {
                timer_comp.current_time += delta_time;
                // std.debug.print("Current time: {}\n", .{timer_comp.current_time});
            }

            // Check if any timers finished
            if (timer_comp.current_time >= timer_comp.max_time and timer_comp.is_finished == false) {
                timer_comp.current_time = timer_comp.max_time;
                timer_comp.is_finished = true;
                timer_comp.on_timeout(); // This runs the time out func
            }
        }
    }

    pub fn addEntity(ctx: *anyopaque, eid: u32) !void {
        const self: *TimerSystem = @ptrCast(@alignCast(ctx));

        const ent: ?*Entity = self.ecs.getEntity(eid);

        if (ent == null) return;
        if (ent.?.components.timer == null) return;

        // {} == void
        try self.ents.put(eid, {});
        std.debug.print("Entity added to timer sys\n", .{});
    }

    pub fn removeEntity(ctx: *anyopaque, eid: u32) void {
        const self: *TimerSystem = @ptrCast(@alignCast(ctx));
        _ = self.ents.remove(eid);
    }

    pub fn create(self: *TimerSystem) System {
        return System{ .ptr = self, .impl = &.{
            .init = init,
            .deinit = deinit,
            .update = update,
            .addEntity = addEntity,
            .removeEntity = removeEntity,
        } };
    }
};
