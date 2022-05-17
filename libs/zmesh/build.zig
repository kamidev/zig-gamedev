const std = @import("std");

pub const pkg = std.build.Pkg{
    .name = "zmesh",
    .path = .{ .path = thisDir() ++ "/src/main.zig" },
};

pub fn build(b: *std.build.Builder) void {
    const build_mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});
    const tests = buildTests(b, build_mode, target);

    const test_step = b.step("test", "Run zmesh tests");
    test_step.dependOn(&tests.step);
}

pub fn buildTests(
    b: *std.build.Builder,
    build_mode: std.builtin.Mode,
    target: std.zig.CrossTarget,
) *std.build.LibExeObjStep {
    const tests = b.addTest(comptime thisDir() ++ "/src/main.zig");
    tests.setBuildMode(build_mode);
    tests.setTarget(target);
    link(tests);
    return tests;
}

fn buildLibrary(exe: *std.build.LibExeObjStep) *std.build.LibExeObjStep {
    const lib = exe.builder.addStaticLibrary("zmesh", comptime thisDir() ++ "/src/main.zig");

    lib.setBuildMode(exe.build_mode);
    lib.setTarget(exe.target);
    lib.linkSystemLibrary("c");
    lib.linkSystemLibrary("c++");

    lib.addIncludeDir(comptime thisDir() ++ "/libs/par_shapes");
    lib.addCSourceFile(
        comptime thisDir() ++ "/libs/par_shapes/par_shapes.c",
        &.{ "-std=c99", "-fno-sanitize=undefined" },
    );

    lib.addCSourceFile(comptime thisDir() ++ "/libs/meshoptimizer/clusterizer.cpp", &.{""});
    lib.addCSourceFile(comptime thisDir() ++ "/libs/meshoptimizer/indexgenerator.cpp", &.{""});
    lib.addCSourceFile(comptime thisDir() ++ "/libs/meshoptimizer/vcacheoptimizer.cpp", &.{""});
    lib.addCSourceFile(comptime thisDir() ++ "/libs/meshoptimizer/vcacheanalyzer.cpp", &.{""});
    lib.addCSourceFile(comptime thisDir() ++ "/libs/meshoptimizer/vfetchoptimizer.cpp", &.{""});
    lib.addCSourceFile(comptime thisDir() ++ "/libs/meshoptimizer/vfetchanalyzer.cpp", &.{""});
    lib.addCSourceFile(comptime thisDir() ++ "/libs/meshoptimizer/overdrawoptimizer.cpp", &.{""});
    lib.addCSourceFile(comptime thisDir() ++ "/libs/meshoptimizer/overdrawanalyzer.cpp", &.{""});
    lib.addCSourceFile(comptime thisDir() ++ "/libs/meshoptimizer/allocator.cpp", &.{""});

    lib.addIncludeDir(comptime thisDir() ++ "/libs/cgltf");
    lib.addCSourceFile(comptime thisDir() ++ "/libs/cgltf/cgltf.c", &.{"-std=c99"});

    return lib;
}

pub fn link(exe: *std.build.LibExeObjStep) void {
    const lib = buildLibrary(exe);
    exe.linkLibrary(lib);
    exe.addIncludeDir(comptime thisDir() ++ "/libs/cgltf");
}

fn thisDir() []const u8 {
    comptime {
        return std.fs.path.dirname(@src().file) orelse ".";
    }
}
