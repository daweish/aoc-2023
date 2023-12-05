const std = @import("std");

//const input = @embedFile("inputTest.txt");
const input = @embedFile("input1.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = arena.deinit();

    var line_iter = std.mem.splitSequence(u8, input, "\r\n");
    const seed_line = line_iter.next().?;
    _ = line_iter.next(); // skip the blank

    const seeds_start = std.mem.indexOfAny(u8, seed_line, "0123456789").?;
    var seed_iter = std.mem.tokenizeScalar(u8, seed_line[seeds_start..], ' ');

    var seeds = std.ArrayList(u32).init(arena.allocator());
    while (seed_iter.next()) |seed_str| {
        const seed = try std.fmt.parseInt(u32, seed_str, 10);
        try seeds.append(seed);
    }

    const MapRanges = std.ArrayList([3]u32);
    var maps = std.ArrayList(MapRanges).init(arena.allocator());

    std.debug.print("Seeds: {any}\n", .{seeds.items});
    std.mem.sort(u32, seeds.items, {}, std.sort.asc(u32));
    std.debug.print("Seeds[sorted]: {any}\n", .{seeds.items});

    while (line_iter.next()) |line| {
        if (line.len == 0) {
            const mapSort = struct {
                pub fn asc(_: void, a: [3]u32, b: [3]u32) bool {
                    return a[1] < b[1];
                }
            }.asc;

            var map = maps.items[maps.items.len - 1].items;

            //std.mem.sort([3]u32, maps.items[maps.items.len - 1].items, {}, mapSort);
            std.mem.sort([3]u32, map, {}, mapSort);
            std.debug.print("Sorting the map: {any}\n", .{map});
            // todo srt the map
            continue;
        }

        // first line is just the title
        if (std.mem.containsAtLeast(u8, line, 1, "map")) {
            // Create a new map to hold these conversions
            std.debug.print("Creating new map: \n", .{});
            try maps.append(MapRanges.init(arena.allocator()));
            continue;
        }

        // parse line of three numbers: target start, source start, range
        var num_iter = std.mem.tokenizeScalar(u8, line, ' ');
        const target = try std.fmt.parseInt(u32, num_iter.next().?, 10);
        const source = try std.fmt.parseInt(u32, num_iter.next().?, 10);
        const range = try std.fmt.parseInt(u32, num_iter.next().?, 10);

        try maps.items[maps.items.len - 1].append(.{ target, source, range });

        //std.debug.print("adding map value: {d},{d},{d}\n", .{ target, source, range });
        // empty line means we've finished a section
    }

    // Now we need to convert all of the seeds
    for (maps.items) |map| {
        var range_iter: usize = 0;
        // iterate through every seed to convert it
        for (seeds.items) |*seed| {
            // if we've hit the end of our ranges, then all seeds have default value
            if (range_iter == map.items.len) {
                std.debug.print("Converting seed: {d}->{d}\n", .{ seed.*, seed.* });
                continue;
            }

            const range: [3]u32 = find: {
                while (range_iter < map.items.len and
                    seed.* >= map.items[range_iter][1] + map.items[range_iter][2]) : (range_iter += 1)
                {}

                if (range_iter == map.items.len) {
                    std.debug.print("Converting seed: {d}->{d}\n", .{ seed.*, seed.* });
                    continue;
                }

                break :find map.items[range_iter];
            };

            // at this point, range is either greater or equal to our value
            if (seed.* < range[1]) {
                std.debug.print("Converting seed: {d}->{d}\n", .{ seed.*, seed.* });
                seed.* = seed.*;
            } else {
                const converted = range[0] + (seed.* - range[1]);
                std.debug.print("Converting seed: {d}->{d} using range: {any}\n", .{ seed.*, converted, range });
                seed.* = converted;
            }
        }

        std.debug.print("Seeds converted: {any}\n", .{seeds.items});

        // sort the seeds
        std.mem.sort(u32, seeds.items, {}, std.sort.asc(u32));
    }

    const min = std.mem.min(u32, seeds.items);
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Min location: {d}\n", .{min});
}
