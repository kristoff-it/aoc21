const input = @embedFile("input.txt");

const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var alloc = gpa.allocator();

    var stack = std.ArrayList(usize).init(alloc);

    var it = std.mem.tokenize(u8, input, "\n");
    var final_scores = std.ArrayList(usize).init(alloc);

    line_loop: while (it.next()) |line| {
        stack.clearRetainingCapacity();

        for (line) |c| switch (c) {
            '(', '[', '{', '<' => {
                try stack.append(if (c == '(') c + 1 else c + 2);
            },
            ')', ']', '}', '>' => {
                if (stack.popOrNull()) |open| {
                    if (c == open) continue;
                } else {
                    std.debug.print("hah I knew it!\n", .{});
                }

                continue :line_loop;
            },
            else => unreachable,
        };

        var line_score: usize = 0;

        var i: usize = stack.items.len - 1;
        while (i >= 0) : (i -= 1) {
            line_score *= 5;
            line_score += switch (stack.items[i]) {
                ')' => @as(usize, 1),
                ']' => 2,
                '}' => 3,
                '>' => 4,
                else => unreachable,
            };
        }

        try final_scores.append(line_score);
    }

    std.sort.sort(usize, final_scores.items, {}, comptime std.sort.asc(usize));
    const median = final_scores.items[@divExact(final_scores.items.len - 1, 2)];

    std.debug.print("result: {}\n", .{median});
}

pub fn main1() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    var stack = std.ArrayList(usize).init(alloc);

    var it = std.mem.tokenize(u8, input, "\n");
    var score: usize = 0;

    while (it.next()) |line| {
        for (line) |c| switch (c) {
            '(', '[', '{', '<' => {
                try stack.append(if (c == '(') c + 1 else c + 2);
            },
            ')', ']', '}', '>' => {
                if (stack.popOrNull()) |open| {
                    if (c == open) continue;
                } else {
                    std.debug.print("hah I knew it!\n", .{});
                }

                score += switch (c) {
                    ')' => @as(usize, 3),
                    ']' => 57,
                    '}' => 1197,
                    '>' => 25137,
                    else => unreachable,
                };

                break;
            },
            else => unreachable,
        };
    }

    std.debug.print("result: {}\n", .{score});
}
