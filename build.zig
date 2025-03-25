const std = @import("std");
const engine = @import("engine.zig");

pub fn build(b: *std.Build) void {
    _ = engine.getZon(b, .{ .x = 4, .y = 4 });
}
