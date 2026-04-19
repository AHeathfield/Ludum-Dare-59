// This just contains all the components for easier access

const Transform2 = @import("transform2.zig").Transform2;
const Texture = @import("texture.zig").Texture;
const Timer = @import("timer.zig").Timer;

pub const Components = struct {
    transform_2d: ?Transform2 = null,
    texture: ?Texture = null,
    timer: ?Timer = null,
};
