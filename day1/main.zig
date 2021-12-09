const input = @embedFile("input.txt");

const std = @import("std");

pub fn main() !void {
    var increments: usize = 0;
    var it = std.mem.tokenize(u8, input, "\n");

    var window: [3]usize = .{
        try std.fmt.parseInt(usize, it.next().?, 10),
        try std.fmt.parseInt(usize, it.next().?, 10),
        try std.fmt.parseInt(usize, it.next().?, 10),
    };

    var last_sum = window[0] + window[1] + window[2];

    while (it.next()) |line| {
        window[0] = window[1];
        window[1] = window[2];
        window[2] = try std.fmt.parseInt(usize, line, 10);

        const new_sum = window[0] + window[1] + window[2];
        if (new_sum > last_sum) increments += 1;

        last_sum = new_sum;
    }

    std.debug.print("result: {}\n", .{increments});
}
