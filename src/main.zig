const std = @import("std");
const clap = @import("clap");

const debug = std.debug;
const io = std.io;
const process = std.process;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const params = comptime clap.parseParamsComptime(
        \\-h, --help                  Display this help and exit.
        \\-t, --token <STR>           An option parameter, which takes a JWT token to decode.
        \\-f, --file <FILE>           An option parameter, which takes a JWT token file to decode.
        \\
    );

    // Declare our own parsers which are used to map the argument strings to other
    const parsers = comptime .{
        .STR = clap.parsers.string,
        .FILE = clap.parsers.string,
    };

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, parsers, .{
        .diagnostic = &diag,
        .allocator = gpa.allocator(),
    }) catch |err| {
        diag.report(io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0)
        return clap.usage(std.io.getStdErr().writer(), clap.Help, &params);
    if (res.args.token) |token| {
        debug.print("token: {s}\n", .{token});

        // var it = std.mem.split(u8, token, ".");
        // while (it.next()) |x| {
        //     debug.print("index: {s}\n", it.index);
        //     debug.print("{s}\n", .{x});
        // }
        // if (it.next()) |encodedHeader| {
        //     var decodedHeader: [1024]u8 = undefined;
        //     const decodedHeaderSlice = try std.base64.standard.Decoder.decode(&decodedHeader, encodedHeader);
        //     debug.print("Decoded Header: {s}\n", .{decodedHeaderSlice});
        // }
        // if (it.next()) |encodedPayload| {
        //     var decodedPayload: [1024]u8 = undefined;
        //     const decodedPayloadSlice = try std.base64.standard.Decoder.decode(&decodedPayload, encodedPayload);
        //     debug.print("Decoded Payload: {s}\n", .{decodedPayloadSlice});
        // }
    }
    if (res.args.file) |file|
        debug.print("--file = {s}\n", .{file});
    for (res.positionals) |pos|
        debug.print("{s}\n", .{pos});
}
