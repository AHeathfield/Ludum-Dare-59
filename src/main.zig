// raylib-zig (c) Nikolas Wipper 2023

const rl = @import("raylib");
const std = @import("std");
const ECS = @import("ecs.zig").ECS;
const systems = @import("Systems/system.zig");
const Color = rl.Color;
const expect = std.testing.expect;

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");

    // const test_texture: Texture = try Texture.create("resources/test.png");

    // var current_fps: i32 = 60;
    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Setting up the allocator see the documentation for how to decide https://ziglang.org/documentation/master/#Choosing-an-Allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Setting up ECS
    var ecs: ECS = ECS.init(allocator);
    try setupSystems(&ecs);

    // Test entities
    const Transform2 = @import("Components/transform2.zig").Transform2;
    const Texture = @import("Components/texture.zig").Texture;
    const Entity = @import("entity.zig").Entity;

    const ent: *Entity = try ecs.createEntity();
    _ = try ecs.addComponent(ent, Texture{
        .img_path = "resources/test.png",
    });
    _ = try ecs.addComponent(ent, Transform2{
        .pos = rl.Vector2{ .x = 50.0, .y = 50.0 },
        .rot = 45.0,
    });

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        try ecs.update(rl.getFrameTime());

        // Draw
        //----------------------------------------------------------------------------------
        // rl.beginDrawing();
        // rl.clearBackground(Color.white);
        // // rl.drawTexture(
        // //     test_texture.texture,
        // //     200 / 2,
        // //     190 / 2,
        // //     Color.white,
        // // );
        // // rl.drawTexture(
        // //     test_texture.texture,
        // //     0,
        // //     0,
        // //     Color.white,
        // // );
        //
        // // rl.drawText(@typeName(@TypeOf(test_texture)), 190, 200, 20, .light_gray);
        // rl.drawText("HIIII", 190, 200, 20, .light_gray);
        // //----------------------------------------------------------------------------------
        // rl.endDrawing();
    }

    // Deinits
    ecs.deinit();
    rl.closeWindow();
}

// NOTE: THE LAST SYSTEM ADDED SHOULD BE RENDER SYSTEM!!!
fn setupSystems(ecs: *ECS) !void {
    const allocator = ecs.getAllocator();

    // Create on HEAP instead of stack or else the actual render system will be destroyed
    // The pointer to the actual render system is what the ecs stores
    // (render_sys is a pointer)
    const render_sys = try allocator.create(systems.RenderSystem);
    render_sys.* = systems.RenderSystem{ .ecs = ecs, .ents = std.AutoHashMap(u32, void).init(allocator), .textures = std.StringHashMap(rl.Texture).init(allocator) };

    // Adding systems in correct order
    try ecs.addSystem(systems.RenderSystem.create(render_sys));

    // Calls the init func on all systems
    ecs.initSystems();
}
