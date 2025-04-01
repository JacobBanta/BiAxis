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
    setMouseBorder(entity);
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
    for (entity.getScene().getScripts(*@import("container.zig"))) |c| {
        c.sendResizeEvent();
    }
}

pub fn setMouseBorder(entity: anytype) void {
    for (entity.getScene().getScripts(*@import("container.zig"))) |c| {
        const boundary = 10;
        if (rl.getMousePosition().x > c.rect.x - boundary and
            rl.getMousePosition().x < c.rect.x + boundary and
            rl.getMousePosition().y < c.rect.y + c.rect.height - boundary and
            rl.getMousePosition().y > c.rect.y + boundary)
        {
            rl.setMouseCursor(.resize_ew);
            return;
        }
        if (rl.getMousePosition().x > c.rect.x + c.rect.width - boundary and
            rl.getMousePosition().x < c.rect.x + c.rect.width + boundary and
            rl.getMousePosition().y < c.rect.y + c.rect.height - boundary and
            rl.getMousePosition().y > c.rect.y + boundary)
        {
            rl.setMouseCursor(.resize_ew);
            return;
        }
        if (rl.getMousePosition().y > c.rect.y - boundary and
            rl.getMousePosition().y < c.rect.y + boundary and
            rl.getMousePosition().x < c.rect.x + c.rect.width - boundary and
            rl.getMousePosition().x > c.rect.x + boundary)
        {
            rl.setMouseCursor(.resize_ns);
            return;
        }
        if (rl.getMousePosition().y > c.rect.y + c.rect.height - boundary and
            rl.getMousePosition().y < c.rect.y + c.rect.height + boundary and
            rl.getMousePosition().x < c.rect.x + c.rect.width - boundary and
            rl.getMousePosition().x > c.rect.x + boundary)
        {
            rl.setMouseCursor(.resize_ns);
            return;
        }
        if (rl.getMousePosition().x > c.rect.x - boundary and
            rl.getMousePosition().x < c.rect.x + boundary and
            rl.getMousePosition().y > c.rect.y - boundary and
            rl.getMousePosition().y < c.rect.y + boundary)
        {
            rl.setMouseCursor(.resize_nwse);
            return;
        }
        if (rl.getMousePosition().x > c.rect.x + c.rect.width - boundary and
            rl.getMousePosition().x < c.rect.x + c.rect.width + boundary and
            rl.getMousePosition().y > c.rect.y + c.rect.height - boundary and
            rl.getMousePosition().y < c.rect.y + c.rect.height + boundary)
        {
            rl.setMouseCursor(.resize_nwse);
            return;
        }
        if (rl.getMousePosition().x > c.rect.x + c.rect.width - boundary and
            rl.getMousePosition().x < c.rect.x + c.rect.width + boundary and
            rl.getMousePosition().y > c.rect.y - boundary and
            rl.getMousePosition().y < c.rect.y + boundary)
        {
            rl.setMouseCursor(.resize_nesw);
            return;
        }
        if (rl.getMousePosition().x > c.rect.x - boundary and
            rl.getMousePosition().x < c.rect.x + boundary and
            rl.getMousePosition().y > c.rect.y + c.rect.height - boundary and
            rl.getMousePosition().y < c.rect.y + c.rect.height + boundary)
        {
            rl.setMouseCursor(.resize_nesw);
            return;
        }
    }
    rl.setMouseCursor(.default);
}
