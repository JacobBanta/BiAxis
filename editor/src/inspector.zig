const rl = @import("raylib");
const std = @import("std");

size: struct {
    w: i32 = 0,
    h: i32 = 0,
} = .{},

pub fn leftClickEvent(self: *@This(), x: i32, y: i32) void {
    _ = self;
    std.debug.print("click: {d}, {d}\n", .{ x, y });
}

pub fn resizeEvent(self: *@This(), w: i32, h: i32) void {
    self.size.w = w;
    self.size.h = h;
}

pub fn render_(self: @This(), offsetX: i32, offsetY: i32) void {
    rl.drawRectangle(offsetX, offsetY, self.size.w, self.size.h, rl.Color.black);
}
