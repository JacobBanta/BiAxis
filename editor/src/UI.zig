const rl = @import("raylib");
const std = @import("std");
pub fn update(self: *@This(), entity: anytype) void {
    _ = self;
    if (rl.isMouseButtonPressed(.left)) {
        sendLeftClick(entity);
    }
    if (rl.isWindowResized()) {
        sendResizeEvent(entity);
    }
}

pub fn sendLeftClick(entity: anytype) void {
    const m = rl.getMousePosition();
    for (entity.getScene().getScripts(@import("container.zig"))) |c| {
        if (c.rect.x < m.x and
            m.x < c.rect.x + c.rect.width and
            c.rect.y < m.y and
            m.y < c.rect.y + c.rect.height)
        {
            c.sendLeftClick();
        }
    }
}
pub fn sendResizeEvent(entity: anytype) void {
    for (entity.getScene().getScripts(@import("container.zig"))) |c| {
        c.sendResizeEvent();
    }
}
