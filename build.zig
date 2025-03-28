const std = @import("std");
const engine = @import("engine.zig");

pub fn build(b: *std.Build) void {
    const text = engine.makeScene(b.allocator, .{
        .entities = &[_]engine.Entity{
            .{ .scripts = &[_]engine.Script{
                engine.getScript("src/script.zig", engine.ParamList({}), b.allocator),
            } },
            .{
                .scripts = &[_]engine.Script{
                    engine.getScript("src/script.zig", .{ .position = .{ .y = 450, .x = 0 }, .size = .{ .x = 800, .y = 1 } }, b.allocator),
                    engine.getScript("src/physics.zig", .{ .g = 0 }, b.allocator),
                },
            },
        },
    });
    var wf = b.addWriteFile(std.mem.join(b.allocator, std.fs.path.sep_str, ([_][]const u8{ b.cache_root.path.?, "gen" })[0..]) catch unreachable, text);
    b.getInstallStep().dependOn(&wf.step);
}
