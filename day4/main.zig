const input = @embedFile("input.txt");

const std = @import("std");

const Board = struct {
    won: bool = false,
    data: [5][5]struct {
        num: u8,
        found: bool,
    } = undefined,

    pub fn countScore(self: Board, num: u8) usize {
        var sum_not_found: usize = 0;
        var i: usize = 0;
        while (i < 5) : (i += 1) {
            var j: usize = 0;
            while (j < 5) : (j += 1) {
                const cell = self.data[i][j];
                if (!cell.found) {
                    sum_not_found += cell.num;
                }
            }
        }

        return sum_not_found * num;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    var it = std.mem.split(u8, input, "\n\n");
    const numbers_line = it.next().?;

    var boards = std.ArrayList(Board).init(alloc);

    while (it.next()) |line| {
        var b: Board = .{};

        var num_it = std.mem.tokenize(u8, line, " \n");

        var i: usize = 0;
        while (i < 5) : (i += 1) {
            var j: usize = 0;
            while (j < 5) : (j += 1) {
                b.data[i][j] = .{
                    .num = try std.fmt.parseInt(u8, num_it.next().?, 10),
                    .found = false,
                };
            }
        }

        try boards.append(b);
    }

    var num_it = std.mem.tokenize(u8, numbers_line, ",");

    var remaining_boards = boards.items.len;
    while (num_it.next()) |tok| {
        const num = try std.fmt.parseInt(u8, tok, 10);

        for (boards.items) |*b| {
            if (b.won) continue;
            // update the board

            var i: usize = 0;
            row_loop: while (i < 5) : (i += 1) {
                var j: usize = 0;
                while (j < 5) : (j += 1) {
                    var cell = &b.data[i][j];
                    if (cell.num == num) {
                        cell.found = true;

                        // check win condition
                        {
                            var x: usize = 0;
                            const row_won = while (x < 5) : (x += 1) {
                                if (b.data[i][x].found == false) break false;
                            } else true;

                            x = 0;
                            const col_won = while (x < 5) : (x += 1) {
                                if (b.data[x][j].found == false) break false;
                            } else true;

                            if (row_won or col_won) {
                                remaining_boards -= 1;
                                b.won = true;

                                if (remaining_boards > 0) {
                                    break :row_loop;
                                }

                                const res = b.countScore(num);
                                std.debug.print("result: {}\n", .{res});
                                return;
                            }
                        }

                        // we found a match, we're done checking this board
                        break :row_loop;
                    }
                }
            }
        }
    }
}

pub fn main1() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    var it = std.mem.split(u8, input, "\n\n");
    const numbers_line = it.next().?;

    var boards = std.ArrayList(Board).init(alloc);

    while (it.next()) |line| {
        var b: Board = undefined;

        var num_it = std.mem.tokenize(u8, line, " \n");

        var i: usize = 0;
        while (i < 5) : (i += 1) {
            var j: usize = 0;
            while (j < 5) : (j += 1) {
                b.data[i][j] = .{
                    .num = try std.fmt.parseInt(u8, num_it.next().?, 10),
                    .found = false,
                };
            }
        }

        try boards.append(b);
    }

    var num_it = std.mem.tokenize(u8, numbers_line, ",");
    while (num_it.next()) |tok| {
        const num = try std.fmt.parseInt(u8, tok, 10);

        for (boards.items) |*b| {
            std.debug.print("{d}\n\n", .{b.data});
            // update the board

            var i: usize = 0;
            row_loop: while (i < 5) : (i += 1) {
                var j: usize = 0;
                while (j < 5) : (j += 1) {
                    var cell = &b.data[i][j];
                    if (cell.num == num) {
                        cell.found = true;

                        // check win condition
                        {
                            var x: usize = 0;
                            const row_won = while (x < 5) : (x += 1) {
                                if (b.data[i][x].found == false) break false;
                            } else true;

                            x = 0;
                            const col_won = while (x < 5) : (x += 1) {
                                if (b.data[x][j].found == false) break false;
                            } else true;

                            if (row_won or col_won) {
                                const res = b.countScore(num);
                                std.debug.print("result: {}\n", .{res});
                                return;
                            }
                        }

                        // we found a match, we're done checking this board
                        break :row_loop;
                    }
                }
            }
        }
    }
}
