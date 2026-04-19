// Abstract Scene
pub const Scene = struct {
    ptr: *anyopaque,
    impl: *const Interface,

    // ctx = context :)
    pub const Interface = struct {
        init: *const fn (ctx: *anyopaque) anyerror!void,
        deinit: *const fn (ctx: *anyopaque) void,
        update: *const fn (ctx: *anyopaque, delta_time: f32) anyerror!void,
    };

    // This is for anything the system needs to initalize
    pub fn init(self: Scene) !void {
        return self.impl.init(self.ptr);
    }

    pub fn deinit(self: Scene) void {
        return self.impl.deinit(self.ptr);
    }

    pub fn update(self: Scene, delta_time: f32) !void {
        return self.impl.update(self.ptr, delta_time);
    }
};
