const std = @import("std");

const input = @embedFile("input1.txt");
//const input = @embedFile("inputTest.txt");

const Pair = struct {
    val: u8,
    text: []const u8,
};

const lookup = [_]Pair{
    .{ .val = '1', .text = "one" },
    .{ .val = '2', .text = "two" },
    .{ .val = '3', .text = "three" },
    .{ .val = '4', .text = "four" },
    .{ .val = '5', .text = "five" },
    .{ .val = '6', .text = "six" },
    .{ .val = '7', .text = "seven" },
    .{ .val = '8', .text = "eight" },
    .{ .val = '9', .text = "nine" },
};

pub fn main() !void {
    var sum: u32 = 0;

    var line_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (line_iter.next()) |line| {
        if (line.len < 2) continue;

        var num: [2]u8 = .{ 0, 0 };
        _ = lookup[0];

        var curr: []const u8 = line;
        while (curr.len > 0) : (curr = curr[1..]) {
            // check if its a digit first
            if (std.ascii.isDigit(curr[0])) {
                if (!std.ascii.isDigit(num[0])) {
                    num[0] = curr[0];
                }

                num[1] = curr[0];
            }

            // check if curr starts with one of our "digits"
            for (lookup) |pair| {
                if (std.mem.startsWith(u8, curr, pair.text)) {
                    // set our character
                    if (!std.ascii.isDigit(num[0])) {
                        num[0] = pair.val;
                    }

                    num[1] = pair.val;

                    // increment curr by our len - 2 since we increment at the end
                    curr = curr[(pair.text.len - 2)..];
                    break;
                }
            }
        }

        const value = std.fmt.parseInt(u32, &num, 10) catch fallback: {
            std.debug.print("failed to parse int: {s}\nfor line: {s}\n", .{ &num, line });
            break :fallback 0;
        };
        sum += value;
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("{d}\n", .{sum});
    try bw.flush(); // don't forget to flush!
}
