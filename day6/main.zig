const input = @embedFile("input.txt");

const std = @import("std");

pub fn main() !void {
    var it = std.mem.tokenize(u8, input, ",");

    var buckets = [1]usize{0} ** 9;

    while (it.next()) |tok| {
        const num = try std.fmt.parseInt(usize, tok, 10);
        buckets[num] += 1;
    }

    var i: usize = 0;
    while (i < 256) : (i += 1) {
        std.mem.rotate(usize, &buckets, 1);
        buckets[6] += buckets[8];
    }

    var res: usize = 0;
    for (buckets) |b| res += b;

    std.debug.print("result: {}\n", .{res});
}
