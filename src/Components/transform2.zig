const Vec2I = @import("../Math/vec2.zig").Vec2I;
const Vec2 = @import("../Math/vec2.zig").Vec2;

pub const Transform2 = struct {
    pos: Vec2I,
    rot: f32 = 0.0,
    scale: Vec2 = .{ .x = 1.0, .y = 1.0 },
};
