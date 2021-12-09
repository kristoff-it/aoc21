const input = @embedFile("input.txt");

const std = @import("std");

pub fn main() !void {
    var it = std.mem.tokenize(u8, input, "\n, ");

    var space = std.mem.zeroes([1_000][1_000]u8);

    while (it.next()) |x1_str| {
        const x1 = try std.fmt.parseInt(usize, x1_str, 10);
        const y1 = try std.fmt.parseInt(usize, it.next().?, 10);
        _ = it.next(); // skip `->`
        const x2 = try std.fmt.parseInt(usize, it.next().?, 10);
        const y2 = try std.fmt.parseInt(usize, it.next().?, 10);

        std.debug.print("coords: {},{} - {},{}\n", .{ x1, y1, x2, y2 });
        // // ignore diagonals
        // if (x1 != x2 and y1 != y2) continue;

        // store points

        var i = std.math.min(x1, x2);
        const i_max = std.math.max(x1, x2);

        if (x1 != x2 and y1 == y2)
            while (i <= i_max) : (i += 1) {
                space[i][y1] += 1;
            };

        var j = std.math.min(y1, y2);
        const j_max = std.math.max(y1, y2);

        if (x1 == x2 and y1 != y2)
            while (j <= j_max) : (j += 1) {
                space[x1][j] += 1;
            };

        if (x1 != x2 and y1 != y2) {
            var x: usize = x1;
            var y: usize = y1;
            while (true) {
                space[x][y] += 1;

                if (x1 < x2) {
                    if (x == x2) break;
                    x += 1;
                } else {
                    if (x == x2) break;
                    x -= 1;
                }
                if (y1 < y2) {
                    y += 1;
                } else {
                    y -= 1;
                }
            }
        }
    }

    var danger_points: usize = 0;
    var i: usize = 0;
    while (i < space.len) : (i += 1) {
        var j: usize = 0;
        while (j < space.len) : (j += 1) {
            if (space[i][j] > 1) danger_points += 1;
        }
    }

    std.debug.print("result: {}\n", .{danger_points});
}
