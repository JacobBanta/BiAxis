const std = @import("std");
const rl = @import("raylib");
const editor = @import("editor");

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "BiAxis Editor");
    defer rl.closeWindow();

    rl.setWindowState(.{ .window_resizable = true });

    var Scene = editor{};
    Scene.init();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);
        rl.drawFPS(0, 0);
        Scene.update();
        Scene.render();
    }
}
