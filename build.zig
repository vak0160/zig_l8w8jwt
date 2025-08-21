const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const upstream_mbedtls = b.dependency("zig_mbedtls", .{
        .target = target,
        .optimize = optimize,
    });
    const upstream_chillbuff = b.dependency("chillbuff", .{});
    const upstream_jsmn = b.dependency("jsmn", .{});
    const upstream_checknum = b.dependency("checknum", .{});
    const upstream = b.dependency("l8w8jwt", .{});

    const lib = b.addLibrary(.{
        .name = "l8w8jwt",
        .linkage = .static,
        .root_module = b.createModule(.{
            .optimize = optimize,
            .target = target,
        }),
    });

    lib.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = &.{
            "decode.c",
            "claim.c",
            "base64.c",
            "version.c",
            "encode.c",
            "util.c",
        },
    });

    lib.linkLibrary(upstream_mbedtls.artifact("mbedtls"));

    lib.addIncludePath(upstream_chillbuff.path("include"));
    lib.addIncludePath(upstream_checknum.path("include"));
    lib.addIncludePath(upstream_jsmn.path("."));
    lib.addIncludePath(upstream.path("include"));

    lib.installHeadersDirectory(upstream_chillbuff.path("include"), "", .{});
    lib.installHeadersDirectory(upstream_checknum.path("include"), "", .{});
    lib.installHeadersDirectory(upstream_jsmn.path("."), "", .{});
    lib.installHeadersDirectory(upstream.path("include"), "", .{});

    lib.linkLibC();

    b.installArtifact(lib);
}
