const std = @import("std");
pub const BiAxis = @import("engine.zig");

pub fn build(b: *std.Build) void {
    const s = BiAxis.Scene{
        .entities = &[_]BiAxis.Entity{
            .{ .scripts = &[_]BiAxis.Script{
                BiAxis.getScript("src/script.zig", BiAxis.ParamList({}), b.allocator),
            } },
            .{
                .scripts = &[_]BiAxis.Script{
                    BiAxis.getScript("src/script.zig", .{ .position = .{ .y = 450, .x = 0 }, .size = .{ .x = 800, .y = 1 } }, b.allocator),
                    BiAxis.getScript("src/physics.zig", .{ .g = 0 }, b.allocator),
                },
            },
        },
    };
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const opts = .{ .target = target, .optimize = optimize };
    const zon_tool = (b.lazyDependency("zon_tool", opts) orelse return).module("zon_tool");
    const e = BiAxis.addModule(b, s, &[_]std.Build.Module.Import{
        .{ .module = zon_tool, .name = "zon_tool" },
    }, "BiAxis", opts);
    b.getInstallStep().dependOn(e.step);
}
