const input = @embedFile("input.txt");

const std = @import("std");

const Direction = enum {
    forward,
    up,
    down,
};
pub fn main() !void {
    var it = std.mem.tokenize(u8, input, "\n ");

    var horz: usize = 0;
    var depth: usize = 0;
    var aim: usize = 0;

    while (it.next()) |direction| {
        const n = try std.fmt.parseInt(usize, it.next().?, 10);

        switch (std.meta.stringToEnum(Direction, direction).?) {
            .forward => {
                horz += n;
                depth += aim * n;
            },
            .up => {
                aim -= n;
            },
            .down => {
                aim += n;
            },
        }
    }

    std.debug.print("result: {}\n", .{horz * depth});
}

pub fn main1() !void {
    var it = std.mem.tokenize(u8, input, "\n ");

    var horz: usize = 0;
    var depth: usize = 0;

    while (it.next()) |direction| {
        const n = try std.fmt.parseInt(usize, it.next().?, 10);

        switch (std.meta.stringToEnum(Direction, direction).?) {
            .forward => {
                horz += n;
            },
            .up => {
                depth -= n;
            },
            .down => {
                depth += n;
            },
        }
    }

    std.debug.print("result: {}\n", .{horz * depth});
}
