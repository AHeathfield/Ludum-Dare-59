const rl = @import("raylib");

pub const Transform2 = struct {
    pos: rl.Vector2,
    rot: f32 = 0.0,
    scale: f32 = 1.0,
};
