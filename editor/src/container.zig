const rl = @import("raylib");
const std = @import("std");
const Inspector = @import("inspector.zig");
const FileBrowser = @import("fileBrowser.zig");
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
    fixed: i32,
};

pub fn init(self: *@This(), entity: anytype) void { //{{{
    switch (self.type) {
        .inspector => {
            self.objectPtr = @intFromPtr(entity.getScene().getScripts(*@import("inspector.zig"))[0]);
        },
        .fileBrowser => {
            self.objectPtr = @intFromPtr(entity.getScene().getScripts(*@import("fileBrowser.zig"))[0]);
        },
        else => {},
    }
    self.sendResizeEvent();
} //}}}
pub fn render(self: @This()) void { //{{{
    switch (self.type) {
        .inspector => {
            const inspector: *Inspector = @ptrFromInt(self.objectPtr.?);
            inspector.render_(@intFromFloat(self.rect.x), @intFromFloat(self.rect.y));
        },
        .fileBrowser => {
            const fileBrowser: *FileBrowser = @ptrFromInt(self.objectPtr.?);
            fileBrowser.render_(@intFromFloat(self.rect.x), @intFromFloat(self.rect.y));
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
        .fileBrowser => {
            const fileBrowser: *FileBrowser = @ptrFromInt(self.objectPtr.?);
            fileBrowser.leftClickEvent(x, y);
        },
        else => {},
    }
}
pub fn sendResizeEvent(self: *@This()) void {
    var resize: bool = false;
    var x: i32 = rl.getScreenWidth();
    var w: i32 = @intFromFloat(self.rect.width);
    switch (self.anchors.right) { //{{{left/right anchor code
        .side => {
            switch (self.anchors.left) {
                .none => {
                    x = x - w;
                    self.rect.x = @floatFromInt(x);
                },
                .fixed => |f2| {
                    w = x - f2;
                    x = f2;
                    resize = true;
                },
                .side => {
                    w = x;
                    x = 0;
                    resize = true;
                },
                .percentage => |p2| {
                    w = x;
                    x = @as(i32, @intFromFloat(@as(f32, @floatFromInt(x)) * p2));
                    w = w - x;
                    resize = true;
                },
            }
        },
        .fixed => |f1| {
            switch (self.anchors.left) {
                .none => {
                    x = x - w - f1;
                    self.rect.x = @floatFromInt(x);
                },
                .side => {
                    w = x - f1;
                    x = 0;
                    resize = true;
                },
                .fixed => |f2| {
                    x = f2;
                    w = f2 - f1;
                    resize = true;
                },
                .percentage => |p2| {
                    w = x;
                    x = @as(i32, @intFromFloat(@as(f32, @floatFromInt(x)) * p2));
                    w = x - f1;
                    resize = true;
                },
            }
        },
        .percentage => |p1| {
            switch (self.anchors.left) {
                .none => {
                    x = x - @as(i32, @intFromFloat(@as(f32, @floatFromInt(x)) * p1)) - w;
                    self.rect.x = @floatFromInt(x);
                },
                .side => {
                    //test this
                    w = @as(i32, @intFromFloat(@as(f32, @floatFromInt(x)) * (1 - p1)));
                    x = 0;
                    resize = true;
                },
                .fixed => |f2| {
                    //test this too
                    w = @as(i32, @intFromFloat(@as(f32, @floatFromInt(x)) * (1 - p1))) - f2;
                    x = f2;
                    resize = true;
                },
                .percentage => |p2| {
                    w = @as(i32, @intFromFloat(@as(f32, @floatFromInt(x)) * ((1 - p1) - p2)));
                    x = @as(i32, @intFromFloat(@as(f32, @floatFromInt(x)) * p2));
                    resize = true;
                },
            }
        },
        .none => {
            switch (self.anchors.left) {
                .none => {
                    x = @intFromFloat(self.rect.x);
                },
                .side => {
                    x = 0;
                    self.rect.x = 0;
                },
                .fixed => |f2| {
                    self.rect.x = @floatFromInt(f2);
                    x = f2;
                },
                .percentage => |p2| {
                    self.rect.x = @as(f32, @floatFromInt(x)) * p2;
                    x = @intFromFloat(self.rect.x);
                },
            }
        },
    } //}}}
    var y: i32 = rl.getScreenHeight();
    var h: i32 = @intFromFloat(self.rect.height);
    switch (self.anchors.down) { //{{{up/down anchor code
        .side => {
            switch (self.anchors.up) {
                .none => {
                    y = y - h;
                    self.rect.y = @floatFromInt(y);
                },
                .fixed => |f2| {
                    h = y - f2;
                    y = f2;
                    resize = true;
                },
                .side => {
                    h = y;
                    y = 0;
                    resize = true;
                },
                .percentage => |p2| {
                    h = y;
                    y = @as(i32, @intFromFloat(@as(f32, @floatFromInt(y)) * p2));
                    h = h - y;
                    resize = true;
                },
            }
        },
        .fixed => |f1| {
            switch (self.anchors.up) {
                .none => {
                    y = y - h - f1;
                    self.rect.y = @floatFromInt(y);
                },
                .side => {
                    h = y - f1;
                    y = 0;
                    resize = true;
                },
                .fixed => |f2| {
                    y = f2;
                    h = f2 - f1;
                    resize = true;
                },
                .percentage => |p2| {
                    h = y;
                    y = @as(i32, @intFromFloat(@as(f32, @floatFromInt(y)) * p2));
                    h = y - f1;
                    resize = true;
                },
            }
        },
        .percentage => |p1| {
            switch (self.anchors.up) {
                .none => {
                    y = y - @as(i32, @intFromFloat(@as(f32, @floatFromInt(y)) * p1)) - h;
                    self.rect.y = @floatFromInt(y);
                },
                .side => {
                    //test this
                    h = @as(i32, @intFromFloat(@as(f32, @floatFromInt(y)) * (1 - p1)));
                    y = 0;
                    resize = true;
                },
                .fixed => |f2| {
                    //test this too
                    h = @as(i32, @intFromFloat(@as(f32, @floatFromInt(y)) * (1 - p1))) - f2;
                    y = f2;
                    resize = true;
                },
                .percentage => |p2| {
                    h = @as(i32, @intFromFloat(@as(f32, @floatFromInt(y)) * ((1 - p1) - p2)));
                    y = @as(i32, @intFromFloat(@as(f32, @floatFromInt(y)) * p2));
                    resize = true;
                },
            }
        },
        .none => {
            switch (self.anchors.up) {
                .none => {
                    y = @intFromFloat(self.rect.y);
                },
                .side => {
                    y = 0;
                    self.rect.y = 0;
                },
                .fixed => |f2| {
                    self.rect.y = @floatFromInt(f2);
                    y = f2;
                },
                .percentage => |p2| {
                    self.rect.y = @as(f32, @floatFromInt(y)) * p2;
                    y = @intFromFloat(self.rect.y);
                },
            }
        },
    } //}}}
    if (resize) {
        self.rect.width = @floatFromInt(w);
        self.rect.x = @floatFromInt(x);
        self.rect.height = @floatFromInt(h);
        self.rect.y = @floatFromInt(y);
        switch (self.type) {
            .inspector => {
                const inspector: *Inspector = @ptrFromInt(self.objectPtr.?);
                inspector.resizeEvent(w, h);
            },
            .fileBrowser => {
                const fileBrowser: *FileBrowser = @ptrFromInt(self.objectPtr.?);
                fileBrowser.resizeEvent(w, h);
            },
            else => {},
        }
    }
} //}}}
