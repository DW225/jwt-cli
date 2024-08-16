const std = @import("std");
const clap = @import("clap");

const stdout = std.io.getStdOut().writer();
const io = std.io;
const process = std.process;
const B64Decoder = std.base64.standard_no_pad.Decoder;

const Header = struct {
    alg: []u8,
    typ: []u8,
};

const Payload = struct {};

pub fn jwt_decoder(token: []u8, allocator: std.mem.Allocator) !void {
    var it = std.mem.split(u8, token, ".");
    var index: usize = 0;
    while (it.next()) |str| {
        if (index < 2) {
            const decoded_length = try B64Decoder.calcSizeForSlice(str);
            const decoded = try allocator.alloc(u8, decoded_length);
            defer allocator.free(decoded);
            try B64Decoder.decode(decoded, str);
            switch (index) {
                0 => {
                    // Header
                    try stdout.print("Header: {s}\n", .{decoded});
                },
                else => {
                    // Payload
                    try stdout.print("Payload: {s}\n", .{decoded});
                },
            }
            index += 1;
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
        try jwt_decoder(@constCast(token), allocator);
    }
    if (res.args.file) |file_path| {
        const max_bytes_per_line = 8192; // max size JWT
        var file = std.fs.cwd().openFile(file_path, .{}) catch {
            // couldn't open file
            return;
        };
        defer file.close();

        var buffered_reader = std.io.bufferedReader(file.reader());
        const reader = buffered_reader.reader();
        while (try reader.readUntilDelimiterOrEofAlloc(allocator, '\n', max_bytes_per_line)) |line| {
            defer allocator.free(line);
            try jwt_decoder(line, allocator);
        }
    }
}
