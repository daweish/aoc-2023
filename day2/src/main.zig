const std = @import("std");
const input = @embedFile("inputTest.txt");
const expect = std.testing.expect;

const RGB = enum {
    red,
    green,
    blue,

    fn fromString(str: []const u8) ?RGB {
        if (std.mem.startsWith(u8, "red", str)) {
            return .red;
        } else if (std.mem.startsWith(u8, "green", str)) {
            return .green;
        } else if (std.mem.startsWith(u8, "blue", str)) {
            return .blue;
        } else {
            return null;
        }
    }
};

const GameResult = struct {
    number: u32,
    counts: [3]u32 = .{ 0, 0, 0 }, // red, green, blue
};

pub fn main() !void {

    // Parse
    // 1. Read in and split by line
    // 2. Split each line into the Game# and Results
    // 3. Split each reuslt into cube set
    // 4.   for each cube set, total the number of r,g,g #might need these separate later
    // 5. Record a game record

    // 6. Check if the game record is possible with the given limits
    // 7. Add to running sum
    const game_pre: []const u8 = "Game ";

    var line_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (line_iter.next()) |line| {

        // Split each line into Game and Results
        var line_split = std.mem.splitScalar(u8, line, ':');
        const game = line_split.next().?;
        try expect(std.mem.startsWith(u8, game, game_pre));
        const game_num = try std.fmt.parseInt(u32, game[game_pre.len..], 10); // skip "Game "

        var game_result: GameResult = .{ .number = game_num };

        const results = line_split.next().?;
        var result_iter = std.mem.splitScalar(u8, results, ';');
        while (result_iter.next()) |result| {
            var color_pairs = std.mem.splitScalar(u8, result, ',');
            while (color_pairs.next()) |pair| {
                // there's an annoying space in front
                var pair_iter = std.mem.splitScalar(u8, pair[1..], ' ');

                const num = std.fmt.parseInt(u32, pair_iter.next().?, 10) catch {
                    std.debug.print("Failed to parse int for pair: '{s}'\n", .{pair});
                    return;
                };

                const color_str = pair_iter.next().?;
                const color = RGB.fromString(color_str) orelse {
                    std.debug.print("Failed to parse color:'{s}' with num {d} for line: '{s}'\n", .{ color_str, num, line });
                    return;
                };
                game_result.counts[@intFromEnum(color)] += num;
            }
        }

        std.debug.print("Parsed game result: {any}\n", .{game_result});
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    _ = stdout;

    //try stdout.print("Run `zig build test` to run the tests.\n", .{});
    try bw.flush();
}
