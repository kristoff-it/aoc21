const input = @embedFile("input.txt");

const std = @import("std");

const Pos = struct {
    row: usize,
    col: usize,
};
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    var it = std.mem.tokenize(u8, input, "\n, ");

    var space = std.mem.zeroes([10][10]u8);

    var must_emit = std.ArrayList(Pos).init(alloc);

    for (space) |*row| {
        row.* = it.next().?.ptr[0..10].*;
        for (row) |*cell| cell.* -= '0';
    }

    var tick: usize = 0;
    while (true) : (tick += 1) {
        var spent = std.mem.zeroes([10][10]bool);
        var tick_flashes: usize = 0;

        // {
        //     std.debug.print("tick: {}\n", .{tick});
        //     for (space) |row, i| std.debug.print("[{}] {d: >2}\n", .{ i, row });
        //     _ = try std.io.getStdIn().reader().readByte();
        // }
        // increase every counter, keep track of exploding octopuses
        for (space) |*row, i| {
            for (row) |*cell, j| {
                cell.* += 1;

                // if the octo is above 9, add to emit list
                if (cell.* > 9) try must_emit.append(.{
                    .row = i,
                    .col = j,
                });
            }
        }
        // std.debug.print("starting octopuses: {d}\n", .{must_emit.items});

        // explode exploding octopuses
        while (must_emit.popOrNull()) |p| {
            // {
            //     std.debug.print("exploding tick: {} p: {}\n", .{ tick, p });
            //     for (space) |row, i| std.debug.print("[{}] {d: >2}\n", .{ i, row });
            //     _ = try std.io.getStdIn().reader().readByte();
            // }
            if (spent[p.row][p.col]) continue;

            space[p.row][p.col] = 0;
            spent[p.row][p.col] = true;
            tick_flashes += 1;

            if (maybeGet(&space, spent, p.row -% 1, p.col -% 1)) |cell| {
                cell.* += 1;
                if (cell.* > 9) try must_emit.append(.{
                    .row = p.row - 1,
                    .col = p.col - 1,
                });
            }

            if (maybeGet(&space, spent, p.row -% 1, p.col)) |cell| {
                cell.* += 1;
                if (cell.* > 9) try must_emit.append(.{
                    .row = p.row - 1,
                    .col = p.col,
                });
            }

            if (maybeGet(&space, spent, p.row -% 1, p.col + 1)) |cell| {
                cell.* += 1;
                if (cell.* > 9) try must_emit.append(.{
                    .row = p.row - 1,
                    .col = p.col + 1,
                });
            }

            if (maybeGet(&space, spent, p.row, p.col -% 1)) |cell| {
                cell.* += 1;
                if (cell.* > 9) try must_emit.append(.{
                    .row = p.row,
                    .col = p.col - 1,
                });
            }

            if (maybeGet(&space, spent, p.row, p.col + 1)) |cell| {
                cell.* += 1;
                if (cell.* > 9) try must_emit.append(.{
                    .row = p.row,
                    .col = p.col + 1,
                });
            }

            if (maybeGet(&space, spent, p.row + 1, p.col -% 1)) |cell| {
                cell.* += 1;
                if (cell.* > 9) try must_emit.append(.{
                    .row = p.row + 1,
                    .col = p.col - 1,
                });
            }

            if (maybeGet(&space, spent, p.row + 1, p.col)) |cell| {
                cell.* += 1;
                if (cell.* > 9) try must_emit.append(.{
                    .row = p.row + 1,
                    .col = p.col,
                });
            }

            if (maybeGet(&space, spent, p.row + 1, p.col + 1)) |cell| {
                cell.* += 1;
                if (cell.* > 9) try must_emit.append(.{
                    .row = p.row + 1,
                    .col = p.col + 1,
                });
            }
        }
        if (tick_flashes == 10 * 10) {
            std.debug.print("result: {}\n", .{tick + 1});
            return;
        }
    }
    std.debug.print("oh no\n", .{});
}

pub fn main1() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    var it = std.mem.tokenize(u8, input, "\n, ");

    var space = std.mem.zeroes([10][10]u8);

    var must_emit = std.ArrayList(Pos).init(alloc);
    var total_flashes: usize = 0;

    for (space) |*row| {
        row.* = it.next().?.ptr[0..10].*;
        for (row) |*cell| cell.* -= '0';
    }

    var tick: usize = 0;
    while (tick < 100) : (tick += 1) {
        var spent = std.mem.zeroes([10][10]bool);

        // {
        //     std.debug.print("tick: {}\n", .{tick});
        //     for (space) |row, i| std.debug.print("[{}] {d: >2}\n", .{ i, row });
        //     _ = try std.io.getStdIn().reader().readByte();
        // }
        // increase every counter, keep track of exploding octopuses
        for (space) |*row, i| {
            for (row) |*cell, j| {
                cell.* += 1;

                // if the octo is above 9, add to emit list
                if (cell.* > 9) try must_emit.append(.{
                    .row = i,
                    .col = j,
                });
            }
        }
        // std.debug.print("starting octopuses: {d}\n", .{must_emit.items});

        // explode exploding octopuses
        while (must_emit.popOrNull()) |p| {
            // {
            //     std.debug.print("exploding tick: {} p: {}\n", .{ tick, p });
            //     for (space) |row, i| std.debug.print("[{}] {d: >2}\n", .{ i, row });
            //     _ = try std.io.getStdIn().reader().readByte();
            // }
            if (spent[p.row][p.col]) continue;

            space[p.row][p.col] = 0;
            spent[p.row][p.col] = true;
            total_flashes += 1;

            if (maybeGet(&space, spent, p.row -% 1, p.col -% 1)) |cell| {
                cell.* += 1;
                if (cell.* > 9) try must_emit.append(.{
                    .row = p.row - 1,
                    .col = p.col - 1,
                });
            }

            if (maybeGet(&space, spent, p.row -% 1, p.col)) |cell| {
                cell.* += 1;
                if (cell.* > 9) try must_emit.append(.{
                    .row = p.row - 1,
                    .col = p.col,
                });
            }

            if (maybeGet(&space, spent, p.row -% 1, p.col + 1)) |cell| {
                cell.* += 1;
                if (cell.* > 9) try must_emit.append(.{
                    .row = p.row - 1,
                    .col = p.col + 1,
                });
            }

            if (maybeGet(&space, spent, p.row, p.col -% 1)) |cell| {
                cell.* += 1;
                if (cell.* > 9) try must_emit.append(.{
                    .row = p.row,
                    .col = p.col - 1,
                });
            }

            if (maybeGet(&space, spent, p.row, p.col + 1)) |cell| {
                cell.* += 1;
                if (cell.* > 9) try must_emit.append(.{
                    .row = p.row,
                    .col = p.col + 1,
                });
            }

            if (maybeGet(&space, spent, p.row + 1, p.col -% 1)) |cell| {
                cell.* += 1;
                if (cell.* > 9) try must_emit.append(.{
                    .row = p.row + 1,
                    .col = p.col - 1,
                });
            }

            if (maybeGet(&space, spent, p.row + 1, p.col)) |cell| {
                cell.* += 1;
                if (cell.* > 9) try must_emit.append(.{
                    .row = p.row + 1,
                    .col = p.col,
                });
            }

            if (maybeGet(&space, spent, p.row + 1, p.col + 1)) |cell| {
                cell.* += 1;
                if (cell.* > 9) try must_emit.append(.{
                    .row = p.row + 1,
                    .col = p.col + 1,
                });
            }
        }
    }

    std.debug.print("result: {}\n", .{total_flashes});
}

fn maybeGet(matrix: *[10][10]u8, spent: [10][10]bool, row: usize, col: usize) ?*u8 {
    if (row < matrix.len and col < matrix.len and !spent[row][col]) return &matrix[row][col];
    return null;
}
