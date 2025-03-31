const rl = @import("raylib");
const std = @import("std");

size: struct {
    w: u32 = 0,
    h: u32 = 0,
} = .{},

pub fn leftClickEvent(self: *@This(), x: u32, y: u32) void {
    _ = self;
    std.debug.print("click: {d}, {d}\n", .{ x, y });
}

pub fn resizeEvent(self: *@This(), w: u32, h: u32) void {
    self.size.w = w;
    self.size.h = h;
}
