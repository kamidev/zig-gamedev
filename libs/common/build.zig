const std = @import("std");
const zwin32 = @import("../zwin32/build.zig");
const ztracy = @import("../ztracy/build.zig");
const zd3d12 = @import("../zd3d12/build.zig");

pub fn getPkg(b: *std.build.Builder, options_pkg: std.build.Pkg) std.build.Pkg {
    const pkg = std.build.Pkg{
        .name = "common",
        .path = .{ .path = comptime thisDir() ++ "/src/common.zig" },
        .dependencies = &[_]std.build.Pkg{
            zwin32.pkg,
            ztracy.getPkg(b, options_pkg),
            zd3d12.getPkg(b, options_pkg),
            options_pkg,
        },
    };
    return b.dupePkg(pkg);
}

pub fn build(b: *std.build.Builder) void {
    _ = b;
}

pub fn link(exe: *std.build.LibExeObjStep) void {
    const lib = buildLibrary(exe);
    exe.linkLibrary(lib);
    exe.addIncludeDir(comptime thisDir() ++ "/src/c");
    exe.addIncludeDir(comptime thisDir() ++ "/../zgpu/libs/imgui");
    exe.addIncludeDir(comptime thisDir() ++ "/../zmesh/libs/cgltf");
    exe.addIncludeDir(comptime thisDir() ++ "/../zgpu/libs/stb");
}

fn buildLibrary(exe: *std.build.LibExeObjStep) *std.build.LibExeObjStep {
    const lib = exe.builder.addStaticLibrary("common", comptime thisDir() ++ "/src/common.zig");

    lib.setBuildMode(exe.build_mode);
    lib.setTarget(exe.target);
    lib.want_lto = false;
    lib.addIncludeDir(comptime thisDir() ++ "/src/c");

    lib.linkSystemLibrary("c");
    lib.linkSystemLibrary("c++");
    lib.linkSystemLibrary("imm32");

    lib.addIncludeDir(comptime thisDir() ++ "/../zgpu/libs");
    lib.addCSourceFile(comptime thisDir() ++ "/../zgpu/libs/imgui/imgui.cpp", &.{""});
    lib.addCSourceFile(comptime thisDir() ++ "/../zgpu/libs/imgui/imgui_widgets.cpp", &.{""});
    lib.addCSourceFile(comptime thisDir() ++ "/../zgpu/libs/imgui/imgui_tables.cpp", &.{""});
    lib.addCSourceFile(comptime thisDir() ++ "/../zgpu/libs/imgui/imgui_draw.cpp", &.{""});
    lib.addCSourceFile(comptime thisDir() ++ "/../zgpu/libs/imgui/imgui_demo.cpp", &.{""});
    lib.addCSourceFile(comptime thisDir() ++ "/../zgpu/libs/imgui/cimgui.cpp", &.{""});

    lib.addIncludeDir(comptime thisDir() ++ "/../zmesh/libs/cgltf");
    lib.addCSourceFile(comptime thisDir() ++ "/../zmesh/libs/cgltf/cgltf.c", &.{"-std=c99"});

    lib.addIncludeDir(comptime thisDir() ++ "/../zgpu/libs/stb");
    lib.addCSourceFile(comptime thisDir() ++ "/../zgpu/libs/stb/stb_image.c", &.{"-std=c99"});

    return lib;
}

fn thisDir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}
