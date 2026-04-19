// raylib-zig (c) Nikolas Wipper 2023

const rl = @import("raylib");
const std = @import("std");
const ECS = @import("ecs.zig").ECS;
const SceneManager = @import("Scenes/scene_manager.zig").SceneManager;
const systems = @import("Systems/all_systems.zig");
const Color = rl.Color;
const expect = std.testing.expect;

// Might be temp
const PlayerScene = @import("Scenes/player_scn.zig").PlayerScene;

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

    // Setting up SceneManager
    var scn_mgr: SceneManager = SceneManager.init(ecs.getAllocator());

    try scn_mgr.addScene(PlayerScene.create(@constCast(&PlayerScene.setup(&ecs, ecs.getAllocator()))));

    // try scn_mgr.addScene(PlayerScene.create(@constCast(&PlayerScene{
    //     .ecs = &ecs,
    //     .ents = std.AutoHashMap(u32, void).init(ecs.getAllocator()),
    // })));

    // Test entities
    // const Transform2 = @import("Components/transform2.zig").Transform2;
    // const Texture = @import("Components/texture.zig").Texture;
    // const Timer = @import("Components/timer.zig").Timer;
    // const Entity = @import("entity.zig").Entity;

    // _ = try ecs.addComponent(ent, Timer{
    //     .max_time = 10.0,
    //     .on_start = onTimerStart,
    //     .on_timeout = onTimerEnd,
    // });

    // ecs.getEntity(0).?.components.timer.?.play();

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        const delta_time: f32 = rl.getFrameTime();

        // Update
        try scn_mgr.update(delta_time);
        try ecs.update(delta_time);

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
    scn_mgr.deinit();
    ecs.deinit();
    rl.closeWindow();
}

fn setupSystems(ecs: *ECS) !void {
    const allocator = ecs.getAllocator();

    // Create on HEAP instead of stack or else the actual system will be
    // destroyed. The pointer to the actual system is what the ecs stores
    const timer_sys = try allocator.create(systems.TimerSystem);
    timer_sys.* = systems.TimerSystem{ .ecs = ecs, .ents = std.AutoHashMap(u32, void).init(allocator) };

    const render_sys = try allocator.create(systems.RenderSystem);
    render_sys.* = systems.RenderSystem{ .ecs = ecs, .ents = std.AutoHashMap(u32, void).init(allocator), .textures = std.StringHashMap(rl.Texture).init(allocator) };

    // Adding systems in correct order
    // NOTE: THE LAST SYSTEM ADDED SHOULD BE RENDER SYSTEM!!!
    try ecs.addSystem(systems.TimerSystem.create(timer_sys));
    try ecs.addSystem(systems.RenderSystem.create(render_sys));

    // Calls the init func on all systems
    ecs.initSystems();
}

// TEST FUNCS FOR TIMER
pub fn onTimerStart() void {
    std.debug.print("Timer started!!\n", .{});
}

pub fn onTimerEnd() void {
    std.debug.print("Timer ended!!\n", .{});
}
