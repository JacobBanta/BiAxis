const std = @import("std");

pub fn getRegistry(allocator: std.Allocator, files: []const []const u8) []const u8 { //{{{
    var buf = std.ArrayList(u8).init(allocator);
    for (files) |file| {
        buf.writer().print("pub const @\"{s}\" = @import(\"{s}\");\n", .{ file, file }) catch unreachable;
    }
    return buf.items;
} //}}}
pub fn getZon(b: *std.Build, obj: anytype) []const u8 { //{{{
    var buf = std.ArrayList(u8).init(b.allocator);
    std.zon.stringify.serialize(obj, .{}, buf.writer()) catch unreachable;
    return buf.items;
} //}}}

pub fn Param(T: type, name: [:0]const u8, value: T) type { //{{{
    return @Type(.{ .Struct = .{
        .layout = .auto,
        .is_tuple = false,
        .fields = &[_]std.builtin.Type.StructField{.{
            .alignment = @alignOf(T),
            .is_comptime = false,
            .type = T,
            .default_value = &value,
            .name = name,
        }},
        .decls = &[_]std.builtin.Type.Declaration{},
    } });
}

pub fn ParamList(params: anytype) type {
    if (@TypeOf(params) == void) return ParamList(.{});
    var ret: std.builtin.Type = @typeInfo(struct {});
    inline for (params) |P| {
        ret.Struct.fields = ret.Struct.fields ++ @typeInfo(P).Struct.fields;
    }
    return @Type(ret);
} //}}}

pub const Scene = struct { //{{{
    entities: []const Entity = &[_]Entity{},
};

pub const Entity = struct {
    scripts: []const Script = &[_]Script{},
};

pub const Script = union(enum) {
    script: struct {
        path: []const u8,
        data: []const u8, //ZON data
    },
}; //}}}
