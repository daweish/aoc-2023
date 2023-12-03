const std = @import("std");

//const input = @embedFile("inputTest.txt");
const input = @embedFile("input1.txt");

const Digits = "0123456789";
const Gear = "*";

const RowNumbers = std.ArrayList([3]usize); // [0] = start index, [1] end index, [1] = part number
const PartNumbers = std.ArrayList(RowNumbers); // items[n] n = row index
const PotentialGears = std.ArrayList([2]usize); // row/col index of *

pub fn main() !void {
    var line_iter = std.mem.tokenizeSequence(u8, input, "\r\n");
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var gears = PotentialGears.init(arena.allocator());
    var parts = PartNumbers.init(arena.allocator());
    var row: usize = 0;
    while (line_iter.next()) |line| : (row += 1) {
        var row_nums = RowNumbers.init(arena.allocator());

        // Just parse the numbers first
        var index: usize = 0;
        var end_index: usize = 0;
        while (index < line.len) : (index = end_index) {
            const start = std.mem.indexOfAnyPos(u8, line, index, Digits) orelse break;
            end_index = std.mem.indexOfNonePos(u8, line, start, Digits) orelse line.len;

            const num = std.fmt.parseInt(u32, line[start..end_index], 10) catch {
                std.debug.print("Failed to parse int: {s} for line {s}\n", .{ line[start..end_index], line });
                return;
            };

            try row_nums.append(.{ start, end_index, num });
            index = end_index;
        }

        try parts.append(row_nums);

        // Parse the gears
        index = 0;
        while (index < line.len) : (index += 1) {
            const gear_index = std.mem.indexOfPos(u8, line, index, Gear) orelse break;
            try gears.append(.{ row, gear_index });
            index = gear_index;
        }
    }

    var sum: usize = 0;
    for (gears.items) |gear| {
        var adjacent: u32 = 0;
        var ratio: usize = 1;
        if (gear[0] > 0) {
            const part_row = parts.items[gear[0] - 1];
            evaluateRow(part_row.items, gear[1], &adjacent, &ratio);
        }

        { // same row as gear
            const part_row = parts.items[gear[0]];
            evaluateRow(part_row.items, gear[1], &adjacent, &ratio);
        }

        if (gear[0] + 1 < parts.items.len) {
            const part_row = parts.items[gear[0] + 1];
            evaluateRow(part_row.items, gear[1], &adjacent, &ratio);
        }

        sum += if (adjacent == 2) ratio else 0;
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Sum: {d}\n", .{sum});
}

fn evaluateRow(parts: []const [3]usize, gear_index: usize, adjacent: *u32, ratio: *usize) void {
    for (parts) |part| {
        const part_min = part[0] -| 1;
        const part_max = part[1];
        if (gear_index >= part_min and gear_index <= part_max) {
            ratio.* *= part[2];
            adjacent.* += 1;
        }
    }
}
