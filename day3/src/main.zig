const std = @import("std");

//const input = @embedFile("inputTest.txt");
const input = @embedFile("input1.txt");

const NotSymbols = "0123456789.";
const Digits = "0123456789";

pub fn main() !void {
    var line_iter = std.mem.tokenizeSequence(u8, input, "\r\n");

    var prev: ?[]const u8 = null;
    var curr: []const u8 = line_iter.next().?;
    var next: ?[]const u8 = null;

    var sum: u32 = 0;

    while (line_iter.next()) |line| {
        next = line;
        sum += checkLine(prev, curr, next);

        // swap
        prev = curr;
        curr = next.?;
    }

    sum += checkLine(prev, curr, next);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Final sum: {d}\n", .{sum});
}

fn checkLine(prev: ?[]const u8, curr: []const u8, next: ?[]const u8) u32 {
    var sum: u32 = 0;
    var index: usize = 0;

    var end_index: usize = 0;
    while (index < curr.len) : (index = end_index) {
        const start = std.mem.indexOfAnyPos(u8, curr, index, Digits) orelse break;
        end_index = std.mem.indexOfNonePos(u8, curr, start, Digits) orelse curr.len;

        // try to parse the int
        const num = std.fmt.parseInt(u32, curr[start..end_index], 10) catch {
            std.debug.print("Failed to parse int: {s} for line {s}\n", .{ curr[start..end_index], curr });
            return sum;
        };

        const sym_start = start -| 1;
        const sym_end = @min(end_index + 1, curr.len);

        if (prev) |p| {
            if (std.mem.indexOfNone(u8, p[sym_start..sym_end], NotSymbols)) |_| {
                sum += num;
                continue;
            }
        }

        if (std.mem.indexOfNone(u8, curr[sym_start..sym_end], NotSymbols)) |_| {
            sum += num;
            continue;
        }

        if (next) |n| {
            if (std.mem.indexOfNone(u8, n[sym_start..sym_end], NotSymbols)) |_| {
                // count this number
                sum += num;
                continue;
            }
        }

        index = end_index;
    }

    return sum;
}
