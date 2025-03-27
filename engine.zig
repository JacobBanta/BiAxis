const std = @import("std");

pub fn getZon(b: *std.Build, obj: anytype) []const u8 {
    var buf = std.ArrayList(u8).init(b.allocator);
    std.zon.stringify.serialize(obj, .{}, buf.writer()) catch unreachable;
    return buf.items;
}

pub fn getRegistry(allocator: std.Allocator, files: []const []const u8) ![]const u8 {
    var buf = std.ArrayList(u8).init(allocator);
    for (files) |file| {
        try buf.writer().print("pub const @\"{s}\" = @import(\"{s}\");\n", .{ file, file });
    }
    return buf.items;
}
