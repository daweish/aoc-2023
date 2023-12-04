const std = @import("std");

//const input = @embedFile("inputTest.txt");
const input = @embedFile("input1.txt");

pub fn main() !void {
    // memory management
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var win_counts = std.ArrayList(u32).init(gpa.allocator());
    defer win_counts.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();

    var sum: u32 = 0;
    var line_iter = std.mem.tokenizeSequence(u8, input, "\r\n");
    while (line_iter.next()) |line| {
        defer _ = arena.reset(.retain_capacity);

        // grab the game portion
        var game_iter = std.mem.splitSequence(u8, line, ": ");
        const game_str = game_iter.next().?;
        const game_num_start = std.mem.indexOfAny(u8, game_str, "0123456789").?;
        const game_num = std.fmt.parseInt(u32, game_str[game_num_start..], 10) catch {
            std.debug.print("failed to parse game {s} for line {s}\n", .{ game_str, line });
            return;
        };
        _ = game_num;

        const numbers = game_iter.next().?;
        var num_set_iter = std.mem.splitSequence(u8, numbers, "| ");
        const winning_str = num_set_iter.next().?;
        var winning_num_iter = std.mem.tokenizeScalar(u8, winning_str, ' ');

        var winning_nums = std.ArrayList(u32).init(arena.allocator());
        while (winning_num_iter.next()) |num_str| {
            try winning_nums.append(try std.fmt.parseInt(u32, num_str, 10));
        }

        // assuming no dupes
        var scratch_nums = std.AutoHashMap(u32, void).init(arena.allocator());

        const scratch_str = num_set_iter.next().?;
        var scratch_num_iter = std.mem.tokenizeScalar(u8, scratch_str, ' ');
        while (scratch_num_iter.next()) |num_str| {
            try scratch_nums.put(try std.fmt.parseInt(u32, num_str, 10), {});
        }

        // score this card
        var score: u32 = 0;
        var wins: u32 = 0;
        for (winning_nums.items) |win| {
            if (scratch_nums.contains(win)) {
                wins += 1;
                score = if (score == 0) 1 else score * 2;
            }
        }

        sum += score;
        try win_counts.append(wins);
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("value: {d}\n", .{sum});

    // stores the memoized cards won for each game
    var win_memo = std.AutoHashMap(usize, u32).init(arena.allocator());

    var total_cards: u32 = 0;
    for (0..win_counts.items.len) |game| {
        total_cards += getWins(game, win_counts.items, &win_memo);
    }

    try stdout.print("total cards: {d}\n", .{total_cards});
}

fn getWins(index: usize, wins: []const u32, memo: *std.AutoHashMap(usize, u32)) u32 {
    if (memo.get(index)) |cards| {
        return cards;
    }

    const win_num = wins[index];
    var sum: u32 = 1; // you at least win one card
    for (0..win_num) |iter| {
        sum += getWins(index + iter + 1, wins, memo);
    }

    memo.put(index, sum) catch {};
    return sum;
}
