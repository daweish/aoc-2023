const std = @import("std");
const input = @embedFile("input1.txt");
//const input = @embedFile("inputTest.txt");
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

pub fn main() !void {
    const game_pre: []const u8 = "Game ";
    const max_counts: [3]u32 = .{ 12, 13, 14 };

    var valid_sum: u32 = 0;
    var power_sum: u32 = 0;

    var line_iter = std.mem.tokenizeSequence(u8, input, "\r\n"); // ugh windows
    while (line_iter.next()) |line| {
        // Split each line into Game and Results
        var line_split = std.mem.splitScalar(u8, line, ':');
        const game = line_split.next().?;
        try expect(std.mem.startsWith(u8, game, game_pre));
        const game_num = try std.fmt.parseInt(u32, game[game_pre.len..], 10); // skip "Game "
        const results = line_split.next().?;

        var result_iter = std.mem.splitScalar(u8, results, ';');
        var min_result = [_]u32{0} ** 3;
        var possible = true;

        while (result_iter.next()) |result| {
            var round_result = [_]u32{0} ** 3;
            var color_pairs = std.mem.splitScalar(u8, result, ',');

            while (color_pairs.next()) |pair| {
                // there's an annoying space in front
                var pair_iter = std.mem.splitScalar(u8, pair[1..], ' ');

                const num = try std.fmt.parseInt(u32, pair_iter.next().?, 10);
                const color_str = pair_iter.next().?;
                const color = RGB.fromString(color_str) orelse return;
                round_result[@intFromEnum(color)] += num;
            }

            for (max_counts, round_result, &min_result) |max, count, *min_count| {
                min_count.* = @max(count, min_count.*);

                if (max < count) {
                    possible = false;
                }
            }
        }

        // This game was valid
        valid_sum += if (possible) game_num else 0;
        power_sum += min_result[0] * min_result[1] * min_result[2];
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("valid game sum: {d}\ngame power sum: {d}\n", .{ valid_sum, power_sum });
    try bw.flush();
}
