const std = @import("std");
const rl = @import("raylib");
const tmp = @import("engine");

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "Editor");
    defer rl.closeWindow();

    rl.setWindowState(.{ .window_resizable = true });

    var Scene = tmp{};
    Scene.init();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);
        Scene.update();
        Scene.render();
    }
}
