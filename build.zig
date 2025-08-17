const std = @import("std");
pub const engine = @import("engine.zig");

pub fn build(b: *std.Build) void {
    const s = engine.Scene{
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
    };
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const opts = .{ .target = target, .optimize = optimize };
    const zon_tool = (b.lazyDependency("zon_tool", opts) orelse return).module("zon_tool");
    const e = engine.addModule(b, s, &[_]std.Build.Module.Import{
        .{ .module = zon_tool, .name = "zon_tool" },
    }, "engine", opts);
    b.getInstallStep().dependOn(e.step);
}
