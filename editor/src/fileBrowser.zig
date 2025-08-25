const rl = @import("raylib");
const std = @import("std");
const SIZE = 150;
files: [30]?[:0]const u8 = undefined,
filePaths: [30]?[:0]const u8 = undefined,
fileLayout: i32 = 0,
path: [:0]const u8 = "",
fileSelected: ?i32 = null,

size: struct {
    w: i32 = 0,
    h: i32 = 0,
} = .{},

pub fn init(self: *@This()) void {
    var walker = (std.fs.cwd().openDir("./", .{ .iterate = true }) catch unreachable).walk(std.heap.page_allocator) catch unreachable;
    self.files = .{null} ** 30;
    self.filePaths = .{null} ** 30;
    while (walker.next() catch unreachable) |i| {
        if (std.mem.indexOf(u8, i.path, ".zig-cache") != null) continue;
        if (std.mem.indexOf(u8, i.path, "zig-out") != null) continue;
        if (std.mem.indexOf(u8, i.path, ".git") != null) continue;
        for (0..self.files.len) |j| {
            if (self.files[j]) |_| continue;

            self.files[j] = std.heap.page_allocator.dupeZ(u8, i.basename) catch unreachable;
            self.filePaths[j] = std.heap.page_allocator.dupeZ(u8, i.path) catch unreachable;
            break;
        }
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
        const path = self.getPath(x);
        if (self.fileSelected) |f| {
            if (f == path) {
                var index: i32 = 0;
                var chars: i32 = 0;
                var it = std.mem.splitSequence(u8, self.path, std.fs.path.sep_str);
                while (it.next()) |i| {
                    if (i.len == 0) continue;
                    index -= 1;
                    chars += @intCast(i.len + 1);
                    if (index == path) break;
                }
                for (self.filePaths, 0..) |f2, i| {
                    if (std.mem.eql(u8, f2 orelse break, self.path[0..@intCast(chars - 1)])) {
                        self.path = self.filePaths[i].?;
                    }
                }

                self.fileSelected = null;
            } else {
                self.fileSelected = path;
            }
        } else {
            self.fileSelected = path;
        }
    }
}

pub fn getFile(self: @This(), file: i32) [:0]const u8 {
    var index: i32 = 0;
    for (self.filePaths) |f| {
        if (std.mem.indexOf(u8, f orelse break, self.path)) |i| {
            if (i != 0) continue;
            if (f.?.len == self.path.len) continue;
        } else continue;
        if (std.mem.indexOf(u8, f.?[self.path.len + 1 ..], std.fs.path.sep_str) != null) continue;
        if (index == file) return f.?;
        index += 1;
    }
    return "";
}

pub fn getPath(self: @This(), x: i32) ?i32 {
    if (x < 8) return null;
    var newX: i32 = 8;
    var index: i32 = 0;
    var it = std.mem.splitSequence(u8, self.path, std.fs.path.sep_str);
    while (it.next()) |i| {
        if (i.len == 0) continue;
        index -= 1;
        const text = std.heap.page_allocator.dupeZ(u8, i) catch unreachable;
        defer std.heap.page_allocator.free(text);
        newX += rl.measureText(text, 20) + 15;
        if (x < newX) return index;
    }

    return null;
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
    for (self.filePaths) |f| {
        if (std.mem.indexOf(u8, f orelse break, self.path)) |i| {
            if (i != 0) continue;
            if (f.?.len == self.path.len) continue;
        } else continue;
        if (std.mem.indexOf(u8, f.?[self.path.len + 1 ..], std.fs.path.sep_str) != null) continue;
        rl.drawRectangle(2 + offsetX + @mod(index, self.fileLayout) * SIZE, 2 + offsetY + topTextSize + @divFloor(index, self.fileLayout) * SIZE, SIZE - 4, SIZE - 4, rl.Color.black);
        if (self.fileSelected) |i| {
            if (index == i) {
                rl.drawRectangleLines(1 + offsetX + @mod(index, self.fileLayout) * SIZE, 1 + offsetY + topTextSize + @divFloor(index, self.fileLayout) * SIZE, SIZE - 2, SIZE - 2, rl.Color.orange);
            }
        }
        var xSize = rl.measureText(f.?[if (self.path.len == 0) 0 else (self.path.len + 1)..], 20);

        if (xSize > SIZE) {
            const text = std.heap.page_allocator.dupeZ(u8, f.?[if (self.path.len == 0) 0 else self.path.len + 1..]) catch unreachable;
            defer std.heap.page_allocator.free(text);
            var index2: usize = 1;
            text[text.len - 2] = '.';
            text[text.len - 3] = '.';
            text[text.len + 0 - index2] = 0;
            while (true) {
                text[text.len - 3 - index2] = '.';
                text[text.len - 1 - index2] = 0;
                xSize = rl.measureText(text[0 .. text.len - index2 :0], 20);
                index2 += 1;
                if (xSize > SIZE) continue;
                rl.drawText(text[0 .. text.len - index2 :0], offsetX + @mod(index, self.fileLayout) * SIZE + 3 + @divFloor(SIZE - xSize, 2), offsetY + topTextSize + 3 + @divFloor(index, self.fileLayout) * SIZE, 20, rl.Color.white);
                break;
            }
        } else {
            rl.drawText(f.?[if (self.path.len == 0) 0 else self.path.len + 1..], offsetX + @mod(index, self.fileLayout) * SIZE + 3 + @divFloor(SIZE - xSize, 2), offsetY + topTextSize + 3 + @divFloor(index, self.fileLayout) * SIZE, 20, rl.Color.white);
        }
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
