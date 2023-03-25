const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});
    const exe = b.addExecutable(.{
        .name = "example",
        .root_source_file = .{ .path = "src/main.zig" },
        .optimize = optimize,
        .target = target,
    });

    exe.linkLibC();

    if (builtin.cpu.arch == .x86_64 and builtin.os.tag == .windows) {
        std.debug.print("Using : exe.addIncludePath(\"deps/include\")\n", .{});
        // Linking statically
        exe.linkLibC();
        exe.addIncludePath("deps/include");
        exe.addObjectFile("deps/lib/x64/SDL2.lib");
        exe.install();
    } else {
        std.debug.print("Using : linkSystemLibrary(\"sdl\")\n", .{});
        exe.linkSystemLibrary("sdl2");
    }

    const run = b.step("run", "Run the demo");
    const run_cmd = exe.run();
    run.dependOn(&run_cmd.step);

    defer std.debug.print("Build complete\n", .{});
}
