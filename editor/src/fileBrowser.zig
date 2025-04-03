const rl = @import("raylib");
const std = @import("std");
files: std.BoundedArray([:0]const u8, 30) = undefined,
size: struct {
    w: i32 = 0,
    h: i32 = 0,
} = .{},

pub fn init(self: *@This()) void {
    var walker = (std.fs.cwd().openDir("./", .{ .iterate = true }) catch unreachable).walk(std.heap.page_allocator) catch unreachable;
    self.files = std.BoundedArray([:0]const u8, 30).init(0) catch unreachable;
    while (walker.next() catch unreachable) |i| {
        if (std.mem.indexOf(u8, i.path, ".zig-cache") != null) continue;
        if (std.mem.indexOf(u8, i.path, "zig-out") != null) continue;
        if (std.mem.indexOf(u8, i.path, ".git") != null) continue;
        self.files.append(std.heap.page_allocator.dupeZ(u8, i.basename) catch unreachable) catch unreachable;
    }
}

pub fn leftClickEvent(self: *@This(), x: i32, y: i32) void {
    std.debug.print("click: {d}, {d}\n", .{ x, y });
    std.debug.print("{s}\n", .{self.files.get(0)});
}

pub fn resizeEvent(self: *@This(), w: i32, h: i32) void {
    self.size.w = w;
    self.size.h = h;
}

pub fn render_(self: @This(), offsetX: i32, offsetY: i32) void {
    rl.drawRectangle(offsetX, offsetY, self.size.w, self.size.h, rl.Color.red);
    for (self.files.slice(), 0..) |file, index| {
        rl.drawText(file, offsetX, offsetY + @as(i32, @intCast(index)) * 20, 20, rl.Color.black);
    }
}
