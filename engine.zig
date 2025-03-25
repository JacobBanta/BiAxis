const std = @import("std");

pub fn getZon(b: *std.Build, obj: anytype) []const u8 {
    var buf = std.ArrayList(u8).init(b.allocator);
    std.zon.stringify.serialize(obj, .{}, buf.writer()) catch unreachable;
    return buf.items;
}
