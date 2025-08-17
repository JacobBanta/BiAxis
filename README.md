# BiAxis
## Documentation

Disclaimer: This documentation was AI generated. I will probably rewrite it by 1.0.0

Looking back, this is not really very helpful.

### Overview

BiAxis is a flexible and customizable framework for building games. It allows users to create custom scripts that can be loaded and executed by the engine. The engine is configured using the `build.zig` file, which defines the initial state of BiAxis and its components.

### Configuration Structure

The configuration is structured as follows:
```zig
engine.addModule(b, .{
    .entities = &[_]engine.Entity{
        // Entity definitions
    },
}, &[_]std.Build.Module.Import{
    // Module imports
}, "engine", opts);
```
### Entity Definitions

Entities are defined using the `engine.Entity` struct, which contains a list of scripts. Scripts are loaded using the `engine.getScript` function, which takes in the script file path, parameters, and an allocator.

#### Script Parameters

Script parameters are defined using the `engine.Param` and `engine.ParamList` functions. `engine.Param` is used to define a single parameter, while `engine.ParamList` is used to define a list of parameters.

For example:
```zig
engine.ParamList(.{
    engine.Param(u32, "x", 50),
    engine.Param(u32, "y", 50),
    engine.Param(u32, "width", 150),
    engine.Param(u32, "height", 150),
})
```
This defines a list of four parameters: `x`, `y`, `width`, and `height`, with their respective types and default values.

#### Script Loading

Scripts are loaded using the `engine.getScript` function, which takes in the script file path, parameters, and an allocator. For example:
```zig
engine.getScript("src/UI.zig", engine.ParamList({}), b.allocator)
```
This loads the `UI.zig` script with no parameters.

### Scripting

BiAxis allows users to create custom scripts that can be loaded and executed by the engine. The scripts can define several functions, including `init`, `deinit`, `render`, `update`, and `fixedUpdate`, which are called by the engine at specific times.

#### Script Functions

The following functions can be defined in a script:

* `init`: Called when the script is initialized.
* `deinit`: Called when the script is deinitialized.
* `render`: Called when the engine is rendering a frame.
* `update`: Called when the engine is updating the game state.
* `fixedUpdate`: Called at a fixed interval, regardless of the frame rate.

These functions can take the following parameters:

* `self`: A reference to the script instance, of type `@This()`.
* `deltatime`: The time elapsed since the last update, of type `f64`.
* `entity`: A reference to the entity that owns the script, of type `anytype`.

The user can choose which parameters to use for each function.

#### Entity Methods

The `entity` parameter provides access to the following methods:

* `getData(self: @This(), T: type, comptime fieldName: []const u8) !T`: Retrieves the value of a field with the given name and type.
* `setData(self: *@This(), T: type, value: T, comptime fieldName: []const u8) void`: Sets the value of a field with the given name and type.
* `getScene(self: *@This()) *This`: Returns a pointer to the scene that contains the entity.

The `getScene` method returns a pointer to a type that has the following method:

* `getScripts(self: *@This(), script: type) []script`: Retrieves an array of scripts of the given type. If the type is a pointer, it returns an array of pointers.

### Limitations

The following limitations apply to script parameters and fields:

* Pointers are not allowed as fields or parameters.
* Other limitations may exist, but have not been discovered yet.

### Error Handling

The engine does not handle errors that occur during script execution. All engine-called functions must have a `void` return type, so any errors that occur must be handled within the script itself.

### Example Script

Here is an example script that demonstrates the use of the `init`, `update`, and `getData` methods:
```zig
const std = @import("std");

my_field: f64 = 0,

pub fn init(self: *@This(), entity: anytype) void {
    _ = self;
    _ = entity;
    // Initialize the script here
}

pub fn update(self: *@This(), deltatime: f64, entity: anytype) void {
    var scene = entity.getScene();
    var scripts = scene.getScripts(@TypeOf(self));
    for (scripts) |script| {
        // Do something with the other scripts
    }
    var data = entity.getData(f64, "my_field") catch |err| {
        // Handle the error here, as the engine won't catch it
        std.debug.print("Error: {s}\n", .{@errorName(err)});
        return;
    };
    // Update the script state here
    data += deltatime;
    entity.setData(f64, data, "my_field");
}
```
