const std = @import("std");
const engine = @import("_2d_engine_3").engine;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});
    const opts = .{ .target = target, .optimize = optimize };
    const raylib_dep = b.dependency("raylib_zig", opts);

    const raylib = raylib_dep.module("raylib");
    const raylib_artifact = raylib_dep.artifact("raylib");

    const engine_mod = engine.addModule(
        b,
        .{
            .entities = &[_]engine.Entity{
                .{ .scripts = &[_]engine.Script{
                    engine.getScript("src/UI.zig", engine.ParamList({}), b.allocator),
                    engine.getScript(
                        "src/container.zig",
                        engine.ParamList(.{
                            engine.Param(engine.ParamList(.{
                                engine.Param(u32, "x", 50),
                                engine.Param(u32, "y", 50),
                                engine.Param(u32, "width", 150),
                                engine.Param(u32, "height", 150),
                            }), "rect", .{}),
                            engine.Param(enum { inspector }, "type", .inspector),
                        }),
                        b.allocator,
                    ),
                    engine.getScript(
                        "src/inspector.zig",
                        engine.Param(engine.ParamList(.{
                            engine.Param(u32, "w", 100),
                            engine.Param(u32, "h", 100),
                        }), "size", .{}),
                        b.allocator,
                    ),
                } },
            },
        },
        &[_]std.Build.Module.Import{.{ .module = raylib, .name = "raylib" }},
        "engine",
        opts,
    );

    const exe = b.addExecutable(.{
        .name = "2e3_editor",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);
    exe.root_module.addImport("engine", engine_mod.module);

    const install_step = b.addInstallArtifact(exe, .{});
    install_step.step.dependOn(engine_mod.step);
    b.getInstallStep().dependOn(&install_step.step);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
