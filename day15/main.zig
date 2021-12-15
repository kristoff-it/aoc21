const input = @embedFile("input.txt");

const std = @import("std");

const Pos = struct {
    x: usize,
    y: usize,
    score: usize,

    pub fn cmp(p1: Pos, p2: Pos) std.math.Order {
        return std.math.order(p1.score, p2.score);
    }
};

const PQ = std.PriorityQueue(Pos, Pos.cmp);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    var space: [100][100]u8 = undefined;
    var known_space = std.mem.zeroes([space.len * 5][space.len * 5]usize);

    var it = std.mem.tokenize(u8, input, "\n");

    for (space) |*row| {
        row.* = it.next().?.ptr[0..space.len].*;
        for (row) |*cell| cell.* -= '0';
    }

    var q = PQ.init(alloc);
    try q.add(Pos{ .x = 0, .y = 0, .score = 0 });

    while (q.removeOrNull()) |p| {
        if (p.x == (space.len * 5) - 1 and p.y == (space.len * 5) - 1) {
            std.debug.print("result: {}\n", .{p.score});
            return;
        }

        var expansions: [4]Pos = .{
            .{ .x = p.x, .y = p.y -% 1, .score = undefined }, // up
            .{ .x = p.x -% 1, .y = p.y, .score = undefined }, // left
            .{ .x = p.x, .y = p.y + 1, .score = undefined }, // down
            .{ .x = p.x + 1, .y = p.y, .score = undefined }, // right
        };

        for (expansions) |*np| {
            if (np.x < space.len * 5 and np.y < space.len * 5) {
                const base_score = space[np.x % space.len][np.y % space.len];
                const tile_steps = @divTrunc(np.x, space.len) + @divTrunc(np.y, space.len);

                const adjusted_score = ((base_score + tile_steps - 1) % 9) + 1;

                np.score = p.score + adjusted_score;

                const last_best = known_space[np.x][np.y];
                if (last_best > 0 and np.score >= last_best) continue;
                known_space[np.x][np.y] = np.score;

                try q.add(np.*);
            }
        }
    }
}

pub fn main1() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    var space: [100][100]u8 = undefined;
    var known_space = std.mem.zeroes([space.len][space.len]bool);

    var it = std.mem.tokenize(u8, input, "\n");

    for (space) |*row| {
        row.* = it.next().?.ptr[0..space.len].*;
        for (row) |*cell| cell.* -= '0';
    }

    var q = PQ.init(alloc);
    try q.add(Pos{ .x = 0, .y = 0, .score = 0 });

    while (q.removeOrNull()) |p| {
        if (p.x == space.len - 1 and p.y == space.len - 1) {
            std.debug.print("result: {}\n", .{p.score});
            return;
        }

        known_space[p.x][p.y] = true;

        var expansions: [4]Pos = .{
            .{ .x = p.x, .y = p.y -% 1, .score = undefined }, // up
            .{ .x = p.x -% 1, .y = p.y, .score = undefined }, // left
            .{ .x = p.x, .y = p.y + 1, .score = undefined }, // down
            .{ .x = p.x + 1, .y = p.y, .score = undefined }, // right
        };

        for (expansions) |*np| {
            if (np.x < space.len and np.y < space.len and !known_space[np.x][np.y]) {
                np.score = p.score + space[np.x][np.y];
                try q.add(np.*);
            }
        }
    }
}
