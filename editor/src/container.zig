const rl = @import("raylib");
const Inspector = @import("inspector.zig");
rect: rl.Rectangle = rl.Rectangle.init(0, 0, 0, 0),
objectPtr: ?usize = null,
type: Type = .none,
pub const Type = enum(u8) {
    none,
    inspector,
};

pub fn sendLeftClick(self: @This()) void {
    const x: u32 = @intFromFloat(rl.getMousePosition().x - self.rect.x);
    const y: u32 = @intFromFloat(rl.getMousePosition().y - self.rect.y);
    switch (self.type) {
        .inspector => {
            const o: *Inspector = @ptrFromInt(self.objectPtr.?);
            o.leftClickEvent(x, y);
        },
        else => {},
    }
}

pub fn init(self: *@This(), entity: anytype) void {
    switch (self.type) {
        .inspector => {
            //@compileLog(&(entity.getScene().getScripts(@import("inspector.zig"))[0]));
            self.objectPtr = @intFromPtr(@constCast(&(entity.getScene().getScripts(@import("inspector.zig"))[0])));
        },
        else => {},
    }
}
