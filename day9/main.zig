const input = @embedFile("input.txt");

const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    var map: [100][100]u8 = undefined;
    var map_basin_ids = std.mem.zeroes([100][100]usize);
    var basin_counts = std.ArrayList(usize).init(alloc);

    var it = std.mem.tokenize(u8, input, "\n");
    for (map) |*row| {
        row.* = it.next().?.ptr[0..100].*;
    }

    if (it.next() != null) unreachable;

    var i: usize = 0;
    while (i < map.len) : (i += 1) {
        var j: usize = 0;
        while (j < map.len) : (j += 1) {
            const center_num = map[i][j];
            if (center_num == '9') continue;

            const up = if (i > 0) map_basin_ids[i - 1][j] else 0;
            var left = if (j > 0) map_basin_ids[i][j - 1] else 0;
            var current_basin = std.math.max(up, left);

            if (up != 0 and left != 0 and up != left) {
                var unlucky_basin = std.math.min(up, left);
                basin_counts.items[current_basin - 1] += basin_counts.items[unlucky_basin - 1];
                basin_counts.items[unlucky_basin - 1] = 0;
            }
            if (current_basin == 0) {
                try basin_counts.append(0);
                current_basin = basin_counts.items.len; // basin_counts index + 1
            }

            map_basin_ids[i][j] = current_basin;
            basin_counts.items[current_basin - 1] += 1;
        }
    }

    std.sort.sort(usize, basin_counts.items, {}, comptime std.sort.desc(usize));

    const result = basin_counts.items[0] * basin_counts.items[1] * basin_counts.items[2];

    std.debug.print("result: {}\n", .{result});
}

pub fn main1() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // var alloc = gpa.allocator();

    var map: [100][100]u8 = undefined;
    var total_risk: usize = 0;

    var it = std.mem.tokenize(u8, input, "\n");
    for (map) |*row| {
        row.* = it.next().?.ptr[0..100].*;
    }

    if (it.next() != null) unreachable;

    var i: usize = 0;
    while (i < map.len) : (i += 1) {
        var j: usize = 0;
        while (j < map.len) : (j += 1) {
            const center = map[i][j];

            const up: u8 = if (i > 0) map[i - 1][j] else '9';
            var down: u8 = if (i < map.len - 1) map[i + 1][j] else '9';
            var left: u8 = if (j > 0) map[i][j - 1] else '9';
            var right: u8 = if (j < map.len - 1) map[i][j + 1] else '9';

            if (center < up and
                center < down and
                center < left and
                center < right)
            {
                total_risk += center + 1 - '0';
            }
        }
    }

    std.debug.print("result: {}\n", .{total_risk});
}
