// The render system contains all textures
pub const Texture = struct {
    img_path: [:0]const u8,
    visible: bool = true,
};
