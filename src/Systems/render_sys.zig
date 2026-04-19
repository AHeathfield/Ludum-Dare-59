const std = @import("std");
const rl = @import("raylib");
const System = @import("system.zig").System;
const Entity = @import("../entity.zig").Entity;
const ECS = @import("../ecs.zig").ECS;
const Color = rl.Color;

pub const RenderSystem = struct {
    ecs: *ECS,
    // arena: std.heap.ArenaAllocator, not needed anymore, use ECS to get allocator
    ents: std.AutoHashMap(u32, void),
    textures: std.StringHashMap(rl.Texture),

    // Lazy method where it will create texture if it's not in hashmap
    fn getTexture(self: *RenderSystem, img_path: [:0]const u8) !rl.Texture {
        if (self.textures.contains(img_path)) {
            const texture: ?rl.Texture = self.textures.get(img_path);
            std.debug.assert(texture != null);
            return texture.?;
        }

        // If texture hasn't been created yet
        const image = try rl.loadImage(img_path);
        const texture = try rl.loadTextureFromImage(image);
        // Once image has been converted to texture and uploaded to VRAM,
        // it can be unloaded from RAM
        rl.unloadImage(image);
        try self.textures.put(img_path, texture);
        return texture;
    }

    // ======== Implementations =======
    pub fn init(ctx: *anyopaque) void {
        _ = ctx;
        // const self: *RenderSystem = @ptrCast(@alignCast(ctx));
        // self.ecs = ecs;
        // self.allocator = allocator;
        // self.ents = std.AutoHashMap(u32, void).init(allocator);
    }

    // I don't think I need to actually do this since it should be freed with the ecs.deinit()
    pub fn deinit(ctx: *anyopaque) void {
        const self: *RenderSystem = @ptrCast(@alignCast(ctx));
        self.ents.deinit();

        // Close window and OpenGl context
        // rl.closeWindow();

        // Unloads all textures
        var iterator = self.textures.iterator();
        while (iterator.next()) |entry| {
            rl.unloadTexture(entry.value_ptr.*);
        }
        self.textures.deinit();
    }

    pub fn update(ctx: *anyopaque, delta_time: f32) !void {
        const self: *RenderSystem = @ptrCast(@alignCast(ctx));
        _ = delta_time;

        rl.beginDrawing();
        rl.clearBackground(Color.white);

        var iterator = self.ents.iterator();
        while (iterator.next()) |entry| {
            const ent: ?*Entity = self.ecs.getEntity(entry.key_ptr.*);
            if (ent == null) continue;

            // Safety check
            const transform_comp = ent.?.components.transform_2d;
            if (transform_comp == null) {
                std.debug.print("(RenderSystem) TRANSFORM IS NULL\n", .{});
                continue;
            }
            const texture_comp = ent.?.components.texture;
            if (texture_comp == null) {
                std.debug.print("(RenderSystem) TEXTURE IS NULL\n", .{});
                continue;
            }

            const texture: rl.Texture = try self.getTexture(texture_comp.?.img_path);

            rl.drawTextureEx(
                texture,
                transform_comp.?.pos,
                transform_comp.?.rot,
                transform_comp.?.scale,
                Color.white,
            );
        }

        // I think drawing text should be done by another system, if so we would end drawing there
        rl.endDrawing();
    }

    pub fn addEntity(ctx: *anyopaque, eid: u32) !void {
        const self: *RenderSystem = @ptrCast(@alignCast(ctx));

        const ent: ?*Entity = self.ecs.getEntity(eid);

        if (ent == null) return;
        if (ent.?.components.transform_2d == null) return;
        if (ent.?.components.texture == null) return;

        // {} == void
        try self.ents.put(eid, {});
        std.debug.print("Entity added to render sys\n", .{});
    }

    pub fn removeEntity(ctx: *anyopaque, eid: u32) void {
        const self: *RenderSystem = @ptrCast(@alignCast(ctx));
        _ = self.ents.remove(eid);
    }

    pub fn create(self: *RenderSystem) System {
        return System{ .ptr = self, .impl = &.{
            .init = init,
            .deinit = deinit,
            .update = update,
            .addEntity = addEntity,
            .removeEntity = removeEntity,
        } };
    }
};
