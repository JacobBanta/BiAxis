const rl = @import("raylib");
const std = @import("std");
const SIZE = 150;
files: std.BoundedArray([:0]const u8, 30) = undefined,
filePaths: std.BoundedArray([:0]const u8, 30) = undefined,
fileLayout: i32 = 0,
path: [:0]const u8 = "",
fileSelected: ?i32 = null,

size: struct {
    w: i32 = 0,
    h: i32 = 0,
} = .{},

pub fn init(self: *@This()) void {
    var walker = (std.fs.cwd().openDir("./", .{ .iterate = true }) catch unreachable).walk(std.heap.page_allocator) catch unreachable;
    self.files = std.BoundedArray([:0]const u8, 30).init(0) catch unreachable;
    self.filePaths = std.BoundedArray([:0]const u8, 30).init(0) catch unreachable;
    while (walker.next() catch unreachable) |i| {
        if (std.mem.indexOf(u8, i.path, ".zig-cache") != null) continue;
        if (std.mem.indexOf(u8, i.path, "zig-out") != null) continue;
        if (std.mem.indexOf(u8, i.path, ".git") != null) continue;
        self.files.append(std.heap.page_allocator.dupeZ(u8, i.basename) catch unreachable) catch unreachable;
        self.filePaths.append(std.heap.page_allocator.dupeZ(u8, i.path) catch unreachable) catch unreachable;
    }
}

pub fn leftClickEvent(self: *@This(), x: i32, y: i32) void {
    const fileSelected = @divFloor(x, SIZE) + @divFloor(y - topTextSize, SIZE) * self.fileLayout;
    if (fileSelected >= 0) {
        if (self.fileSelected) |f| {
            if (f == fileSelected) {
                self.path = self.getFile(f);
                self.fileSelected = null;
            } else {
                self.fileSelected = fileSelected;
            }
        } else {
            self.fileSelected = fileSelected;
        }
    } else {
        if (self.fileSelected) |f| {
            if (f == fileSelected) {
                // TODO: buncha math
                // this is for selecting the folder in the top display
                self.fileSelected = null;
            } else {
                self.fileSelected = fileSelected;
            }
        } else {
            self.fileSelected = fileSelected;
        }
    }
}

pub fn getFile(self: @This(), file: i32) [:0]const u8 {
    var index: i32 = 0;
    for (self.filePaths.slice()) |f| {
        if (std.mem.indexOf(u8, f, self.path)) |i| {
            if (i != 0) continue;
            if (f.len == self.path.len) continue;
        } else continue;
        if (std.mem.indexOf(u8, f[self.path.len + 1 ..], std.fs.path.sep_str) != null) continue;
        if (index == file) return f;
        index += 1;
    }
    return "";
}

pub fn resizeEvent(self: *@This(), w: i32, h: i32) void {
    self.size.w = w;
    self.size.h = h;
    self.fileLayout = @intCast(@divFloor(w, SIZE));
}

const topTextSize = 30;
pub fn render_(self: @This(), offsetX: i32, offsetY: i32) void {
    rl.drawRectangle(offsetX, offsetY, self.size.w, self.size.h, rl.Color.dark_gray);
    var index: i32 = 0;
    for (self.filePaths.slice()) |f| {
        if (std.mem.indexOf(u8, f, self.path)) |i| {
            if (i != 0) continue;
            if (f.len == self.path.len) continue;
        } else continue;
        if (std.mem.indexOf(u8, f[self.path.len + 1 ..], std.fs.path.sep_str) != null) continue;
        rl.drawRectangle(2 + offsetX + @mod(index, self.fileLayout) * SIZE, 2 + offsetY + topTextSize + @divFloor(index, self.fileLayout) * SIZE, SIZE - 4, SIZE - 4, rl.Color.black);
        if (self.fileSelected) |i| {
            if (index == i) {
                rl.drawRectangleLines(1 + offsetX + @mod(index, self.fileLayout) * SIZE, 1 + offsetY + topTextSize + @divFloor(index, self.fileLayout) * SIZE, SIZE - 2, SIZE - 2, rl.Color.orange);
            }
        }
        const xSize = rl.measureText(f[self.path.len..], 20);
        rl.drawText(f[if (self.path.len == 0) 0 else self.path.len + 1..], offsetX + @mod(index, self.fileLayout) * SIZE + 3 + @divFloor(SIZE - xSize, 2), offsetY + topTextSize + 3 + @divFloor(index, self.fileLayout) * SIZE, 20, rl.Color.white);
        index += 1;
    }

    var it = std.mem.splitSequence(u8, self.path, std.fs.path.sep_str);
    var x: i32 = 15;
    while (it.next()) |i| {
        if (i.len == 0) continue;
        const text = std.heap.page_allocator.dupeZ(u8, i) catch unreachable;
        defer std.heap.page_allocator.free(text);
        rl.drawText(text, x, offsetY, 20, rl.Color.white);
        x += rl.measureText(text, 20) + 15;
    }
}
