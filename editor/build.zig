const std = @import("std");
const BiAxis = @import("BiAxis").BiAxis;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});
    const opts = .{ .target = target, .optimize = optimize };
    const raylib_dep = b.dependency("raylib_zig", opts);

    const raylib = raylib_dep.module("raylib");
    const raylib_artifact = raylib_dep.artifact("raylib");

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // add the zon tool module to the engine
    const zon_tool = b.dependency("zon_tool", opts).module("zon_tool");

    const BiAxis_mod = BiAxis.addModule(b, .{
        .entities = &[_]BiAxis.Entity{
            .{
                .scripts = &[_]BiAxis.Script{
                    BiAxis.getScript("src/UI.zig", BiAxis.ParamList({}), b.allocator),
                    BiAxis.getScript("src/container.zig", BiAxis.ParamList(.{
                        BiAxis.Param(BiAxis.ParamList(.{
                            BiAxis.Param(u32, "x", 50),
                            BiAxis.Param(u32, "y", 50),
                            BiAxis.Param(u32, "width", 150),
                            BiAxis.Param(u32, "height", 150),
                        }), "rect", .{}),
                        BiAxis.Param(enum { inspector }, "type", .inspector),
                        BiAxis.Param(BiAxis.ParamList(.{
                            BiAxis.Param(enum { side }, "right", .side),
                            BiAxis.Param(union(enum) { percentage: f32 }, "left", .{ .percentage = 0.8 }),
                            BiAxis.Param(enum { side }, "down", .side),
                            BiAxis.Param(union(enum) { fixed: i32 }, "up", .{ .fixed = 20 }),
                        }), "anchors", .{}),
                    }), b.allocator),
                    BiAxis.getScript(
                        "src/inspector.zig",
                        BiAxis.Param(BiAxis.ParamList(.{
                            BiAxis.Param(u32, "w", 100),
                            BiAxis.Param(u32, "h", 100),
                        }), "size", .{}),
                        b.allocator,
                    ),
                    BiAxis.getScript("src/container.zig", BiAxis.ParamList(.{
                        BiAxis.Param(BiAxis.ParamList(.{
                            BiAxis.Param(u32, "x", 300),
                            BiAxis.Param(u32, "y", 75),
                            BiAxis.Param(u32, "width", 150),
                            BiAxis.Param(u32, "height", 150),
                        }), "rect", .{}),
                        BiAxis.Param(enum { fileBrowser }, "type", .fileBrowser),
                        BiAxis.Param(BiAxis.ParamList(.{
                            BiAxis.Param(enum { side }, "left", .side),
                            BiAxis.Param(union(enum) { percentage: f32 }, "right", .{ .percentage = 0.2 }),
                            BiAxis.Param(enum { side }, "down", .side),
                            BiAxis.Param(union(enum) { percentage: f32 }, "up", .{ .percentage = 0.7 }),
                        }), "anchors", .{}),
                    }), b.allocator),
                    BiAxis.getScript(
                        "src/fileBrowser.zig",
                        BiAxis.ParamList({}),
                        b.allocator,
                    ),
                },
            },
        },
    }, &[_]std.Build.Module.Import{
        .{ .module = raylib, .name = "raylib" },
        .{ .module = zon_tool, .name = "zon_tool" },
    }, "editor_gen", opts);

    const exe = b.addExecutable(.{
        .name = "BiAxis_editor",
        .root_module = exe_mod,
    });

    exe.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);
    exe.root_module.addImport("editor", BiAxis_mod.module);

    const install_step = b.addInstallArtifact(exe, .{});
    install_step.step.dependOn(BiAxis_mod.step);
    b.getInstallStep().dependOn(&install_step.step);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
