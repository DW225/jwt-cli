const std = @import("std");
const clap = @import("clap");

const debug = std.debug;
const io = std.io;
const process = std.process;
const B64Decoder = std.base64.standard_no_pad.Decoder;

fn jwtDecoder(token: []u8, allocator: std.mem.Allocator) !void {
    var it = std.mem.split(u8, token, ".");
    var arrIndex: usize = 0;
    while (it.next()) |str| {
        if (arrIndex < 2) {
            const decoded_length = try B64Decoder.calcSizeForSlice(str);
            const decoded = try allocator.alloc(u8, decoded_length);
            defer allocator.free(decoded);
            try B64Decoder.decode(decoded, str);
            switch (arrIndex) {
                0 => {
                    // Header
                    debug.print("Header: {s}\n", .{decoded});
                },
                else => {
                    // Payload
                    debug.print("Payload: {s}\n", .{decoded});
                },
            }
            arrIndex += 1;
        }
    }
}

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

    const allocator = gpa.allocator();

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, parsers, .{
        .diagnostic = &diag,
        .allocator = allocator,
    }) catch |err| {
        diag.report(io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0)
        return clap.usage(std.io.getStdErr().writer(), clap.Help, &params);
    if (res.args.token) |token| {
        jwtDecoder(token, allocator);
    }
    if (res.args.file) |file|
        debug.print("--file = {s}\n", .{file});
}
