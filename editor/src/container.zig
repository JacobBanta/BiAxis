const rl = @import("raylib");
const std = @import("std");
const Inspector = @import("inspector.zig");
rect: rl.Rectangle = rl.Rectangle.init(0, 0, 0, 0),
objectPtr: ?usize = null,
type: Type = .none,
anchors: struct {
    up: Anchor = .none,
    down: Anchor = .none,
    left: Anchor = .none,
    right: Anchor = .none,
} = .{},
pub const Type = enum {
    none,
    inspector,
    toolbar,
    fileBrowser,
    scene,
};
pub const AnchorMode = enum {
    none,
    side,
    percentage,
    fixed,
};
pub const Anchor = union(AnchorMode) {
    none: void,
    side: void,
    percentage: f32,
    fixed: u32,
};

pub fn init(self: *@This(), entity: anytype) void { //{{{
    switch (self.type) {
        .inspector => {
            self.objectPtr = @intFromPtr(entity.getScene().getScripts(*@import("inspector.zig"))[0]);
            const inspector: *Inspector = @ptrFromInt(self.objectPtr.?);
            inspector.resizeEvent(@intFromFloat(self.rect.width), @intFromFloat(self.rect.height));
        },
        else => {},
    }
} //}}}
pub fn render(self: @This()) void { //{{{
    switch (self.type) {
        .inspector => {
            //std.debug.print("hello\n", .{});
            const inspector: *Inspector = @ptrFromInt(self.objectPtr.?);
            inspector.render_(@intFromFloat(self.rect.x), @intFromFloat(self.rect.y));
        },
        else => {},
    }
} //}}}

//events{{{
pub fn sendLeftClick(self: @This()) void {
    const x: i32 = @intFromFloat(rl.getMousePosition().x - self.rect.x);
    const y: i32 = @intFromFloat(rl.getMousePosition().y - self.rect.y);
    switch (self.type) {
        .inspector => {
            const inspector: *Inspector = @ptrFromInt(self.objectPtr.?);
            inspector.leftClickEvent(x, y);
        },
        else => {},
    }
}
pub fn sendResizeEvent(self: @This()) void {
    var x: i32 = rl.getScreenWidth();
    var y: i32 = rl.getScreenHeight();
    switch (self.type) {
        .inspector => {
            const inspector: *Inspector = @ptrFromInt(self.objectPtr.?);
            if (self.anchors.right == .side) {
                x = x - @as(i32, @intFromFloat(self.rect.x));
            } else {
                x = x - 100;
            }
            if (self.anchors.down == .side) {
                y = y - @as(i32, @intFromFloat(self.rect.y));
            } else {
                y = y - 100;
            }
            inspector.resizeEvent(x - 1, y - 1);
        },
        else => {},
    }
} //}}}
