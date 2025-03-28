const std = @import("std");

pub fn getRegistry(allocator: std.Allocator, files: []const []const u8) []const u8 { //{{{
    var buf = std.ArrayList(u8).init(allocator);
    for (files) |file| {
        buf.writer().print("pub const @\"{s}\" = @import(\"{s}\");\n", .{ file, file }) catch unreachable;
    }
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
pub fn getScript(path: []const u8, data: anytype, allocator: std.mem.Allocator) Script { //{{{
    //@compileLog(@typeInfo(data));
    var arraylist = std.ArrayList(u8).init(allocator);
    switch (@TypeOf(data)) {
        type => {
            std.zon.stringify.serialize(data{}, .{}, arraylist.writer()) catch unreachable;
        },
        else => {
            std.zon.stringify.serialize(data, .{}, arraylist.writer()) catch unreachable;
        },
    }
    return .{ .script = .{ .path = path, .data = arraylist.items } };
} //}}}
pub fn makeScene(allocator: std.mem.Allocator, scene: Scene) []const u8 {
    var buf = std.ArrayList(u8).init(allocator);
    buf.writer().print(
        \\pub const std = @import("std"); const This = @This();
    , .{}) catch unreachable;
    for (0..scene.entities.len) |i| {
        buf.writer().print("entity{d}: struct{{", .{i}) catch unreachable;
        for (0..scene.entities[i].scripts.len) |x| {
            buf.writer().print(
                \\script{d}: registry.@"{s}" = @import("entity{d}.script{d}.zon"),
            , .{ x, scene.entities[i].scripts[x].script.path, i, x }) catch unreachable;
        }
        buf.writer().print(
            \\pub fn getData(self: @This(), T: type, comptime fieldName: []const u8) !T {{
        , .{}) catch unreachable;
        for (0..scene.entities[i].scripts.len) |x| {
            buf.writer().print(
                \\if (@hasField(@TypeOf(self.script{d}), fieldName)) return @field(self.script{d}, fieldName);
            , .{ x, x }) catch unreachable;
        }
        buf.writer().print(
            \\return error.FieldNotFound;}}pub fn setData(self: *@This(), T: type, value: T, comptime fieldName: []const u8) void {{
        , .{}) catch unreachable;
        for (0..scene.entities[i].scripts.len) |x| {
            buf.writer().print(
                \\if (@hasField(@TypeOf(self.script{d}), fieldName)) @field(self.script{d}, fieldName) = value;
            , .{ x, x }) catch unreachable;
        }
        buf.writer().print(
            \\}} pub fn getScene(self: *@This()) *This {{ return @fieldParentPtr("entity{d}", self); }} }} = .{{}},
        , .{i}) catch unreachable;
    }
    //std.debug.print("{s}", .{buf.items});
    return buf.items;
}
