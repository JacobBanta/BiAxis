const rl = @import("raylib");
const std = @import("std");
pub fn update(self: *@This(), entity: anytype) void {
    _ = self;
    if (rl.isMouseButtonPressed(.left)) {
        std.debug.print("click!\n", .{});
        sendLeftClick(entity);
    }
}

pub fn render(self: @This(), entity: anytype) void {
    _ = self;
    _ = entity;
}

pub fn sendLeftClick(entity: anytype) void {
    const m = rl.getMousePosition();
    for (entity.getScene().getScripts(@import("container.zig"))) |c| {
        std.debug.print("click!!\n", .{});
        if (c.rect.x < m.x and
            m.x < c.rect.x + c.rect.width and
            c.rect.y < m.y and
            m.y < c.rect.y + c.rect.height)
        {
            std.debug.print("click!!!\n", .{});
            c.sendLeftClick();
        }
    }
}
